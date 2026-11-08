import 'dart:convert';

import '../../../../core/clock.dart';
import '../../../../core/failure.dart';
import '../../../../core/ids.dart';
import '../../../../core/result.dart';
import '../../../needs/domain/need.dart';
import '../../../sync/domain/outbox_queue.dart';
import '../bid.dart';
import '../bid_repository.dart';

/// Hace (o cambia) la oferta de la persona. Se guarda en el teléfono y entra a la cola de
/// pendientes: funciona sin internet.
class PlaceBid {
  PlaceBid({
    required this.bids,
    required this.outbox,
    required this.clock,
    required this.ids,
  });

  final BidRepository bids;
  final OutboxQueue outbox;
  final Clock clock;
  final IdGenerator ids;

  static const opType = 'place_bid';
  static const maxSoles = 99999;
  static const badAmount = 'Escribe un precio válido, de 0 a 99 999 soles.';

  Future<Result<Bid>> call({
    required BidSubject subject,
    required String bidder,
    required String amountText,
    String message = '',
    String whenText = '',
  }) async {
    final amount = int.tryParse(amountText.trim());
    if (amount == null || amount < 0 || amount > maxSoles) {
      return const Err(ValidationFailure(badAmount));
    }
    final now = clock.now();
    final bid = Bid(
      id: ids.newUuid(),
      subjectId: subject.id,
      kind: subject.kind,
      bidder: bidder,
      amountSoles: amount,
      message: message.trim(),
      whenText: whenText.trim(),
      createdAt: now,
      isMine: true,
      syncStatus: SyncStatus.pending,
    );
    final saved = await bids.replaceMine(bid);
    if (saved case Err(:final failure)) return Err(failure);
    final queued = await outbox.enqueue(
      OutboxOp(
        id: bid.id,
        type: opType,
        payload: jsonEncode({
          'subjectId': subject.id,
          'kind': subject.kind.name,
          'amount': amount,
          'message': bid.message,
          'when': bid.whenText,
        }),
        createdAt: now,
      ),
    );
    if (queued case Err(:final failure)) return Err(failure);
    return Ok(bid);
  }
}
