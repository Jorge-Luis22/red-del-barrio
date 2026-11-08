import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/solidarity/domain/offer.dart';
import '../../features/solidarity/domain/offer_repository.dart';
import '../../features/solidarity/domain/post_response.dart';
import '../../features/solidarity/domain/usecases/publish_offer.dart';
import '../../features/solidarity/infrastructure/drift_offer_repository.dart';
import '../../features/solidarity/infrastructure/drift_post_response_repository.dart';
import 'core_providers.dart';
import 'sync_providers.dart';

final offerRepositoryProvider = Provider<OfferRepository>(
  (ref) => DriftOfferRepository(ref.watch(appDatabaseProvider)),
);

final publishOfferProvider = Provider<PublishOffer>(
  (ref) => PublishOffer(
    offers: ref.watch(offerRepositoryProvider),
    outbox: ref.watch(outboxProvider),
    clock: ref.watch(clockProvider),
    ids: ref.watch(idGeneratorProvider),
  ),
);

final offersStreamProvider = StreamProvider<List<Offer>>(
  (ref) => ref.watch(offerRepositoryProvider).watchAll(),
);

final postResponseRepositoryProvider = Provider<PostResponseRepository>(
  (ref) => DriftPostResponseRepository(ref.watch(appDatabaseProvider)),
);

final sendPostResponseProvider = Provider<SendPostResponse>(
  (ref) => SendPostResponse(
    responses: ref.watch(postResponseRepositoryProvider),
    outbox: ref.watch(outboxProvider),
    clock: ref.watch(clockProvider),
    ids: ref.watch(idGeneratorProvider),
  ),
);

/// Las respuestas que la persona envió a ofertas del muro.
final myPostResponsesProvider = StreamProvider<List<PostResponse>>(
  (ref) => ref.watch(postResponseRepositoryProvider).watchMine(),
);

/// Su respuesta a una publicación, o `null` si todavía no respondió.
final myResponseForProvider = Provider.family<PostResponse?, String>((
  ref,
  postId,
) {
  final list = ref.watch(myPostResponsesProvider).value ?? const [];
  for (final r in list) {
    if (r.postId == postId) return r;
  }
  return null;
});
