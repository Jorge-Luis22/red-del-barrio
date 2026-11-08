import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../app/theme/brand.dart';
import '../../../app/ui/components.dart';
import '../../../app/ui/sheet.dart';
import '../../../core/result.dart';
import '../../sync/presentation/sync_controller.dart';
import '../domain/offer.dart';
import 'modality_labels.dart';
import '../../../app/l10n.dart';
import '../../../app/ui/failure_text.dart';

/// "Ofrecer algo al barrio": modalidad + qué ofreces.
Future<void> showOfferSheet(BuildContext context) =>
    showBvSheet<void>(context, builder: (_) => const _OfferSheet());

class _OfferSheet extends ConsumerStatefulWidget {
  const _OfferSheet();

  @override
  ConsumerState<_OfferSheet> createState() => _OfferSheetState();
}

class _OfferSheetState extends ConsumerState<_OfferSheet> {
  Modality _modality = Modality.free;
  final _text = TextEditingController();
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
    final r = await ref.read(publishOfferProvider)(
      modality: _modality,
      text: _text.text,
    );
    if (!mounted) return;
    final l = context.l;
    switch (r) {
      case Ok():
        final messenger = ScaffoldMessenger.of(context);
        Navigator.of(context).pop();
        confirmHaptic(enabled: ref.read(appSettingsProvider).vibration);
        await ref.read(syncControllerProvider.notifier).flushNow();
        messenger.showSnackBar(SnackBar(content: Text(l.listoTuOfertaQuedo)));
      case Err(:final failure):
        setState(() {
          _busy = false;
          _error = failureText(context.l, failure);
        });
    }
  }

  @override
  Widget build(BuildContext context) => BvSheetScaffold(
    title: context.l.ofrecerAlgoAlBarrio,
    subtitle: context.l.unaHerramientaTuTiempo,
    actionLabel: context.l.publicarOferta,
    actionIcon: Icons.volunteer_activism_rounded,
    busy: _busy,
    onAction: _text.text.trim().length >= 3 ? _publish : null,
    children: [
      Text(context.l.comoLoOfreces, style: context.tt.titleSmall),
      const SizedBox(height: 10),
      Row(
        children: [
          for (final m in Modality.values) ...[
            Expanded(
              child: Semantics(
                button: true,
                selected: _modality == m,
                label: ModalityLabels.name(context.l, m),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => setState(() => _modality = m),
                  child: Ink(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _modality == m
                          ? toneColors(context, ModalityLabels.tone(m)).bg
                          : context.cs.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: _modality == m
                            ? context.cs.primary
                            : context.tones.hairline,
                        width: _modality == m ? 2 : 1.5,
                      ),
                    ),
                    child: ExcludeSemantics(
                      child: Column(
                        children: [
                          Icon(
                            ModalityLabels.icon(m),
                            color: toneIconColor(
                              context,
                              ModalityLabels.tone(m),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            ModalityLabels.name(context.l, m),
                            style: context.tt.labelMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (m != Modality.values.last) const SizedBox(width: 10),
          ],
        ],
      ),
      const SizedBox(height: 6),
      Text(
        ModalityLabels.hint(context.l, _modality),
        style: context.tt.bodySmall?.copyWith(color: context.tones.muted),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: _text,
        minLines: 2,
        maxLines: 4,
        maxLength: 200,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: context.l.queOfreces,
          errorText: _error,
        ),
        onChanged: (_) => setState(() => _error = null),
      ),
    ],
  );
}
