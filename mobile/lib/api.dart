import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'config.dart';

/// Cuenta anónima automática del piloto (Supabase Auth) y llamadas autenticadas al servidor.
/// Es el mismo contrato que usa la web (app/src/lib/auth.ts): sin correo ni contraseña; la sesión vive en
/// ESTE teléfono. Sin conexión no pasa nada: la sesión se conserva y se renueva al volver la red.
class Session {
  Session({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.userId,
  });

  final String accessToken;
  final String refreshToken;

  /// Segundos desde 1970 en que vence el token de acceso.
  final int expiresAt;
  final String userId;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'expires_at': expiresAt,
        'user_id': userId,
      };

  static Session? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final Object? a = raw['access_token'];
    final Object? r = raw['refresh_token'];
    final Object? u = raw['user_id'];
    final Object? e = raw['expires_at'];
    if (a is String && r is String && u is String && e is num) {
      return Session(accessToken: a, refreshToken: r, userId: u, expiresAt: e.toInt());
    }
    return null;
  }
}

enum AuthFailure { offline, rejected, server, noSession, disabled }

class AuthError implements Exception {
  AuthError(this.kind, this.message);
  final AuthFailure kind;
  final String message;
  @override
  String toString() => message;
}

class ApiError implements Exception {
  ApiError(this.status, this.message);
  final int status;
  final String message;
  @override
  String toString() => 'Servidor $status: $message';
}

/// Por qué falló entrar al barrio (para mostrar un mensaje claro).
class JoinFailed implements Exception {
  JoinFailed(this.code);

  /// bad_code, too_many_attempts, banned, not_configured, bad_name, no_auth, offline, disabled, server
  final String code;
  @override
  String toString() => code;
}

class Api {
  Api._();
  static final Api instance = Api._();

  static const String _sessionKey = 'redbarrio.session.v1';

  final http.Client _client = http.Client();
  SharedPreferences? _prefs;
  Session? _session;
  Future<Session>? _refreshing;

  /// Se llama cuando el servidor rechaza renovar la sesión (hay que volver a entrar con el código).
  void Function()? onSessionLost;

