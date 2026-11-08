import 'package:flutter/material.dart';

import '../catalog.dart';
import '../store.dart';
import '../theme.dart';
import '../util.dart';
import 'chat.dart';
import 'moderation.dart';
import 'wall.dart' show plainTitle;

/// Un pedido del muro: detalle, propuestas (si es tuyo) y formulario para ayudar (si es de otro).
class NeedDetailScreen extends StatefulWidget {
  const NeedDetailScreen({super.key, required this.needId});

  final String needId;

  @override
  State<NeedDetailScreen> createState() => _NeedDetailScreenState();
}

class _NeedDetailScreenState extends State<NeedDetailScreen> {
  final TextEditingController _price = TextEditingController();
  final TextEditingController _message = TextEditingController();
  final TextEditingController _eta = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _price.dispose();
    _message.dispose();
    _eta.dispose();
    super.dispose();
  }

  void _openChat(String interactionId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (BuildContext _) => ChatScreen(interactionId: interactionId)),
    );
  }

  Future<void> _sendProposal(Rec need) async {
    if (_busy) return;
    final bool free = isFreeCategory(sv(need, 'category'));
    final double? value = double.tryParse(_price.text.trim().replaceAll(',', '.'));
    if (!free && value == null) {
      toast(context, 'Escribe cuánto cobrarías (o 0 si es gratis).');
      return;
    }
    final double amount = value ?? 0;
    final int cents = free ? 0 : (amount.clamp(0, 99999).toDouble() * 100).round();
    setState(() => _busy = true);
    try {
      await store.createProposal(
        needId: sv(need, 'id'),
        priceCents: cents,
        message: _message.text.length > 300 ? _message.text.substring(0, 300) : _message.text,
        eta: _eta.text,
      );
      _price.clear();
      _message.clear();
      _eta.clear();
      if (mounted) toast(context, 'Propuesta enviada. Te avisamos aquí cuando la acepten.');
    } catch (_) {
      if (mounted) toast(context, 'No se pudo enviar. Inténtalo otra vez.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _accept(Rec proposal) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final String code = await store.acceptProposal(sv(proposal, 'id'));
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (BuildContext ctx) => AlertDialog(
          title: const Text('Trato acordado'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('Tu código de encuentro es:'),
              const SizedBox(height: 8),
              Text(code, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, letterSpacing: 6, color: brand)),
              const SizedBox(height: 8),
              const Text(
                'Dícelo a la persona cuando se encuentren, así saben que son ustedes. '
                'Solo tú lo ves. Después coordinen la hora y el lugar en el chat.',
              ),
            ],
          ),
          actions: <Widget>[
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(48, 44)),
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
    } on StateError catch (e) {
      if (mounted) toast(context, e.message);
    } catch (_) {
      if (mounted) toast(context, 'No se pudo aceptar. Inténtalo otra vez.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _close(Rec need) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('¿Cerrar este pedido?'),
        content: const Text('Dejará de aparecer en el muro. Ya no recibirás más propuestas.'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('No')),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(48, 44)),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sí, cerrar'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await store.closeNeed(sv(need, 'id'));
      if (mounted) Navigator.of(context).pop();
    }
  }

  Widget _proposalCard(Rec p, {required bool owner, required bool canAccept}) {
    final String providerId = sv(p, 'provider_id');
    final String status = sv(p, 'status');
    final int cents = iv(p, 'price_cents');
    final String msg = sv(p, 'message');
    final String eta = sv(p, 'eta');
    final LevelInfo level = store.levelOf(providerId);
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Avatar(name: store.nameOf(providerId), color: store.colorOf(providerId), size: 36),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      owner ? store.nameOf(providerId) : 'Tu propuesta',
                      style: const TextStyle(fontWeight: FontWeight.w800, color: ink),
                    ),
                    Text(level.name, style: const TextStyle(color: muted, fontSize: 12)),
                  ],
                ),
              ),
              Text(soles(cents), style: const TextStyle(fontWeight: FontWeight.w800, color: brand, fontSize: 16)),
            ],
          ),
          if (msg.isNotEmpty) ...<Widget>[const SizedBox(height: 8), Text(msg)],
          if (eta.isNotEmpty) ...<Widget>[
            const SizedBox(height: 4),
            Text('Disponible: $eta', style: const TextStyle(color: muted, fontSize: 13)),
          ],
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Pill(
                status == 'aceptada' ? 'Aceptada' : (status == 'rechazada' ? 'Rechazada' : 'Enviada'),
                bg: status == 'aceptada' ? brandSoft : const Color(0xFFEFEDE6),
                fg: status == 'aceptada' ? brand : muted,
              ),
              const Spacer(),
              if (owner && canAccept && status == 'enviada')
                FilledButton(
                  style: FilledButton.styleFrom(minimumSize: const Size(48, 44)),
                  onPressed: _busy ? null : () => _accept(p),
                  child: const Text('Aceptar'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _proposalForm(Rec need) {
    final bool free = isFreeCategory(sv(need, 'category'));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SectionLabel('Quiero ayudar'),
        if (!free) ...<Widget>[
          const Text('¿Cuánto cobrarías? (en soles, 0 si es gratis)', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: _price,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(prefixText: 'S/ ', hintText: '0.00'),
          ),
          const SizedBox(height: 12),
        ],
        const Text('Tu mensaje (opcional)', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: _message,
          minLines: 2,
          maxLines: 4,
          maxLength: 300,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'Ej. Puedo ir con mis herramientas'),
        ),
        const Text('¿Cuándo puedes? (opcional)', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (final String e in const <String>['Ahora mismo', 'Hoy', 'Mañana', 'Esta semana'])
              ChoiceChipBtn(label: e, on: _eta.text == e, onTap: () => setState(() => _eta.text = _eta.text == e ? '' : e)),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _busy ? null : () => _sendProposal(need),
            child: Text(_busy ? 'Enviando…' : 'Enviar propuesta'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (BuildContext context, Widget? child) {
        final Rec? need = store.needById(widget.needId);
        if (need == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: EmptyState(icon: '🔍', title: 'Este pedido ya no está')),
          );
        }
        final String id = sv(need, 'id');
        final String authorId = sv(need, 'author_id');
        final bool owner = authorId == store.meId;
        final String status = sv(need, 'status');
        final bool open = status == 'abierta';
        final Rec? deal = store.dealForNeed(id);
        final bool iAmProvider = deal != null && sv(deal, 'provider_id') == store.meId;
        final bool iAmRequester = deal != null && sv(deal, 'requester_id') == store.meId;
        final List<Rec> all = store.proposalsFor(id);
        final List<Rec> mineProposals = all.where((Rec p) => sv(p, 'provider_id') == store.meId).toList();
        final String? dir = directionOf(sv(need, 'title'));
        final String description = sv(need, 'description');
        final LevelInfo authorLevel = store.levelOf(authorId);
        final Stats authorStats = store.statsOf(authorId);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Pedido'),
            actions: <Widget>[
              PersonMenu(
                userId: authorId,
                name: store.nameOf(authorId),
                entity: 'need',
                entityId: id,
                onBlocked: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: <Widget>[
              Wrap(
                spacing: 6,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  if (dir == 'ofrezco') const Pill('Ofrece', bg: warmSoft, fg: warm) else const Pill('Necesita'),
                  Pill(needLabel[sv(need, 'type')] ?? sv(need, 'type'), bg: const Color(0xFFEFEDE6), fg: muted),
                  Pill(
                    status == 'abierta' ? 'Abierto' : (status == 'en_curso' ? 'En curso' : 'Cerrado'),
                    bg: open ? brandSoft : warmSoft,
                    fg: open ? brand : warm,
                  ),
                  Text(timeAgo(sv(need, 'created_at')), style: const TextStyle(color: muted, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 10),
              Text(plainTitle(sv(need, 'title')), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: ink)),
              if (description.isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                Text(description, style: const TextStyle(fontSize: 16, height: 1.4, color: ink)),
              ],
              const SizedBox(height: 6),
              Text(
                '📍 ${sv(need, 'zone').isEmpty ? 'Zona aproximada' : sv(need, 'zone')}',
                style: const TextStyle(color: muted, fontSize: 13),
              ),
              const SizedBox(height: 14),
              Panel(
                child: Row(
                  children: <Widget>[
                    Avatar(name: store.nameOf(authorId), color: store.colorOf(authorId)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            owner ? '${store.nameOf(authorId)} (tú)' : store.nameOf(authorId),
                            style: const TextStyle(fontWeight: FontWeight.w800, color: ink, fontSize: 16),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${authorLevel.name} · ${authorStats.helps} ${authorStats.helps == 1 ? 'ayuda' : 'ayudas'}'
                            '${authorStats.avgStars == null ? '' : ' · ★ ${authorStats.avgStars!.toStringAsFixed(1)}'}',
                            style: const TextStyle(color: muted, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (deal != null && (owner || iAmProvider)) ...<Widget>[
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _openChat(sv(deal, 'id')),
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: Text(iAmRequester ? 'Abrir chat del trato' : 'Abrir chat con ${store.nameOf(authorId)}'),
                  ),
                ),
                const SizedBox(height: 6),
              ],
              if (owner) ...<Widget>[
                SectionLabel('Propuestas', hint: all.isEmpty ? '' : '(${all.length})'),
                if (all.isEmpty)
                  const Panel(
                    child: Text(
                      'Todavía nadie propuso. Cuando un vecino ofrezca ayuda, aparecerá aquí.',
                      style: TextStyle(color: muted),
                    ),
                  )
                else
                  for (final Rec p in all) _proposalCard(p, owner: true, canAccept: open && deal == null),
                if (deal == null && (open || status == 'en_curso')) ...<Widget>[
                  const SizedBox(height: 6),
                  OutlinedButton(onPressed: () => _close(need), child: const Text('Cerrar este pedido')),
                ],
              ] else ...<Widget>[
                if (mineProposals.isNotEmpty) ...<Widget>[
                  const SectionLabel('Tu propuesta'),
                  for (final Rec p in mineProposals) _proposalCard(p, owner: false, canAccept: false),
                ] else if (open) ...<Widget>[
                  _proposalForm(need),
                ] else
                  const Panel(
                    child: Text('Este pedido ya no recibe propuestas.', style: TextStyle(color: muted)),
                  ),
                if (all.isNotEmpty && !owner)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      all.length == 1 ? '1 vecino ya propuso.' : '${all.length} vecinos ya propusieron.',
                      style: const TextStyle(color: muted, fontSize: 13),
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}
