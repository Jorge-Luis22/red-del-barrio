import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../../../core/result.dart';
import '../domain/outbox_queue.dart';
import '../../../core/storage_guard.dart';

class DriftOutbox implements OutboxQueue {
  DriftOutbox(this._db);

  final AppDatabase _db;

  @override
  Future<Result<void>> enqueue(OutboxOp op) async {
    return guardStorage('No se pudo guardar el envío pendiente.', () async {
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
    });
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
  Stream<int> watchPendingCount() =>
      _db.select(_db.outboxOps).watch().map((rows) => rows.length);

  @override
  Future<Result<void>> remove(String id) async {
    return guardStorage('No se pudo actualizar la cola.', () async {
      await (_db.delete(_db.outboxOps)..where((t) => t.id.equals(id))).go();
    });
  }

  @override
  Future<Result<void>> markFailed(String id, String error) async {
    return guardStorage('No se pudo actualizar la cola.', () async {
      await _db.customUpdate(
        'UPDATE outbox_ops SET attempts = attempts + 1, last_error = ? WHERE id = ?',
        variables: [Variable.withString(error), Variable.withString(id)],
        updates: {_db.outboxOps},
      );
    });
  }
}
