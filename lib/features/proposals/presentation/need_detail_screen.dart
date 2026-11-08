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
import '../../../app/l10n.dart';
import '../../../app/ui/failure_text.dart';
import '../../assistant/presentation/tr.dart';

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failureText(context.l, failure))));
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
        body: BvEmptyState(
          title: context.l.noEncontramosEstePedido,
          message: context.l.puedeQueYaNo,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go('/')),
        title: Text(NeedLabels.kind(context.l, need.kind)),
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
      BvSectionTitle(
        context.l.propuestasDeTuBarrio,
        subtitle: context.l.aquiElPrecioLo,
      ),
      const SizedBox(height: 14),
      BvSegmented<_Sort>(
        options: [
          (
            value: _Sort.reputation,
            label: context.l.reputacion,
            icon: Icons.star_rounded,
          ),
          (
            value: _Sort.distance,
            label: context.l.cercania,
            icon: Icons.near_me_rounded,
          ),
          (
            value: _Sort.price,
            label: context.l.precio,
            icon: Icons.sell_rounded,
          ),
        ],
        selected: _sort,
        onChanged: (s) => setState(() => _sort = s),
      ),
      const SizedBox(height: 14),
      views.when(
        loading: () => const BvSkeletonRows(),
        error: (_, _) => BvErrorState(
          message: context.l.noPudimosCargarLas,
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
          if (sorted.isEmpty) {
            return BvEmptyState(
              title: tr(
                context,
                'Todavía no hay vecinos de ejemplo para este pedido',
                'No example neighbors for this request yet',
              ),
              message: tr(
                context,
                'En esta versión de prueba solo hay vecinos de ejemplo para algunos oficios '
                    '(gasfitería, electricidad, carpintería, cerrajería, costura, clases y mascotas). '
                    'Con vecinos reales aquí llegarían sus propuestas.',
                'In this test version there are example neighbors for only some trades. '
                    'With real neighbors, their proposals would arrive here.',
              ),
            );
          }
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
              context.l.para2(NeedLabels.urgency(context.l, need.urgency)),
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
    final badge = syncBadge(context.l, need.syncStatus);
    final notSent = need.syncStatus != SyncStatus.sent;
    return BvBanner(
      icon: badge.icon,
      tone: badge.tone,
      message: [
        syncLabel(context.l, need.syncStatus, isDemo: isDemo),
        if (need.syncStatus == SyncStatus.sent && isDemo)
          context.l.todaviaNoHayServidor,
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
              label: Text(
                busy ? context.l.enviando : context.l.reintentarAhora,
              ),
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
                      context.l.recomiendan(p.role, view.vistoBueno.total),
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
                context.l.aprox(formatDistance(p.distanceMeters)),
                icon: Icons.near_me_rounded,
              ),
              BvPill(p.availability, icon: Icons.schedule_rounded),
            ],
          ),
          if (p.diagnosticVisitSoles != null) ...[
            const SizedBox(height: 10),
            Text(
              context.l.ofreceVisitaDeDiagnostico(p.diagnosticVisitSoles!),
              style: context.tt.bodySmall?.copyWith(color: context.tones.muted),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onAccept,
              icon: const Icon(Icons.handshake_rounded),
              label: Text(context.l.aceptarPropuesta),
            ),
          ),
        ],
      ),
    );
  }
}

/// Texto del estado del trato (también lo usa la lista de Inicio en el futuro).
String dealStatusLabel(AppLocalizations l, DealStatus s) => switch (s) {
  DealStatus.accepted => l.aceptada,
  DealStatus.inProgress => l.enCurso,
  DealStatus.awaitingRating => l.faltaCalificar,
  DealStatus.closed => l.resuelta,
};
