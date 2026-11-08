import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../../../core/result.dart';
import '../../../core/storage_guard.dart';
import '../domain/deal.dart';
import '../domain/price_change.dart';

class DriftPriceChangeRepository implements PriceChangeRepository {
  DriftPriceChangeRepository(this._db);

  final AppDatabase _db;

  PriceChangesCompanion _row(PriceChange c) => PriceChangesCompanion.insert(
    id: c.id,
    dealId: c.dealId,
    previousPrice: c.previousPrice,
    newPrice: c.newPrice,
    reason: c.reason,
    status: c.status.name,
    author: Value(c.author),
    createdAt: c.createdAt,
    resolvedAt: Value(c.resolvedAt),
  );

  @override
  Future<Result<void>> save(PriceChange c) =>
      guardStorage('No se pudo guardar la contraoferta.', () async {
        await _db.into(_db.priceChanges).insertOnConflictUpdate(_row(c));
      });

  @override
  Future<Result<void>> saveAccepted(Deal d, PriceChange c) =>
      guardStorage('No se pudo guardar el nuevo precio.', () async {
        await _db.transaction(() async {
          await (_db.update(_db.deals)..where((t) => t.id.equals(d.id))).write(
            DealsCompanion(
              priceSoles: Value(d.priceSoles),
              priceLabel: Value(d.priceLabel),
            ),
          );
          await _db.into(_db.priceChanges).insertOnConflictUpdate(_row(c));
        });
      });

  PriceChange _toDomain(PriceChangeRow r) => PriceChange(
    id: r.id,
    dealId: r.dealId,
    previousPrice: r.previousPrice,
    newPrice: r.newPrice,
    reason: r.reason,
    status: PriceChangeStatus.values.byName(r.status),
    createdAt: r.createdAt,
    resolvedAt: r.resolvedAt,
    author: r.author,
  );

  @override
  Future<List<PriceChange>> forDeal(String dealId) async {
    final rows =
        await (_db.select(_db.priceChanges)
              ..where((t) => t.dealId.equals(dealId))
              ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
            .get();
    return rows.map(_toDomain).toList();
  }

  @override
  Stream<List<PriceChange>> watchAll() =>
      (_db.select(_db.priceChanges)
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .watch()
          .map((rows) => rows.map(_toDomain).toList());
}
