import '../../../core/result.dart';
import 'outbox_queue.dart';

/// A quién se envía una operación. En mobile-ux es un destino de demostración;
/// en mobile-mejoras será Supabase (idempotente por UUID).
abstract interface class SyncGateway {
  /// `true` si el destino NO es un servidor real: la UI debe decir "demo".
  bool get isDemo;

  Future<Result<void>> send(OutboxOp op);
}
