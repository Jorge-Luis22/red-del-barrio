import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di/providers.dart';
import '../../../app/theme/brand.dart';
import '../../../app/ui/components.dart';
import '../../../core/geo/geo_math.dart';
import '../../assistant/presentation/tr.dart';
import '../../directory/domain/listing.dart';
import '../../directory/domain/trades.dart';
import '../../needs/domain/need.dart';
import '../../needs/presentation/composer_sheet.dart';
import '../domain/explore_nearby.dart';
import 'explore_controller.dart';
import '../../../app/l10n.dart';
import '../../directory/presentation/trade_labels.dart';

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
          context.l.explorarCerca,
          subtitle: context.l.losVecinosYNegocios,
        ),
        const SizedBox(height: 12),
        BvSegmented<ListingKind>(
          options: [
            (
              value: ListingKind.service,
              label: context.l.servicios,
              icon: Icons.handyman_rounded,
            ),
            (
              value: ListingKind.product,
              label: context.l.productos,
              icon: Icons.storefront_rounded,
            ),
          ],
          selected: filters.kind,
          onChanged: ctl.setKind,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: trades.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => Center(
                    child: ChoiceChip(
                      label: Text(tradeLabel(context.l, trades[i])),
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
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        items.when(
          loading: () => const BvSkeletonRows(),
          error: (_, _) => BvErrorState(
            message: context.l.noPudimosCargarLo,
            onRetry: () => ref.invalidate(exploreItemsProvider),
          ),
          data: (list) {
            if (list.isEmpty) {
              return BvPanel(
                child: BvEmptyState(
                  title: context.l.nadaPorAhora,
                  message: context.l.noHayResultadosCon,
                  action: OutlinedButton(
                    onPressed: () => ctl.setTrade('Todos'),
                    child: Text(context.l.verTodos),
                  ),
                ),
              );
            }
            final shown = compact ? list.take(_preview).toList() : list;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final i in shown) ...[
                  ExploreRow(item: i, compact: compact),
                  const SizedBox(height: 10),
                ],
                if (compact && list.length > shown.length)
                  TextButton.icon(
                    onPressed: () => context.push('/explorar'),
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text(
                      isService
                          ? context.l.verTodosServicios(list.length)
                          : context.l.verTodosProductos(list.length),
                    ),
                  ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: context.tones.muted,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        tr(
                          context,
                          'Datos de ejemplo para la demostración. El Visto Bueno Vecinal son recomendaciones de vecinos; no verifica la identidad.',
                          "Sample data for the demo. Neighborhood Approval is made of neighbors' recommendations; it does not verify identity.",
                        ),
                        style: context.tt.bodySmall?.copyWith(
                          color: context.tones.muted,
                        ),
                      ),
                    ),
                  ],
                ),
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
    appBar: AppBar(title: Text(context.l.explorarCerca)),
    body: const SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 4, 16, 32),
        child: ExploreSection(),
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

class ExploreRow extends ConsumerWidget {
  const ExploreRow({super.key, required this.item, this.compact = false});

  final ExploreItem item;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = item.listing;
    final myBid = ref.watch(myBidForProvider(l.id));
    final vb = item.vistoBueno;
    final isService = l.kind == ListingKind.service;
    final dist = item.distanceMeters == null
        ? null
        : (item.distanceIsReal
              ? context.l.aDistancia(formatDistance(item.distanceMeters!))
              : context.l.aDistanciaAprox(
                  formatDistance(item.distanceMeters!),
                ));
    final trade = isService
        ? roleLabel(context.l, item.provider.role)
        : tradeLabel(context.l, l.trade);
    final votes = vb.example + vb.confirmed;
    final tone = isService ? BvTone.violet : BvTone.coral;
    final muted = context.tt.bodySmall?.copyWith(color: context.tones.muted);

    return BvPanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BvIconBadge(_tradeIcon(l), tone: tone, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.title, style: context.tt.titleMedium),
                    const SizedBox(height: 2),
                    Wrap(
                      spacing: 10,
                      runSpacing: 2,
                      children: [
                        Text(trade, style: muted),
                        if (dist != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.near_me_rounded,
                                size: 14,
                                color: context.tones.muted,
                              ),
                              const SizedBox(width: 3),
                              Text(dist, style: muted),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (!isService) ...[
            Row(
              children: [
                Icon(Icons.sell_rounded, size: 18, color: context.cs.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(l.reference, style: context.tt.titleSmall),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          vb.isEmpty
              ? Row(
                  children: [
                    Icon(
                      Icons.hourglass_empty_rounded,
                      size: 18,
                      color: context.tones.muted,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        context.l.aunSinRecomendaciones,
                        style: muted,
                      ),
                    ),
                  ],
                )
              : Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: context.tones.trustSoft,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.thumb_up_alt_rounded,
                        size: 16,
                        color: context.tones.trustText,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          tr(
                            context,
                            'Visto Bueno Vecinal · $votes ${votes == 1 ? 'vecino' : 'vecinos'}',
                            'Neighborhood Approval · $votes ${votes == 1 ? 'neighbor' : 'neighbors'}',
                          ),
                          style: context.tt.labelMedium?.copyWith(
                            color: context.tones.trustText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          if (!compact) ...[
            const SizedBox(height: 8),
            Text(
              isService ? '${l.availability} · ${l.reference}' : l.availability,
              style: muted,
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: isService
                ? FilledButton.icon(
                    onPressed: () => showComposer(
                      context,
                      kind: NeedKind.service,
                      text: l.requestText,
                    ),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(64, 48),
                    ),
                    icon: const Icon(Icons.front_hand_rounded),
                    label: Text(context.l.pedirEsteServicio),
                  )
                : FilledButton.icon(
                    onPressed: () => context.push('/oferta/sale/${l.id}'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(64, 48),
                    ),
                    icon: const Icon(Icons.gavel_rounded),
                    label: Text(
                      myBid == null
                          ? context.l.bidOfferBtn
                          : context.l.bidChangeOffer,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
