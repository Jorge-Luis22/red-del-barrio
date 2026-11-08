import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../app/theme/brand.dart';
import '../../../app/ui/components.dart';
import '../../../app/ui/sheet.dart';
import '../../../core/result.dart';
import '../../sync/presentation/sync_controller.dart';
import '../domain/emergency.dart';

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
  late final TextEditingController _text = TextEditingController(
    text: _situation.template,
  );
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _pick(SosSituation s) {
    // Si la persona no tocó el texto, la plantilla acompaña a la situación.
    final untouched = SosSituation.values.any((x) => x.template == _text.text);
    setState(() {
      _situation = s;
      if (untouched) _text.text = s.template;
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
    switch (r) {
      case Ok():
        final messenger = ScaffoldMessenger.of(context);
        Navigator.of(context).pop();
        confirmHaptic(enabled: ref.read(appSettingsProvider).vibration);
        await ref.read(syncControllerProvider.notifier).flushNow();
        messenger.showSnackBar(
          const SnackBar(
            duration: Duration(seconds: 8),
            content: Text(
              'Tu aviso quedó guardado. Si es grave, llama ya a los servicios oficiales.',
            ),
          ),
        );
      case Err(:final failure):
        // El error va dentro de la hoja: un aviso flotante quedaría tapado por ella.
        setState(() {
          _busy = false;
          _error = failure.message;
        });
    }
  }

  @override
  Widget build(BuildContext context) => BvSheetScaffold(
    title: 'Necesito ayuda',
    subtitle: 'Elige qué pasa. El texto ya está escrito: enviar es un toque.',
    actionLabel: 'Enviar aviso',
    actionIcon: Icons.campaign_rounded,
    danger: true,
    busy: _busy,
    onAction: _send,
    children: [
      if (_error != null) ...[
        BvBanner(
          icon: Icons.error_rounded,
          tone: BvTone.emergency,
          title: 'No se pudo guardar el aviso',
          message: '$_error Si es urgente, llama a los servicios oficiales.',
        ),
        const SizedBox(height: 16),
      ],
      BvBanner(
        icon: Icons.phone_in_talk_rounded,
        tone: BvTone.emergency,
        title: 'Primero, los servicios oficiales',
        message: 'Si hay peligro ahora, llama a emergencias antes de usar la app. Los vecinos no reemplazan a Bomberos, Policía ni SAMU.',
      ),
      const SizedBox(height: 20),
      Text('¿Qué pasa?', style: context.tt.titleSmall),
      const SizedBox(height: 10),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final s in SosSituation.values)
            Semantics(
              button: true,
              selected: _situation == s,
              label: s.label,
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
                        Text(s.label, style: context.tt.labelLarge),
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
        const BvBanner(
          icon: Icons.lock_rounded,
          tone: BvTone.violet,
          message:
              'Este aviso es privado: no se muestra en el muro del barrio.',
        ),
      ],
      const SizedBox(height: 16),
      TextField(
        controller: _text,
        minLines: 2,
        maxLines: 4,
        maxLength: 200,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(
          labelText: 'Qué pasó (puedes cambiarlo)',
        ),
      ),
      Text(
        'Tu ubicación exacta no se comparte. Se guarda en tu teléfono y se envía cuando haya internet.',
        style: context.tt.bodySmall?.copyWith(color: context.tones.muted),
      ),
    ],
  );
}
