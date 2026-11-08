import 'package:flutter/material.dart';

import '../../../app/l10n.dart';
import '../../../app/theme/brand.dart';
import '../../../app/ui/components.dart';
import '../../needs/domain/need.dart';
import '../../needs/presentation/need_labels.dart';
import '../domain/request_assistant.dart';
import '../domain/safety_guard.dart';
import 'tr.dart';

/// Sugerencia del asistente de pedido: propone tipo, plazo y un texto ordenado.
class RequestSuggestionCard extends StatelessWidget {
  const RequestSuggestionCard({
    super.key,
    required this.suggestion,
    required this.onApply,
  });

  final RequestSuggestion suggestion;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final s = suggestion;
    final kind = NeedLabels.kind(context.l, s.kind);
    final trade = s.trade == null ? '' : ' · ${s.trade}';
    final when = s.urgency == null
        ? ''
        : ' · ${NeedLabels.urgency(context.l, s.urgency!)}';
    return BvBanner(
      icon: Icons.tips_and_updates_rounded,
      tone: BvTone.violet,
      title: tr(context, 'Asistente del pedido', 'Request assistant'),
      message: tr(
        context,
        'Parece: $kind$trade$when. Puedes aplicarlo con un toque.',
        'Looks like: $kind$trade$when. Apply it with one tap.',
      ),
      action: Align(
        alignment: Alignment.centerLeft,
        child: FilledButton.tonal(
          onPressed: onApply,
          child: Text(tr(context, 'Aplicar sugerencia', 'Apply suggestion')),
        ),
      ),
    );
  }
}

/// Texto del aviso de cada riesgo.
String safetyMessage(BuildContext context, SafetyFlag f) => switch (f) {
  SafetyFlag.phone => tr(
    context,
    'Parece un número de teléfono. Mejor coordinen dentro de la app.',
    'Looks like a phone number. Better to coordinate inside the app.',
  ),
  SafetyFlag.idNumber => tr(
    context,
    'Parece un número de documento (DNI). No lo compartas.',
    'Looks like an ID number. Do not share it.',
  ),
  SafetyFlag.email => tr(
    context,
    'Incluye un correo electrónico. Evita compartir datos de contacto.',
    'Includes an email address. Avoid sharing contact details.',
  ),
  SafetyFlag.exactAddress => tr(
    context,
    'Parece una dirección exacta. Comparte solo la zona; la dirección, cuando se encuentren.',
    'Looks like an exact address. Share only the area; the address, when you meet.',
  ),
  SafetyFlag.advancePayment => tr(
    context,
    'Habla de pagos por adelantado o transferencias. Paga solo cuando el servicio esté hecho y en persona.',
    'Mentions advance payments or transfers. Pay only after the service is done, in person.',
  ),
  SafetyFlag.secretCode => tr(
    context,
    'Habla de códigos o claves. Nunca compartas claves; el código de encuentro se dice en persona.',
    'Mentions codes or passwords. Never share passwords; the meeting code is said in person.',
  ),
  SafetyFlag.externalLink => tr(
    context,
    'Incluye un enlace externo. Desconfía de enlaces desconocidos.',
    'Includes an external link. Be wary of unknown links.',
  ),
};

/// Aviso de seguridad (no bloquea: la persona decide).
class SafetyWarning extends StatelessWidget {
  const SafetyWarning({super.key, required this.flags});

  final List<SafetyFlag> flags;

  @override
  Widget build(BuildContext context) => BvBanner(
    icon: Icons.shield_outlined,
    tone: BvTone.sun,
    title: tr(context, 'Cuidado con tus datos', 'Take care with your data'),
    message: flags.map((f) => '• ${safetyMessage(context, f)}').join('\n'),
  );
}

/// Pregunta antes de publicar o enviar un texto con riesgos. `true` = enviar igual.
Future<bool?> confirmSafety(BuildContext context, List<SafetyFlag> flags) =>
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr(ctx, 'Antes de enviar', 'Before sending')),
        content: SingleChildScrollView(
          child: Text(flags.map((f) => '• ${safetyMessage(ctx, f)}').join('\n\n')),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(tr(ctx, 'Corregir', 'Edit')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(tr(ctx, 'Enviar igual', 'Send anyway')),
          ),
        ],
      ),
    );

/// ¿Vale la pena mostrar la sugerencia? Solo si cambiaría algo de lo que hay en pantalla.
bool suggestionIsUseful(
  RequestSuggestion s,
  NeedKind currentKind,
  Urgency currentUrgency,
) =>
    s.kind != currentKind ||
    (s.urgency != null && s.urgency != currentUrgency) ||
    s.changesText;
