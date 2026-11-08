import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di/providers.dart';
import '../../../app/l10n.dart';
import '../../../app/theme/brand.dart';
import '../../../app/ui/components.dart';
import '../../needs/domain/need.dart';
import '../../needs/presentation/need_labels.dart';
import '../../proposals/domain/deal.dart';
import '../../reputation/domain/interaction.dart';
import '../../solidarity/domain/offer.dart';
import '../domain/barrio_stats.dart';
import 'tr.dart';

/// Estadísticas reales de este teléfono (sin nombres ni textos de personas).
final _realStatsProvider = Provider<BarrioStats>((ref) {
  return BarrioStats.fromData(
    needs: ref.watch(needsStreamProvider).value ?? const <Need>[],
    offers: ref.watch(offersStreamProvider).value ?? const <Offer>[],
    deals: ref.watch(dealsStreamProvider).value ?? const <Deal>[],
    interactions:
        ref.watch(interactionsStreamProvider).value ?? const <Interaction>[],
  );
});

/// Entrada en Perfil que abre el tablero.
class TableroEntry extends StatelessWidget {
  const TableroEntry({super.key});

  @override
  Widget build(BuildContext context) => BvPanel(
    child: InkWell(
      onTap: () => context.push('/perfil/tablero'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const BvIconBadge(Icons.insights_rounded, tone: BvTone.trust),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr(context, 'Tablero del barrio', 'Neighborhood dashboard'),
                    style: context.tt.titleSmall,
                  ),
                  Text(
                    tr(
                      context,
                      'Vista anónima para la municipalidad (prototipo)',
                      'Anonymous view for the municipality (prototype)',
                    ),
                    style: context.tt.bodySmall?.copyWith(
                      color: context.tones.muted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: context.tones.muted),
          ],
        ),
      ),
    ),
  );
}

class TableroScreen extends ConsumerStatefulWidget {
  const TableroScreen({super.key});

  @override
  ConsumerState<TableroScreen> createState() => _TableroScreenState();
}

class _TableroScreenState extends ConsumerState<TableroScreen> {
  bool? _exampleOverride;

