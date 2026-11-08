import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../../../core/result.dart';
import '../../needs/domain/need.dart';
import '../domain/emergency.dart';
import '../domain/emergency_repository.dart';
import '../../../core/storage_guard.dart';

class DriftEmergencyRepository implements EmergencyRepository {
  DriftEmergencyRepository(this._db);

  final AppDatabase _db;

  @override
  Future<Result<void>> savePost(EmergencyPost post) async {
    return guardStorage('No se pudo guardar tu aviso.', () async {
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
    });
  }

  @override
  Future<Result<void>> updatePostStatus(String id, SyncStatus status) async {
    return guardStorage('No se pudo actualizar el aviso.', () async {
      await (_db.update(_db.emergencyPosts)..where((t) => t.id.equals(id)))
          .write(EmergencyPostsCompanion(syncStatus: Value(status.name)));
    });
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
    return guardStorage('No se pudo guardar el punto de acopio.', () async {
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
    });
  }

  @override
  Future<Result<void>> saveContact(TrustedContact c) =>
      guardStorage('No se pudo guardar el contacto.', () async {
        await _db
            .into(_db.trustedContacts)
            .insertOnConflictUpdate(
              TrustedContactsCompanion.insert(
                id: c.id,
                name: c.name,
                phone: c.phone,
                createdAt: c.createdAt,
              ),
            );
      });

  @override
  Future<Result<void>> deleteContact(String id) =>
      guardStorage('No se pudo guardar el contacto.', () async {
        await (_db.delete(
          _db.trustedContacts,
        )..where((t) => t.id.equals(id))).go();
      });

  @override
  Stream<List<TrustedContact>> watchContacts() {
    final q = _db.select(_db.trustedContacts)
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
    return q.watch().map((rows) => rows.map(_contact).toList());
  }

  @override
  Future<List<TrustedContact>> contacts() async {
    final q = _db.select(_db.trustedContacts)
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
    return (await q.get()).map(_contact).toList();
  }

  TrustedContact _contact(TrustedContactRow r) => TrustedContact(
    id: r.id,
    name: r.name,
    phone: r.phone,
    createdAt: r.createdAt,
  );

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
