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

/// Muro de favores entre vecinos, sin dinero por defecto: se pide, se ofrece, se presta.
/// Los vecinos del muro son de ejemplo; lo que publica la persona queda en su teléfono.
final _wallProvider = Provider<List<WallEntry>>((ref) {
  final offers = ref.watch(offersStreamProvider).value ?? const <Offer>[];
  final needs = ref.watch(needsStreamProvider).value ?? const <Need>[];
  return [
    for (final o in offers)
      WallEntry(
        id: o.id,
        author: 'Tú',
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
        author: 'Tú',
        text: n.text,
        tag: NeedLabels.kind(n.kind),
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
            title: 'Vecinos',
            subtitle: 'Favores, préstamos y ayuda entre vecinos.',
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
                        label: const Text('Pedir algo'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => showOfferSheet(context),
                        icon: const Icon(Icons.volunteer_activism_rounded),
                        label: const Text('Ofrecer'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const BvBanner(
                  icon: Icons.info_outline_rounded,
                  tone: BvTone.sun,
                  message: 'Por ahora los vecinos del muro son de ejemplo. Lo que publiques queda guardado en tu teléfono.',
                ),
                const SizedBox(height: 20),
                BvSegmented<bool>(
                  options: const [
                    (
                      value: true,
                      label: 'Piden',
                      icon: Icons.front_hand_rounded,
                    ),
                    (
                      value: false,
                      label: 'Ofrecen',
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
                        label: const Text('Todas'),
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
                          label: Text(ModalityLabels.name(m)),
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
                          ? 'Nadie pide esto por ahora'
                          : 'Nadie ofrece esto por ahora',
                      message: _requests
                          ? 'Cambia la modalidad o pide tú algo al barrio.'
                          : 'Cambia la modalidad u ofrece tú algo al barrio.',
                      action: OutlinedButton(
                        onPressed: () => setState(() => _modality = null),
                        child: const Text('Ver todas'),
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
    final badge = status == null ? null : syncBadge(status);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BvAvatar(
            entry.author,
            tone: entry.isExample ? BvTone.violet : BvTone.trust,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(entry.author, style: context.tt.titleSmall),
                    ),
                    if (entry.isExample) const BvPill('Ejemplo'),
                  ],
                ),
                const SizedBox(height: 4),
                Text(entry.text, style: context.tt.bodyMedium),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (m != null)
                      BvPill(
                        ModalityLabels.name(m),
                        icon: ModalityLabels.icon(m),
                        tone: ModalityLabels.tone(m),
                      )
                    else if (entry.tag != null)
                      BvPill(
                        entry.tag!,
                        icon: Icons.handshake_rounded,
                        tone: BvTone.violet,
                      ),
                    if (entry.distanceMeters != null)
                      BvPill(
                        'a ${formatDistance(entry.distanceMeters!)} (aprox.)',
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
