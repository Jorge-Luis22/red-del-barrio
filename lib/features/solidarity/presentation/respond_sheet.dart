import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../app/l10n.dart';
import '../../../app/theme/brand.dart';
import '../../../app/ui/components.dart';
import '../../../app/ui/sheet.dart';
import '../../../core/result.dart';
import '../../assistant/presentation/tr.dart';
import '../../needs/presentation/need_labels.dart';
import '../../sync/presentation/sync_controller.dart';
import '../domain/offer.dart';
import '../domain/post_response.dart';
import 'wall_text.dart';

/// Texto del botón principal según el tipo de oferta.
String actionLabel(BuildContext context, PostKind k) => switch (k) {
  PostKind.loanOffer => tr(context, 'Pedir prestado', 'Borrow it'),
  PostKind.rentOffer => tr(context, 'Quiero alquilarlo', 'I want to rent it'),
  PostKind.barter || PostKind.barterRequest => tr(
    context,
    'Proponer intercambio',
    'Propose a swap',
  ),
  PostKind.helpFree => tr(context, 'Puedo ayudarte', 'I can help'),
};

IconData actionIcon(PostKind k) => switch (k) {
  PostKind.loanOffer => Icons.handshake_rounded,
  PostKind.rentOffer => Icons.payments_rounded,
  PostKind.barter || PostKind.barterRequest => Icons.swap_horiz_rounded,
  PostKind.helpFree => Icons.volunteer_activism_rounded,
};

String _fieldLabel(BuildContext c, ResponseField f) => switch (f) {
  ResponseField.price => tr(
    c,
    'Cuánto ofreces por día (S/)',
    'What you offer per day (S/)',
  ),
  ResponseField.availability => tr(c, 'Disponibilidad', 'Availability'),
  ResponseField.duration => tr(c, 'Por cuánto tiempo', 'For how long'),
  ResponseField.conditions => tr(c, 'Condiciones', 'Conditions'),
  ResponseField.offeredResource => tr(
    c,
    'Qué ofreces a cambio',
    'What you offer in return',
  ),
  ResponseField.inExchange => tr(
    c,
    'Qué pides a cambio',
    'What you ask in return',
  ),
  ResponseField.coordination => tr(c, 'Cómo coordinamos', 'How we coordinate'),
  ResponseField.message => tr(c, 'Mensaje (opcional)', 'Message (optional)'),
};

String _fieldHint(BuildContext c, ResponseField f) => switch (f) {
  ResponseField.price => tr(c, 'Ej.: 15', 'e.g. 15'),
  ResponseField.availability => tr(
    c,
    'Ej.: hoy en la tarde',
    'e.g. this afternoon',
  ),
  ResponseField.duration => tr(c, 'Ej.: 2 días', 'e.g. 2 days'),
  ResponseField.conditions => tr(
    c,
    'Ej.: lo devuelvo limpio',
    'e.g. I return it clean',
  ),
  ResponseField.inExchange => tr(
    c,
    'Ej.: que me ayudes con el celular',
    'e.g. help with my phone',
  ),
  ResponseField.offeredResource => tr(
    c,
    'Ej.: ayuda con el celular',
    'e.g. help with your phone',
  ),
  ResponseField.coordination => tr(
    c,
    'Ej.: nos vemos en la plaza',
    'e.g. we meet at the square',
  ),
  ResponseField.message => '',
};

/// Formulario de respuesta adaptado al tipo. La publicación queda visible arriba.
Future<void> showRespondSheet(
  BuildContext context,
  WallEntry post,
  PostKind kind,
) => showBvSheet<void>(
  context,
  builder: (_) => _RespondSheet(post: post, kind: kind),
);

