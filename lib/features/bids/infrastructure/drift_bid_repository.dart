import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../../../core/result.dart';
import '../../../core/storage_guard.dart';
import '../../needs/domain/need.dart';
import '../domain/bid.dart';
import '../domain/bid_repository.dart';

class DriftBidRepository implements BidRepository {
  DriftBidRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<Bid>> watchMine() {
    final q = _db.select(_db.neighborBids)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return q.watch().map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Future<Result<void>> replaceMine(Bid bid) =>
      guardStorage('No se pudo guardar tu oferta.', () async {
        await _db.transaction(() async {
          await (_db.delete(
            _db.neighborBids,
          )..where((t) => t.subjectId.equals(bid.subjectId))).go();
          await _db
              .into(_db.neighborBids)
              .insert(
                NeighborBidsCompanion.insert(
                  id: bid.id,
                  subjectId: bid.subjectId,
                  kind: bid.kind.name,
                  bidder: bid.bidder,
                  amount: bid.amountSoles,
                  message: Value(bid.message),
                  whenText: Value(bid.whenText),
                  createdAt: bid.createdAt,
                  syncStatus: (bid.syncStatus ?? SyncStatus.pending).name,
                ),
              );
        });
      });

  @override
  Future<Result<void>> updateStatus(String id, SyncStatus status) =>
      guardStorage('No se pudo actualizar la oferta.', () async {
        await (_db.update(_db.neighborBids)..where((t) => t.id.equals(id)))
            .write(NeighborBidsCompanion(syncStatus: Value(status.name)));
      });

  Bid _toDomain(BidRow r) => Bid(
    id: r.id,
    subjectId: r.subjectId,
    kind: BidKind.values.byName(r.kind),
    bidder: r.bidder,
    amountSoles: r.amount,
    message: r.message,
    whenText: r.whenText,
    createdAt: r.createdAt,
    isMine: true,
    syncStatus: SyncStatus.values.byName(r.syncStatus),
  );
}
