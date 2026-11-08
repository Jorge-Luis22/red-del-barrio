import 'dart:convert';

import '../../../core/clock.dart';
import '../../../core/failure.dart';
import '../../../core/ids.dart';
import '../../../core/result.dart';
import '../../needs/domain/need.dart';
import '../../sync/domain/outbox_queue.dart';
import 'offer.dart';

/// Qué tipo de oferta del muro se está respondiendo. No toda publicación se responde igual:
/// pedir prestado, alquilar y proponer un trueque piden datos distintos.
enum PostKind { loanOffer, rentOffer, barter }

/// Clasifica una oferta ajena del muro. `null` si no se puede responder
/// (es un pedido, o es una oferta propia).
PostKind? classifyOffer(WallEntry e) {
  if (e.isRequest || e.syncStatus != null) return null;
  return switch (e.modality) {
    Modality.free => PostKind.loanOffer,
    Modality.rent => PostKind.rentOffer,
    Modality.barter => PostKind.barter,
    null => null,
  };
}

/// Datos que puede pedir el formulario de respuesta.
enum ResponseField {
  price,
  availability,
  duration,
  conditions,
  offeredResource,
  coordination,
  message,
}

/// Solo los campos que tienen sentido para cada tipo. El dinero aparece únicamente
/// donde hay alquiler: nunca en préstamos gratis ni en trueques.
List<ResponseField> fieldsFor(PostKind k) => switch (k) {
  PostKind.loanOffer => const [
    ResponseField.duration,
    ResponseField.coordination,
    ResponseField.message,
  ],
  PostKind.rentOffer => const [
    ResponseField.price,
    ResponseField.duration,
    ResponseField.coordination,
    ResponseField.message,
  ],
  PostKind.barter => const [
    ResponseField.offeredResource,
    ResponseField.conditions,
    ResponseField.message,
  ],
};

/// Campos obligatorios; los demás son opcionales.
List<ResponseField> requiredFor(PostKind k) => switch (k) {
  PostKind.loanOffer => const [ResponseField.duration],
  PostKind.rentOffer => const [ResponseField.price, ResponseField.duration],
  PostKind.barter => const [ResponseField.offeredResource],
};

/// Respuesta de la persona a una oferta del muro. Se guarda en el teléfono y entra
/// a la cola de pendientes: sirve sin internet.
class PostResponse {
  const PostResponse({
    required this.id,
    required this.postId,
    required this.kind,
    required this.values,
    required this.createdAt,
    required this.syncStatus,
  });

  final String id;

  /// La publicación respondida (evita responder dos veces a la misma).
  final String postId;
  final PostKind kind;
  final Map<String, String> values;
  final DateTime createdAt;
  final SyncStatus syncStatus;

  String get valuesJson => jsonEncode(values);
}

abstract interface class PostResponseRepository {
  Stream<List<PostResponse>> watchMine();

  Future<PostResponse?> byPostId(String postId);

  Future<Result<void>> save(PostResponse response);

  Future<Result<void>> updateStatus(String id, SyncStatus status);
}

/// Envía la respuesta a una oferta: valida según el tipo, evita duplicados y la deja
/// en la cola de pendientes.
class SendPostResponse {
  SendPostResponse({
    required this.responses,
    required this.outbox,
    required this.clock,
    required this.ids,
  });

  final PostResponseRepository responses;
  final OutboxQueue outbox;
  final Clock clock;
  final IdGenerator ids;

  static const opType = 'post_response';
  static const missing = 'Completa los datos que faltan.';
  static const badPrice = 'Escribe un precio mayor que cero.';
  static const duplicate = 'Ya enviaste una propuesta para esta publicación.';

  Future<Result<PostResponse>> call(
    WallEntry post,
    PostKind kind,
    Map<ResponseField, String> input,
  ) async {
    final values = <String, String>{};
    for (final f in fieldsFor(kind)) {
      final v = (input[f] ?? '').trim();
      if (requiredFor(kind).contains(f) && v.isEmpty) {
        return const Err(ValidationFailure(missing));
      }
      if (f == ResponseField.price && v.isNotEmpty) {
        final n = int.tryParse(v);
        if (n == null || n <= 0 || n > 99999) {
          return const Err(ValidationFailure(badPrice));
        }
        values[f.name] = '$n';
      } else if (v.isNotEmpty) {
        values[f.name] = v;
      }
    }
    if (await responses.byPostId(post.id) != null) {
      return const Err(ValidationFailure(duplicate));
    }
    final now = clock.now();
    final r = PostResponse(
      id: ids.newUuid(),
      postId: post.id,
      kind: kind,
      values: values,
      createdAt: now,
      syncStatus: SyncStatus.pending,
    );
    final saved = await responses.save(r);
    if (saved case Err(:final failure)) return Err(failure);
    final queued = await outbox.enqueue(
      OutboxOp(
        id: r.id,
        type: opType,
        payload: jsonEncode({
          'postId': post.id,
          'kind': kind.name,
          'values': values,
        }),
        createdAt: now,
      ),
    );
    if (queued case Err(:final failure)) return Err(failure);
    return Ok(r);
  }
}
