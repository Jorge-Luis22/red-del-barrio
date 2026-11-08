import '../../../app/l10n.dart';
import '../domain/wall_demo.dart';

/// Texto traducido de los mensajes de ejemplo del muro. Lo que escribe la persona
/// no pasa por aquí: se muestra tal cual.
String wallDemoText(AppLocalizations l, String id, String fallback) {
  if (l.localeName != 'en') return fallback;
  for (final e in demoWall) {
    if (e.id == id && e.textEn != null) return e.textEn!;
  }
  return fallback;
}
