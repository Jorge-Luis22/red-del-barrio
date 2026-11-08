import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di/providers.dart';
import '../../../app/theme/brand.dart';
import '../../../app/ui/components.dart';
import '../../../core/result.dart';
import '../../sync/presentation/sync_controller.dart';
import '../domain/need.dart';
import 'need_labels.dart';

/// Abre el formulario de "¿Qué necesitas?".
///
/// Pensado para ≤ 3 toques: abrir → elegir una frase (fija tipo y texto) → Publicar.
/// Con texto propio: abrir → tocar el campo → Publicar (el tipo por defecto es Servicio).
Future<void> showComposer(
  BuildContext context, {
  NeedKind? kind,
  String? text,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
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
  late final TextEditingController _text = TextEditingController(
    text: widget.initialText ?? '',
  );
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
        messenger.showSnackBar(
          const SnackBar(
            duration: Duration(seconds: 6),
            content: Text(
              'Listo: tu pedido quedó guardado. Mira su estado en la siguiente pantalla.',
            ),
          ),
        );
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
    final tt = context.tt;
    final canPublish = !_busy && _text.text.trim().length >= 3;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text('¿Qué necesitas?', style: tt.headlineSmall),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Elige una frase o escribe con tus palabras. Tu barrio te propone cómo resolverlo.',
                    style: tt.bodyMedium?.copyWith(color: context.tones.muted),
                  ),
                  const SizedBox(height: 20),
                  _stepLabel(context, '1', 'Qué tipo de ayuda'),
                  const SizedBox(height: 10),
                  _kindGrid(context),
                  const SizedBox(height: 20),
                  _stepLabel(context, '2', 'Elige una frase o escríbelo'),
                  const SizedBox(height: 10),
                  for (final s in NeedLabels.suggestions(_kind))
                    _SuggestionRow(
                      text: s,
                      selected: _text.text == s,
                      onTap: () => setState(() => _text.text = s),
                    ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _text,
                    minLines: 2,
                    maxLines: 4,
                    maxLength: 200,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: 'Con tus palabras (${NeedLabels.kind(_kind)})',
                      errorText: _error,
                    ),
                    onChanged: (_) => setState(() => _error = null),
                  ),
                  const SizedBox(height: 12),
                  _stepLabel(context, '3', '¿Para cuándo lo necesitas?'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final u in Urgency.values)
                        ChoiceChip(
                          label: Text(NeedLabels.urgency(u)),
                          selected: _urgency == u,
                          onSelected: (_) => setState(() => _urgency = u),
                          labelStyle: tt.labelMedium?.copyWith(
                            color: _urgency == u
                                ? context.cs.onPrimary
                                : context.cs.onSurface,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Botón fijo: siempre visible, también con el teclado abierto.
          Container(
            decoration: BoxDecoration(
              color: context.tones.cream,
              border: Border(top: BorderSide(color: context.tones.hairline)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: canPublish ? _publish : null,
                  icon: _busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : const Icon(Icons.send_rounded),
                  label: Text(_busy ? 'Publicando…' : 'Publicar'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepLabel(BuildContext context, String n, String label) => Row(
    children: [
      Container(
        width: 26,
        height: 26,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.cs.primary,
          shape: BoxShape.circle,
        ),
        child: Text(
          n,
          style: context.tt.labelSmall?.copyWith(color: context.cs.onPrimary),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(child: Text(label, style: context.tt.titleSmall)),
    ],
  );

  Widget _kindGrid(BuildContext context) => GridView.count(
    padding: EdgeInsets.zero,
    crossAxisCount: 2,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    mainAxisSpacing: 10,
    crossAxisSpacing: 10,
    childAspectRatio: 1.55,
    children: [
      for (final k in NeedKind.values)
        Semantics(
          button: true,
          selected: _kind == k,
          label: '${NeedLabels.kind(k)}. ${NeedLabels.hint(k)}',
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => setState(() => _kind = k),
            child: Ink(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _kind == k
                    ? toneColors(context, NeedLabels.tone(k)).bg
                    : context.cs.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _kind == k
                      ? context.cs.primary
                      : context.tones.hairline,
                  width: _kind == k ? 2 : 1.5,
                ),
              ),
              child: ExcludeSemantics(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Icon(
                          NeedLabels.icon(k),
                          size: 24,
                          color: toneIconColor(context, NeedLabels.tone(k)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            NeedLabels.kind(k),
                            style: context.tt.titleSmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      NeedLabels.hint(k),
                      style: context.tt.bodySmall?.copyWith(
                        color: context.tones.muted,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
    ],
  );
}

class _SuggestionRow extends StatelessWidget {
  const _SuggestionRow({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: selected ? context.tones.violetSoft : context.cs.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? context.cs.primary : context.tones.hairline,
              width: selected ? 2 : 1.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(child: Text(text, style: context.tt.bodyMedium)),
              const SizedBox(width: 8),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.add_circle_outline_rounded,
                color: selected ? context.cs.primary : context.tones.muted,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
