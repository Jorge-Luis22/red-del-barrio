import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/geo/geo_math.dart';
import '../../directory/domain/listing.dart';
import '../../directory/domain/trades.dart';
import '../../needs/presentation/composer_sheet.dart';
import '../../needs/domain/need.dart';
import '../domain/explore_nearby.dart';
import 'explore_controller.dart';

/// "Explorar cerca": oficios y productos del barrio con Visto Bueno y distancia.
class ExploreSection extends ConsumerWidget {
  const ExploreSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final filters = ref.watch(exploreFiltersProvider);
    final items = ref.watch(exploreItemsProvider);
    final ctl = ref.read(exploreFiltersProvider.notifier);
    final trades = filters.kind == ListingKind.service ? serviceTrades : productTrades;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Explorar cerca', style: theme.textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          'Oficios y productos del barrio. Los vecinos y negocios son de ejemplo, ubicados alrededor de ti.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        SegmentedButton<ListingKind>(
          segments: const [
            ButtonSegment(value: ListingKind.service, label: Text('Servicios')),
            ButtonSegment(value: ListingKind.product, label: Text('Productos')),
          ],
          selected: {filters.kind},
          onSelectionChanged: (s) => ctl.setKind(s.first),
        ),
        const SizedBox(height: 8),
        Wrap(spacing: 8, children: [
          for (final t in trades)
            ChoiceChip(label: Text(t), selected: filters.trade == t, onSelected: (_) => ctl.setTrade(t)),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          const Text('Ordenar:'),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('Más recomendados'),
            selected: filters.sort == ExploreSort.recommended,
            onSelected: (_) => ctl.setSort(ExploreSort.recommended),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('Más cerca'),
            selected: filters.sort == ExploreSort.nearest,
            onSelected: (_) => ctl.setSort(ExploreSort.nearest),
          ),
        ]),
        const SizedBox(height: 12),
        items.when(
          loading: () => const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
          error: (_, _) => const Text('No pudimos cargar lo que hay cerca. Inténtalo otra vez.'),
          data: (list) => list.isEmpty
              ? const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('No hay resultados con ese rubro por ahora.')))
              : Column(children: [for (final i in list) _ExploreCard(item: i)]),
        ),
      ],
    );
  }
}

class _ExploreCard extends StatelessWidget {
  const _ExploreCard({required this.item});

  final ExploreItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = item.listing;
    final vb = item.vistoBueno;
    final dist = item.distanceMeters == null
        ? ''
        : ' · a ${formatDistance(item.distanceMeters!)}${item.distanceIsReal ? '' : ' (aprox.)'}';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              CircleAvatar(child: Text(_initials(item.provider.name))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l.title, style: theme.textTheme.titleMedium),
                  Text('${l.kind == ListingKind.service ? item.provider.role : l.trade}$dist',
                      style: theme.textTheme.bodySmall),
                ]),
              ),
              const Chip(label: Text('Ejemplo')),
            ]),
            const SizedBox(height: 8),
            if (vb.isEmpty)
              const Text('Aún sin recomendaciones')
            else
              Wrap(spacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
                const Icon(Icons.verified_outlined, size: 18),
                Text(
                  'Vecinos que lo recomiendan: ${vb.example} (ejemplo)'
                  '${vb.confirmed > 0 ? ' + ${vb.confirmed} tuya${vb.confirmed == 1 ? '' : 's'}' : ''}',
                ),
              ]),
            const SizedBox(height: 4),
            Text('${l.availability} · ${l.reference}', style: theme.textTheme.bodySmall),
            if (!item.recommendedByMe)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Podrás recomendarlo cuando cierres un trato con esta persona.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: () => showComposer(
                context,
                kind: l.kind == ListingKind.service ? NeedKind.service : NeedKind.product,
                text: l.requestText,
              ),
              child: Text(l.kind == ListingKind.service ? 'Pedir este servicio' : 'Lo quiero'),
            ),
          ],
        ),
      ),
    );
  }

  static String _initials(String n) =>
      n.split(' ').where((w) => w.isNotEmpty).map((w) => w[0]).take(2).join();
}
