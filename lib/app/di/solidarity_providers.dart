import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/solidarity/domain/offer.dart';
import '../../features/solidarity/domain/offer_repository.dart';
import '../../features/solidarity/domain/usecases/publish_offer.dart';
import '../../features/solidarity/infrastructure/drift_offer_repository.dart';
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
