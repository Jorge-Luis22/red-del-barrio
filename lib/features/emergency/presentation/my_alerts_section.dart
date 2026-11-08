import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../app/l10n.dart';
import '../../../app/theme/brand.dart';
import '../../../app/ui/components.dart';
import '../../needs/presentation/need_labels.dart';
import '../domain/emergency.dart';
import 'sos_labels.dart';
import 'sos_sheet.dart' show sosIcon;

/// "Mis avisos": lo que la persona pidió, con su estado de envío. No hay respuestas inventadas.
class MyAlertsSection extends ConsumerWidget {
  const MyAlertsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    return ref
        .watch(emergencyPostsStreamProvider)
        .when(
          loading: () => const BvSkeletonRows(count: 1),
          error: (_, _) => BvErrorState(
            message: l.noPudimosLeerTus4,
            onRetry: () => ref.invalidate(emergencyPostsStreamProvider),
          ),
          data: (list) => list.isEmpty
              ? const SizedBox.shrink()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BvSectionTitle(l.misAvisos),
                    const SizedBox(height: 12),
                    BvRows(children: [for (final p in list) _PostRow(post: p)]),
                    const SizedBox(height: 8),
                    Text(
                      l.todaviaNoHayVecinos,
                      style: context.tt.bodySmall?.copyWith(
                        color: context.tones.muted,
                      ),
                    ),
                  ],
                ),
        );
  }
}

class _PostRow extends StatelessWidget {
  const _PostRow({required this.post});

  final EmergencyPost post;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final badge = syncBadge(l, post.syncStatus);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.tones.emergencySoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              sosIcon(post.situation),
              color: context.tones.emergency,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sosLabel(l, post.situation), style: context.tt.titleSmall),
                const SizedBox(height: 2),
                Text(post.text, style: context.tt.bodyMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    BvPill(badge.label, icon: badge.icon, tone: badge.tone),
                    if (post.situation.isPrivate)
                      BvPill(
                        l.privado,
                        icon: Icons.lock_rounded,
                        tone: BvTone.violet,
                      ),
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
