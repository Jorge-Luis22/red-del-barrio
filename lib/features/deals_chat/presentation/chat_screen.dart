import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di/providers.dart';
import '../../../app/theme/brand.dart';
import '../../../app/ui/components.dart';
import '../../../app/ui/sheet.dart';
import '../../../core/result.dart';
import '../../needs/presentation/need_labels.dart';
import '../../proposals/domain/deal.dart';
import '../../proposals/presentation/need_detail_screen.dart';
import '../../sync/presentation/sync_controller.dart';
import '../domain/chat.dart';

/// Chat de un trato. No hay otra persona conectada todavía: lo que escribes se guarda en tu
/// teléfono y NO se inventan respuestas.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.dealId});

  final String dealId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _text = TextEditingController();
  final _scroll = ScrollController();
  bool _sending = false;

  @override
  void dispose() {
    _text.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send([String? phrase]) async {
    final body = (phrase ?? _text.text).trim();
    if (body.isEmpty || _sending) return;
    setState(() => _sending = true);
    final r = await ref.read(sendMessageProvider)(
      dealId: widget.dealId,
      text: body,
    );
    if (!mounted) return;
    setState(() => _sending = false);
    switch (r) {
      case Ok():
        _text.clear();
        confirmHaptic(enabled: ref.read(appSettingsProvider).vibration);
        ref.read(syncControllerProvider.notifier).flushNow();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scroll.hasClients) {
            _scroll.animateTo(
              _scroll.position.maxScrollExtent,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
            );
          }
        });
      case Err(:final failure):
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final deals = ref.watch(dealsStreamProvider).value ?? const <Deal>[];
    Deal? deal;
    for (final d in deals) {
      if (d.id == widget.dealId) deal = d;
    }
    final messages = ref.watch(dealMessagesProvider(widget.dealId));

    if (deal == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const BvEmptyState(
          title: 'No encontramos este trato',
          message: 'Vuelve a Mensajes para ver tus conversaciones.',
        ),
      );
    }

    final current = deal;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            BvAvatar(current.providerName, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    current.providerName,
                    style: context.tt.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Trato: ${dealStatusLabel(current.status)}',
                    style: context.tt.bodySmall?.copyWith(
                      color: context.tones.muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Ver el pedido',
            icon: const Icon(Icons.assignment_outlined),
            onPressed: () => context.push('/need/${current.needId}'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: BvBanner(
                icon: Icons.info_outline_rounded,
                tone: BvTone.sun,
                message:
                    'Todavía no hay cuentas: tus mensajes se guardan en tu teléfono. '
                    'El chat con la otra persona llegará con el servidor.',
              ),
            ),
            Expanded(
              child: messages.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: BvErrorState(
                    message: 'No pudimos leer los mensajes.',
                    onRetry: () =>
                        ref.invalidate(dealMessagesProvider(widget.dealId)),
                  ),
                ),
                data: (list) => list.isEmpty
                    ? const BvEmptyState(
                        title: 'Sin mensajes todavía',
                        message: 'Escribe abajo o toca una frase rápida.',
                      )
                    : ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        itemCount: list.length,
                        itemBuilder: (_, i) => _Bubble(message: list[i]),
                      ),
              ),
            ),
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: quickPhrases.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) => ActionChip(
                  label: Text(quickPhrases[i]),
                  onPressed: () => _send(quickPhrases[i]),
                  labelStyle: context.tt.labelMedium,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _text,
                      minLines: 1,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Escribe un mensaje',
                      ),
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: 'Enviar mensaje',
                    onPressed: _text.text.trim().isEmpty || _sending
                        ? null
                        : _send,
                    icon: const Icon(Icons.send_rounded),
                    style: IconButton.styleFrom(
                      minimumSize: const Size(56, 56),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final badge = syncBadge(message.syncStatus);
    final sent = message.syncStatus.name == 'sent';
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.8,
        ),
        decoration: BoxDecoration(
          color: context.cs.primary,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(6),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.text,
              style: context.tt.bodyMedium?.copyWith(
                color: context.cs.onPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  sent ? Icons.done_rounded : badge.icon,
                  size: 14,
                  color: context.cs.onPrimary.withValues(alpha: 0.85),
                ),
                const SizedBox(width: 4),
                Text(
                  sent ? 'Guardado' : badge.label,
                  style: context.tt.labelSmall?.copyWith(
                    color: context.cs.onPrimary.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
