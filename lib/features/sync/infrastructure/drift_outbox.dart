import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../../../core/failure.dart';
import '../../../core/result.dart';
import '../domain/outbox_queue.dart';

class DriftOutbox implements OutboxQueue {
  DriftOutbox(this._db);

  final AppDatabase _db;

  @override
  Future<Result<void>> enqueue(OutboxOp op) async {
    try {
      // insertOrIgnore: el mismo UUID no se encola dos veces.
      await _db
          .into(_db.outboxOps)
          .insert(
            OutboxOpsCompanion.insert(
              id: op.id,
              opType: op.type,
              payload: op.payload,
              createdAt: op.createdAt,
            ),
            mode: InsertMode.insertOrIgnore,
          );
      return const Ok(null);
    } catch (_) {
      return const Err(
        StorageFailure('No se pudo guardar el envío pendiente.'),
      );
    }
  }

  @override
  Future<List<OutboxOp>> pending() async {
    final rows = await (_db.select(
      _db.outboxOps,
    )..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).get();
    return rows
        .map(
          (r) => OutboxOp(
            id: r.id,
            type: r.opType,
            payload: r.payload,
            createdAt: r.createdAt,
            attempts: r.attempts,
            lastError: r.lastError,
          ),
        )
        .toList();
  }

  @override
  Future<Result<void>> remove(String id) async {
    try {
      await (_db.delete(_db.outboxOps)..where((t) => t.id.equals(id))).go();
      return const Ok(null);
    } catch (_) {
      return const Err(StorageFailure('No se pudo actualizar la cola.'));
    }
  }

  @override
  Future<Result<void>> markFailed(String id, String error) async {
    try {
      await _db.customUpdate(
        'UPDATE outbox_ops SET attempts = attempts + 1, last_error = ? WHERE id = ?',
        variables: [Variable.withString(error), Variable.withString(id)],
        updates: {_db.outboxOps},
      );
      return const Ok(null);
    } catch (_) {
      return const Err(StorageFailure('No se pudo actualizar la cola.'));
    }
  }
}
