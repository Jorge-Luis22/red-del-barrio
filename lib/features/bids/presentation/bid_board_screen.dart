import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../app/l10n.dart';
import '../../../app/theme/brand.dart';
import '../../../app/ui/components.dart';
import '../../needs/presentation/need_labels.dart';
import '../../solidarity/presentation/wall_text.dart';
import '../domain/bid.dart';
import 'bid_sheet.dart';
import 'bid_subject.dart';

/// Ofertas de un anuncio, de la mejor a la peor, y el botón para sumar la propia.
/// Venta: gana la oferta más alta. Pedido: gana la propuesta más baja (0 = solidario).
class BidBoardScreen extends ConsumerWidget {
  const BidBoardScreen({super.key, required this.kind, required this.id});

  final BidKind kind;
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final subject = ref.watch(bidSubjectProvider((kind: kind, id: id)));
    final mine = ref.watch(myBidForProvider(id));

    return Scaffold(
      appBar: AppBar(),
      body: subject.when(
        loading: () =>
            const Padding(padding: EdgeInsets.all(16), child: BvSkeletonRows()),
        error: (_, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: BvErrorState(message: l.bidNotFound),
        ),
        data: (s) {
          if (s == null) {
            return BvEmptyState(title: l.bidNotFound, message: '');
          }
          final now = ref.read(clockProvider).now();
          final all = rankBids(kind, [...demoBidsFor(s, now), ?mine]);
          return _Board(subject: s, bids: all, mine: mine);
        },
      ),
      bottomNavigationBar: subject.value == null
          ? null
          : _BottomAction(subject: subject.value!, mine: mine),
    );
  }
}

class _Board extends StatelessWidget {
  const _Board({required this.subject, required this.bids, required this.mine});

  final BidSubject subject;
  final List<Bid> bids;
  final Bid? mine;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final isSale = subject.kind == BidKind.sale;
    final title = isSale
        ? subject.title
        : wallDemoText(l, subject.id, subject.title);
    final rule = isSale
        ? (subject.referenceSoles == null
              ? l.bidRuleHigh
              : l.bidRuleHighRef('S/ ${subject.referenceSoles}'))
        : l.bidRuleLow;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        BvPanel(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: context.tt.headlineSmall),
              if (subject.byline.isNotEmpty && subject.byline != title) ...[
                const SizedBox(height: 4),
                Text(
                  subject.byline,
                  style: context.tt.bodyMedium?.copyWith(
                    color: context.tones.muted,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.gavel_rounded,
                    size: 20,
                    color: context.cs.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      rule,
                      style: context.tt.bodyMedium?.copyWith(
                        color: context.cs.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        BvSectionTitle(
          isSale ? l.bidsTitle(bids.length) : l.proposalsCount(bids.length),
        ),
        const SizedBox(height: 12),
        if (bids.isEmpty)
          BvBanner(
            icon: Icons.hourglass_empty_rounded,
            tone: BvTone.violet,
            message: l.bidNone,
          )
        else
          for (var i = 0; i < bids.length; i++) ...[
            _BidCard(bid: bids[i], isBest: i == 0, isSale: isSale),
            const SizedBox(height: 12),
          ],
        const SizedBox(height: 4),
        Text(
          l.bidDemoNote,
          style: context.tt.bodySmall?.copyWith(color: context.tones.muted),
        ),
      ],
    );
  }
}

class _BidCard extends StatelessWidget {
  const _BidCard({
    required this.bid,
    required this.isBest,
    required this.isSale,
  });

  final Bid bid;
  final bool isBest;
  final bool isSale;

  String _message(AppLocalizations l) {
    if (!bid.isExample) return bid.message;
    return switch ((bid.kind, bid.demoSlot)) {
      (BidKind.sale, 0) => l.bidDemoSale1,
      (BidKind.sale, _) => l.bidDemoSale2,
      (BidKind.request, 0) => l.bidDemoReq1,
      (BidKind.request, _) => l.bidDemoReq2,
    };
  }

  String _when(AppLocalizations l) {
    if (!bid.isExample) return bid.whenText;
    return bid.demoSlot == 0 ? l.bidDemoWhen1 : l.bidDemoWhen2;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final message = _message(l);
    final when = _when(l);
    final status = bid.syncStatus == null
        ? null
        : syncBadge(l, bid.syncStatus!);
    final name = bid.isMine
        ? (bid.bidder.isEmpty ? l.tu : '${l.tu} · ${bid.bidder}')
        : bid.bidder;

    return BvPanel(
      color: bid.isMine ? context.tones.violetSoft : null,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(name, style: context.tt.titleMedium)),
              const SizedBox(width: 8),
              Text(
                'S/ ${bid.amountSoles}',
                style: context.tt.titleLarge?.copyWith(
                  color: context.cs.primary,
                ),
              ),
            ],
          ),
          if (message.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(message, style: context.tt.bodyMedium),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (isBest)
                BvPill(
                  isSale ? l.bidBestOffer : l.bidBestProposal,
                  icon: Icons.emoji_events_rounded,
                  tone: BvTone.trust,
                ),
              if (when.isNotEmpty)
                BvPill(when, icon: Icons.schedule_rounded, tone: BvTone.violet),
              if (status != null)
                BvPill(status.label, icon: status.icon, tone: status.tone),
            ],
          ),
        ],
      ),
    );
  }
}

/// Botón fijo abajo: nunca queda tapado por el contenido ni por el teclado.
class _BottomAction extends StatelessWidget {
  const _BottomAction({required this.subject, required this.mine});

  final BidSubject subject;
  final Bid? mine;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final isSale = subject.kind == BidKind.sale;
    final label = mine != null
        ? (isSale ? l.bidChangeOffer : l.bidChangeProposal)
        : (isSale ? l.bidMakeOffer : l.bidHelpBtn);
    return Container(
      decoration: BoxDecoration(
        color: context.tones.cream,
        border: Border(top: BorderSide(color: context.tones.hairline)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final done = l.bidSaved;
              if (await showBidSheet(
                context,
                subject: subject,
                existing: mine,
              )) {
                messenger.showSnackBar(SnackBar(content: Text(done)));
              }
            },
            icon: const Icon(Icons.gavel_rounded),
            label: Text(label),
          ),
        ),
      ),
    );
  }
}
