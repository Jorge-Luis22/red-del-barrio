import 'dart:convert';

import '../../../../core/clock.dart';
import '../../../../core/failure.dart';
import '../../../../core/ids.dart';
import '../../../../core/result.dart';
import '../../../needs/domain/need.dart';
import '../../../sync/domain/outbox_queue.dart';
import '../emergency.dart';
import '../emergency_repository.dart';

/// Publica un aviso de ayuda. Sin internet queda guardado y se envía al volver la red.
/// NO inventa respuestas: si nadie ayuda todavía, la pantalla lo dice.
class PublishSos {
  PublishSos({
    required this.emergency,
    required this.outbox,
    required this.clock,
    required this.ids,
  });

  final EmergencyRepository emergency;
  final OutboxQueue outbox;
  final Clock clock;
  final IdGenerator ids;

  static const opType = 'publish_sos';

  Future<Result<EmergencyPost>> call({
    required SosSituation situation,
    required String text,
  }) async {
    final clean = text.trim().isEmpty ? situation.template : text.trim();
    final now = clock.now();
    final post = EmergencyPost(
      id: ids.newUuid(),
      situation: situation,
      text: clean,
      createdAt: now,
      syncStatus: SyncStatus.pending,
    );
    final saved = await emergency.savePost(post);
    if (saved case Err(:final failure)) return Err(failure);
    final queued = await outbox.enqueue(
      OutboxOp(
        id: post.id,
        type: opType,
        payload: jsonEncode({
          'situation': situation.name,
          'text': clean,
          'private': situation.isPrivate,
        }),
        createdAt: now,
      ),
    );
    if (queued case Err(:final failure)) return Err(failure);
    return Ok(post);
  }
}

/// Propone un punto de acopio (queda "propuesto por ti, sin verificar").
class ProposeCollectionPoint {
  ProposeCollectionPoint({
    required this.emergency,
    required this.clock,
    required this.ids,
  });

  final EmergencyRepository emergency;
  final Clock clock;
  final IdGenerator ids;

  Future<Result<CollectionPoint>> call({
    required String name,
    required String reference,
  }) async {
    final n = name.trim();
    if (n.length < 3) {
      return const Err(ValidationFailure('Escribe el nombre del lugar.'));
    }
    final point = CollectionPoint(
      id: ids.newUuid(),
      name: n,
      reference: reference.trim(),
      createdAt: clock.now(),
    );
    final saved = await emergency.saveCollectionPoint(point);
    if (saved case Err(:final failure)) return Err(failure);
    return Ok(point);
  }
}
