import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../../../core/result.dart';
import '../../../core/storage_guard.dart';
import '../../needs/domain/need.dart';
import '../domain/post_response.dart';

class DriftPostResponseRepository implements PostResponseRepository {
  DriftPostResponseRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<PostResponse>> watchMine() {
    final q = _db.select(_db.postResponses)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return q.watch().map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Future<PostResponse?> byPostId(String postId) async {
    final row = await (_db.select(
      _db.postResponses,
    )..where((t) => t.postId.equals(postId))).getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<Result<void>> save(PostResponse r) =>
      guardStorage('No se pudo guardar tu propuesta.', () async {
        await _db
            .into(_db.postResponses)
            .insert(
              PostResponsesCompanion.insert(
                id: r.id,
                postId: r.postId,
                kind: r.kind.name,
                valuesJson: r.valuesJson,
                createdAt: r.createdAt,
                syncStatus: r.syncStatus.name,
              ),
            );
      });

  @override
  Future<Result<void>> updateStatus(String id, SyncStatus status) =>
      guardStorage('No se pudo actualizar la propuesta.', () async {
        await (_db.update(_db.postResponses)..where((t) => t.id.equals(id)))
            .write(PostResponsesCompanion(syncStatus: Value(status.name)));
      });

  PostResponse _toDomain(PostResponseRow r) => PostResponse(
    id: r.id,
    postId: r.postId,
    kind: PostKind.values.byName(r.kind),
    values: (jsonDecode(r.valuesJson) as Map).map(
      (k, v) => MapEntry('$k', '$v'),
    ),
    createdAt: r.createdAt,
    syncStatus: SyncStatus.values.byName(r.syncStatus),
  );
}
