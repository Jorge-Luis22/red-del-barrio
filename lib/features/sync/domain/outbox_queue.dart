import '../../../core/result.dart';

/// Operación pendiente de enviar. [id] es el UUID de cliente: el mismo id nunca se encola dos veces.
class OutboxOp {
  const OutboxOp({
    required this.id,
    required this.type,
    required this.payload,
    required this.createdAt,
    this.attempts = 0,
    this.lastError,
  });

  final String id;
  final String type;
  final String payload;
  final DateTime createdAt;
  final int attempts;
  final String? lastError;
}

abstract interface class OutboxQueue {
  /// Idempotente: encolar un id existente no crea un duplicado.
  Future<Result<void>> enqueue(OutboxOp op);

  Future<List<OutboxOp>> pending();

  /// Cuántos envíos hay en la cola ahora y cada vez que cambia.
  Stream<int> watchPendingCount();

  Future<Result<void>> remove(String id);

  Future<Result<void>> markFailed(String id, String error);
}
