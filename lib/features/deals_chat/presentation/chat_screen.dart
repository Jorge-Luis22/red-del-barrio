import 'dart:io';

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
import '../domain/photo_message.dart';
import '../../needs/presentation/need_extras_widgets.dart';
import '../../../app/l10n.dart';
import 'quick_phrases.dart';
import '../../../app/ui/failure_text.dart';
import '../../assistant/domain/safety_guard.dart';
import '../../assistant/presentation/assistant_widgets.dart';
import '../../assistant/presentation/quechua_sheet.dart';
import '../../assistant/presentation/tr.dart';
import '../../meeting/domain/meeting_point.dart';
import '../../meeting/presentation/meeting_map.dart';

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

  Future<void> _send([String? phrase, bool trusted = false]) async {
    final body = (phrase ?? _text.text).trim();
    if (body.isEmpty || _sending) return;
    final flags = trusted ? <SafetyFlag>[] : const SafetyGuard().scan(body);
    if (flags.isNotEmpty) {
      final ok = await confirmSafety(context, flags);
      if (ok != true || !mounted) return;
    }
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failureText(context.l, failure))),
        );
    }
  }

  Future<void> _pickMeeting() async {
    final point = await showMeetingPicker(context);
    if (point == null || !mounted) return;
    await _send(point.toMessage(), true);
  }

  Future<void> _pickPhoto() async {
    final source = await askPhotoSource(context);
    if (source == null || !mounted) return;
    final path = await pickPhotoToAppFolder(context, source, 'foto_chat');
    if (path == null || !mounted) return;
    await _send(photoMessage(path), true);
  }

  Future<void> _pickQuechua() async {
    final phrase = await showQuechuaSheet(context);
    if (phrase == null || !mounted) return;
    final current = _text.text.trim();
    final text = current.isEmpty ? phrase : '$current $phrase';
    setState(() {
      _text.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    });
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
        body: BvEmptyState(
          title: context.l.noEncontramosEsteTrato,
          message: context.l.vuelveAMensajesPara,
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
                    context.l.trato(dealStatusLabel(context.l, current.status)),
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
            tooltip: context.l.verElPedido,
            icon: const Icon(Icons.assignment_outlined),
            onPressed: () => context.push('/need/${current.needId}'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: BvBanner(
                icon: Icons.info_outline_rounded,
                tone: BvTone.sun,
                message: context.l.todaviaNoHayCuentas2,
              ),
            ),
            Expanded(
              child: messages.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: BvErrorState(
                    message: context.l.noPudimosLeerLos,
                    onRetry: () =>
                        ref.invalidate(dealMessagesProvider(widget.dealId)),
                  ),
                ),
                data: (list) => list.isEmpty
                    ? BvEmptyState(
                        title: context.l.sinMensajesTodavia,
                        message: context.l.escribeAbajoOToca,
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
                itemCount: quickPhrases(context.l).length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) => ActionChip(
                  label: Text(quickPhrases(context.l)[i]),
                  onPressed: () => _send(quickPhrases(context.l)[i]),
                  labelStyle: context.tt.labelMedium,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    tooltip: tr(
                      context,
                      'Proponer lugar de encuentro',
                      'Suggest a meeting place',
                    ),
                    onPressed: _pickMeeting,
                    icon: const Icon(Icons.place_rounded),
                    style: IconButton.styleFrom(
                      minimumSize: const Size(48, 56),
                    ),
                  ),
                  IconButton(
                    tooltip: tr(context, 'Enviar una foto', 'Send a photo'),
                    onPressed: _pickPhoto,
                    icon: const Icon(Icons.photo_camera_rounded),
                    style: IconButton.styleFrom(
                      minimumSize: const Size(48, 56),
                    ),
                  ),
                  IconButton(
                    tooltip: tr(
                      context,
                      'Frases en quechua',
                      'Quechua phrases',
                    ),
                    onPressed: _pickQuechua,
                    icon: const Icon(Icons.translate_rounded),
                    style: IconButton.styleFrom(
                      minimumSize: const Size(48, 56),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _text,
                      minLines: 1,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: context.l.escribeUnMensaje,
                      ),
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: context.l.enviarMensaje,
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
    final badge = syncBadge(context.l, message.syncStatus);
    final sent = message.syncStatus.name == 'sent';
    final point = MeetingPoint.tryParse(message.text);
    final photo = photoPathOf(message.text);
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
            if (photo != null)
              GestureDetector(
                onTap: () => showDialog<void>(
                  context: context,
                  builder: (_) => Dialog(
                    child: InteractiveViewer(child: Image.file(File(photo))),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(photo),
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Text(
                      tr(context, '📷 Foto no disponible', '📷 Photo unavailable'),
                      style: context.tt.bodyMedium?.copyWith(
                        color: context.cs.onPrimary,
                      ),
                    ),
                  ),
                ),
              )
            else if (point == null)
              Text(
                message.text,
                style: context.tt.bodyMedium?.copyWith(
                  color: context.cs.onPrimary,
                ),
              )
            else ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.place_rounded,
                    size: 20,
                    color: context.cs.onPrimary,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      tr(
                        context,
                        'Punto de encuentro: ${point.label}',
                        'Meeting point: ${point.label}',
                      ),
                      style: context.tt.bodyMedium?.copyWith(
                        color: context.cs.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () => showMeetingViewer(context, point),
                icon: Icon(Icons.map_rounded, color: context.cs.onPrimary),
                label: Text(
                  tr(context, 'Ver en el mapa', 'View on map'),
                  style: TextStyle(color: context.cs.onPrimary),
                ),
              ),
            ],
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
                  sent ? context.l.guardado : badge.label,
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
