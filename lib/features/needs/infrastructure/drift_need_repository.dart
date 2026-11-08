import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../../../core/result.dart';
import '../domain/need.dart';
import '../domain/need_repository.dart';
import '../../../core/storage_guard.dart';

class DriftNeedRepository implements NeedRepository {
  DriftNeedRepository(this._db);

  final AppDatabase _db;

  @override
  Future<Result<void>> save(Need need) async {
    return guardStorage('No se pudo guardar en tu teléfono.', () async {
      await _db
          .into(_db.needs)
          .insertOnConflictUpdate(
            NeedsCompanion.insert(
              id: need.id,
              kind: need.kind.name,
              body: need.text,
              urgency: need.urgency.name,
              createdAt: need.createdAt,
              syncStatus: need.syncStatus.name,
            ),
          );
    });
  }

  @override
  Future<Result<void>> updateStatus(String id, SyncStatus status) async {
    return guardStorage('No se pudo actualizar el estado.', () async {
      await (_db.update(_db.needs)..where((t) => t.id.equals(id))).write(
        NeedsCompanion(syncStatus: Value(status.name)),
      );
    });
  }

  @override
  Stream<List<Need>> watchAll() {
    final query = _db.select(_db.needs)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  Need _toDomain(NeedRow r) => Need(
    id: r.id,
    kind: NeedKind.values.byName(r.kind),
    text: r.body,
    urgency: Urgency.values.byName(r.urgency),
    createdAt: r.createdAt,
    syncStatus: SyncStatus.values.byName(r.syncStatus),
  );
}
