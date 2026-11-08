import 'package:flutter/material.dart';

/// Paleta oficial Barrio Vivo. Es la ÚNICA fuente de color: todo lo demás se deriva
/// de estos ocho valores (mezclas con blanco/crema/tinta), nunca se inventa un color nuevo.
class BarrioPalette {
  BarrioPalette._();

  static const violet = Color(0xFF5635B8);
  static const coral = Color(0xFFFF795F);
  static const cream = Color(0xFFFFF7ED);
  static const white = Color(0xFFFFFFFF);
  static const ink = Color(0xFF30283B);
  static const trust = Color(0xFF16816B);
  static const sun = Color(0xFFF5C863);
  static const emergency = Color(0xFFC73535);

  /// Mezcla [color] sobre [base] con [amount] de opacidad (para fondos suaves).
  static Color tint(Color color, double amount, {Color base = white}) =>
      Color.alphaBlend(color.withValues(alpha: amount), base);
}

/// Colores de apoyo que Material no trae: confianza, sol, coral y emergencia con su versión suave.
@immutable
class BarrioTones extends ThemeExtension<BarrioTones> {
  const BarrioTones({
    required this.cream,
    required this.trust,
    required this.trustSoft,
    required this.sun,
    required this.sunSoft,
    required this.coral,
    required this.coralSoft,
    required this.emergency,
    required this.emergencySoft,
    required this.violetSoft,
    required this.muted,
    required this.hairline,
  });

  final Color cream;
  final Color trust;
  final Color trustSoft;
  final Color sun;
  final Color sunSoft;
  final Color coral;
  final Color coralSoft;
  final Color emergency;
  final Color emergencySoft;
  final Color violetSoft;

  /// Texto secundario (tinta al 72 %: contraste suficiente sobre crema y blanco).
  final Color muted;

  /// Líneas separadoras muy suaves.
  final Color hairline;

  static BarrioTones light({bool highContrast = false}) => BarrioTones(
    cream: BarrioPalette.cream,
    trust: BarrioPalette.trust,
    trustSoft: BarrioPalette.tint(BarrioPalette.trust, 0.12),
    sun: BarrioPalette.sun,
    sunSoft: BarrioPalette.tint(BarrioPalette.sun, 0.30),
    coral: BarrioPalette.coral,
    coralSoft: BarrioPalette.tint(BarrioPalette.coral, 0.16),
    emergency: BarrioPalette.emergency,
    emergencySoft: BarrioPalette.tint(BarrioPalette.emergency, 0.10),
    violetSoft: BarrioPalette.tint(BarrioPalette.violet, 0.10),
    muted: BarrioPalette.ink.withValues(alpha: highContrast ? 0.92 : 0.72),
    hairline: BarrioPalette.ink.withValues(alpha: highContrast ? 0.40 : 0.10),
  );

  static BarrioTones dark({bool highContrast = false}) {
    final base = Color.alphaBlend(
      Colors.black.withValues(alpha: 0.35),
      BarrioPalette.ink,
    );
    return BarrioTones(
      cream: base,
      trust: BarrioPalette.tint(
        BarrioPalette.trust,
        0.55,
        base: BarrioPalette.white,
      ),
      trustSoft: BarrioPalette.tint(BarrioPalette.trust, 0.28, base: base),
      sun: BarrioPalette.sun,
      sunSoft: BarrioPalette.tint(BarrioPalette.sun, 0.22, base: base),
      coral: BarrioPalette.coral,
      coralSoft: BarrioPalette.tint(BarrioPalette.coral, 0.22, base: base),
      emergency: BarrioPalette.tint(
        BarrioPalette.emergency,
        0.60,
        base: BarrioPalette.white,
      ),
      emergencySoft: BarrioPalette.tint(
        BarrioPalette.emergency,
        0.28,
        base: base,
      ),
      violetSoft: BarrioPalette.tint(BarrioPalette.violet, 0.40, base: base),
      muted: BarrioPalette.white.withValues(alpha: highContrast ? 0.92 : 0.72),
      hairline: BarrioPalette.white.withValues(
        alpha: highContrast ? 0.45 : 0.12,
      ),
    );
  }

  @override
  BarrioTones copyWith() => this;

  @override
  BarrioTones lerp(ThemeExtension<BarrioTones>? other, double t) =>
      t < 0.5 ? this : (other as BarrioTones? ?? this);
}

extension BarrioContext on BuildContext {
  ColorScheme get cs => Theme.of(this).colorScheme;
  TextTheme get tt => Theme.of(this).textTheme;
  BarrioTones get tones => Theme.of(this).extension<BarrioTones>()!;
}

/// Pesos de Nunito Sans (fuente variable): se fija el eje `wght` además del peso,
/// para que `bold` y `w800` se vean distintos en todos los dispositivos.
extension BarrioText on TextStyle {
  TextStyle weight(FontWeight w) => copyWith(
    fontWeight: w,
    fontVariations: [FontVariation.weight(w.value.toDouble())],
  );
}
