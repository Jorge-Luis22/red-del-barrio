import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../app/l10n.dart';
import '../../../app/theme/brand.dart';
import '../../../app/ui/components.dart';
import '../../assistant/presentation/tr.dart';
import '../../proposals/domain/deal.dart';

/// Evidencia de lo que la persona aportó, calculada de sus tratos cerrados.
/// Solo ella la ve. No hay puntos, puestos ni prioridad.
class HelpSummary {
  const HelpSummary({
    required this.confirmed,
    required this.people,
    required this.averageStars,
    required this.minutes,
  });

  final int confirmed;
  final int people;
  final double? averageStars;
  final int minutes;
}

final helpSummaryProvider = Provider<HelpSummary>((ref) {
  final deals = (ref.watch(dealsStreamProvider).value ?? const <Deal>[]).where(
    (d) => d.status == DealStatus.closed,
  );
  final interactions = ref.watch(interactionsStreamProvider).value ?? const [];
  final stars = interactions.map((i) => i.stars).toList();
  return HelpSummary(
    confirmed: deals.length,
    people: deals.map((d) => d.providerId).toSet().length,
    averageStars: stars.isEmpty
        ? null
        : stars.reduce((a, b) => a + b) / stars.length,
    minutes: deals.fold<int>(0, (sum, d) => sum + (d.duration?.inMinutes ?? 0)),
  );
});

/// Cuatro tarjetas con el resumen de "Tu ayuda al barrio".
class HelpGrid extends StatelessWidget {
  const HelpGrid({super.key, required this.help});

  final HelpSummary help;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final items = [
      (
        Icons.task_alt_rounded,
        '${help.confirmed}',
        l.tratosResueltos,
        BvTone.trust,
      ),
      (
        Icons.groups_rounded,
        '${help.people}',
        l.personasDistintas,
        BvTone.violet,
      ),
      (
        Icons.star_rounded,
        help.averageStars == null ? '—' : help.averageStars!.toStringAsFixed(1),
        l.calificacionQueDiste,
        BvTone.sun,
      ),
      (
        Icons.timer_rounded,
        l.min(help.minutes),
        l.tiempoEnTratos,
        BvTone.coral,
      ),
    ];
    Widget card((IconData, String, String, BvTone) it) {
      final (icon, value, label, tone) = it;
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: toneColors(context, tone).bg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 26, color: toneIconColor(context, tone)),
              const SizedBox(height: 10),
              Text(value, style: context.tt.headlineSmall),
              const SizedBox(height: 2),
              Text(label, style: context.tt.bodySmall),
            ],
          ),
        ),
      );
    }

    Widget pair(int a, int b) => IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [card(items[a]), const SizedBox(width: 10), card(items[b])],
      ),
    );

    return Column(
      children: [
        if (help.confirmed == 0) ...[
          BvBanner(
            icon: Icons.hourglass_empty_rounded,
            tone: BvTone.violet,
            title: tr(
              context,
              'Aún no cierras ningún trato',
              'You have not closed any deal yet',
            ),
            message: tr(
              context,
              'Cuando cierres uno, tu aporte aparecerá aquí.',
              'When you close one, your contribution will show up here.',
            ),
          ),
          const SizedBox(height: 10),
        ],
        pair(0, 1),
        const SizedBox(height: 10),
        pair(2, 3),
      ],
    );
  }
}
