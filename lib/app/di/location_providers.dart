import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/location/domain/location_provider.dart';
import '../../features/location/domain/usecases/get_location.dart';
import '../../features/location/domain/zone_memory.dart';
import '../../features/location/infrastructure/geolocator_location_provider.dart';
import '../../features/location/infrastructure/settings_zone_memory.dart';
import 'settings_providers.dart';

final locationProvider = Provider<LocationProvider>(
  (_) => const GeolocatorLocationProvider(),
);

final zoneMemoryProvider = Provider<ZoneMemory>(
  (ref) => SettingsZoneMemory(ref.watch(settingsRepositoryProvider)),
);

final getLocationProvider = Provider<GetLocation>(
  (ref) => GetLocation(
    provider: ref.watch(locationProvider),
    memory: ref.watch(zoneMemoryProvider),
  ),
);
