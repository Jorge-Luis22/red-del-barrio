import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../app/theme/brand.dart';
import '../../../app/ui/components.dart';
import '../../../app/ui/sheet.dart';
import '../../../core/result.dart';
import '../../sync/presentation/sync_controller.dart';
import '../domain/emergency.dart';
import '../../../app/l10n.dart';
import 'sos_labels.dart';
import '../../../app/ui/failure_text.dart';

/// "Necesito ayuda": situación → (texto ya escrito) → Enviar aviso. Tres toques.
Future<void> showSosSheet(BuildContext context) =>
    showBvSheet<void>(context, builder: (_) => const _SosSheet());

IconData sosIcon(SosSituation s) => switch (s) {
  SosSituation.earthquake => Icons.vibration_rounded,
  SosSituation.fire => Icons.local_fire_department_rounded,
  SosSituation.medical => Icons.medical_services_rounded,
  SosSituation.elderly => Icons.elderly_rounded,
  SosSituation.violence => Icons.shield_rounded,
};

class _SosSheet extends ConsumerStatefulWidget {
  const _SosSheet();

  @override
  ConsumerState<_SosSheet> createState() => _SosSheetState();
}

class _SosSheetState extends ConsumerState<_SosSheet> {
  SosSituation _situation = SosSituation.medical;
  final TextEditingController _text = TextEditingController();
  bool _textReady = false;
  bool _busy = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // El texto inicial depende del idioma: se prepara una sola vez, ya con el contexto listo.
    if (!_textReady) {
      _textReady = true;
      _text.text = sosTemplate(context.l, _situation);
    }
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _pick(SosSituation s) {
    // Si la persona no tocó el texto, la plantilla acompaña a la situación.
    final l = context.l;
    final untouched = SosSituation.values.any(
      (x) => sosTemplate(l, x) == _text.text,
    );
    setState(() {
      _situation = s;
      if (untouched) _text.text = sosTemplate(l, s);
    });
  }

  Future<void> _send() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final r = await ref.read(publishSosProvider)(
      situation: _situation,
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
        messenger.showSnackBar(
          SnackBar(
            duration: Duration(seconds: 8),
            content: Text(l.tuAvisoQuedoGuardado),
          ),
        );
      case Err(:final failure):
        // El error va dentro de la hoja: un aviso flotante quedaría tapado por ella.
        setState(() {
          _busy = false;
          _error = failureText(context.l, failure);
        });
    }
  }

  @override
  Widget build(BuildContext context) => BvSheetScaffold(
    title: context.l.necesitoAyuda,
    subtitle: context.l.eligeQuePasaEl,
    actionLabel: context.l.enviarAviso,
    actionIcon: Icons.campaign_rounded,
    danger: true,
    busy: _busy,
    onAction: _send,
    children: [
      if (_error != null) ...[
        BvBanner(
          icon: Icons.error_rounded,
          tone: BvTone.emergency,
          title: context.l.noSePudoGuardar,
          message: context.l.siEsUrgenteLlama(_error!),
        ),
        const SizedBox(height: 16),
      ],
      BvBanner(
        icon: Icons.phone_in_talk_rounded,
        tone: BvTone.emergency,
        title: context.l.primeroLosServiciosOficiales,
        message: context.l.siHayPeligroAhora,
      ),
      const SizedBox(height: 20),
      Text(context.l.quePasa, style: context.tt.titleSmall),
      const SizedBox(height: 10),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final s in SosSituation.values)
            Semantics(
              button: true,
              selected: _situation == s,
              label: sosLabel(context.l, s),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _pick(s),
                child: Ink(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: _situation == s
                        ? context.tones.emergencySoft
                        : context.cs.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _situation == s
                          ? context.tones.emergency
                          : context.tones.hairline,
                      width: _situation == s ? 2 : 1.5,
                    ),
                  ),
                  child: ExcludeSemantics(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          sosIcon(s),
                          size: 22,
                          color: context.tones.emergency,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          sosLabel(context.l, s),
                          style: context.tt.labelLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      if (_situation.isPrivate) ...[
        const SizedBox(height: 12),
        BvBanner(
          icon: Icons.lock_rounded,
          tone: BvTone.violet,
          message: context.l.esteAvisoEsPrivado,
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
          labelText: context.l.quePasoPuedesCambiarlo,
        ),
      ),
      Text(
        context.l.tuUbicacionExactaNo,
        style: context.tt.bodySmall?.copyWith(color: context.tones.muted),
      ),
    ],
  );
}
