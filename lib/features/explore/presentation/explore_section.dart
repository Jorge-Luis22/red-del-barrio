import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/brand.dart';
import '../../../app/ui/components.dart';
import '../../../core/geo/geo_math.dart';
import '../../directory/domain/listing.dart';
import '../../directory/domain/trades.dart';
import '../../needs/domain/need.dart';
import '../../needs/presentation/composer_sheet.dart';
import '../domain/explore_nearby.dart';
import 'explore_controller.dart';

/// "Explorar cerca" en Inicio: un adelanto de 3 resultados y un acceso a la pantalla completa.
/// Con [compact] en falso muestra todo (lo usa [ExploreScreen]).
class ExploreSection extends ConsumerWidget {
  const ExploreSection({super.key, this.compact = false});

  final bool compact;

  static const _preview = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(exploreFiltersProvider);
    final items = ref.watch(exploreItemsProvider);
    final ctl = ref.read(exploreFiltersProvider.notifier);
    final isService = filters.kind == ListingKind.service;
    final trades = isService ? serviceTrades : productTrades;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BvSectionTitle(
          'Explorar cerca',
          subtitle: 'Los vecinos y negocios son de ejemplo, ubicados alrededor de ti.',
          trailing: compact
              ? null
              : _SortMenu(sort: filters.sort, onChanged: ctl.setSort),
        ),
        const SizedBox(height: 14),
        BvSegmented<ListingKind>(
          options: const [
            (
              value: ListingKind.service,
              label: 'Servicios',
              icon: Icons.handyman_rounded,
            ),
            (
              value: ListingKind.product,
              label: 'Productos',
              icon: Icons.storefront_rounded,
            ),
          ],
          selected: filters.kind,
          onChanged: ctl.setKind,
        ),
        if (!compact) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: trades.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) => ChoiceChip(
                label: Text(trades[i]),
                selected: filters.trade == trades[i],
                onSelected: (_) => ctl.setTrade(trades[i]),
                labelStyle: context.tt.labelMedium?.copyWith(
                  color: filters.trade == trades[i]
                      ? context.cs.onPrimary
                      : context.cs.onSurface,
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 14),
        items.when(
          loading: () => const BvSkeletonRows(),
          error: (_, _) => BvErrorState(
            message: 'No pudimos cargar lo que hay cerca.',
            onRetry: () => ref.invalidate(exploreItemsProvider),
          ),
          data: (list) {
            if (list.isEmpty) {
              return BvPanel(
                child: BvEmptyState(
                  title: 'Nada por ahora',
                  message:
                      'No hay resultados con ese rubro. Prueba con "Todos".',
                  action: OutlinedButton(
                    onPressed: () => ctl.setTrade('Todos'),
                    child: const Text('Ver todos'),
                  ),
                ),
              );
            }
            final shown = compact ? list.take(_preview).toList() : list;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BvRows(
                  children: [
                    for (final i in shown)
                      ExploreRow(item: i, compact: compact),
                  ],
                ),
                if (compact && list.length > shown.length) ...[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => context.push('/explorar'),
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text(
                      'Ver todos los ${isService ? 'servicios' : 'productos'} (${list.length})',
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

/// Pantalla completa de Explorar cerca: rubro, orden y la lista entera.
class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Explorar cerca')),
    body: const SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 4, 16, 32),
        child: ExploreSection(),
      ),
    ),
  );
}

class _SortMenu extends StatelessWidget {
  const _SortMenu({required this.sort, required this.onChanged});

  final ExploreSort sort;
  final ValueChanged<ExploreSort> onChanged;

  @override
  Widget build(BuildContext context) => PopupMenuButton<ExploreSort>(
    tooltip: 'Ordenar',
    initialValue: sort,
    onSelected: onChanged,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    itemBuilder: (_) => const [
      PopupMenuItem(
        value: ExploreSort.recommended,
        child: Text('Más recomendados'),
      ),
      PopupMenuItem(value: ExploreSort.nearest, child: Text('Más cerca')),
    ],
    child: Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sort_rounded, size: 20, color: context.cs.primary),
          const SizedBox(width: 4),
          Text(
            sort == ExploreSort.recommended ? 'Recomendados' : 'Más cerca',
            style: context.tt.labelMedium?.copyWith(color: context.cs.primary),
          ),
        ],
      ),
    ),
  );
}

IconData _tradeIcon(Listing l) {
  final t = l.trade.toLowerCase();
  if (t.contains('gasfit')) return Icons.plumbing_rounded;
  if (t.contains('electric')) return Icons.electrical_services_rounded;
  if (t.contains('carpint')) return Icons.carpenter_rounded;
  if (t.contains('cerraj')) return Icons.key_rounded;
  if (t.contains('costur')) return Icons.checkroom_rounded;
  if (t.contains('clase')) return Icons.school_rounded;
  if (t.contains('mascota')) return Icons.pets_rounded;
  if (t.contains('bodega') || t.contains('minimarket')) {
    return Icons.storefront_rounded;
  }
  return l.kind == ListingKind.service
      ? Icons.handyman_rounded
      : Icons.shopping_basket_rounded;
}

class ExploreRow extends StatelessWidget {
  const ExploreRow({super.key, required this.item, this.compact = false});

  final ExploreItem item;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l = item.listing;
    final vb = item.vistoBueno;
    final isService = l.kind == ListingKind.service;
    final dist = item.distanceMeters == null
        ? null
        : 'a ${formatDistance(item.distanceMeters!)}${item.distanceIsReal ? '' : ' (aprox.)'}';
    final subtitle = [
      isService ? item.provider.role : l.trade,
      ?dist,
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BvIconBadge(
                _tradeIcon(l),
                tone: isService ? BvTone.violet : BvTone.coral,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(l.title, style: context.tt.titleMedium),
                        ),
                        const SizedBox(width: 8),
                        const BvPill('Ejemplo'),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: context.tt.bodySmall?.copyWith(
                        color: context.tones.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: vb.isEmpty
                    ? const Align(
                        alignment: Alignment.centerLeft,
                        child: BvPill(
                          'Aún sin recomendaciones',
                          icon: Icons.hourglass_empty_rounded,
                        ),
                      )
                    : Align(
                        alignment: Alignment.centerLeft,
                        child: BvPill(
                          '${vb.example} vecinos lo recomiendan (ejemplo)'
                          '${vb.confirmed > 0 ? ' + ${vb.confirmed} tuya${vb.confirmed == 1 ? '' : 's'}' : ''}',
                          icon: Icons.verified_rounded,
                          tone: BvTone.trust,
                        ),
                      ),
              ),
            ],
          ),
          if (!compact) ...[
            const SizedBox(height: 10),
            Text(
              '${l.availability} · ${l.reference}',
              style: context.tt.bodySmall?.copyWith(color: context.tones.muted),
            ),
            if (!item.recommendedByMe) ...[
              const SizedBox(height: 4),
              Text(
                'Podrás recomendarlo cuando cierres un trato con esta persona.',
                style: context.tt.bodySmall?.copyWith(
                  color: context.tones.muted,
                ),
              ),
            ],
          ],
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.tonal(
              onPressed: () => showComposer(
                context,
                kind: isService ? NeedKind.service : NeedKind.product,
                text: l.requestText,
              ),
              style: FilledButton.styleFrom(minimumSize: const Size(64, 48)),
              child: Text(isService ? 'Pedir este servicio' : 'Lo quiero'),
            ),
          ),
        ],
      ),
    );
  }
}
