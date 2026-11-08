import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../../../core/failure.dart';
import '../../../core/result.dart';
import '../../needs/domain/need.dart';
import '../domain/emergency.dart';
import '../domain/emergency_repository.dart';

class DriftEmergencyRepository implements EmergencyRepository {
  DriftEmergencyRepository(this._db);

  final AppDatabase _db;

  @override
  Future<Result<void>> savePost(EmergencyPost post) async {
    try {
      await _db
          .into(_db.emergencyPosts)
          .insertOnConflictUpdate(
            EmergencyPostsCompanion.insert(
              id: post.id,
              situation: post.situation.name,
              body: post.text,
              createdAt: post.createdAt,
              syncStatus: post.syncStatus.name,
            ),
          );
      return const Ok(null);
    } catch (_) {
      return const Err(StorageFailure('No se pudo guardar tu aviso.'));
    }
  }

  @override
  Future<Result<void>> updatePostStatus(String id, SyncStatus status) async {
    try {
      await (_db.update(_db.emergencyPosts)..where((t) => t.id.equals(id)))
          .write(EmergencyPostsCompanion(syncStatus: Value(status.name)));
      return const Ok(null);
    } catch (_) {
      return const Err(StorageFailure('No se pudo actualizar el aviso.'));
    }
  }

  @override
  Stream<List<EmergencyPost>> watchPosts() {
    final query = _db.select(_db.emergencyPosts)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.watch().map(
      (rows) => [
        for (final r in rows)
          EmergencyPost(
            id: r.id,
            situation: SosSituation.values.byName(r.situation),
            text: r.body,
            createdAt: r.createdAt,
            syncStatus: SyncStatus.values.byName(r.syncStatus),
          ),
      ],
    );
  }

  @override
  Future<Result<void>> saveCollectionPoint(CollectionPoint point) async {
    try {
      await _db
          .into(_db.collectionPoints)
          .insertOnConflictUpdate(
            CollectionPointsCompanion.insert(
              id: point.id,
              name: point.name,
              reference: point.reference,
              createdAt: point.createdAt,
            ),
          );
      return const Ok(null);
    } catch (_) {
      return const Err(
        StorageFailure('No se pudo guardar el punto de acopio.'),
      );
    }
  }

  @override
  Stream<List<CollectionPoint>> watchCollectionPoints() {
    final query = _db.select(_db.collectionPoints)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.watch().map(
      (rows) => [
        for (final r in rows)
          CollectionPoint(
            id: r.id,
            name: r.name,
            reference: r.reference,
            createdAt: r.createdAt,
          ),
      ],
    );
  }
}
