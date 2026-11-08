import 'dart:convert';

import '../../../../core/clock.dart';
import '../../../../core/failure.dart';
import '../../../../core/ids.dart';
import '../../../../core/result.dart';
import '../../../needs/domain/need.dart';
import '../../../sync/domain/outbox_queue.dart';
import '../offer.dart';
import '../offer_repository.dart';

/// Publica una oferta al barrio: se guarda en el teléfono y entra a la cola de pendientes.
class PublishOffer {
  PublishOffer({
    required this.offers,
    required this.outbox,
    required this.clock,
    required this.ids,
  });

  final OfferRepository offers;
  final OutboxQueue outbox;
  final Clock clock;
  final IdGenerator ids;

  static const opType = 'publish_offer';

  Future<Result<Offer>> call({
    required Modality modality,
    required String text,
  }) async {
    final clean = text.trim();
    if (clean.length < 3) {
      return const Err(
        ValidationFailure('Cuéntanos qué ofreces (al menos 3 letras).'),
      );
    }
    final now = clock.now();
    final offer = Offer(
      id: ids.newUuid(),
      modality: modality,
      text: clean,
      createdAt: now,
      syncStatus: SyncStatus.pending,
    );
    final saved = await offers.save(offer);
    if (saved case Err(:final failure)) return Err(failure);
    final queued = await outbox.enqueue(
      OutboxOp(
        id: offer.id,
        type: opType,
        payload: jsonEncode({'modality': modality.name, 'text': clean}),
        createdAt: now,
      ),
    );
    if (queued case Err(:final failure)) return Err(failure);
    return Ok(offer);
  }
}
