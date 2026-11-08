import 'package:flutter/material.dart';

import '../store.dart';
import '../theme.dart';
import '../util.dart';
import 'moderation.dart';
import 'wall.dart' show plainTitle;

/// Chat de un trato: mensajes, código de encuentro (para quien pidió), confirmar y calificar.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.interactionId});

  final String interactionId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _input = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final String text = _input.text.trim();
    if (text.isEmpty) return;
    _input.clear();
    await store.sendMessage(widget.interactionId, text);
  }

  Future<void> _confirm() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await store.confirmDone(widget.interactionId);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _rate(String otherName) async {
    final String? result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: paper,
      builder: (BuildContext ctx) => _RateSheet(interactionId: widget.interactionId, otherName: otherName),
    );
    if (result != null && mounted) toast(context, result);
  }

  Widget _bubble(Rec m) {
    final String sender = sv(m, 'sender_id');
    final bool system = sender == 'system';
    final bool mine = sender == store.meId;
    if (system) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        child: Text(
          sv(m, 'body'),
          textAlign: TextAlign.center,
          style: const TextStyle(color: muted, fontSize: 13, fontStyle: FontStyle.italic, height: 1.3),
        ),
      );
    }
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: BoxDecoration(
          color: mine ? brand : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: mine ? null : Border.all(color: line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(sv(m, 'body'), style: TextStyle(color: mine ? Colors.white : ink, fontSize: 15.5, height: 1.3)),
            const SizedBox(height: 2),
            Text(
              timeAgo(sv(m, 'created_at')),
              style: TextStyle(color: mine ? Colors.white70 : muted, fontSize: 10.5),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (BuildContext context, Widget? child) {
        final Rec? inter = store.interactionById(widget.interactionId);
        if (inter == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: EmptyState(icon: '💬', title: 'Este chat ya no está')),
          );
        }
        final String my = store.meId ?? '';
        final bool iAmRequester = sv(inter, 'requester_id') == my;
        final String otherId = iAmRequester ? sv(inter, 'provider_id') : sv(inter, 'requester_id');
        final String otherName = store.nameOf(otherId);
        final String status = sv(inter, 'status');
        final Rec? need = store.needById(sv(inter, 'need_id'));
        final int cents = iv(inter, 'price_cents');
        final bool iConfirmed = iv(inter, iAmRequester ? 'confirmed_by_requester' : 'confirmed_by_provider') == 1;
        final bool otherConfirmed = iv(inter, iAmRequester ? 'confirmed_by_provider' : 'confirmed_by_requester') == 1;
        final String? code = iAmRequester ? store.codeFor(sv(inter, 'id')) : null;
        final List<Rec> msgs = store.messagesOf(widget.interactionId);
        final int? myStars = store.myStarsFor(widget.interactionId);
        final bool live = status == 'acordado' || status == 'en_curso';
        final bool done = status == 'completado';

        return Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            title: Row(
              children: <Widget>[
                Avatar(name: otherName, color: store.colorOf(otherId), size: 34),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(otherName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
                ),
              ],
            ),
            actions: <Widget>[
              PersonMenu(
                userId: otherId,
                name: otherName,
                entity: 'interaction',
                entityId: sv(inter, 'id'),
                onBlocked: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          body: Column(
            children: <Widget>[
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            need == null ? 'Trato' : plainTitle(sv(need, 'title')),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w800, color: ink),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(soles(cents), style: const TextStyle(fontWeight: FontWeight.w800, color: brand)),
                        const SizedBox(width: 8),
                        Pill(
                          dealStatusLabel(status),
                          bg: done ? brandSoft : warmSoft,
                          fg: done ? brand : warm,
                        ),
                      ],
                    ),
                    if (code != null && live)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Código de encuentro (solo tú lo ves): $code',
                          style: const TextStyle(color: muted, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                    if (live) ...<Widget>[
                      const SizedBox(height: 8),
                      if (!iConfirmed)
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(minimumSize: const Size(48, 44)),
                            onPressed: _busy ? null : _confirm,
                            icon: const Icon(Icons.check),
                            label: const Text('Ya se hizo el trato'),
                          ),
                        )
                      else
                        Text(
                          otherConfirmed
                              ? 'Las dos partes confirmaron.'
                              : 'Confirmaste. Falta que $otherName también confirme.',
                          style: const TextStyle(color: brand, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                    ],
                    if (done) ...<Widget>[
                      const SizedBox(height: 8),
                      if (myStars == null)
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(minimumSize: const Size(48, 44), backgroundColor: warm),
                            onPressed: () => _rate(otherName),
                            icon: const Icon(Icons.star_outline),
                            label: Text('Calificar a $otherName'),
                          ),
                        )
                      else
                        Text(
                          'Tu calificación: ${'★' * myStars}${'☆' * (5 - myStars)}',
                          style: const TextStyle(color: warm, fontWeight: FontWeight.w700),
                        ),
                    ],
                  ],
                ),
              ),
              const Divider(height: 1, color: line),
              Expanded(
                child: msgs.isEmpty
                    ? const Center(child: Text('Escribe el primer mensaje.', style: TextStyle(color: muted)))
                    : ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                        itemCount: msgs.length,
                        itemBuilder: (BuildContext _, int index) => _bubble(msgs[msgs.length - 1 - index]),
                      ),
              ),
              if (status != 'cancelado')
                SafeArea(
                  top: false,
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: _input,
                            minLines: 1,
                            maxLines: 4,
                            maxLength: 1000,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(hintText: 'Escribe un mensaje', counterText: ''),
                          ),
                        ),
                        const SizedBox(width: 6),
                        IconButton.filled(
                          tooltip: 'Enviar',
                          onPressed: _send,
                          icon: const Icon(Icons.send),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _RateSheet extends StatefulWidget {
  const _RateSheet({required this.interactionId, required this.otherName});

  final String interactionId;
  final String otherName;

  @override
  State<_RateSheet> createState() => _RateSheetState();
}

class _RateSheetState extends State<_RateSheet> {
  int _stars = 5;
  final TextEditingController _comment = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_busy) return;
    setState(() => _busy = true);
    await store.rate(widget.interactionId, _stars, _comment.text);
    if (mounted) Navigator.of(context).pop('Gracias por calificar a ${widget.otherName}.');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '¿Cómo te fue con ${widget.otherName}?',
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: ink),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                for (int i = 1; i <= 5; i++)
                  IconButton(
                    tooltip: '$i ${i == 1 ? 'estrella' : 'estrellas'}',
                    iconSize: 40,
                    onPressed: () => setState(() => _stars = i),
                    icon: Icon(i <= _stars ? Icons.star : Icons.star_border, color: warm),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _comment,
              minLines: 2,
              maxLines: 4,
              maxLength: 200,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'Comentario (opcional)'),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _busy ? null : _send,
                child: Text(_busy ? 'Enviando…' : 'Enviar calificación'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
