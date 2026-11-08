import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../../../core/failure.dart';
import '../../../core/result.dart';
import '../domain/deal.dart';
import '../domain/deal_repository.dart';

class DriftDealRepository implements DealRepository {
  DriftDealRepository(this._db);

  final AppDatabase _db;

  @override
  Future<Result<void>> save(Deal d) async {
    try {
      await _db
          .into(_db.deals)
          .insertOnConflictUpdate(
            DealsCompanion.insert(
              id: d.id,
              needId: d.needId,
              providerId: d.providerId,
              providerName: d.providerName,
              priceSoles: d.priceSoles,
              priceLabel: d.priceLabel,
              code: d.code,
              status: d.status.name,
              acceptedAt: d.acceptedAt,
              startedAt: Value(d.startedAt),
              completedAt: Value(d.completedAt),
            ),
          );
      return const Ok(null);
    } catch (_) {
      return const Err(
        StorageFailure('No se pudo guardar el trato en tu teléfono.'),
      );
    }
  }

  @override
  Future<Deal?> byId(String id) async {
    final r = await (_db.select(
      _db.deals,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return r == null ? null : _toDomain(r);
  }

  @override
  Future<Deal?> byNeed(String needId) async {
    final r = await (_db.select(
      _db.deals,
    )..where((t) => t.needId.equals(needId))).getSingleOrNull();
    return r == null ? null : _toDomain(r);
  }

  @override
  Stream<List<Deal>> watchAll() =>
      _db.select(_db.deals).watch().map((rows) => rows.map(_toDomain).toList());

  Deal _toDomain(DealRow r) => Deal(
    id: r.id,
    needId: r.needId,
    providerId: r.providerId,
    providerName: r.providerName,
    priceSoles: r.priceSoles,
    priceLabel: r.priceLabel,
    code: r.code,
    status: DealStatus.values.byName(r.status),
    acceptedAt: r.acceptedAt,
    startedAt: r.startedAt,
    completedAt: r.completedAt,
  );
}
