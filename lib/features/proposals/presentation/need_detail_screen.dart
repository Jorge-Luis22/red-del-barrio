import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di/providers.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final need = ref.watch(needByIdProvider(widget.needId));
    final deal = ref.watch(dealByNeedProvider(widget.needId));
    final isDemo = ref.watch(syncGatewayProvider).isDemo;

    if (need == null) {
      return Scaffold(
        appBar: AppBar(leading: BackButton(onPressed: () => context.go('/'))),
        body: const Center(child: Text('No encontramos este pedido.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go('/')),
        title: Text(NeedLabels.kind(need.kind)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(need.text, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text('Para: ${NeedLabels.urgency(need.urgency)}'),
          const SizedBox(height: 12),
          _SyncCard(need: need, isDemo: isDemo),
          const SizedBox(height: 16),
          if (deal != null)
            DealPanel(deal: deal)
          else if (need.syncStatus == SyncStatus.sent)
            ..._proposals(context),
        ],
      ),
    );
  }

  List<Widget> _proposals(BuildContext context) {
    final theme = Theme.of(context);
    final views = ref.watch(proposalViewsProvider(widget.needId));
    return [
      Text('Propuestas de tu barrio', style: theme.textTheme.titleLarge),
      const SizedBox(height: 4),
      const Text('Aquí el precio lo pone cada persona al ver tu pedido. Tú eliges. Las propuestas son de ejemplo.'),
      const SizedBox(height: 8),
      Wrap(spacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
        const Text('Ordenar por'),
        for (final s in _Sort.values)
          ChoiceChip(
            label: Text(switch (s) { _Sort.reputation => 'Reputación', _Sort.distance => 'Cercanía', _Sort.price => 'Precio' }),
            selected: _sort == s,
            onSelected: (_) => setState(() => _sort = s),
          ),
      ]),
      const SizedBox(height: 8),
      views.when(
        loading: () => const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
        error: (_, _) => const Text('No pudimos cargar las propuestas. Inténtalo otra vez.'),
        data: (list) {
          final sorted = [...list]..sort((a, b) => switch (_sort) {
              _Sort.reputation => b.reputation.average.compareTo(a.reputation.average),
              _Sort.distance => a.proposal.distanceMeters.compareTo(b.proposal.distanceMeters),
              _Sort.price => a.proposal.priceSoles.compareTo(b.proposal.priceSoles),
            });
          return Column(children: [for (final v in sorted) _ProposalCard(view: v, onAccept: () => _accept(v))]);
        },
      ),
    ];
  }
}

class _SyncCard extends ConsumerWidget {
  const _SyncCard({required this.need, required this.isDemo});

  final Need need;
  final bool isDemo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busy = ref.watch(syncControllerProvider);
    final (icon, color) = switch (need.syncStatus) {
      SyncStatus.pending => (Icons.schedule, Theme.of(context).colorScheme.tertiaryContainer),
      SyncStatus.sent => (Icons.check_circle_outline, Theme.of(context).colorScheme.primaryContainer),
      SyncStatus.error => (Icons.error_outline, Theme.of(context).colorScheme.errorContainer),
    };
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon),
            const SizedBox(width: 8),
            Expanded(child: Text(syncLabel(need.syncStatus, isDemo: isDemo))),
          ]),
          if (need.syncStatus != SyncStatus.sent) ...[
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: busy ? null : () => ref.read(syncControllerProvider.notifier).flushNow(),
              child: Text(busy ? 'Enviando…' : 'Reintentar ahora'),
            ),
          ],
          if (need.syncStatus == SyncStatus.sent && isDemo)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text('Todavía no hay servidor: las propuestas que ves son de ejemplo.'),
            ),
        ]),
      ),
    );
  }
}

class _ProposalCard extends StatelessWidget {
  const _ProposalCard({required this.view, required this.onAccept});

  final ProposalView view;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = view.proposal;
    final rep = view.reputation;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p.providerName, style: theme.textTheme.titleMedium),
                Text('${p.role} · ${view.vistoBueno.total} recomiendan', style: theme.textTheme.bodySmall),
              ]),
            ),
            Text('★ ${rep.average.toStringAsFixed(1)}', style: theme.textTheme.titleMedium),
          ]),
          const SizedBox(height: 8),
          Wrap(spacing: 16, runSpacing: 4, children: [
            Text('Distancia: ${formatDistance(p.distanceMeters)} (aprox.)'),
            Text('Precio: ${p.priceLabel}'),
            Text(p.availability),
          ]),
          if (p.diagnosticVisitSoles != null)
            Text('Ofrece visita de diagnóstico: S/ ${p.diagnosticVisitSoles} (se descuenta)', style: theme.textTheme.bodySmall),
          if (p.isExample) const Padding(padding: EdgeInsets.only(top: 4), child: Chip(label: Text('Ejemplo'))),
          const SizedBox(height: 8),
          SizedBox(width: double.infinity, child: FilledButton(onPressed: onAccept, child: const Text('Aceptar propuesta'))),
        ]),
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
