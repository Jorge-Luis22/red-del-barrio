import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../app/theme/brand.dart';
import '../../../app/ui/components.dart';
import '../../../core/result.dart';
import '../../assistant/presentation/tr.dart';
import '../domain/deal.dart';
import '../domain/price_change.dart';

/// "Revisar condiciones": aparece solo con el trato en curso (código validado).
/// Muestra el precio vigente, las contraofertas que quedan (máx. 2) y el historial.
/// El prestador propone el nuevo monto; la persona solo acepta o rechaza.
class PriceReviewSection extends ConsumerWidget {
  const PriceReviewSection({super.key, required this.deal});

  final Deal deal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all =
        (ref.watch(priceChangesStreamProvider).value ?? const <PriceChange>[])
            .where((c) => c.dealId == deal.id)
            .toList();
    final pending = all
        .where((c) => c.status == PriceChangeStatus.pending)
        .firstOrNull;
    final left = maxCounterOffers - all.length;
    final negotiable = deal.priceSoles > 0;
    final muted = context.tt.bodySmall?.copyWith(color: context.tones.muted);

    final status = !negotiable
        ? tr(
            context,
            'Este trato no se negocia por precio.',
            'This deal is not negotiated by price.',
          )
        : pending != null
        ? tr(
            context,
            'Hay una contraoferta pendiente.',
            'There is a pending counteroffer.',
          )
        : left <= 0
        ? tr(
            context,
            'Ya se usaron las $maxCounterOffers contraofertas de este trato.',
            'Both counteroffers for this deal were used.',
          )
        : tr(
            context,
            'Contraofertas disponibles: $left de $maxCounterOffers.',
            'Counteroffers available: $left of $maxCounterOffers.',
          );

    return BvPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr(context, 'Revisar condiciones', 'Review conditions'),
            style: context.tt.titleMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                tr(context, 'Precio vigente: ', 'Current price: '),
                style: context.tt.bodyMedium,
              ),
              Text(
                deal.priceLabel,
                style: context.tt.titleLarge?.copyWith(
                  color: context.cs.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(status, style: context.tt.labelLarge),
          if (pending != null) ...[
            const SizedBox(height: 10),
            _PendingCard(change: pending, deal: deal),
          ] else if (negotiable && left > 0) ...[
            const SizedBox(height: 4),
            Text(
              tr(
                context,
                'El prestador puede proponer un nuevo precio con su motivo. El precio no cambia hasta que tú lo aceptes.',
                'The provider can propose a new price with a reason. The price does not change until you accept.',
              ),
              style: muted,
            ),
          ] else if (negotiable) ...[
            const SizedBox(height: 4),
            Text(
              tr(
                context,
                'Si no hay acuerdo, continúa con el precio vigente o cancela el trato.',
                'If there is no agreement, continue with the current price or cancel the deal.',
              ),
              style: muted,
            ),
          ],
          if (all.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              tr(context, 'Historial de contraofertas', 'Counteroffer history'),
              style: context.tt.titleSmall,
            ),
            for (final c in all)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'S/ ${c.previousPrice} → S/ ${c.newPrice} · ${_status(context, c.status)}\n${tr(context, 'Motivo', 'Reason')}: ${c.reason}',
                  style: context.tt.bodySmall,
                ),
              ),
          ],
          if (negotiable && pending == null && left > 0) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _simulate(context, ref),
              icon: const Icon(Icons.science_outlined),
              label: Text(
                tr(
                  context,
                  'Prueba: el prestador propone otro precio',
                  'Test: the provider proposes another price',
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              tr(
                context,
                'Todavía no hay cuentas de prestador: esto simula su contraoferta.',
                'There are no provider accounts yet: this simulates their counteroffer.',
              ),
              style: muted,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _simulate(BuildContext context, WidgetRef ref) async {
    final newPrice = deal.priceSoles + 10;
    final r = await ref
        .read(counterOfferProvider)
        .propose(
          deal.id,
          by: deal.providerId,
          newPrice: newPrice,
          reason: tr(
            context,
            'El trabajo resultó más largo de lo previsto.',
            'The job turned out longer than expected.',
          ),
        );
    if (!context.mounted) return;
    if (r case Err(:final failure)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }

  static String _status(BuildContext context, PriceChangeStatus s) =>
      switch (s) {
        PriceChangeStatus.pending => tr(context, 'pendiente', 'pending'),
        PriceChangeStatus.accepted => tr(context, 'aceptada', 'accepted'),
        PriceChangeStatus.rejected => tr(context, 'rechazada', 'rejected'),
      };
}

class _PendingCard extends ConsumerWidget {
  const _PendingCard({required this.change, required this.deal});

  final PriceChange change;
  final Deal deal;

  Future<void> _answer(BuildContext context, WidgetRef ref, bool accept) async {
    final r = await ref
        .read(counterOfferProvider)
        .respond(deal.id, change.id, accept: accept);
    if (!context.mounted) return;
    if (r case Err(:final failure)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: context.tones.violetSoft,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr(
            context,
            'El prestador propone S/ ${change.newPrice} (antes S/ ${change.previousPrice})',
            'The provider proposes S/ ${change.newPrice} (was S/ ${change.previousPrice})',
          ),
          style: context.tt.titleSmall,
        ),
        const SizedBox(height: 2),
        Text(
          '${tr(context, 'Motivo', 'Reason')}: ${change.reason}',
          style: context.tt.bodyMedium,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: () => _answer(context, ref, true),
                child: Text(tr(context, 'Aceptar', 'Accept')),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _answer(context, ref, false),
                child: Text(tr(context, 'Rechazar', 'Reject')),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          tr(
            context,
            'Rechazar no tiene penalidad: el trato sigue con el precio vigente.',
            'Rejecting has no penalty: the deal continues at the current price.',
          ),
          style: context.tt.bodySmall?.copyWith(color: context.tones.muted),
        ),
      ],
    ),
  );
}