  Session? get session => _session;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final String? raw = _prefs!.getString(_sessionKey);
    if (raw != null) {
      try {
        _session = Session.fromJson(jsonDecode(raw));
      } catch (_) {
        _session = null;
      }
    }
  }

  Future<void> _write(Session? s) async {
    _session = s;
    final SharedPreferences? p = _prefs;
    if (p == null) return;
    if (s == null) {
      await p.remove(_sessionKey);
    } else {
      await p.setString(_sessionKey, jsonEncode(s.toJson()));
    }
  }

  /// Olvida la cuenta en este teléfono (no borra nada en el servidor).
  Future<void> clearLocal() => _write(null);

  String get _base => Config.supabaseUrl.replaceAll(RegExp(r'/+$'), '');

  Map<String, String> get _authHeaders => <String, String>{
        'apikey': Config.anonKey,
        'Content-Type': 'application/json; charset=utf-8',
      };

  Future<http.Response> _send(
    String method,
    String url,
    Map<String, String> headers,
    String? body,
  ) async {
    try {
      final http.Request request = http.Request(method, Uri.parse(url));
      request.headers.addAll(headers);
      if (body != null) request.bodyBytes = utf8.encode(body);
      final http.StreamedResponse streamed =
          await _client.send(request).timeout(const Duration(seconds: 20));
      return await http.Response.fromStream(streamed).timeout(const Duration(seconds: 20));
    } on TimeoutException {
      throw AuthError(AuthFailure.offline, 'Sin conexión');
    } catch (error) {
      throw AuthError(AuthFailure.offline, error.toString());
    }
  }

  static String _text(http.Response res) => utf8.decode(res.bodyBytes, allowMalformed: true);

  Session _toSession(Object? json) {
    if (json is Map) {
      final Object? access = json['access_token'];
      final Object? refresh = json['refresh_token'];
      final Object? user = json['user'];
      final Object? userId = user is Map ? user['id'] : null;
      if (access is String && refresh is String && userId is String) {
        final Object? exp = json['expires_at'];
        final Object? expIn = json['expires_in'];
        final int expiresAt = exp is num
            ? exp.toInt()
            : DateTime.now().millisecondsSinceEpoch ~/ 1000 + (expIn is num ? expIn.toInt() : 3600);
        return Session(accessToken: access, refreshToken: refresh, expiresAt: expiresAt, userId: userId);
      }
    }
    throw AuthError(AuthFailure.server, 'Respuesta de cuenta inesperada');
  }

  /// Crea una cuenta anónima nueva (la primera vez que alguien abre el piloto).
  Future<Session> signUpAnonymous() async {
    final http.Response res = await _send('POST', '$_base/auth/v1/signup', _authHeaders, '{}');
    if (res.statusCode < 200 || res.statusCode >= 300) {
      final String text = _text(res);
      if (res.statusCode == 422 || RegExp('anonymous', caseSensitive: false).hasMatch(text)) {
        throw AuthError(AuthFailure.disabled, 'El servidor todavía no admite cuentas automáticas.');
      }
      throw AuthError(AuthFailure.server, 'No se pudo crear la cuenta (${res.statusCode}).');
    }
    final Session s = _toSession(jsonDecode(_text(res)));
    await _write(s);
    return s;
  }

  Future<Session> _refresh(Session current) {
    final Future<Session>? running = _refreshing;
    if (running != null) return running;
    final Future<Session> job = () async {
      final http.Response res = await _send(
        'POST',
        '$_base/auth/v1/token?grant_type=refresh_token',
        _authHeaders,
        jsonEncode(<String, dynamic>{'refresh_token': current.refreshToken}),
      );
      if (res.statusCode == 400 || res.statusCode == 401 || res.statusCode == 403) {
        await _write(null);
        final void Function()? lost = onSessionLost;
        if (lost != null) lost();
        throw AuthError(AuthFailure.rejected, 'La sesión de este teléfono ya no es válida.');
      }
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw AuthError(AuthFailure.server, 'No se pudo renovar la sesión (${res.statusCode}).');
      }
      final Session next = _toSession(jsonDecode(_text(res)));
      await _write(next);
      return next;
    }();
    _refreshing = job;
    // Libera el candado al terminar (con éxito o con error) sin dejar errores sin atender.
    job.then<void>((Session _) {}, onError: (Object _) {}).whenComplete(() {
      _refreshing = null;
    });
    return job;
  }

  /// Token de acceso vigente (lo renueva si vence en menos de un minuto).
  Future<String> accessToken({bool force = false}) async {
    Session? s = _session;
    if (s == null) throw AuthError(AuthFailure.noSession, 'Falta iniciar sesión.');
    final int now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (force || s.expiresAt - now < 60) {
      s = await _refresh(s);
    }
    return s.accessToken;
  }

  /// Pide al servidor con la sesión de este teléfono. Si el token venció, lo renueva y reintenta una vez.
  Future<http.Response> rest(String path, {String method = 'GET', String? body}) async {
    Future<http.Response> attempt(bool force) async {
      final String token = await accessToken(force: force);
      return _send(
        method,
        '$_base/rest/v1/$path',
        <String, String>{...Map<String, String>.from(_authHeaders), 'Authorization': 'Bearer $token'},
        body,
      );
    }

    http.Response res = await attempt(false);
    if (res.statusCode == 401) res = await attempt(true);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      final String text = _text(res);
      String message = text.length > 160 ? text.substring(0, 160) : text;
      try {
        final Object? parsed = jsonDecode(text);
        if (parsed is Map && parsed['message'] is String) message = parsed['message'] as String;
      } catch (_) {
        // texto plano
      }
      throw ApiError(res.statusCode, message);
    }
    return res;
  }

  /// Llama a una función del servidor (todas las escrituras del piloto pasan por aquí).
  Future<dynamic> rpc(String fn, Map<String, dynamic> args) async {
    final http.Response res = await rest('rpc/$fn', method: 'POST', body: jsonEncode(args));
    if (res.statusCode == 204) return null;
    final String text = _text(res);
    return text.isEmpty ? null : jsonDecode(text);
  }

  /// Decodifica una respuesta GET como lista de objetos.
  List<dynamic> decodeList(http.Response res) {
    final Object? parsed = jsonDecode(_text(res));
    return parsed is List ? parsed : <dynamic>[];
  }

  /// Crea la cuenta (si hace falta) y entra al barrio con el código. Devuelve el id de la cuenta.
  Future<String> join(String code, String name, String zone) async {
    try {
      final Session s = _session ?? await signUpAnonymous();
      final dynamic result = await rpc('pilot_join', <String, dynamic>{
        'p_code': code,
        'p_name': name,
        'p_zone': zone,
      });
      final bool ok = result is Map && result['ok'] == true;
      if (!ok) {
        final Object? err = result is Map ? result['error'] : null;
        throw JoinFailed(err is String ? err : 'server');
      }
      return s.userId;
    } on JoinFailed {
      rethrow;
    } on AuthError catch (e) {
      if (e.kind == AuthFailure.offline) throw JoinFailed('offline');
      if (e.kind == AuthFailure.disabled) throw JoinFailed('disabled');
      throw JoinFailed('server');
    } on ApiError {
      throw JoinFailed('server');
    }
  }

  /// Datos de mi cuenta en el servidor (null si no existe o está vetada).
  Future<Map<String, dynamic>?> fetchMyMember() async {
    final http.Response res = await rest('pilot_members?select=display_name,zone,banned');
    final List<dynamic> rows = decodeList(res);
    if (rows.isEmpty) return null;
    final Object? first = rows.first;
    if (first is Map && first['banned'] != true) return Map<String, dynamic>.from(first);
    return null;
  }
}