  @override
  Widget build(BuildContext context) {
    final real = ref.watch(_realStatsProvider);
    final empty = real.needs + real.offers + real.deals == 0;
    final useExample = _exampleOverride ?? empty;
    final stats = useExample ? BarrioStats.example : real;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr(context, 'Tablero del barrio', 'Neighborhood dashboard'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          BvBanner(
            icon: Icons.privacy_tip_outlined,
            tone: BvTone.trust,
            message: tr(
              context,
              'Resumen anónimo: solo cifras, sin nombres ni textos de personas. '
                  'Es un prototipo: lo que ves sale de este teléfono.',
              'Anonymous summary: figures only, no names or personal texts. '
                  'This is a prototype: what you see comes from this phone.',
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              tr(context, 'Ver datos de ejemplo', 'Show example data'),
              style: context.tt.titleSmall,
            ),
            subtitle: Text(
              tr(
                context,
                'Cifras inventadas para mostrar cómo se vería con un barrio activo.',
                'Made-up figures to show how it would look with an active neighborhood.',
              ),
            ),
            value: useExample,
            onChanged: (v) => setState(() => _exampleOverride = v),
          ),
          if (stats.isExample)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: BvPill(
                tr(
                  context,
                  'EJEMPLO · no son personas reales',
                  'EXAMPLE · not real people',
                ),
                tone: BvTone.sun,
              ),
            ),
          const SizedBox(height: 4),
          _StatGrid(stats: stats),
          const SizedBox(height: 20),
          Text(
            tr(context, 'Qué piden los vecinos', 'What neighbors ask for'),
            style: context.tt.titleMedium,
          ),
          const SizedBox(height: 10),
          if (stats.needs == 0)
            Text(
              tr(context, 'Todavía no hay pedidos.', 'No requests yet.'),
              style: context.tt.bodyMedium?.copyWith(
                color: context.tones.muted,
              ),
            )
          else
            for (final k in NeedKind.values)
              _KindBar(
                label: NeedLabels.kind(context.l, k),
                count: stats.byKind[k] ?? 0,
                total: stats.needs,
              ),
          const SizedBox(height: 20),
          Text(
            tr(context, 'Lectura del tablero', 'What the dashboard says'),
            style: context.tt.titleMedium,
          ),
          const SizedBox(height: 10),
          BvPanel(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final line in _insights(context, stats))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('• $line', style: context.tt.bodyMedium),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            tr(
              context,
              'Cómo se calcula: conteos y reglas simples sobre los datos del teléfono. '
                  'No usa inteligencia artificial ni servidor.',
              'How it is computed: counts and simple rules over the phone data. '
                  'No artificial intelligence and no server.',
            ),
            style: context.tt.bodySmall?.copyWith(color: context.tones.muted),
          ),
        ],
      ),
    );
  }

  List<String> _insights(BuildContext context, BarrioStats s) {
    final out = <String>[];
    if (s.needs == 0) {
      out.add(
        tr(
          context,
          'Todavía no hay pedidos para analizar.',
          'There are no requests to analyze yet.',
        ),
      );
      return out;
    }
    final top = s.topKind;
    if (top != null) {
      final label = NeedLabels.kind(context.l, top);
      final n = s.byKind[top] ?? 0;
      out.add(
        tr(
          context,
          'El tipo de pedido más frecuente es «$label» ($n de ${s.needs}).',
          'The most common request type is “$label” ($n of ${s.needs}).',
        ),
      );
    }
    out.add(
      tr(
        context,
        '${s.urgentPercent}% de los pedidos se necesita ahora o hoy.',
        '${s.urgentPercent}% of requests are needed now or today.',
      ),
    );
    if (s.offers < s.needs) {
      out.add(
        tr(
          context,
          'Hay más pedidos que ofertas (${s.needs} frente a ${s.offers}): conviene convocar a más vecinos con oficios o tiempo.',
          'There are more requests than offers (${s.needs} vs ${s.offers}): it would help to invite more neighbors with skills or time.',
        ),
      );
    } else {
      out.add(
        tr(
          context,
          'Hay más ofertas que pedidos: conviene difundir la app para que más vecinos pidan ayuda.',
          'There are more offers than requests: spreading the app would help more neighbors ask for help.',
        ),
      );
    }
    if (s.deals > 0) {
      out.add(
        tr(
          context,
          'Se cerraron ${s.closedDeals} de ${s.deals} tratos.',
          '${s.closedDeals} of ${s.deals} deals were closed.',
        ),
      );
    }
    return out;
  }
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.stats});

  final BarrioStats stats;

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        Icons.assignment_rounded,
        '${stats.needs}',
        tr(context, 'Pedidos', 'Requests'),
        BvTone.violet,
      ),
      (
        Icons.bolt_rounded,
        '${stats.urgentPercent}%',
        tr(context, 'Urgentes (ahora u hoy)', 'Urgent (now or today)'),
        BvTone.coral,
      ),
      (
        Icons.volunteer_activism_rounded,
        '${stats.offers}',
        tr(
          context,
          'Ofertas (${stats.freeOffers} gratis)',
          'Offers (${stats.freeOffers} free)',
        ),
        BvTone.trust,
      ),
      (
        Icons.task_alt_rounded,
        '${stats.closedDeals}/${stats.deals}',
        tr(context, 'Tratos cerrados', 'Deals closed'),
        BvTone.sun,
      ),
      (
        Icons.star_rounded,
        stats.averageStars == null
            ? '—'
            : stats.averageStars!.toStringAsFixed(1),
        tr(context, 'Calificación media', 'Average rating'),
        BvTone.sun,
      ),
    ];
    return GridView.count(
      padding: EdgeInsets.zero,
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.45,
      children: [
        for (final (icon, value, label, tone) in items)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: toneColors(context, tone).bg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: toneIconColor(context, tone)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(value, style: context.tt.headlineSmall),
                    Text(label, style: context.tt.bodySmall),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _KindBar extends StatelessWidget {
  const _KindBar({
    required this.label,
    required this.count,
    required this.total,
  });

  final String label;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: context.tt.bodyMedium)),
            Text('$count', style: context.tt.titleSmall),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: total == 0 ? 0 : count / total,
            minHeight: 10,
            backgroundColor: context.tones.hairline,
          ),
        ),
      ],
    ),
  );
}
