import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/domain/app_settings.dart';
import '../../features/settings/domain/settings_repository.dart';
import '../../features/settings/infrastructure/drift_settings_repository.dart';
import 'core_providers.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => DriftSettingsRepository(ref.watch(appDatabaseProvider)),
);

final settingsStreamProvider = StreamProvider<AppSettings>(
  (ref) => ref.watch(settingsRepositoryProvider).watch(),
);

/// Ajustes actuales (valores por defecto mientras cargan).
final appSettingsProvider = Provider<AppSettings>(
  (ref) => ref.watch(settingsStreamProvider).value ?? const AppSettings(),
);
