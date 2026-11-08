import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/proposals/domain/deal.dart';
import '../../features/proposals/domain/deal_repository.dart';
import '../../features/proposals/domain/price_change.dart';
import '../../features/proposals/domain/proposal_repository.dart';
import '../../features/proposals/domain/usecases/deal_usecases.dart';
import '../../features/proposals/domain/usecases/list_proposals.dart';
import '../../features/proposals/infrastructure/demo_proposal_repository.dart';
import '../../features/proposals/infrastructure/drift_deal_repository.dart';
import '../../features/proposals/infrastructure/drift_price_change_repository.dart';
import '../../features/reputation/domain/interaction.dart';
import '../../features/reputation/domain/reputation_repository.dart';
import '../../features/reputation/infrastructure/drift_reputation_repository.dart';
import 'core_providers.dart';
import 'directory_providers.dart';

/// Propuestas, tratos y reputación.

final proposalRepositoryProvider = Provider<ProposalRepository>(
  (_) => const DemoProposalRepository(),
);
final dealRepositoryProvider = Provider<DealRepository>(
  (ref) => DriftDealRepository(ref.watch(appDatabaseProvider)),
);
final reputationRepositoryProvider = Provider<ReputationRepository>(
  (ref) => DriftReputationRepository(ref.watch(appDatabaseProvider)),
);

final listProposalsProvider = Provider<ListProposals>(
  (ref) => ListProposals(ref.watch(proposalRepositoryProvider)),
);

final acceptProposalProvider = Provider<AcceptProposal>(
  (ref) => AcceptProposal(
    deals: ref.watch(dealRepositoryProvider),
    clock: ref.watch(clockProvider),
    ids: ref.watch(idGeneratorProvider),
  ),
);

final validateMeetingCodeProvider = Provider<ValidateMeetingCode>(
  (ref) => ValidateMeetingCode(
    deals: ref.watch(dealRepositoryProvider),
    clock: ref.watch(clockProvider),
  ),
);

final completeDealProvider = Provider<CompleteDeal>(
  (ref) => CompleteDeal(
    deals: ref.watch(dealRepositoryProvider),
    clock: ref.watch(clockProvider),
  ),
);

final closeAndRateProvider = Provider<CloseAndRate>(
  (ref) => CloseAndRate(
    deals: ref.watch(dealRepositoryProvider),
    reputation: ref.watch(reputationRepositoryProvider),
    directory: ref.watch(directoryRepositoryProvider),
    clock: ref.watch(clockProvider),
    ids: ref.watch(idGeneratorProvider),
  ),
);

final rateClientProvider = Provider<RateClient>(
  (ref) => RateClient(
    deals: ref.watch(dealRepositoryProvider),
    reputation: ref.watch(reputationRepositoryProvider),
    clock: ref.watch(clockProvider),
  ),
);

final dealsStreamProvider = StreamProvider<List<Deal>>(
  (ref) => ref.watch(dealRepositoryProvider).watchAll(),
);
final interactionsStreamProvider = StreamProvider<List<Interaction>>(
  (ref) => ref.watch(reputationRepositoryProvider).watchAll(),
);

final priceChangeRepositoryProvider = Provider<PriceChangeRepository>(
  (ref) => DriftPriceChangeRepository(ref.watch(appDatabaseProvider)),
);

/// Todas las contraofertas de los tratos de la persona.
final priceChangesStreamProvider = StreamProvider<List<PriceChange>>(
  (ref) => ref.watch(priceChangeRepositoryProvider).watchAll(),
);

final counterOfferProvider = Provider<CounterOfferService>(
  (ref) => CounterOfferService(
    deals: ref.watch(dealRepositoryProvider),
    changes: ref.watch(priceChangeRepositoryProvider),
    clock: ref.watch(clockProvider),
    ids: ref.watch(idGeneratorProvider),
  ),
);

final cancelDealProvider = Provider<CancelDeal>(
  (ref) => CancelDeal(
    deals: ref.watch(dealRepositoryProvider),
    clock: ref.watch(clockProvider),
  ),
);
