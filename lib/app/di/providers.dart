import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clock.dart';
import '../../core/db/app_database.dart';
import '../../core/ids.dart';
import '../../core/infrastructure/uuid_id_generator.dart';
import '../../features/deals_chat/domain/chat.dart';
import '../../features/deals_chat/domain/chat_repository.dart';
import '../../features/deals_chat/domain/usecases/send_message.dart';
import '../../features/deals_chat/infrastructure/drift_chat_repository.dart';
import '../../features/emergency/domain/emergency.dart';
import '../../features/emergency/domain/emergency_repository.dart';
import '../../features/emergency/domain/usecases/emergency_usecases.dart';
import '../../features/emergency/infrastructure/drift_emergency_repository.dart';
import '../../features/settings/domain/app_settings.dart';
import '../../features/settings/domain/settings_repository.dart';
import '../../features/settings/infrastructure/drift_settings_repository.dart';
import '../../features/solidarity/domain/offer.dart';
import '../../features/solidarity/domain/offer_repository.dart';
import '../../features/solidarity/domain/usecases/publish_offer.dart';
import '../../features/solidarity/infrastructure/drift_offer_repository.dart';
import '../../features/directory/domain/directory_repository.dart';
import '../../features/directory/infrastructure/demo_directory_repository.dart';
import '../../features/explore/domain/explore_nearby.dart';
import '../../features/location/domain/location_provider.dart';
import '../../features/location/infrastructure/geolocator_location_provider.dart';
import '../../features/needs/domain/need.dart';
import '../../features/needs/domain/need_repository.dart';
import '../../features/needs/domain/usecases/publish_need.dart';
import '../../features/needs/infrastructure/drift_need_repository.dart';
import '../../features/proposals/domain/deal.dart';
import '../../features/proposals/domain/deal_repository.dart';
import '../../features/proposals/domain/proposal_repository.dart';
import '../../features/proposals/domain/usecases/deal_usecases.dart';
import '../../features/proposals/domain/usecases/list_proposals.dart';
import '../../features/proposals/infrastructure/demo_proposal_repository.dart';
import '../../features/proposals/infrastructure/drift_deal_repository.dart';
import '../../features/reputation/domain/interaction.dart';
import '../../features/reputation/domain/reputation_repository.dart';
import '../../features/reputation/infrastructure/drift_reputation_repository.dart';
import '../../features/sync/domain/connectivity_monitor.dart';
import '../../features/sync/domain/outbox_queue.dart';
import '../../features/sync/domain/sync_gateway.dart';
import '../../features/sync/domain/usecases/flush_outbox.dart';
import '../../features/sync/infrastructure/connectivity_plus_monitor.dart';
import '../../features/sync/infrastructure/demo_sync_gateway.dart';
import '../../features/sync/infrastructure/drift_outbox.dart';

/// ÚNICO lugar que decide qué adaptador implementa cada puerto.
/// mobile-ux: adaptadores locales (Drift) y datos de demostración.
/// mobile-mejoras: aquí se cambian por los de Supabase, sin tocar dominio ni pantallas.

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.open();
  ref.onDispose(db.close);
  return db;
});

final clockProvider = Provider<Clock>((_) => const SystemClock());
final idGeneratorProvider = Provider<IdGenerator>((_) => UuidIdGenerator());

// --- Puertos ---
final needRepositoryProvider = Provider<NeedRepository>(
  (ref) => DriftNeedRepository(ref.watch(appDatabaseProvider)),
);
final outboxProvider = Provider<OutboxQueue>(
  (ref) => DriftOutbox(ref.watch(appDatabaseProvider)),
);
final syncGatewayProvider = Provider<SyncGateway>(
  (_) => const DemoSyncGateway(),
);
final connectivityProvider = Provider<ConnectivityMonitor>(
  (_) => ConnectivityPlusMonitor(),
);
final locationProvider = Provider<LocationProvider>(
  (_) => const GeolocatorLocationProvider(),
);
final directoryRepositoryProvider = Provider<DirectoryRepository>(
  (_) => const DemoDirectoryRepository(),
);
final proposalRepositoryProvider = Provider<ProposalRepository>(
  (_) => const DemoProposalRepository(),
);
final dealRepositoryProvider = Provider<DealRepository>(
  (ref) => DriftDealRepository(ref.watch(appDatabaseProvider)),
);
final reputationRepositoryProvider = Provider<ReputationRepository>(
  (ref) => DriftReputationRepository(ref.watch(appDatabaseProvider)),
);

