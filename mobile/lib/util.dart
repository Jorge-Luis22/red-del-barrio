import 'package:flutter/material.dart';

/// Un registro del servidor (necesidad, propuesta, mensaje…): datos tal cual viajan en `pilot_records`.
typedef Rec = Map<String, dynamic>;

/// Texto de un campo (vacío si no existe).
String sv(Rec? r, String key, [String fallback = '']) {
  final Object? v = r == null ? null : r[key];
  return v == null ? fallback : v.toString();
}

/// Número entero de un campo (acepta 1/0, true/false y texto).
int iv(Rec? r, String key, [int fallback = 0]) {
  final Object? v = r == null ? null : r[key];
  if (v is num) return v.toInt();
  if (v is bool) return v ? 1 : 0;
  return int.tryParse(v == null ? '' : v.toString()) ?? fallback;
}

/// Minúsculas y sin tildes, para buscar sin que importen los acentos.
String norm(String input) {
  const String from = 'áéíóúüñÁÉÍÓÚÜÑ';
  const String to = 'aeiouunaeiouun';
  final StringBuffer out = StringBuffer();
  for (final int rune in input.trim().runes) {
    final String ch = String.fromCharCode(rune);
    final int at = from.indexOf(ch);
    out.write(at >= 0 ? to[at] : ch.toLowerCase());
  }
  return out.toString();
}

String soles(int cents) => cents <= 0 ? 'Gratis' : 'S/ ${(cents / 100).toStringAsFixed(2)}';

/// "hace 5 min", "hace 2 h", "hace 3 días".
String timeAgo(String iso) {
  final DateTime? t = DateTime.tryParse(iso);
  if (t == null) return '';
  final Duration d = DateTime.now().toUtc().difference(t.toUtc());
  if (d.inMinutes < 1) return 'ahora';
  if (d.inMinutes < 60) return 'hace ${d.inMinutes} min';
  if (d.inHours < 24) return 'hace ${d.inHours} h';
  final int days = d.inDays;
  return days == 1 ? 'hace 1 día' : 'hace $days días';
}

Color colorFromHex(String hex, [Color fallback = const Color(0xFF0A6B66)]) {
  try {
    final String h = hex.replaceFirst('#', '');
    if (h.length != 6) return fallback;
    return Color(int.parse('FF$h', radix: 16));
  } catch (_) {
    return fallback;
  }
}

/// Nivel del vecino: 2 puntos por ayuda completada + 1 por recomendación (igual que la web).
class LevelInfo {
  const LevelInfo(this.name, this.points, this.next, this.missing, this.capped);
  final String name;
  final int points;
  final String? next;
  final int missing;
  final bool capped;
}

LevelInfo computeLevel(int helps, int recommendations, double? avgStars, int ratings) {
  const List<List<Object>> levels = <List<Object>>[
    <Object>['Vecino nuevo', 0],
    <Object>['Vecino activo', 2],
    <Object>['Vecino de confianza', 6],
    <Object>['Vecino referente', 14],
  ];
  final int points = helps * 2 + recommendations;
  final bool capped = ratings >= 2 && avgStars != null && avgStars < 3.5;
  int index = 0;
  for (int i = 0; i < levels.length; i++) {
    if (points >= (levels[i][1] as int)) index = i;
  }
  if (capped && index > 1) index = 1;
  final bool hasNext = index + 1 < levels.length;
  return LevelInfo(
    levels[index][0] as String,
    points,
    hasNext ? levels[index + 1][0] as String : null,
    hasNext ? ((levels[index + 1][1] as int) - points).clamp(0, 1000000).toInt() : 0,
    capped,
  );
}
