import 'package:drift/drift.dart' show Value;

import '../../../core/db/app_database.dart';
import '../../../core/failure.dart';
import '../../../core/result.dart';
import '../domain/interaction.dart';
import '../domain/reputation_repository.dart';

class DriftReputationRepository implements ReputationRepository {
  DriftReputationRepository(this._db);

  final AppDatabase _db;

  @override
  Future<Result<void>> record(Interaction i) async {
    try {
      await _db
          .into(_db.interactions)
          .insertOnConflictUpdate(
            InteractionsCompanion.insert(
              id: i.id,
              dealId: i.dealId,
              providerId: i.providerId,
              raterId: i.raterId,
              stars: i.stars,
              recommended: i.recommended,
              closedAt: i.closedAt,
              comment: Value(i.comment),
            ),
          );
      return const Ok(null);
    } catch (_) {
      return const Err(StorageFailure('No se pudo guardar tu calificación.'));
    }
  }

  @override
  Future<List<Interaction>> forProvider(String providerId) async {
    final rows = await (_db.select(
      _db.interactions,
    )..where((t) => t.providerId.equals(providerId))).get();
    return rows.map(_toDomain).toList();
  }

  @override
  Stream<List<Interaction>> watchAll() => _db
      .select(_db.interactions)
      .watch()
      .map((rows) => rows.map(_toDomain).toList());

  Interaction _toDomain(InteractionRow r) => Interaction(
    id: r.id,
    dealId: r.dealId,
    providerId: r.providerId,
    raterId: r.raterId,
    stars: r.stars,
    recommended: r.recommended,
    closedAt: r.closedAt,
    comment: r.comment,
  );
}
