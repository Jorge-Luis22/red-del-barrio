import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di/providers.dart';
import '../../../app/theme/brand.dart';
import '../../../app/ui/components.dart';
import '../../../core/geo/geo_math.dart';
import '../../../core/result.dart';
import '../../needs/domain/need.dart';
import '../../needs/presentation/need_labels.dart';
import '../../sync/presentation/sync_controller.dart';
import '../domain/deal.dart';
import 'deal_panel.dart';
import 'deal_providers.dart';

enum _Sort { reputation, distance, price }

class NeedDetailScreen extends ConsumerStatefulWidget {
  const NeedDetailScreen({super.key, required this.needId});

  final String needId;

  @override
  ConsumerState<NeedDetailScreen> createState() => _NeedDetailScreenState();
}

class _NeedDetailScreenState extends ConsumerState<NeedDetailScreen> {
  _Sort _sort = _Sort.reputation;

  Future<void> _accept(ProposalView v) async {
    final need = ref.read(needByIdProvider(widget.needId));
    if (need == null) return;
    final r = await ref.read(acceptProposalProvider)(need, v.proposal);
    if (!mounted) return;
    if (r case Err(:final failure)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final need = ref.watch(needByIdProvider(widget.needId));
    final deal = ref.watch(dealByNeedProvider(widget.needId));
    final isDemo = ref.watch(syncGatewayProvider).isDemo;

    if (need == null) {
      return Scaffold(
        appBar: AppBar(leading: BackButton(onPressed: () => context.go('/'))),
        body: const BvEmptyState(
          title: 'No encontramos este pedido',
          message: 'Puede que ya no esté en tu teléfono. Vuelve a Inicio para ver tus pedidos.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go('/')),
        title: Text(NeedLabels.kind(need.kind)),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
          children: [
            _NeedHeader(need: need),
            const SizedBox(height: 16),
            _SyncBanner(need: need, isDemo: isDemo),
            const SizedBox(height: 24),
            if (deal != null)
              DealPanel(deal: deal)
            else if (need.syncStatus == SyncStatus.sent)
              ..._proposals(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _proposals(BuildContext context) {
    final views = ref.watch(proposalViewsProvider(widget.needId));
    return [
      const BvSectionTitle(
        'Propuestas de tu barrio',
        subtitle: 'Aquí el precio lo pone cada persona al ver tu pedido. Tú eliges. Las propuestas son de ejemplo.',
      ),
      const SizedBox(height: 14),
      BvSegmented<_Sort>(
        options: const [
          (
            value: _Sort.reputation,
            label: 'Reputación',
            icon: Icons.star_rounded,
          ),
          (
            value: _Sort.distance,
            label: 'Cercanía',
            icon: Icons.near_me_rounded,
          ),
          (value: _Sort.price, label: 'Precio', icon: Icons.sell_rounded),
        ],
        selected: _sort,
        onChanged: (s) => setState(() => _sort = s),
      ),
      const SizedBox(height: 14),
      views.when(
        loading: () => const BvSkeletonRows(),
        error: (_, _) => BvErrorState(
          message: 'No pudimos cargar las propuestas.',
          onRetry: () => ref.invalidate(proposalViewsProvider(widget.needId)),
        ),
        data: (list) {
          final sorted = [...list]
            ..sort(
              (a, b) => switch (_sort) {
                _Sort.reputation => b.reputation.average.compareTo(
                  a.reputation.average,
                ),
                _Sort.distance => a.proposal.distanceMeters.compareTo(
                  b.proposal.distanceMeters,
                ),
                _Sort.price => a.proposal.priceSoles.compareTo(
                  b.proposal.priceSoles,
                ),
              },
            );
          return Column(
            children: [
              for (final v in sorted) ...[
                _ProposalCard(view: v, onAccept: () => _accept(v)),
                const SizedBox(height: 12),
              ],
            ],
          );
        },
      ),
    ];
  }
}

class _NeedHeader extends StatelessWidget {
  const _NeedHeader({required this.need});

  final Need need;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      BvIconBadge(
        NeedLabels.icon(need.kind),
        tone: NeedLabels.tone(need.kind),
        size: 56,
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(need.text, style: context.tt.headlineSmall),
            const SizedBox(height: 8),
            BvPill(
              'Para: ${NeedLabels.urgency(need.urgency)}',
              icon: Icons.schedule_rounded,
              tone: BvTone.violet,
            ),
          ],
        ),
      ),
    ],
  );
}

class _SyncBanner extends ConsumerWidget {
  const _SyncBanner({required this.need, required this.isDemo});

  final Need need;
  final bool isDemo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busy = ref.watch(syncControllerProvider);
    final badge = syncBadge(need.syncStatus);
    final notSent = need.syncStatus != SyncStatus.sent;
    return BvBanner(
      icon: badge.icon,
      tone: badge.tone,
      message: [
        syncLabel(need.syncStatus, isDemo: isDemo),
        if (need.syncStatus == SyncStatus.sent && isDemo)
          'Todavía no hay servidor: las propuestas que ves son de ejemplo.',
      ].join('\n'),
      action: notSent
          ? OutlinedButton.icon(
              onPressed: busy
                  ? null
                  : () => ref.read(syncControllerProvider.notifier).flushNow(),
              icon: busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : const Icon(Icons.sync_rounded),
              label: Text(busy ? 'Enviando…' : 'Reintentar ahora'),
            )
          : null,
    );
  }
}

class _ProposalCard extends StatelessWidget {
  const _ProposalCard({required this.view, required this.onAccept});

  final ProposalView view;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    final p = view.proposal;
    final rep = view.reputation;
    return BvPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BvAvatar(p.providerName),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.providerName, style: context.tt.titleMedium),
                    Text(
                      '${p.role} · ${view.vistoBueno.total} recomiendan',
                      style: context.tt.bodySmall?.copyWith(
                        color: context.tones.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    p.priceLabel,
                    style: context.tt.headlineSmall?.copyWith(
                      color: context.cs.primary,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 18,
                        color: context.tones.sun,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        rep.average.toStringAsFixed(1),
                        style: context.tt.labelMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              BvPill(
                '${formatDistance(p.distanceMeters)} (aprox.)',
                icon: Icons.near_me_rounded,
              ),
              BvPill(p.availability, icon: Icons.schedule_rounded),
              if (p.isExample) const BvPill('Ejemplo'),
            ],
          ),
          if (p.diagnosticVisitSoles != null) ...[
            const SizedBox(height: 10),
            Text(
              'Ofrece visita de diagnóstico: S/ ${p.diagnosticVisitSoles} (se descuenta)',
              style: context.tt.bodySmall?.copyWith(color: context.tones.muted),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onAccept,
              icon: const Icon(Icons.handshake_rounded),
              label: const Text('Aceptar propuesta'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Texto del estado del trato (también lo usa la lista de Inicio en el futuro).
String dealStatusLabel(DealStatus s) => switch (s) {
  DealStatus.accepted => 'Aceptada',
  DealStatus.inProgress => 'En curso',
  DealStatus.awaitingRating => 'Falta calificar',
  DealStatus.closed => 'Resuelta',
};