/// "Cancelar trato": pide el motivo y lo registra. Sin multas ni baja de reputación.
Future<void> askCancelDeal(
  BuildContext context,
  WidgetRef ref,
  Deal deal,
) async {
  final reason = TextEditingController();
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(tr(ctx, 'Cancelar trato', 'Cancel deal')),
      content: TextField(
        controller: reason,
        autofocus: true,
        maxLength: 120,
        decoration: InputDecoration(
          labelText: tr(
            ctx,
            'Motivo de la cancelación',
            'Reason for cancelling',
          ),
          helperText: tr(
            ctx,
            'No hay multas ni se baja la reputación.',
            'No fines and no reputation loss.',
          ),
          helperMaxLines: 2,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(tr(ctx, 'Volver', 'Back')),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: FilledButton.styleFrom(
            backgroundColor: ctx.tones.emergency,
            foregroundColor: ctx.cs.onError,
          ),
          child: Text(tr(ctx, 'Cancelar trato', 'Cancel deal')),
        ),
      ],
    ),
  );
  final text = reason.text;
  reason.dispose();
  if (ok != true || !context.mounted) return;
  final r = await ref.read(cancelDealProvider)(deal.id, reason: text);
  if (!context.mounted) return;
  if (r case Err(:final failure)) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(failure.message)));
  }
}

/// Lo que se ve cuando el trato fue cancelado.
class CancelledCard extends StatelessWidget {
  const CancelledCard({super.key, required this.deal});

  final Deal deal;

  @override
  Widget build(BuildContext context) => BvBanner(
    icon: Icons.cancel_outlined,
    tone: BvTone.neutral,
    title: tr(context, 'Trato cancelado', 'Deal cancelled'),
    message:
        '${tr(context, 'Motivo', 'Reason')}: ${deal.cancelReason ?? ''}\n${tr(context, 'No hay multas ni cambia tu reputación.', 'No fines and your reputation is unchanged.')}',
  );
}
