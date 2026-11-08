import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/failure.dart';
import '../../../core/log.dart';
import '../../../core/result.dart';
import 'remote_store.dart';

/// Adaptador real con Supabase. Traduce TODA excepción a un [Failure] con mensaje claro:
/// el detalle técnico va al registro de desarrollo, nunca a la pantalla.
class SupabaseRemoteStore implements RemoteStore {
  SupabaseRemoteStore(this._client);

  final SupabaseClient _client;

  static const _noInternet = NetworkFailure(
    'No pudimos conectar con el barrio. Se enviará cuando haya internet.',
  );

  @override
  Future<Result<void>> ensureSession() async {
    if (_client.auth.currentSession != null) return const Ok(null);
    try {
      await _client.auth.signInAnonymously();
      return const Ok(null);
    } on AuthException catch (e, st) {
      logError('supabase_remote_store.session', e, st);
      return const Err(
        UnknownFailure(
          'No pudimos abrir tu sesión en el barrio. Inténtalo de nuevo más tarde.',
        ),
      );
    } on SocketException {
      return const Err(_noInternet);
    } on TimeoutException {
      return const Err(_noInternet);
    } catch (e, st) {
      logError('supabase_remote_store.session', e, st);
      return const Err(_noInternet);
    }
  }

  @override
  Future<Result<void>> insert(String table, Map<String, Object?> row) async {
    try {
      await _client.from(table).insert(row);
      return const Ok(null);
    } on PostgrestException catch (e, st) {
      // 23505 = ya existe esa clave: la operación ya se había enviado antes (idempotencia).
      if (e.code == '23505') return const Ok(null);
      logError('supabase_remote_store.insert($table)', e, st);
      if (e.code == '23514') {
        return const Err(
          ValidationFailure('El texto no cumple lo que pide el barrio.'),
        );
      }
      if (e.code == '42501') {
        return const Err(
          PermissionFailure('No tienes permiso para enviar esto.'),
        );
      }
      return const Err(
        UnknownFailure('No se pudo enviar ahora. Lo intentaremos otra vez.'),
      );
    } on SocketException {
      return const Err(_noInternet);
    } on TimeoutException {
      return const Err(_noInternet);
    } catch (e, st) {
      logError('supabase_remote_store.insert($table)', e, st);
      return const Err(_noInternet);
    }
  }
}
