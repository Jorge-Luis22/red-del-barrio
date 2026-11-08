import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/location/presentation/location_controller.dart';
import '../features/settings/presentation/tutorial_sheet.dart';
import '../features/sync/presentation/connection_banner_bar.dart';
import '../features/sync/presentation/sync_controller.dart';
import 'di/providers.dart';
import 'l10n.dart';
import 'theme/brand.dart';

/// Marco de la app: contenido, franja de conexión y barra inferior de cinco pestañas.
/// Emergencia lleva el rojo de la paleta para que nunca se confunda con el resto.
class ShellScaffold extends ConsumerStatefulWidget {
  const ShellScaffold({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  ConsumerState<ShellScaffold> createState() => _ShellScaffoldState();
}

class _ShellScaffoldState extends ConsumerState<ShellScaffold> {
  bool _tutorialChecked = false;

  /// Al volver a la app: se actualiza la ubicación (si está activada) y se reintenta enviar.
  late final AppLifecycleListener _lifecycle = AppLifecycleListener(
    onResume: () {
      ref.read(locationControllerProvider.notifier).refreshIfEnabled();
      ref.read(syncControllerProvider.notifier).flushNow();
    },
  );

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shell = widget.shell;
    // La primera vez que se abre la app se muestra el tutorial una sola vez.
    ref.listen(settingsStreamProvider, (_, next) {
      final settings = next.value;
      if (settings == null || _tutorialChecked) return;
      _tutorialChecked = true;
      if (!settings.tutorialSeen) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) showTutorial(context);
        });
      }
    });
    final emergency = context.tones.emergency;
    return Scaffold(
      body: shell,
      // La franja de conexión va sobre la barra: empuja el contenido, nunca lo tapa.
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ConnectionBannerBar(),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: context.tones.hairline)),
            ),
            child: NavigationBar(
              selectedIndex: shell.currentIndex,
              onDestinationSelected: (i) =>
                  shell.goBranch(i, initialLocation: i == shell.currentIndex),
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: const Icon(Icons.home_rounded),
                  label: context.l.inicio,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.diversity_3_outlined),
                  selectedIcon: const Icon(Icons.diversity_3_rounded),
                  label: context.l.vecinos,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.chat_bubble_outline_rounded),
                  selectedIcon: const Icon(Icons.chat_bubble_rounded),
                  label: context.l.mensajes,
                ),
                NavigationDestination(
                  icon: Icon(Icons.crisis_alert_outlined, color: emergency),
                  selectedIcon: Icon(
                    Icons.crisis_alert_rounded,
                    color: emergency,
                  ),
                  label: context.l.emergencia,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.person_outline_rounded),
                  selectedIcon: const Icon(Icons.person_rounded),
                  label: context.l.perfil,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
