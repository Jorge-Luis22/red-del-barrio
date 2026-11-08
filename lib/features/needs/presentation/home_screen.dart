import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di/providers.dart';
import '../../explore/presentation/explore_section.dart';
import '../../location/presentation/location_controller.dart';
import 'composer_sheet.dart';
import 'need_labels.dart';

/// Inicio: pedir, mis necesidades y Explorar cerca.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final needs = ref.watch(needsStreamProvider);
    final loc = ref.watch(locationControllerProvider);
    final isDemo = ref.watch(syncGatewayProvider).isDemo;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Red del barrio'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              loc.location == null
                  ? 'Zona aproximada · sin dirección exacta'
                  : 'Zona ${loc.location!.zone.lat.toStringAsFixed(2)}, ${loc.location!.zone.lng.toStringAsFixed(2)} (aprox. 1 km)',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('¿Qué necesitas?', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4),
          const Text('Cuéntalo y los vecinos y negocios de tu zona te proponen cómo resolverlo.'),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => showComposer(context),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Pedir algo'),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            for (final q in NeedLabels.quick)
              ActionChip(
                label: Text(q.label),
                onPressed: () => showComposer(context, kind: q.kind, text: q.text),
              ),
          ]),
          const SizedBox(height: 16),
          _LocationCard(state: loc),
          const SizedBox(height: 16),
          needs.when(
            data: (list) => list.isEmpty
                ? const SizedBox.shrink()
                : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Mis necesidades', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    for (final n in list)
                      Card(
                        child: ListTile(
                          leading: Icon(NeedLabels.icon(n.kind)),
                          title: Text(n.text),
                          subtitle: Text(
                            '${NeedLabels.kind(n.kind)} · Para: ${NeedLabels.urgency(n.urgency)}\n${syncLabel(n.syncStatus, isDemo: isDemo)}',
                          ),
                          isThreeLine: true,
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.go('/need/${n.id}'),
                        ),
                      ),
                    const SizedBox(height: 16),
                  ]),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const Text('No pudimos leer tus datos. Reinicia la app.'),
          ),
          const ExploreSection(),
        ],
      ),
    );
  }
}

class _LocationCard extends ConsumerWidget {
  const _LocationCard({required this.state});

  final LocationState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.status == LocationStatus.ready) return const SizedBox.shrink();
    final loading = state.status == LocationStatus.loading;
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Tu ubicación se queda en tu teléfono. La usamos solo para calcular qué hay cerca. '
              'Cuando haya cuentas, los vecinos verán únicamente una zona de unos 1000 m.'),
          if (state.status == LocationStatus.failed) ...[
            const SizedBox(height: 6),
            Text(state.message ?? 'No pudimos obtener tu ubicación.'),
          ],
          const SizedBox(height: 8),
          FilledButton(
            onPressed: loading ? null : () => ref.read(locationControllerProvider.notifier).request(),
            child: Text(loading ? 'Buscando…' : 'Usar mi ubicación'),
          ),
        ]),
      ),
    );
  }
}
