import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../app/l10n.dart';
import '../../../app/theme/brand.dart';
import '../../../app/ui/components.dart';
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
