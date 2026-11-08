import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../app/l10n.dart';
import '../../../app/ui/components.dart';
import '../../explore/presentation/explore_section.dart';
import '../../location/presentation/location_banner.dart';
import '../../location/presentation/location_controller.dart';
import 'home_hero.dart';
import 'my_needs_preview.dart';
import 'quick_shortcuts.dart';

/// Inicio: pedir, lo que necesita atención de mis pedidos y un adelanto de Explorar cerca.
/// Cada bloque es corto; lo demás vive en su propia pantalla ("Ver todos").
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = ref.watch(locationControllerProvider);
    final address = ref.watch(activeAddressProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: HomeHero(loc: loc, address: address),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            sliver: SliverList.list(
              children: [
                if (address == null && locationNeedsBanner(loc)) ...[
                  LocationBanner(state: loc),
                  const SizedBox(height: 24),
                ],
                BvSectionTitle(
                  context.l.atajos,
                  subtitle: context.l.unToqueAbreEl,
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          const SliverToBoxAdapter(child: QuickShortcuts()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 28, 16, 32),
            sliver: SliverList.list(
              children: const [MyNeedsPreview(), ExploreSection(compact: true)],
            ),
          ),
        ],
      ),
    );
  }
}
