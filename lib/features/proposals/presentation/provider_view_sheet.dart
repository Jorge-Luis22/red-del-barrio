import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../app/theme/brand.dart';
import '../../../app/ui/components.dart';
import '../../../app/ui/sheet.dart';
import '../../assistant/presentation/tr.dart';
import '../../reputation/domain/deal_ratings.dart';
import '../../reputation/domain/interaction.dart';
import '../domain/deal.dart';
import 'deal_stage_cards.dart';

String _providerFirstName(Deal d) => d.providerName.split(' ').first;

/// Abre la pantalla de quien prestó el servicio. En esta versión de un solo teléfono
/// es una simulación; con servidor, cada persona verá la suya.
Future<void> showProviderView(BuildContext context, Deal deal) =>
    showBvSheet<void>(context, builder: (_) => ProviderViewSheet(deal: deal));

/// En la pantalla de quien pidió el servicio: avisa que la calificación al cliente la hace
/// la otra persona desde su propia pantalla, y deja abrir esa pantalla para simularlo.
class ClientRatingNotice extends ConsumerWidget {
  const ClientRatingNotice({super.key, required this.deal});

  final Deal deal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = _providerFirstName(deal);
    final all = ref.watch(interactionsStreamProvider).value ?? const [];
    final done = DealRatings.of(deal.id, all).ofClient != null;
    return BvPanel(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr(context, 'Calificación mutua', 'Mutual rating'),
            style: context.tt.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            tr(
              context,
              '$name también te califica a ti, desde su propia pantalla. '
                  'Así la confianza va en los dos sentidos. '
                  'Su calificación hacia ti se mostrará cuando haya cuentas.',
              '$name also rates you, from their own screen. '
                  'Trust goes both ways. '
                  'Their rating of you will show up once there are accounts.',
            ),
            style: context.tt.bodyMedium?.copyWith(color: context.tones.muted),
          ),
          const SizedBox(height: 12),
          if (done) ...[
            BvPill(
              tr(context, '$name ya te calificó', '$name already rated you'),
              icon: Icons.check_circle_rounded,
              tone: BvTone.trust,
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => showProviderView(context, deal),
              icon: const Icon(Icons.science_outlined),
              label: Text(
                tr(
                  context,
                  'Ver como $name (simulación)',
                  'See as $name (simulation)',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pantalla de quien prestó el servicio: cómo lo calificó el cliente y, desde aquí,
/// su calificación al cliente.
class ProviderViewSheet extends ConsumerWidget {
  const ProviderViewSheet({super.key, required this.deal});

  final Deal deal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = _providerFirstName(deal);
    final all = ref.watch(interactionsStreamProvider).value ?? const [];
    final ratings = DealRatings.of(deal.id, all);
    return BvSheetScaffold(
      title: tr(context, 'Vista de $name', "$name's view"),
      subtitle: tr(
        context,
        'Así ve el trato quien prestó el servicio. En esta versión de un solo '
            'teléfono es una simulación; con servidor, cada persona verá su propia pantalla.',
        'This is how the person who did the service sees the deal. In this '
            'single-phone version it is a simulation; with a server, each person will see their own screen.',
      ),
      actionLabel: tr(context, 'Volver a mi pantalla', 'Back to my screen'),
      actionIcon: Icons.arrow_back_rounded,
      onAction: () => Navigator.of(context).pop(),
      children: [
        _ReceivedRatingCard(rating: ratings.ofProvider),
        const SizedBox(height: 16),
        ClientRatingCard(deal: deal),
      ],
    );
  }
}

/// Lo que el cliente calificó a quien prestó el servicio, visto desde su pantalla.
class _ReceivedRatingCard extends StatelessWidget {
  const _ReceivedRatingCard({required this.rating});

  final Interaction? rating;

  @override
  Widget build(BuildContext context) {
    final r = rating;
    return BvPanel(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr(
              context,
              'Cómo te calificó el cliente',
              'How the client rated you',
            ),
            style: context.tt.titleMedium,
          ),
          const SizedBox(height: 12),
          if (r == null)
            Text(
              tr(
                context,
                'Todavía no te calificó.',
                'The client has not rated you yet.',
              ),
              style: context.tt.bodyMedium?.copyWith(
                color: context.tones.muted,
              ),
            )
          else ...[
            Row(
              children: [
                BvStars(value: r.stars, size: 28),
                const SizedBox(width: 10),
                Text('${r.stars} / 5', style: context.tt.titleSmall),
              ],
            ),
            if (r.recommended) ...[
              const SizedBox(height: 8),
              BvPill(
                tr(context, 'Te recomendó', 'Recommended you'),
                icon: Icons.thumb_up_rounded,
                tone: BvTone.trust,
              ),
            ],
            if (r.comment.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(r.comment, style: context.tt.bodyMedium),
            ],
          ],
        ],
      ),
    );
  }
}
