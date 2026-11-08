import 'dart:convert';

import '../../../../core/clock.dart';
import '../../../../core/failure.dart';
import '../../../../core/ids.dart';
import '../../../../core/result.dart';
import '../../../sync/domain/outbox_queue.dart';
import '../need.dart';
import '../need_repository.dart';

/// Publica una necesidad: la guarda en el teléfono como "Pendiente" y la encola.
/// El envío real ocurre después ([FlushOutbox]); aquí nunca se dice "enviada".
class PublishNeed {
  PublishNeed({
    required this.needs,
    required this.outbox,
    required this.clock,
    required this.ids,
  });

  final NeedRepository needs;
  final OutboxQueue outbox;
  final Clock clock;
  final IdGenerator ids;

  Future<Result<Need>> call({
    required NeedKind kind,
    required String text,
    Urgency urgency = Urgency.today,
  }) async {
    final clean = text.trim();
    if (clean.length < 3) {
      return const Err(
        ValidationFailure('Cuéntanos qué necesitas (al menos 3 letras).'),
      );
    }
    final now = clock.now();
    final need = Need(
      id: ids.newUuid(),
      kind: kind,
      text: clean,
      urgency: urgency,
      createdAt: now,
      syncStatus: SyncStatus.pending,
    );
    final saved = await needs.save(need);
    if (saved case Err(:final failure)) return Err(failure);
    final queued = await outbox.enqueue(OutboxOp(
      id: need.id,
      type: 'publish_need',
      payload: jsonEncode({
        'kind': kind.name,
        'text': clean,
        'urgency': urgency.name,
      }),
      createdAt: now,
    ));
    if (queued case Err(:final failure)) return Err(failure);
    return Ok(need);
  }
}
