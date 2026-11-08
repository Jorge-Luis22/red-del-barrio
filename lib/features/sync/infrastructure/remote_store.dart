import '../../../core/result.dart';

/// Borde mínimo con el servidor: sesión + insertar una fila. Existe para que el gateway se
/// pruebe sin red y para que ningún tipo de Supabase salga de `infrastructure/`.
abstract interface class RemoteStore {
  /// Garantiza una sesión (anónima) con el servidor. Sin internet → `NetworkFailure`.
  Future<Result<void>> ensureSession();

  /// Inserta una fila. Es IDEMPOTENTE: si ese id ya existe, devuelve `Ok` (no duplica).
  Future<Result<void>> insert(String table, Map<String, Object?> row);
}
