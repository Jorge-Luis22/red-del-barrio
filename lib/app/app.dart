import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/settings/domain/app_settings.dart';
import '../features/sync/presentation/sync_controller.dart';
import 'di/providers.dart';
import 'l10n.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class RedBarrioApp extends ConsumerWidget {
  const RedBarrioApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(
      syncControllerProvider,
    ); // vacía la cola al abrir y al volver la red
    final settings = ref.watch(appSettingsProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      theme: AppTheme.light(highContrast: settings.highContrast),
      darkTheme: AppTheme.dark(highContrast: settings.highContrast),
      themeMode: switch (settings.theme) {
        ThemePreference.system => ThemeMode.system,
        ThemePreference.light => ThemeMode.light,
        ThemePreference.dark => ThemeMode.dark,
      },
      routerConfig: appRouter,
      // Sin elección propia sigue al sistema; si el sistema no es es/en, usa español.
      locale: settings.languageCode == null
          ? null
          : Locale(settings.languageCode!),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      localeResolutionCallback: (device, supported) {
        for (final s in supported) {
          if (s.languageCode == device?.languageCode) return s;
        }
        return const Locale('es');
      },
      // El tamaño de texto elegido en Perfil se suma al del sistema.
      builder: (context, child) {
        final system = MediaQuery.textScalerOf(context).scale(1);
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(system * settings.textScale),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
