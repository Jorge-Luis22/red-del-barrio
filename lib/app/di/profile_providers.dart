import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/profile/domain/profile.dart';
import '../../features/profile/domain/profile_repository.dart';
import '../../features/profile/domain/usecases/profile_usecases.dart';
import '../../features/profile/infrastructure/drift_profile_repository.dart';
import 'core_providers.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => DriftProfileRepository(ref.watch(appDatabaseProvider)),
);

final saveProfileProvider = Provider<SaveProfile>(
  (ref) => SaveProfile(
    profiles: ref.watch(profileRepositoryProvider),
    clock: ref.watch(clockProvider),
  ),
);

final addAddressProvider = Provider<AddAddress>(
  (ref) => AddAddress(
    profiles: ref.watch(profileRepositoryProvider),
    clock: ref.watch(clockProvider),
    ids: ref.watch(idGeneratorProvider),
  ),
);

final profileStreamProvider = StreamProvider<UserProfile?>(
  (ref) => ref.watch(profileRepositoryProvider).watchProfile(),
);

final addressesStreamProvider = StreamProvider<List<SavedAddress>>(
  (ref) => ref.watch(profileRepositoryProvider).watchAddresses(),
);

/// La dirección desde la que se miden las distancias (`null` si no hay ninguna).
final activeAddressProvider = Provider<SavedAddress?>((ref) {
  final list = ref.watch(addressesStreamProvider).value ?? const [];
  for (final a in list) {
    if (a.isActive) return a;
  }
  return null;
});
