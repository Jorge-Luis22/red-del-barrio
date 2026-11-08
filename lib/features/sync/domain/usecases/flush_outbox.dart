import '../../../../core/result.dart';
import '../../../needs/domain/need.dart';
import '../../../needs/domain/need_repository.dart';
import '../connectivity_monitor.dart';
import '../outbox_queue.dart';
import '../sync_gateway.dart';

/// Cómo marcar el estado de envío de un registro según el tipo de operación.
typedef StatusUpdater = Future<void> Function(String id, SyncStatus status);

/// Vacía la cola de pendientes. Sin conexión no hace nada.
/// Éxito → "Enviada"; fallo → "Error" (la operación queda para reintentar).
/// Nunca marca como enviada una operación que el gateway no confirmó.
class FlushOutbox {
  FlushOutbox({
    required this.outbox,
    required this.gateway,
    required this.connectivity,
    required this.needs,
    this.statusUpdaters = const {},
  });

  final OutboxQueue outbox;
  final SyncGateway gateway;
  final ConnectivityMonitor connectivity;
  final NeedRepository needs;

  /// Un actualizador por tipo de operación (ofertas, mensajes, avisos de emergencia…).
  /// Las operaciones sin actualizador propio se tratan como pedidos.
  final Map<String, StatusUpdater> statusUpdaters;

  Future<void> _mark(OutboxOp op, SyncStatus status) async {
    final custom = statusUpdaters[op.type];
    if (custom != null) {
      await custom(op.id, status);
    } else {
      await needs.updateStatus(op.id, status);
    }
  }

  /// Devuelve cuántas operaciones se enviaron.
  Future<Result<int>> call() async {
    if (!await connectivity.isOnline) return const Ok(0);
    var sent = 0;
    for (final op in await outbox.pending()) {
      final result = await gateway.send(op);
      switch (result) {
        case Ok():
          await outbox.remove(op.id);
          await _mark(op, SyncStatus.sent);
          sent++;
        case Err(:final failure):
          await outbox.markFailed(op.id, failure.message);
          await _mark(op, SyncStatus.error);
      }
    }
    return Ok(sent);
  }
}
