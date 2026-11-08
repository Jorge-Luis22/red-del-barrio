import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config.dart';

import '../../features/bids/domain/usecases/place_bid.dart';
import '../../features/deals_chat/domain/usecases/send_message.dart';
import '../../features/emergency/domain/usecases/emergency_usecases.dart';
import '../../features/solidarity/domain/post_response.dart';
import '../../features/solidarity/domain/usecases/publish_offer.dart';
import '../../features/sync/domain/connectivity_monitor.dart';
import '../../features/sync/domain/outbox_queue.dart';
import '../../features/sync/domain/sync_gateway.dart';
import '../../features/sync/domain/usecases/flush_outbox.dart';
import '../../features/sync/infrastructure/connectivity_plus_monitor.dart';
import '../../features/sync/infrastructure/demo_sync_gateway.dart';
import '../../features/sync/infrastructure/drift_outbox.dart';
import '../../features/sync/infrastructure/supabase_remote_store.dart';
import '../../features/sync/infrastructure/supabase_sync_gateway.dart';
import 'bids_providers.dart';
import 'chat_providers.dart';
import 'core_providers.dart';
import 'emergency_providers.dart';
import 'needs_providers.dart';
import 'solidarity_providers.dart';

/// Cola de pendientes, conexión y destino de los envíos.

final outboxProvider = Provider<OutboxQueue>(
  (ref) => DriftOutbox(ref.watch(appDatabaseProvider)),
);

/// Con claves del servidor (y conexión iniciada) se envía a Supabase; si no, destino de demostración.
final syncGatewayProvider = Provider<SyncGateway>(
  (_) => AppConfig.supabaseReady
      ? SupabaseSyncGateway(SupabaseRemoteStore(Supabase.instance.client))
      : const DemoSyncGateway(),
);

final connectivityProvider = Provider<ConnectivityMonitor>(
  (_) => ConnectivityPlusMonitor(),
);

final flushOutboxProvider = Provider<FlushOutbox>(
  (ref) => FlushOutbox(
    outbox: ref.watch(outboxProvider),
    gateway: ref.watch(syncGatewayProvider),
    connectivity: ref.watch(connectivityProvider),
    needs: ref.watch(needRepositoryProvider),
    statusUpdaters: {
      PlaceBid.opType: ref.watch(bidRepositoryProvider).updateStatus,
      PublishOffer.opType: ref.watch(offerRepositoryProvider).updateStatus,
      SendPostResponse.opType: ref
          .watch(postResponseRepositoryProvider)
          .updateStatus,
      SendMessage.opType: ref.watch(chatRepositoryProvider).updateStatus,
      PublishSos.opType: ref
          .watch(emergencyRepositoryProvider)
          .updatePostStatus,
    },
  ),
);
