import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../../../core/failure.dart';
import '../../../core/result.dart';
import '../../needs/domain/need.dart';
import '../domain/chat.dart';
import '../domain/chat_repository.dart';

class DriftChatRepository implements ChatRepository {
  DriftChatRepository(this._db);

  final AppDatabase _db;

  @override
  Future<Result<void>> save(ChatMessage message) async {
    try {
      await _db
          .into(_db.chatMessages)
          .insertOnConflictUpdate(
            ChatMessagesCompanion.insert(
              id: message.id,
              dealId: message.dealId,
              body: message.text,
              createdAt: message.createdAt,
              syncStatus: message.syncStatus.name,
            ),
          );
      return const Ok(null);
    } catch (_) {
      return const Err(StorageFailure('No se pudo guardar tu mensaje.'));
    }
  }

  @override
  Future<Result<void>> updateStatus(String id, SyncStatus status) async {
    try {
      await (_db.update(_db.chatMessages)..where((t) => t.id.equals(id))).write(
        ChatMessagesCompanion(syncStatus: Value(status.name)),
      );
      return const Ok(null);
    } catch (_) {
      return const Err(StorageFailure('No se pudo actualizar el mensaje.'));
    }
  }

  @override
  Stream<List<ChatMessage>> watchDeal(String dealId) {
    final query = _db.select(_db.chatMessages)
      ..where((t) => t.dealId.equals(dealId))
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Stream<List<ChatMessage>> watchAll() {
    final query = _db.select(_db.chatMessages)
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  ChatMessage _toDomain(ChatMessageRow r) => ChatMessage(
    id: r.id,
    dealId: r.dealId,
    text: r.body,
    createdAt: r.createdAt,
    syncStatus: SyncStatus.values.byName(r.syncStatus),
  );
}
