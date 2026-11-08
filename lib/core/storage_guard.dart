import 'failure.dart';
import 'result.dart';

/// Ejecuta una escritura en el almacenamiento local y traduce cualquier excepción a un
/// [StorageFailure] con [message]. Ninguna excepción de la base de datos llega a la interfaz.
Future<Result<void>> guardStorage(
  String message,
  Future<void> Function() write,
) async {
  try {
    await write();
    return const Ok(null);
  } catch (_) {
    return Err(StorageFailure(message));
  }
}
