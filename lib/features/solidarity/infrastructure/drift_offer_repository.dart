import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../../../core/result.dart';
import '../../needs/domain/need.dart';
import '../domain/offer.dart';
import '../domain/offer_repository.dart';
import '../../../core/storage_guard.dart';

class DriftOfferRepository implements OfferRepository {
  DriftOfferRepository(this._db);

  final AppDatabase _db;

  @override
  Future<Result<void>> save(Offer offer) async {
    return guardStorage('No se pudo guardar en tu teléfono.', () async {
      await _db
          .into(_db.offers)
          .insertOnConflictUpdate(
            OffersCompanion.insert(
              id: offer.id,
              modality: offer.modality.name,
              body: offer.text,
              createdAt: offer.createdAt,
              syncStatus: offer.syncStatus.name,
            ),
          );
    });
  }

  @override
  Future<Result<void>> updateStatus(String id, SyncStatus status) async {
    return guardStorage('No se pudo actualizar el estado.', () async {
      await (_db.update(_db.offers)..where((t) => t.id.equals(id))).write(
        OffersCompanion(syncStatus: Value(status.name)),
      );
    });
  }

  @override
  Stream<List<Offer>> watchAll() {
    final query = _db.select(_db.offers)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.watch().map(
      (rows) => [
        for (final r in rows)
          Offer(
            id: r.id,
            modality: Modality.values.byName(r.modality),
            text: r.body,
            createdAt: r.createdAt,
            syncStatus: SyncStatus.values.byName(r.syncStatus),
          ),
      ],
    );
  }
}
