import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../../../core/failure.dart';
import '../../../core/result.dart';
import '../../needs/domain/need.dart';
import '../domain/offer.dart';
import '../domain/offer_repository.dart';

class DriftOfferRepository implements OfferRepository {
  DriftOfferRepository(this._db);

  final AppDatabase _db;

  @override
  Future<Result<void>> save(Offer offer) async {
    try {
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
      return const Ok(null);
    } catch (_) {
      return const Err(StorageFailure('No se pudo guardar en tu teléfono.'));
    }
  }

  @override
  Future<Result<void>> updateStatus(String id, SyncStatus status) async {
    try {
      await (_db.update(_db.offers)..where((t) => t.id.equals(id))).write(
        OffersCompanion(syncStatus: Value(status.name)),
      );
      return const Ok(null);
    } catch (_) {
      return const Err(StorageFailure('No se pudo actualizar el estado.'));
    }
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
