import '../../../app/l10n.dart';

/// Texto traducido de los mensajes de ejemplo del muro. Lo que escribe la persona
/// no pasa por aquí: se muestra tal cual.
String wallDemoText(AppLocalizations l, String id, String fallback) =>
    switch (id) {
      'w1' => l.wall1,
      'w2' => l.wall2,
      'w3' => l.wall3,
      'w4' => l.wall4,
      'w5' => l.wall5,
      'w6' => l.wall6,
      _ => fallback,
    };
