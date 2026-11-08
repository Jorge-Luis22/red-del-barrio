import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/directory/domain/directory_repository.dart';
import '../../features/directory/infrastructure/demo_directory_repository.dart';
import '../../features/explore/domain/explore_nearby.dart';
import 'deals_providers.dart';

final directoryRepositoryProvider = Provider<DirectoryRepository>(
  (_) => const DemoDirectoryRepository(),
);

final exploreNearbyProvider = Provider<ExploreNearby>(
  (ref) => ExploreNearby(
    directory: ref.watch(directoryRepositoryProvider),
    reputation: ref.watch(reputationRepositoryProvider),
  ),
);
