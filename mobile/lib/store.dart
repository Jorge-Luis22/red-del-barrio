import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'api.dart';
import 'util.dart';

/// Datos y sincronización de la app móvil.
///
/// Misma idea que la web en modo piloto: todo son "registros" (necesidades, propuestas, mensajes…) que se
/// suben con la función `pilot_push` y se bajan de `pilot_records`. El servidor decide de quién es cada
/// registro y quién puede leerlo (los chats solo los ven las dos personas del trato), así que web y celular
/// comparten el mismo barrio.
///
/// Esta versión es "primero en línea": los datos viven en memoria y se vuelven a bajar al abrir la app. Lo
/// que se escribe sin señal queda en cola y se sube solo al volver la red (mientras la app siga abierta).

/// Orden de dependencias: primero lo que otras filas referencian.
const List<String> _order = <String>[
  'user',
  'service_offer',
  'need',
  'proposal',
  'interaction',
  'message',
  'rating',
  'recommendation',
];

const List<String> _avatarColors = <String>[
  '#0a6b66',
  '#b5651d',
  '#6a4c93',
  '#2a6f97',
  '#8a5a44',
  '#4f772d',
];

final Random _rng = Random();

/// Fecha y hora en UTC con milisegundos, como la web (2026-11-08T16:50:07.123Z).
String nowIso() {
  final String s = DateTime.now().toUtc().toIso8601String();
  return '${s.substring(0, 23)}Z';
}

String newId(String prefix) {
  final String a = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
  final String b = _rng.nextInt(1 << 30).toRadixString(36);
  final String c = _rng.nextInt(1 << 30).toRadixString(36);
  return '${prefix}_$a$b$c';
}

class Conversation {
  Conversation({
    required this.id,
    required this.needTitle,
    required this.otherId,
    required this.otherName,
    required this.otherColor,
    required this.status,
    required this.lastBody,
    required this.lastAt,
  });
  final String id;
  final String needTitle;
  final String otherId;
  final String otherName;
  final String otherColor;
  final String status;
  final String lastBody;
  final String lastAt;
}

class DirEntry {
  DirEntry({
    required this.user,
    required this.offers,
    required this.recs,
    required this.mine,
    required this.level,
  });
  final Rec user;
  final List<Rec> offers;
  final int recs;
  final bool mine;
  final LevelInfo level;
}

class Stats {
  Stats(this.helps, this.people, this.avgStars, this.ratings, this.recommendations);
  final int helps;
  final int people;
  final double? avgStars;
  final int ratings;
  final int recommendations;
}

class AppStore extends ChangeNotifier {
  AppStore();

  final Api api = Api.instance;
  final Map<String, Map<String, Rec>> _db = <String, Map<String, Rec>>{};
  final Set<String> _pending = <String>{};
  final Set<String> _blocked = <String>{};
  final Map<String, String> _codes = <String, String>{};
  SharedPreferences? _prefs;
  Timer? _timer;
  bool _busy = false;
  bool _again = false;
  String? _cursor;
  bool _profileChecked = false;

  bool ready = false;
  bool member = false;
  String? meId;

  /// Aviso para la pantalla de entrada ('session_lost', 'not_member').
  String? notice;

  /// 'ok', 'sin_conexion' o 'error'.
  String syncState = 'ok';
  String syncDetail = '';
  DateTime? lastOk;

  /* ------------------------------------------------------------------ */
  /* Arranque, entrada y salida                                          */
  /* ------------------------------------------------------------------ */

  Future<void> boot() async {
    _prefs = await SharedPreferences.getInstance();
    await api.init();
    api.onSessionLost = () => _lose('session_lost');
    _blocked.addAll(_prefs!.getStringList('redbarrio.blocked') ?? <String>[]);
    final Session? s = api.session;
    if (s != null && _prefs!.getString('redbarrio.member') == s.userId) {
      meId = s.userId;
      member = true;
      for (final String line in _prefs!.getStringList('redbarrio.codes') ?? <String>[]) {
        final int at = line.indexOf('|');
        if (at > 0) _codes[line.substring(0, at)] = line.substring(at + 1);
      }
    }
    ready = true;
    notifyListeners();
    if (member) _startSync();
  }

