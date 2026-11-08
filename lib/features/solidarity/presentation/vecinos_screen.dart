import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../app/theme/brand.dart';
import '../../../app/ui/components.dart';
import '../../../app/ui/section_header.dart';
import '../../../core/geo/geo_math.dart';
import '../../needs/domain/need.dart';
import '../../needs/presentation/composer_sheet.dart';
import '../../needs/presentation/need_labels.dart';
import '../domain/offer.dart';
import '../domain/wall_demo.dart';
import 'modality_labels.dart';
import 'offer_sheet.dart';
import '../../../app/l10n.dart';

/// Muro de favores entre vecinos, sin dinero por defecto: se pide, se ofrece, se presta.
/// Los vecinos del muro son de ejemplo; lo que publica la persona queda en su teléfono.
final _wallProvider = Provider<List<WallEntry>>((ref) {
  final offers = ref.watch(offersStreamProvider).value ?? const <Offer>[];
  final needs = ref.watch(needsStreamProvider).value ?? const <Need>[];
  return [
    for (final o in offers)
      WallEntry(
        id: o.id,
        author: '',
        text: o.text,
        modality: o.modality,
        isRequest: false,
        isExample: false,
        syncStatus: o.syncStatus,
      ),
    for (final n in needs.where(
      (n) => n.kind == NeedKind.loan || n.kind == NeedKind.help,
    ))
      WallEntry(
        id: n.id,
        author: '',
        text: n.text,
        tag: n.kind.name,
        isRequest: true,
        isExample: false,
        syncStatus: n.syncStatus,
      ),
    ...demoWall,
  ];
});

class VecinosScreen extends ConsumerStatefulWidget {
  const VecinosScreen({super.key});

  @override
  ConsumerState<VecinosScreen> createState() => _VecinosScreenState();
}

class _VecinosScreenState extends ConsumerState<VecinosScreen> {
  bool _requests = true;
  Modality? _modality;

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(_wallProvider);
    final shown = all
        .where(
          (e) =>
              e.isRequest == _requests &&
              (_modality == null || e.modality == _modality),
        )
        .toList();

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          BvSectionHeader(
            title: context.l.vecinos,
            subtitle: context.l.favoresPrestamosYAyuda,
            icon: Icons.diversity_3_rounded,
            background: context.tones.coral,
            foreground: context.cs.onSecondary,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () =>
                            showComposer(context, kind: NeedKind.loan),
                        icon: const Icon(Icons.front_hand_rounded),
                        label: Text(context.l.pedirAlgo),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => showOfferSheet(context),
                        icon: const Icon(Icons.volunteer_activism_rounded),
                        label: Text(context.l.ofrecer),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                BvBanner(
                  icon: Icons.info_outline_rounded,
                  tone: BvTone.sun,
                  message: context.l.porAhoraLosVecinos,
                ),
                const SizedBox(height: 20),
                BvSegmented<bool>(
                  options: [
                    (
                      value: true,
                      label: context.l.piden,
                      icon: Icons.front_hand_rounded,
                    ),
                    (
                      value: false,
                      label: context.l.ofrecen,
                      icon: Icons.volunteer_activism_rounded,
                    ),
                  ],
                  selected: _requests,
                  onChanged: (v) => setState(() => _requests = v),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ChoiceChip(
                        label: Text(context.l.todas),
                        selected: _modality == null,
                        onSelected: (_) => setState(() => _modality = null),
                        labelStyle: context.tt.labelMedium?.copyWith(
                          color: _modality == null
                              ? context.cs.onPrimary
                              : context.cs.onSurface,
                        ),
                      ),
                      for (final m in Modality.values) ...[
                        const SizedBox(width: 8),
                        ChoiceChip(
                          avatar: Icon(
                            ModalityLabels.icon(m),
                            size: 18,
                            color: _modality == m
                                ? context.cs.onPrimary
                                : context.cs.primary,
                          ),
                          label: Text(ModalityLabels.name(context.l, m)),
                          selected: _modality == m,
                          onSelected: (_) => setState(() => _modality = m),
                          labelStyle: context.tt.labelMedium?.copyWith(
                            color: _modality == m
                                ? context.cs.onPrimary
                                : context.cs.onSurface,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                if (shown.isEmpty)
                  BvPanel(
                    child: BvEmptyState(
                      title: _requests
                          ? context.l.nadiePideEstoPor
                          : context.l.nadieOfreceEstoPor,
                      message: _requests
                          ? context.l.cambiaLaModalidadO
                          : context.l.cambiaLaModalidadU,
                      action: OutlinedButton(
                        onPressed: () => setState(() => _modality = null),
                        child: Text(context.l.verTodas),
                      ),
                    ),
                  )
                else
                  BvRows(children: [for (final e in shown) _WallRow(entry: e)]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WallRow extends StatelessWidget {
  const _WallRow({required this.entry});

  final WallEntry entry;

  @override
  Widget build(BuildContext context) {
    final m = entry.modality;
    final status = entry.syncStatus;
    final badge = status == null ? null : syncBadge(context.l, status);
    final author = status != null ? context.l.tu : entry.author;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BvAvatar(
            author,
            tone: entry.isExample ? BvTone.violet : BvTone.trust,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(author, style: context.tt.titleSmall)),
                    if (entry.isExample) BvPill(context.l.ejemplo),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  entry.isExample ? _demoText(context.l, entry) : entry.text,
                  style: context.tt.bodyMedium,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (m != null)
                      BvPill(
                        ModalityLabels.name(context.l, m),
                        icon: ModalityLabels.icon(m),
                        tone: ModalityLabels.tone(m),
                      )
                    else if (entry.tag != null)
                      BvPill(
                        NeedLabels.kind(
                          context.l,
                          NeedKind.values.byName(entry.tag!),
                        ),
                        icon: Icons.handshake_rounded,
                        tone: BvTone.violet,
                      ),
                    if (entry.distanceMeters != null)
                      BvPill(
                        context.l.aAprox(formatDistance(entry.distanceMeters!)),
                        icon: Icons.near_me_rounded,
                      ),
                    if (badge != null)
                      BvPill(badge.label, icon: badge.icon, tone: badge.tone),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Los mensajes de ejemplo del muro se traducen; lo que escribe la persona se muestra tal cual.
String _demoText(AppLocalizations l, WallEntry e) => switch (e.id) {
  'w1' => l.wall1,
  'w2' => l.wall2,
  'w3' => l.wall3,
  'w4' => l.wall4,
  'w5' => l.wall5,
  'w6' => l.wall6,
  _ => e.text,
};
