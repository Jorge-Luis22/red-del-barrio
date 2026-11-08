import 'dart:convert';

import '../../../../core/clock.dart';
import '../../../../core/failure.dart';
import '../../../../core/ids.dart';
import '../../../../core/result.dart';
import '../../../needs/domain/need.dart';
import '../../../sync/domain/outbox_queue.dart';
import '../chat.dart';
import '../chat_repository.dart';

/// Guarda el mensaje en el teléfono y lo deja en la cola de pendientes (con o sin internet).
class SendMessage {
  SendMessage({
    required this.chat,
    required this.outbox,
    required this.clock,
    required this.ids,
  });

  final ChatRepository chat;
  final OutboxQueue outbox;
  final Clock clock;
  final IdGenerator ids;

  static const opType = 'send_message';

  Future<Result<ChatMessage>> call({
    required String dealId,
    required String text,
  }) async {
    final clean = text.trim();
    if (clean.isEmpty) {
      return const Err(ValidationFailure('Escribe un mensaje.'));
    }
    final now = clock.now();
    final msg = ChatMessage(
      id: ids.newUuid(),
      dealId: dealId,
      text: clean,
      createdAt: now,
      syncStatus: SyncStatus.pending,
    );
    final saved = await chat.save(msg);
    if (saved case Err(:final failure)) return Err(failure);
    final queued = await outbox.enqueue(
      OutboxOp(
        id: msg.id,
        type: opType,
        payload: jsonEncode({'dealId': dealId, 'text': clean}),
        createdAt: now,
      ),
    );
    if (queued case Err(:final failure)) return Err(failure);
    return Ok(msg);
  }
}
