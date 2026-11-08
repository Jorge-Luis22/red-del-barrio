import '../../../../core/result.dart';
import '../../../needs/domain/need.dart';
import '../../../needs/domain/need_repository.dart';
import '../connectivity_monitor.dart';
import '../outbox_queue.dart';
import '../sync_gateway.dart';

/// Vacía la cola de pendientes. Sin conexión no hace nada.
/// Éxito → "Enviada"; fallo → "Error" (la operación queda para reintentar).
/// Nunca marca como enviada una operación que el gateway no confirmó.
class FlushOutbox {
  FlushOutbox({
    required this.outbox,
    required this.gateway,
    required this.connectivity,
    required this.needs,
  });

  final OutboxQueue outbox;
  final SyncGateway gateway;
  final ConnectivityMonitor connectivity;
  final NeedRepository needs;

  /// Devuelve cuántas operaciones se enviaron.
  Future<Result<int>> call() async {
    if (!await connectivity.isOnline) return const Ok(0);
    var sent = 0;
    for (final op in await outbox.pending()) {
      final result = await gateway.send(op);
      switch (result) {
        case Ok():
          await outbox.remove(op.id);
          await needs.updateStatus(op.id, SyncStatus.sent);
          sent++;
        case Err(:final failure):
          await outbox.markFailed(op.id, failure.message);
          await needs.updateStatus(op.id, SyncStatus.error);
      }
    }
    return Ok(sent);
  }
}
