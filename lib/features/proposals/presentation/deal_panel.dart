import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n.dart';
import '../../../app/theme/brand.dart';
import '../../../app/ui/components.dart';
import '../domain/deal.dart';
import 'deal_stage_cards.dart';
import 'deal_timeline.dart';
import 'price_review.dart';
import 'provider_view_sheet.dart';
import '../../assistant/presentation/tr.dart';

/// Panel del trato: quién es, línea de tiempo y la tarjeta de la etapa en que va.
/// Aceptada → En curso → Falta calificar → Resuelta.
class DealPanel extends ConsumerWidget {
  const DealPanel({super.key, required this.deal});

  final Deal deal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final d = deal;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BvPanel(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              BvAvatar(d.providerName, size: 52),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.providerName, style: context.tt.titleMedium),
                    Text(
                      context.l.trato(d.priceLabel),
                      style: context.tt.bodyMedium?.copyWith(
                        color: context.tones.muted,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                tooltip: context.l.abrirElChatDe,
                onPressed: () => context.push('/mensajes/${d.id}'),
                icon: const Icon(Icons.chat_bubble_rounded),
                style: IconButton.styleFrom(minimumSize: const Size(52, 52)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (d.status != DealStatus.cancelled) ...[
          DealTimeline(current: d.status.index),
          const SizedBox(height: 20),
        ],
        switch (d.status) {
          DealStatus.accepted => MeetingCodeCard(deal: d),
          DealStatus.inProgress => InProgressCard(deal: d),
          DealStatus.awaitingRating => RatingCard(deal: d),
          DealStatus.closed => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClosedSummaryCard(deal: d),
              const SizedBox(height: 16),
              ClientRatingNotice(deal: d),
            ],
          ),
          DealStatus.cancelled => CancelledCard(deal: d),
        },
        if (d.status == DealStatus.inProgress) ...[
          const SizedBox(height: 16),
          PriceReviewSection(deal: d),
        ],
        if (d.status == DealStatus.accepted ||
            d.status == DealStatus.inProgress) ...[
          const SizedBox(height: 12),
          Center(
            child: TextButton.icon(
              onPressed: () => askCancelDeal(context, ref, d),
              style: TextButton.styleFrom(
                foregroundColor: context.tones.emergency,
                minimumSize: const Size(48, 48),
              ),
              icon: const Icon(Icons.cancel_outlined),
              label: Text(tr(context, 'Cancelar trato', 'Cancel deal')),
            ),
          ),
        ],
      ],
    );
  }
}
