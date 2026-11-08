import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di/providers.dart';
import '../../../app/theme/brand.dart';
import '../../../app/ui/components.dart';
import '../../../app/ui/section_header.dart';
import '../../needs/presentation/composer_sheet.dart';
import '../../proposals/domain/deal.dart';
import '../../proposals/presentation/deal_providers.dart';
import '../domain/chat.dart';
import '../../../app/l10n.dart';

/// Una conversación por trato: se abre al aceptar una propuesta.
class MensajesScreen extends ConsumerWidget {
  const MensajesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deals = ref.watch(dealsStreamProvider);
    final messages =
        ref.watch(chatMessagesStreamProvider).value ?? const <ChatMessage>[];
    final last = <String, ChatMessage>{for (final m in messages) m.dealId: m};

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          BvSectionHeader(
            title: context.l.mensajes,
            subtitle: context.l.elChatDeCada,
            icon: Icons.chat_bubble_rounded,
            background: context.cs.primary,
            foreground: context.cs.onPrimary,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            child: deals.when(
              loading: () => const BvSkeletonRows(),
              error: (_, _) => BvErrorState(
                message: context.l.noPudimosLeerTus3,
                onRetry: () => ref.invalidate(dealsStreamProvider),
              ),
              data: (list) {
                if (list.isEmpty) {
                  return BvPanel(
                    child: BvEmptyState(
                      title: context.l.aunNoTienesConversaciones,
                      message: context.l.cuandoAceptesUnaPropuesta,
                      action: FilledButton.icon(
                        onPressed: () => showComposer(context),
                        icon: const Icon(Icons.add_circle_rounded),
                        label: Text(context.l.pedirAlgo),
                      ),
                    ),
                  );
                }
                final sorted = [...list]
                  ..sort((a, b) {
                    final ta = last[a.id]?.createdAt ?? a.acceptedAt;
                    final tb = last[b.id]?.createdAt ?? b.acceptedAt;
                    return tb.compareTo(ta);
                  });
                return BvRows(
                  children: [
                    for (final d in sorted)
                      _ConversationRow(
                        deal: d,
                        last: last[d.id],
                        onTap: () => context.push('/mensajes/${d.id}'),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationRow extends ConsumerWidget {
  const _ConversationRow({
    required this.deal,
    required this.last,
    required this.onTap,
  });

  final Deal deal;
  final ChatMessage? last;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final need = ref.watch(needByIdProvider(deal.needId));
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            BvAvatar(deal.providerName, size: 52),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(deal.providerName, style: context.tt.titleSmall),
                  if (need != null)
                    Text(
                      need.text,
                      style: context.tt.bodySmall?.copyWith(
                        color: context.tones.muted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  Text(
                    last == null
                        ? context.l.escribeElPrimerMensaje
                        : context.l.tu2(last!.text),
                    style: context.tt.bodyMedium?.copyWith(
                      fontStyle: last == null
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: context.tones.muted),
          ],
        ),
      ),
    );
  }
}