  /// Entra al barrio con el código. Lanza [JoinFailed] si algo sale mal.
  Future<void> join(String code, String name, String zone) async {
    final String id = await api.join(code.trim(), name.trim(), zone.trim());
    await _prefs!.setString('redbarrio.member', id);
    meId = id;
    member = true;
    notice = null;
    _profileChecked = true;
    final Rec user = <String, dynamic>{
      'id': id,
      'display_name': name.trim(),
      'zone': zone.trim(),
      'lat': null,
      'lng': null,
      'avatar_color': _colorFor(id),
      'created_at': nowIso(),
    };
    _save('user', user, quiet: true);
    notifyListeners();
    _startSync();
  }

  String _colorFor(String id) {
    int hash = 0;
    for (final int unit in id.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return _avatarColors[hash % _avatarColors.length];
  }

  /// El servidor ya no reconoce la cuenta de este teléfono: se vuelve a la pantalla de entrada.
  Future<void> _lose(String why) async {
    _timer?.cancel();
    _timer = null;
    _db.clear();
    _pending.clear();
    _codes.clear();
    _cursor = null;
    _profileChecked = false;
    await api.clearLocal();
    await _prefs?.remove('redbarrio.member');
    await _prefs?.remove('redbarrio.codes');
    member = false;
    meId = null;
    notice = why;
    notifyListeners();
  }

  /// Elimina mi cuenta y todo lo que publiqué en el servidor, y vuelve a la entrada.
  Future<void> deleteAccount() async {
    await api.rpc('pilot_delete_me', <String, dynamic>{});
    _blocked.clear();
    await _prefs?.remove('redbarrio.blocked');
    await _lose('');
    notice = null;
    notifyListeners();
  }

  /* ------------------------------------------------------------------ */
  /* Sincronización                                                      */
  /* ------------------------------------------------------------------ */

  void _startSync() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer _) {
      unawaited(sync());
    });
    unawaited(sync());
  }

  Future<bool> sync() async {
    if (!member) return false;
    if (_busy) {
      _again = true;
      return false;
    }
    _busy = true;
    bool changed = false;
    final String before = syncState;
    try {
      await _flush();
      final int n = await _pull();
      changed = n > 0;
      syncState = 'ok';
      syncDetail = 'Conectado';
      lastOk = DateTime.now();
      if (!_profileChecked) {
        _profileChecked = true;
        await _ensureProfile();
      }
    } on AuthError catch (e) {
      if (e.kind == AuthFailure.offline) {
        syncState = 'sin_conexion';
        syncDetail = 'Sin conexión con el servidor';
      } else if (e.kind != AuthFailure.rejected) {
        syncState = 'error';
        syncDetail = e.message;
      }
    } on ApiError catch (e) {
      if (e.message.contains('not_member')) {
        await _lose('not_member');
      } else {
        syncState = 'error';
        syncDetail = e.toString();
      }
    } catch (e) {
      syncState = 'error';
      syncDetail = e.toString();
    } finally {
      _busy = false;
      if (changed || before != syncState) notifyListeners();
      if (_again) {
        _again = false;
        unawaited(sync());
      }
    }
    return changed;
  }

  /// Si mi perfil no llegó al servidor la primera vez, se vuelve a publicar con los datos de mi cuenta.
  Future<void> _ensureProfile() async {
    final String? id = meId;
    if (id == null || _db['user']?[id] != null) return;
    final Map<String, dynamic>? m = await api.fetchMyMember();
    if (m == null) return;
    _save('user', <String, dynamic>{
      'id': id,
      'display_name': sv(m, 'display_name', 'Vecino'),
      'zone': sv(m, 'zone'),
      'lat': null,
      'lng': null,
      'avatar_color': _colorFor(id),
      'created_at': nowIso(),
    });
  }

  Future<void> _flush() async {
    if (_pending.isEmpty) return;
    final List<String> snapshot = _pending.toList();
    _pending.clear();
    final List<List<String>> items = <List<String>>[];
    for (final String key in snapshot) {
      final int at = key.indexOf('|');
      items.add(<String>[key.substring(0, at), key.substring(at + 1)]);
    }
    items.sort((List<String> a, List<String> b) => _order.indexOf(a[0]).compareTo(_order.indexOf(b[0])));
    final List<Map<String, dynamic>> records = <Map<String, dynamic>>[];
    for (final List<String> it in items) {
      Rec? data = _db[it[0]]?[it[1]];
      if (data == null && it[0] == 'recommendation') data = _tombstones[it[1]];
      if (data == null) continue;
      if (it[0] == 'user' && it[1] != meId) continue; // solo publico mi propio perfil
      records.add(<String, dynamic>{'entity': it[0], 'id': it[1], 'data': data});
    }
    try {
      for (int i = 0; i < records.length; i += 100) {
        final int end = min(i + 100, records.length);
        await api.rpc('pilot_push', <String, dynamic>{'p_records': records.sublist(i, end)});
      }
      _tombstones.clear();
    } catch (_) {
      _pending.addAll(snapshot);
      rethrow;
    }
  }

  Future<int> _pull() async {
    int changed = 0;
    String? from;
    final String? cursor = _cursor;
    if (cursor != null) {
      final DateTime? t = DateTime.tryParse(cursor);
      if (t != null) from = t.subtract(const Duration(seconds: 5)).toUtc().toIso8601String();
    }
    for (int page = 0; page < 20; page++) {
      final String filter = from == null ? '' : '&updated_at=gte.${Uri.encodeQueryComponent(from)}';
      final http.Response res = await api.rest(
        'pilot_records?select=entity,id,data,updated_at&order=updated_at.asc&limit=500$filter',
      );
      final List<dynamic> rows = api.decodeList(res);
      if (rows.isEmpty) break;
      final List<Map<String, dynamic>> typed = <Map<String, dynamic>>[];
      for (final dynamic row in rows) {
        if (row is Map) typed.add(Map<String, dynamic>.from(row));
      }
      typed.sort((Map<String, dynamic> a, Map<String, dynamic> b) {
        final int byEntity = _order.indexOf(sv(a, 'entity')).compareTo(_order.indexOf(sv(b, 'entity')));
        return byEntity != 0 ? byEntity : sv(a, 'updated_at').compareTo(sv(b, 'updated_at'));
      });
      for (final Map<String, dynamic> row in typed) {
        try {
          final Object? data = row['data'];
          if (data is Map) {
            if (_apply(sv(row, 'entity'), sv(row, 'id'), Map<String, dynamic>.from(data))) changed++;
          }
        } catch (_) {
          // fila mal formada: se ignora
        }
      }
      final String last = sv(typed.last, 'updated_at');
      _cursor = last;
      if (rows.length < 500) break;
      from = DateTime.tryParse(last)?.toUtc().toIso8601String();
      if (from == null) break;
    }
    return changed;
  }

  int _rank(String entity, String status) {
    if (entity == 'need') return status == 'abierta' ? 0 : (status == 'en_curso' ? 1 : 2);
    if (entity == 'interaction') return status == 'acordado' ? 0 : (status == 'en_curso' ? 1 : 2);
    return 0;
  }

  /// Aplica una fila del servidor. Nunca retrocede un estado (un trato completado no vuelve a "acordado").
  bool _apply(String entity, String id, Rec data) {
    if (!_order.contains(entity)) return false;
    data['id'] = id;
    final Map<String, Rec> table = _db.putIfAbsent(entity, () => <String, Rec>{});
    final Rec? old = table[id];
    if (entity == 'user' && id == meId && old != null) return false; // mi perfil manda lo local
    if (entity == 'recommendation' && data['_deleted'] == true) {
      final List<String> gone = <String>[];
      table.forEach((String key, Rec r) {
        if (sv(r, 'provider_id') == sv(data, 'provider_id') && sv(r, 'voter_id') == sv(data, 'voter_id')) {
          gone.add(key);
        }
      });
      for (final String key in gone) {
        table.remove(key);
      }
      return gone.isNotEmpty;
    }
    if (old != null) {
      if (entity == 'need' || entity == 'interaction') {
        if (_rank(entity, sv(data, 'status')) < _rank(entity, sv(old, 'status'))) {
          data['status'] = old['status'];
        }
      }
      if (entity == 'proposal' && sv(old, 'status') != 'enviada') data['status'] = old['status'];
      if (entity == 'interaction') {
        data['confirmed_by_requester'] = max(iv(old, 'confirmed_by_requester'), iv(data, 'confirmed_by_requester'));
        data['confirmed_by_provider'] = max(iv(old, 'confirmed_by_provider'), iv(data, 'confirmed_by_provider'));
      }
      if (mapEquals(old, data)) return false;
    }
    table[id] = data;
    if (entity == 'interaction') _checkDone(data);
    return true;
  }

  /// Si las dos partes ya confirmaron (aunque lo hicieran a la vez), el trato queda completado.
  void _checkDone(Rec inter) {
    final String status = sv(inter, 'status');
    if (iv(inter, 'confirmed_by_requester') == 1 &&
        iv(inter, 'confirmed_by_provider') == 1 &&
        (status == 'acordado' || status == 'en_curso')) {
      inter['status'] = 'completado';
      _pending.add('interaction|${sv(inter, 'id')}');
      final Rec? need = _db['need']?[sv(inter, 'need_id')];
      if (need != null && sv(need, 'status') != 'cancelada' && sv(need, 'status') != 'cerrada') {
        need['status'] = 'cerrada';
        _pending.add('need|${sv(need, 'id')}');
      }
    }
  }

  /// Guarda un registro local y lo deja listo para subir.
  void _save(String entity, Rec data, {bool quiet = false}) {
    final String id = sv(data, 'id');
    _db.putIfAbsent(entity, () => <String, Rec>{})[id] = data;
    _pending.add('$entity|$id');
    if (!quiet) notifyListeners();
    unawaited(sync());
  }

  /* ------------------------------------------------------------------ */
  /* Consultas                                                           */
  /* ------------------------------------------------------------------ */

  Iterable<Rec> _all(String entity) => (_db[entity] ?? <String, Rec>{}).values;

  Rec? get meUser => meId == null ? null : _db['user']?[meId!];
  Rec? userOf(String id) => _db['user']?[id];
  Rec? needById(String id) => _db['need']?[id];
  Rec? interactionById(String id) => _db['interaction']?[id];
  bool isBlocked(String id) => _blocked.contains(id);
  String nameOf(String id) {
    final Rec? u = userOf(id);
    return u == null ? 'Vecino' : sv(u, 'display_name', 'Vecino');
  }

  String colorOf(String id) {
    final Rec? u = userOf(id);
    return u == null ? '#0a6b66' : sv(u, 'avatar_color', '#0a6b66');
  }

  List<Map<String, String>> blockedList() {
    final List<Map<String, String>> out = <Map<String, String>>[];
    for (final String id in _blocked) {
      out.add(<String, String>{'id': id, 'name': nameOf(id)});
    }
    return out;
  }

  /// Muro del barrio: pedidos abiertos o en curso, lo más nuevo primero.
  List<Rec> wall({String q = '', String type = 'todos'}) {
    final String needle = norm(q);
    final List<Rec> out = <Rec>[];
    for (final Rec n in _all('need')) {
      final String status = sv(n, 'status');
      if (iv(n, 'is_emergency') != 0) continue;
      if (status != 'abierta' && status != 'en_curso') continue;
      if (_blocked.contains(sv(n, 'author_id'))) continue;
      if (type != 'todos' && sv(n, 'type') != type) continue;
      if (needle.isNotEmpty) {
        final String hay = norm(
          '${sv(n, 'title')} ${sv(n, 'description')} ${sv(n, 'category')} ${nameOf(sv(n, 'author_id'))}',
        );
        if (!hay.contains(needle)) continue;
      }
      out.add(n);
    }
    out.sort((Rec a, Rec b) => sv(b, 'created_at').compareTo(sv(a, 'created_at')));
    return out;
  }

  List<Rec> proposalsFor(String needId) {
    final List<Rec> out = <Rec>[];
    for (final Rec p in _all('proposal')) {
      if (sv(p, 'need_id') == needId && !_blocked.contains(sv(p, 'provider_id'))) out.add(p);
    }
    out.sort((Rec a, Rec b) => sv(a, 'created_at').compareTo(sv(b, 'created_at')));
    return out;
  }

  /// Trato vivo de un pedido (el que se acordó), si existe.
  Rec? dealForNeed(String needId) {
    for (final Rec i in _all('interaction')) {
      if (sv(i, 'need_id') == needId && sv(i, 'status') != 'cancelado') return i;
    }
    return null;
  }

  String? codeFor(String interactionId) => _codes[interactionId];

  List<Rec> messagesOf(String interactionId) {
    final List<Rec> out = <Rec>[];
    for (final Rec m in _all('message')) {
      if (sv(m, 'interaction_id') == interactionId) out.add(m);
    }
    out.sort((Rec a, Rec b) => sv(a, 'created_at').compareTo(sv(b, 'created_at')));
    return out;
  }

  List<Conversation> conversations() {
    final String? my = meId;
    final List<Conversation> out = <Conversation>[];
    if (my == null) return out;
    for (final Rec i in _all('interaction')) {
      final String requester = sv(i, 'requester_id');
      final String provider = sv(i, 'provider_id');
      if (requester != my && provider != my) continue;
      final String other = requester == my ? provider : requester;
      if (_blocked.contains(other)) continue;
      final List<Rec> msgs = messagesOf(sv(i, 'id'));
      final Rec? last = msgs.isEmpty ? null : msgs.last;
      out.add(Conversation(
        id: sv(i, 'id'),
        needTitle: sv(needById(sv(i, 'need_id')), 'title', 'Trato'),
        otherId: other,
        otherName: nameOf(other),
        otherColor: colorOf(other),
        status: sv(i, 'status'),
        lastBody: last == null ? '' : sv(last, 'body'),
        lastAt: last == null ? sv(i, 'created_at') : sv(last, 'created_at'),
      ));
    }
    out.sort((Conversation a, Conversation b) => b.lastAt.compareTo(a.lastAt));
    return out;
  }

  Stats statsOf(String userId) {
    int helps = 0;
    final Set<String> people = <String>{};
    for (final Rec i in _all('interaction')) {
      if (sv(i, 'status') != 'completado') continue;
      final String a = sv(i, 'requester_id');
      final String b = sv(i, 'provider_id');
      if (a == userId || b == userId) {
        helps++;
        people.add(a == userId ? b : a);
      }
    }
    int count = 0;
    int sum = 0;
    for (final Rec r in _all('rating')) {
      if (sv(r, 'to_user') == userId) {
        count++;
        sum += iv(r, 'stars', 5);
      }
    }
    int recs = 0;
    for (final Rec r in _all('recommendation')) {
      if (sv(r, 'provider_id') == userId) recs++;
    }
    return Stats(helps, people.length, count == 0 ? null : sum / count, count, recs);
  }

  LevelInfo levelOf(String userId) {
    final Stats s = statsOf(userId);
    return computeLevel(s.helps, s.recommendations, s.avgStars, s.ratings);
  }

  List<Rec> myServices() {
    final String? my = meId;
    final List<Rec> out = <Rec>[];
    if (my == null) return out;
    for (final Rec o in _all('service_offer')) {
      if (sv(o, 'provider_id') == my && iv(o, 'active', 1) == 1) out.add(o);
    }
    out.sort((Rec a, Rec b) => sv(a, 'created_at').compareTo(sv(b, 'created_at')));
    return out;
  }

  bool recommendedByMe(String providerId) {
    for (final Rec r in _all('recommendation')) {
      if (sv(r, 'provider_id') == providerId && sv(r, 'voter_id') == meId) return true;
    }
    return false;
  }

  /// Directorio de vecinos (menos yo) con lo que ofrece cada uno.
  List<DirEntry> directory({String q = '', String trade = 'todos', bool nowOnly = false}) {
    final String needle = norm(q);
    final List<DirEntry> out = <DirEntry>[];
    for (final Rec u in _all('user')) {
      final String id = sv(u, 'id');
      if (id == meId || _blocked.contains(id)) continue;
      final List<Rec> offers = <Rec>[];
      for (final Rec o in _all('service_offer')) {
        if (sv(o, 'provider_id') == id && iv(o, 'active', 1) == 1) offers.add(o);
      }
      if (trade != 'todos' && !offers.any((Rec o) => sv(o, 'trade') == trade)) continue;
      if (nowOnly && !offers.any((Rec o) => iv(o, 'available_now') == 1)) continue;
      if (needle.isNotEmpty) {
        final String hay = norm(
          '${sv(u, 'display_name')} ${sv(u, 'zone')} ${offers.map((Rec o) => '${sv(o, 'trade')} ${sv(o, 'description')}').join(' ')}',
        );
        if (!hay.contains(needle)) continue;
      }
      out.add(DirEntry(
        user: u,
        offers: offers,
        recs: statsOf(id).recommendations,
        mine: recommendedByMe(id),
        level: levelOf(id),
      ));
    }
    out.sort((DirEntry a, DirEntry b) {
      final int byRecs = b.recs.compareTo(a.recs);
      if (byRecs != 0) return byRecs;
      final int an = a.offers.any((Rec o) => iv(o, 'available_now') == 1) ? 1 : 0;
      final int bn = b.offers.any((Rec o) => iv(o, 'available_now') == 1) ? 1 : 0;
      return bn.compareTo(an);
    });
    return out;
  }

  /// Oficios que existen hoy en el barrio, con cuántos vecinos los ofrecen.
  List<MapEntry<String, int>> tradesInUse() {
    final Map<String, Set<String>> byTrade = <String, Set<String>>{};
    for (final Rec o in _all('service_offer')) {
      if (iv(o, 'active', 1) != 1 || sv(o, 'provider_id') == meId) continue;
      byTrade.putIfAbsent(sv(o, 'trade'), () => <String>{}).add(sv(o, 'provider_id'));
    }
    final List<MapEntry<String, int>> out = <MapEntry<String, int>>[];
    byTrade.forEach((String trade, Set<String> who) => out.add(MapEntry<String, int>(trade, who.length)));
    out.sort((MapEntry<String, int> a, MapEntry<String, int> b) {
      final int byCount = b.value.compareTo(a.value);
      return byCount != 0 ? byCount : a.key.compareTo(b.key);
    });
    return out;
  }

  /* ------------------------------------------------------------------ */
  /* Acciones                                                            */
  /* ------------------------------------------------------------------ */

  Future<void> createNeed({
    required String type,
    required String title,
    required String description,
    required String category,
  }) async {
    final String my = meId!;
    _save('need', <String, dynamic>{
      'id': newId('n'),
      'author_id': my,
      'type': type,
      'title': title.trim(),
      'description': description.trim(),
      'category': category,
      'zone': sv(meUser, 'zone'),
      'lat_public': null,
      'lng_public': null,
      'status': 'abierta',
      'is_emergency': 0,
      'created_at': nowIso(),
    });
  }

  Future<void> closeNeed(String needId) async {
    final Rec? n = needById(needId);
    if (n == null || sv(n, 'author_id') != meId) return;
    if (sv(n, 'status') == 'abierta' || sv(n, 'status') == 'en_curso') {
      n['status'] = 'cerrada';
      _save('need', n);
    }
  }

  Future<void> saveService({
    required String trade,
    required String description,
    required bool urgent,
    required bool availableNow,
    required String schedule,
  }) async {
    final String ts = nowIso();
    _save('service_offer', <String, dynamic>{
      'id': newId('o'),
      'provider_id': meId!,
      'trade': trade,
      'description': description.trim(),
      'urgent': urgent ? 1 : 0,
      'available_now': availableNow ? 1 : 0,
      'schedule': schedule.trim(),
      'active': 1,
      'created_at': ts,
      'updated_at': ts,
    });
  }

  Future<void> updateService(String id, {bool? urgent, bool? availableNow}) async {
    final Rec? o = _db['service_offer']?[id];
    if (o == null || sv(o, 'provider_id') != meId) return;
    if (urgent != null) o['urgent'] = urgent ? 1 : 0;
    if (availableNow != null) o['available_now'] = availableNow ? 1 : 0;
    o['updated_at'] = nowIso();
    _save('service_offer', o);
  }

  Future<void> removeService(String id) async {
    final Rec? o = _db['service_offer']?[id];
    if (o == null || sv(o, 'provider_id') != meId) return;
    o['active'] = 0;
    o['updated_at'] = nowIso();
    _save('service_offer', o);
  }

  Future<void> createProposal({
    required String needId,
    required int priceCents,
    required String message,
    required String eta,
  }) async {
    _save('proposal', <String, dynamic>{
      'id': newId('p'),
      'need_id': needId,
      'provider_id': meId!,
      'price_cents': max(0, priceCents),
      'message': message.trim(),
      'eta': eta.trim(),
      'status': 'enviada',
      'created_at': nowIso(),
    });
  }

  /// Quien publicó acepta una propuesta: se crea el trato y el código de encuentro (solo lo ve quien pidió).
  Future<String> acceptProposal(String proposalId) async {
    final Rec? p = _db['proposal']?[proposalId];
    if (p == null) throw StateError('Propuesta no encontrada');
    if (sv(p, 'status') != 'enviada') throw StateError('Esta propuesta ya fue respondida');
    final Rec? need = needById(sv(p, 'need_id'));
    if (need == null || sv(need, 'author_id') != meId) {
      throw StateError('Solo quien publicó puede aceptar propuestas');
    }
    final String interactionId = newId('i');
    final String code = (1000 + _rng.nextInt(9000)).toString();
    final String ts = nowIso();
    final int cents = iv(p, 'price_cents');

    p['status'] = 'aceptada';
    need['status'] = 'en_curso';
    final Rec inter = <String, dynamic>{
      'id': interactionId,
      'need_id': sv(need, 'id'),
      'proposal_id': proposalId,
      'requester_id': meId!,
      'provider_id': sv(p, 'provider_id'),
      'room_id': '!local:$interactionId',
      'price_cents': cents,
      'status': 'acordado',
      'confirmed_by_requester': 0,
      'confirmed_by_provider': 0,
      'created_at': ts,
    };
    final Rec msg = <String, dynamic>{
      'id': newId('m'),
      'interaction_id': interactionId,
      'room_id': '!local:$interactionId',
      'sender_id': 'system',
      'body':
          'Trato acordado${cents > 0 ? ' por ${soles(cents)}' : ' (sin dinero)'}. Coordinen aquí la hora y el lugar. El código de encuentro se muestra solo a quien pidió.',
      'txn_id': newId('txn'),
      'status': 'enviado',
      'created_at': ts,
    };
    _codes[interactionId] = code;
    await _saveCodes();
    _save('proposal', p, quiet: true);
    _save('need', need, quiet: true);
    _save('interaction', inter, quiet: true);
    _save('message', msg);
    return code;
  }

  Future<void> _saveCodes() async {
    final List<String> lines = <String>[];
    _codes.forEach((String id, String code) => lines.add('$id|$code'));
    await _prefs?.setStringList('redbarrio.codes', lines);
  }

  Future<void> sendMessage(String interactionId, String body) async {
    final String text = body.trim();
    if (text.isEmpty) return;
    final Rec? inter = interactionById(interactionId);
    if (inter == null) return;
    _save('message', <String, dynamic>{
      'id': newId('m'),
      'interaction_id': interactionId,
      'room_id': sv(inter, 'room_id', '!local:$interactionId'),
      'sender_id': meId!,
      'body': text.length > 1000 ? text.substring(0, 1000) : text,
      'txn_id': newId('txn'),
      'status': 'enviado',
      'created_at': nowIso(),
    });
  }

  /// Cada parte confirma que el trato se hizo. Cuando confirman las dos, el trato queda completado.
  Future<void> confirmDone(String interactionId) async {
    final Rec? i = interactionById(interactionId);
    if (i == null) return;
    final bool isRequester = sv(i, 'requester_id') == meId;
    if (!isRequester && sv(i, 'provider_id') != meId) return;
    final String status = sv(i, 'status');
    if (status == 'completado' || status == 'cancelado') return;
    i[isRequester ? 'confirmed_by_requester' : 'confirmed_by_provider'] = 1;
    i['status'] = 'en_curso';
    final bool both = iv(i, 'confirmed_by_requester') == 1 && iv(i, 'confirmed_by_provider') == 1;
    if (both) i['status'] = 'completado';
    final Rec? need = needById(sv(i, 'need_id'));
    if (both && need != null && sv(need, 'author_id') == meId && sv(need, 'status') != 'cancelada') {
      need['status'] = 'cerrada';
      _save('need', need, quiet: true);
    }
    _save('interaction', i, quiet: true);
    _save('message', <String, dynamic>{
      'id': newId('m'),
      'interaction_id': interactionId,
      'room_id': sv(i, 'room_id', '!local:$interactionId'),
      'sender_id': 'system',
      'body': both
          ? 'Trato completado: las dos partes confirmaron. Ahora pueden calificarse.'
          : '${nameOf(meId!)} confirmó que el trato se hizo. Falta la confirmación de la otra parte.',
      'txn_id': newId('txn'),
      'status': 'enviado',
      'created_at': nowIso(),
    });
  }

  int? myStarsFor(String interactionId) {
    for (final Rec r in _all('rating')) {
      if (sv(r, 'interaction_id') == interactionId && sv(r, 'from_user') == meId) return iv(r, 'stars', 5);
    }
    return null;
  }

  /// Califica a la otra parte (1 a 5). Solo con el trato completado, una vez por persona.
  Future<void> rate(String interactionId, int stars, String comment) async {
    final Rec? i = interactionById(interactionId);
    if (i == null || sv(i, 'status') != 'completado') return;
    if (myStarsFor(interactionId) != null) return;
    final bool isRequester = sv(i, 'requester_id') == meId;
    final String to = isRequester ? sv(i, 'provider_id') : sv(i, 'requester_id');
    final String note = comment.trim();
    _save('rating', <String, dynamic>{
      'id': newId('r'),
      'interaction_id': interactionId,
      'from_user': meId!,
      'to_user': to,
      'stars': stars.clamp(1, 5).toInt(),
      'comment': note.length > 200 ? note.substring(0, 200) : note,
      'created_at': nowIso(),
    });
  }

  Future<void> toggleRecommendation(String providerId) async {
    final Map<String, Rec> table = _db.putIfAbsent('recommendation', () => <String, Rec>{});
    String? existing;
    table.forEach((String key, Rec r) {
      if (sv(r, 'provider_id') == providerId && sv(r, 'voter_id') == meId) existing = key;
    });
    final String? found = existing;
    if (found != null) {
      final Rec gone = <String, dynamic>{
        'id': found,
        'provider_id': providerId,
        'voter_id': meId!,
        'created_at': sv(table[found], 'created_at', nowIso()),
        '_deleted': true,
      };
      table.remove(found);
      _pending.add('recommendation|$found');
      // Se sube la marca de borrado (no queda como recomendación viva).
      _tombstones[found] = gone;
      notifyListeners();
      unawaited(sync());
    } else {
      _save('recommendation', <String, dynamic>{
        'id': newId('r'),
        'provider_id': providerId,
        'voter_id': meId!,
        'created_at': nowIso(),
      });
    }
  }

  /// Marcas de borrado de recomendaciones que faltan por subir.
  final Map<String, Rec> _tombstones = <String, Rec>{};

  Future<void> saveProfile(String name, String zone) async {
    final Rec? u = meUser;
    if (u == null) return;
    u['display_name'] = name.trim().isEmpty ? 'Vecino' : name.trim();
    u['zone'] = zone.trim();
    _save('user', u);
  }

  Future<void> blockUser(String id) async {
    _blocked.add(id);
    await _prefs?.setStringList('redbarrio.blocked', _blocked.toList());
    notifyListeners();
  }

  Future<void> unblockUser(String id) async {
    _blocked.remove(id);
    await _prefs?.setStringList('redbarrio.blocked', _blocked.toList());
    notifyListeners();
  }

  /// Reporta a un vecino a quien organiza el piloto.
  Future<void> report(String entity, String entityId, String target, String reason) async {
    await api.rpc('pilot_report', <String, dynamic>{
      'p_entity': entity,
      'p_id': entityId,
      'p_target': target,
      'p_reason': reason,
    });
  }
}

/// Un solo almacén para toda la app.
final AppStore store = AppStore();

/// Convierte un id de usuario en algo que el servidor acepta como destino de un reporte (uuid).
bool looksLikeUuid(String value) => RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    ).hasMatch(value);

/// Texto corto del estado del trato para tarjetas.
String dealStatusLabel(String status) {
  switch (status) {
    case 'acordado':
      return 'Acordado';
    case 'en_curso':
      return 'En curso';
    case 'completado':
      return 'Completado';
    case 'cancelado':
      return 'Cancelado';
    default:
      return status;
  }
}

/// JSON ligero para depurar (no se usa en pantalla).
String debugDump(Rec r) => jsonEncode(r);
