import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clock.dart';
import '../../core/db/app_database.dart';
import '../../core/ids.dart';
import '../../core/infrastructure/uuid_id_generator.dart';
import '../../features/location/domain/location_provider.dart';
import '../../features/location/infrastructure/geolocator_location_provider.dart';
import '../../features/needs/domain/need.dart';
import '../../features/needs/domain/need_repository.dart';
import '../../features/needs/domain/usecases/publish_need.dart';
import '../../features/needs/infrastructure/drift_need_repository.dart';
import '../../features/sync/domain/connectivity_monitor.dart';
import '../../features/sync/domain/outbox_queue.dart';
import '../../features/sync/domain/sync_gateway.dart';
import '../../features/sync/domain/usecases/flush_outbox.dart';
import '../../features/sync/infrastructure/connectivity_plus_monitor.dart';
import '../../features/sync/infrastructure/demo_sync_gateway.dart';
import '../../features/sync/infrastructure/drift_outbox.dart';

/// ÚNICO lugar que decide qué adaptador implementa cada puerto.
/// mobile-ux: adaptadores locales (Drift) y un destino de demostración.
/// mobile-mejoras: aquí se cambian por los de Supabase, sin tocar dominio ni pantallas.

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.open();
  ref.onDispose(db.close);
  return db;
});

final clockProvider = Provider<Clock>((_) => const SystemClock());
final idGeneratorProvider = Provider<IdGenerator>((_) => UuidIdGenerator());

final needRepositoryProvider = Provider<NeedRepository>(
  (ref) => DriftNeedRepository(ref.watch(appDatabaseProvider)),
);
final outboxProvider = Provider<OutboxQueue>(
  (ref) => DriftOutbox(ref.watch(appDatabaseProvider)),
);
final syncGatewayProvider = Provider<SyncGateway>((_) => const DemoSyncGateway());
final connectivityProvider = Provider<ConnectivityMonitor>((_) => ConnectivityPlusMonitor());
final locationProvider = Provider<LocationProvider>((_) => const GeolocatorLocationProvider());

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
  ),
);

/// Necesidades de esta persona, más recientes primero.
final needsStreamProvider = StreamProvider<List<Need>>(
  (ref) => ref.watch(needRepositoryProvider).watchAll(),
);
