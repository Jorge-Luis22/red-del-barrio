import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di/providers.dart';
import '../../../core/result.dart';
import '../../sync/presentation/sync_controller.dart';
import '../domain/need.dart';
import 'need_labels.dart';

/// Abre el formulario de "¿Qué necesitas?".
///
/// Pensado para ≤ 3 toques: abrir → elegir una frase (fija tipo y texto) → Publicar.
/// Con texto propio: abrir → tocar el campo → Publicar (el tipo por defecto es Servicio).
Future<void> showComposer(BuildContext context, {NeedKind? kind, String? text}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => ComposerSheet(initialKind: kind, initialText: text),
  );
}

class ComposerSheet extends ConsumerStatefulWidget {
  const ComposerSheet({super.key, this.initialKind, this.initialText});

  final NeedKind? initialKind;
  final String? initialText;

  @override
  ConsumerState<ComposerSheet> createState() => _ComposerSheetState();
}

class _ComposerSheetState extends ConsumerState<ComposerSheet> {
  late NeedKind _kind = widget.initialKind ?? NeedKind.service;
  Urgency _urgency = Urgency.today;
  late final TextEditingController _text = TextEditingController(text: widget.initialText ?? '');
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await ref.read(publishNeedProvider)(
      kind: _kind,
      text: _text.text,
      urgency: _urgency,
    );
    if (!mounted) return;
    switch (result) {
      case Ok(:final value):
        final router = GoRouter.of(context);
        final messenger = ScaffoldMessenger.of(context);
        Navigator.of(context).pop();
        await ref.read(syncControllerProvider.notifier).flushNow();
        messenger.showSnackBar(const SnackBar(
          duration: Duration(seconds: 6),
          content: Text('Listo: tu pedido quedó guardado. Mira su estado en la siguiente pantalla.'),
        ));
        router.go('/need/${value.id}');
      case Err(:final failure):
        setState(() {
          _busy = false;
          _error = failure.message;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('¿Qué necesitas?', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(
              'Elige una frase o escribe con tus palabras. Tu barrio te propone cómo resolverlo.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            for (final k in NeedKind.values) ...[
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 4),
                child: Row(children: [
                  Icon(NeedLabels.icon(k), size: 20),
                  const SizedBox(width: 8),
                  Text('${NeedLabels.kind(k)} · ${NeedLabels.hint(k)}', style: theme.textTheme.labelLarge),
                ]),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final s in NeedLabels.suggestions(k))
                    ChoiceChip(
                      label: Text(s),
                      selected: _kind == k && _text.text == s,
                      onSelected: (_) => setState(() {
                        _kind = k;
                        _text.text = s;
                      }),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _text,
              minLines: 2,
              maxLines: 4,
              maxLength: 200,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Describe qué necesitas (${NeedLabels.kind(_kind)})',
                border: const OutlineInputBorder(),
                errorText: _error,
              ),
              onChanged: (_) => setState(() => _error = null),
            ),
            const SizedBox(height: 8),
            Text('Tipo', style: theme.textTheme.labelLarge),
            const SizedBox(height: 4),
            Wrap(spacing: 8, children: [
              for (final k in NeedKind.values)
                ChoiceChip(
                  label: Text(NeedLabels.kind(k)),
                  selected: _kind == k,
                  onSelected: (_) => setState(() => _kind = k),
                ),
            ]),
            const SizedBox(height: 12),
            Text('¿Para cuándo lo necesitas?', style: theme.textTheme.labelLarge),
            const SizedBox(height: 4),
            Wrap(spacing: 8, children: [
              for (final u in Urgency.values)
                ChoiceChip(
                  label: Text(NeedLabels.urgency(u)),
                  selected: _urgency == u,
                  onSelected: (_) => setState(() => _urgency = u),
                ),
            ]),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: (_busy || _text.text.trim().length < 3) ? null : _publish,
                child: Text(_busy ? 'Publicando…' : 'Publicar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