final offerRepositoryProvider = Provider<OfferRepository>(
  (ref) => DriftOfferRepository(ref.watch(appDatabaseProvider)),
);
final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => DriftChatRepository(ref.watch(appDatabaseProvider)),
);
final emergencyRepositoryProvider = Provider<EmergencyRepository>(
  (ref) => DriftEmergencyRepository(ref.watch(appDatabaseProvider)),
);
final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => DriftSettingsRepository(ref.watch(appDatabaseProvider)),
);

// --- Casos de uso ---
final publishNeedProvider = Provider<PublishNeed>(
  (ref) => PublishNeed(
    needs: ref.watch(needRepositoryProvider),
    outbox: ref.watch(outboxProvider),
    clock: ref.watch(clockProvider),
    ids: ref.watch(idGeneratorProvider),
  ),
);

final flushOutboxProvider = Provider<FlushOutbox>(
  (ref) => FlushOutbox(
    outbox: ref.watch(outboxProvider),
    gateway: ref.watch(syncGatewayProvider),
    connectivity: ref.watch(connectivityProvider),
    needs: ref.watch(needRepositoryProvider),
    statusUpdaters: {
      PublishOffer.opType: ref.watch(offerRepositoryProvider).updateStatus,
      SendMessage.opType: ref.watch(chatRepositoryProvider).updateStatus,
      PublishSos.opType: ref
          .watch(emergencyRepositoryProvider)
          .updatePostStatus,
    },
  ),
);

final publishOfferProvider = Provider<PublishOffer>(
  (ref) => PublishOffer(
    offers: ref.watch(offerRepositoryProvider),
    outbox: ref.watch(outboxProvider),
    clock: ref.watch(clockProvider),
    ids: ref.watch(idGeneratorProvider),
  ),
);

final sendMessageProvider = Provider<SendMessage>(
  (ref) => SendMessage(
    chat: ref.watch(chatRepositoryProvider),
    outbox: ref.watch(outboxProvider),
    clock: ref.watch(clockProvider),
    ids: ref.watch(idGeneratorProvider),
  ),
);

final publishSosProvider = Provider<PublishSos>(
  (ref) => PublishSos(
    emergency: ref.watch(emergencyRepositoryProvider),
    outbox: ref.watch(outboxProvider),
    clock: ref.watch(clockProvider),
    ids: ref.watch(idGeneratorProvider),
  ),
);

final proposeCollectionPointProvider = Provider<ProposeCollectionPoint>(
  (ref) => ProposeCollectionPoint(
    emergency: ref.watch(emergencyRepositoryProvider),
    clock: ref.watch(clockProvider),
    ids: ref.watch(idGeneratorProvider),
  ),
);

final exploreNearbyProvider = Provider<ExploreNearby>(
  (ref) => ExploreNearby(
    directory: ref.watch(directoryRepositoryProvider),
    reputation: ref.watch(reputationRepositoryProvider),
  ),
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

// --- Flujos de datos observables ---
final needsStreamProvider = StreamProvider<List<Need>>(
  (ref) => ref.watch(needRepositoryProvider).watchAll(),
);
final dealsStreamProvider = StreamProvider<List<Deal>>(
  (ref) => ref.watch(dealRepositoryProvider).watchAll(),
);
final interactionsStreamProvider = StreamProvider<List<Interaction>>(
  (ref) => ref.watch(reputationRepositoryProvider).watchAll(),
);

final offersStreamProvider = StreamProvider<List<Offer>>(
  (ref) => ref.watch(offerRepositoryProvider).watchAll(),
);
final chatMessagesStreamProvider = StreamProvider<List<ChatMessage>>(
  (ref) => ref.watch(chatRepositoryProvider).watchAll(),
);
final dealMessagesProvider = StreamProvider.family<List<ChatMessage>, String>(
  (ref, dealId) => ref.watch(chatRepositoryProvider).watchDeal(dealId),
);
final emergencyPostsStreamProvider = StreamProvider<List<EmergencyPost>>(
  (ref) => ref.watch(emergencyRepositoryProvider).watchPosts(),
);
final collectionPointsStreamProvider = StreamProvider<List<CollectionPoint>>(
  (ref) => ref.watch(emergencyRepositoryProvider).watchCollectionPoints(),
);
final settingsStreamProvider = StreamProvider<AppSettings>(
  (ref) => ref.watch(settingsRepositoryProvider).watch(),
);

/// Ajustes actuales (valores por defecto mientras cargan).
final appSettingsProvider = Provider<AppSettings>(
  (ref) => ref.watch(settingsStreamProvider).value ?? const AppSettings(),
);
