import '../../../app/l10n.dart';
import '../../location/domain/zone.dart';
import '../domain/emergency.dart';
import 'sos_labels.dart';

/// Texto del SMS de aviso. Solo lleva la ZONA de ~1 km (nunca coordenadas exactas, porque
/// ni siquiera recibe una posición exacta) y la referencia que la persona escribió.
String buildAlertSms(
  AppLocalizations l, {
  required SosSituation situation,
  required String text,
  Zone? zone,
  String? reference,
}) {
  final lines = <String>[
    l.smsAlert(
      sosLabel(l, situation),
      text.trim().isEmpty ? sosTemplate(l, situation) : text.trim(),
    ),
  ];
  if (zone != null) {
    final lat = zone.lat.toStringAsFixed(2);
    final lng = zone.lng.toStringAsFixed(2);
    lines.add(l.smsZone(lat, lng, 'https://maps.google.com/?q=$lat,$lng'));
  }
  final ref = reference?.trim() ?? '';
  if (ref.isNotEmpty) lines.add(l.smsRef(ref));
  lines.add(l.smsFooter);
  return lines.join('\n');
}

/// `sms:` con varios destinatarios y el texto ya escrito. Se codifica con `%20`: algunas apps
/// de mensajes muestran un `+` literal si el espacio se codifica como `+`.
Uri buildSmsUri(List<String> phones, String body) =>
    Uri.parse('sms:${phones.join(',')}?body=${Uri.encodeComponent(body)}');