/// Estado de una propuesta ya enviada.
Future<void> showResponseStatus(
  BuildContext context,
  WallEntry post,
  PostResponse r,
) => showBvSheet<void>(
  context,
  builder: (ctx) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr(context, 'Tu propuesta', 'Your proposal'),
          style: context.tt.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text(
          '${post.author}: ${wallDemoText(context.l, post.id, post.text)}',
          style: context.tt.bodyMedium,
        ),
        const SizedBox(height: 12),
        BvPanel(
          color: context.tones.violetSoft,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final f in fieldsFor(r.kind))
                if ((r.values[f.name] ?? '').isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text:
                                '${_fieldLabel(context, f).replaceAll(' (opcional)', '').replaceAll(' (optional)', '')}: ',
                            style: context.tt.labelLarge,
                          ),
                          TextSpan(
                            text: f == ResponseField.price
                                ? 'S/ ${r.values[f.name]}'
                                : r.values[f.name],
                            style: context.tt.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Builder(
          builder: (context) {
            final badge = syncBadge(context.l, r.syncStatus);
            return Row(
              children: [
                BvPill(badge.label, icon: badge.icon, tone: badge.tone),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    tr(
                      context,
                      'Esperando la respuesta de ${post.author}. No es una confirmación.',
                      'Waiting for ${post.author} to answer. This is not a confirmation.',
                    ),
                    style: context.tt.bodySmall?.copyWith(
                      color: context.tones.muted,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    ),
  ),
);

class _RespondSheet extends ConsumerStatefulWidget {
  const _RespondSheet({required this.post, required this.kind});

  final WallEntry post;
  final PostKind kind;

  @override
  ConsumerState<_RespondSheet> createState() => _RespondSheetState();
}

class _RespondSheetState extends ConsumerState<_RespondSheet> {
  late final Map<ResponseField, TextEditingController> _c = {
    for (final f in fieldsFor(widget.kind)) f: TextEditingController(),
  };
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _ready =>
      [for (final f in requiredFor(widget.kind)) _c[f]!.text.trim().isNotEmpty]
          .every((v) => v);

  Future<void> _send() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final r = await ref.read(sendPostResponseProvider)(
      widget.post,
      widget.kind,
      {for (final e in _c.entries) e.key: e.value.text},
    );
    if (!mounted) return;
    switch (r) {
      case Ok():
        confirmHaptic(enabled: ref.read(appSettingsProvider).vibration);
        ref.read(syncControllerProvider.notifier).flushNow();
        final messenger = ScaffoldMessenger.of(context);
        final done = tr(context, 'Propuesta guardada', 'Proposal saved');
        Navigator.of(context).pop();
        messenger.showSnackBar(SnackBar(content: Text(done)));
      case Err(:final failure):
        setState(() {
          _busy = false;
          _error = tr(context, failure.message, failure.message);
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    return BvSheetScaffold(
      title: actionLabel(context, widget.kind),
      subtitle:
          '${post.author}: ${wallDemoText(context.l, post.id, post.text)}',
      actionLabel: tr(context, 'Enviar propuesta', 'Send proposal'),
      actionIcon: actionIcon(widget.kind),
      busy: _busy,
      onAction: _ready ? _send : null,
      disabledHint: tr(
        context,
        'Completa los datos con * para enviar.',
        'Fill in the fields marked * to send.',
      ),
      children: [
        for (final f in fieldsFor(widget.kind)) ...[
          TextField(
            controller: _c[f],
            keyboardType: f == ResponseField.price
                ? TextInputType.number
                : TextInputType.text,
            inputFormatters: f == ResponseField.price
                ? [FilteringTextInputFormatter.digitsOnly]
                : null,
            maxLength: f == ResponseField.message ? 200 : 60,
            minLines: f == ResponseField.message ? 2 : 1,
            maxLines: f == ResponseField.message ? 3 : 1,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText:
                  '${_fieldLabel(context, f)}${requiredFor(widget.kind).contains(f) ? ' *' : ''}',
              hintText: _fieldHint(context, f),
              prefixText: f == ResponseField.price ? 'S/ ' : null,
              counterText: '',
              errorText: f == fieldsFor(widget.kind).first ? _error : null,
              errorMaxLines: 2,
            ),
            onChanged: (_) => setState(() => _error = null),
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}
