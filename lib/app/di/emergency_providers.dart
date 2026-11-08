import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/emergency/domain/emergency.dart';
import '../../features/emergency/domain/emergency_repository.dart';
import '../../features/emergency/domain/usecases/emergency_usecases.dart';
import '../../features/emergency/infrastructure/drift_emergency_repository.dart';
import 'core_providers.dart';
import 'sync_providers.dart';

final emergencyRepositoryProvider = Provider<EmergencyRepository>(
  (ref) => DriftEmergencyRepository(ref.watch(appDatabaseProvider)),
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

final addContactProvider = Provider<AddContact>(
  (ref) => AddContact(
    emergency: ref.watch(emergencyRepositoryProvider),
    clock: ref.watch(clockProvider),
    ids: ref.watch(idGeneratorProvider),
  ),
);

final contactsStreamProvider = StreamProvider<List<TrustedContact>>(
  (ref) => ref.watch(emergencyRepositoryProvider).watchContacts(),
);

final emergencyPostsStreamProvider = StreamProvider<List<EmergencyPost>>(
  (ref) => ref.watch(emergencyRepositoryProvider).watchPosts(),
);

final collectionPointsStreamProvider = StreamProvider<List<CollectionPoint>>(
  (ref) => ref.watch(emergencyRepositoryProvider).watchCollectionPoints(),
);
