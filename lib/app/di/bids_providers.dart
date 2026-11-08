import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/bids/domain/bid.dart';
import '../../features/bids/domain/bid_repository.dart';
import '../../features/bids/domain/usecases/place_bid.dart';
import '../../features/bids/infrastructure/drift_bid_repository.dart';
import 'core_providers.dart';
import 'sync_providers.dart';

final bidRepositoryProvider = Provider<BidRepository>(
  (ref) => DriftBidRepository(ref.watch(appDatabaseProvider)),
);

final placeBidProvider = Provider<PlaceBid>(
  (ref) => PlaceBid(
    bids: ref.watch(bidRepositoryProvider),
    outbox: ref.watch(outboxProvider),
    clock: ref.watch(clockProvider),
    ids: ref.watch(idGeneratorProvider),
  ),
);

/// Todas las ofertas propias de la persona.
final myBidsStreamProvider = StreamProvider<List<Bid>>(
  (ref) => ref.watch(bidRepositoryProvider).watchMine(),
);

/// Su oferta para un anuncio, o `null` si todavía no oferta.
final myBidForProvider = Provider.family<Bid?, String>((ref, subjectId) {
  final list = ref.watch(myBidsStreamProvider).value ?? const <Bid>[];
  for (final b in list) {
    if (b.subjectId == subjectId) return b;
  }
  return null;
});
