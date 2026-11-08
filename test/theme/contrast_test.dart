import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:red_barrio/app/theme/brand.dart';

/// Contraste WCAG entre dos colores. Si el primero es translúcido, se mezcla sobre [bg].
double ratio(Color fg, Color bg) {
  final f = Color.alphaBlend(fg, bg).computeLuminance();
  final b = bg.computeLuminance();
  final hi = f > b ? f : b;
  final lo = f > b ? b : f;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  const white = BarrioPalette.white;
  final light = BarrioTones.light();
  final dark = BarrioTones.dark();

  group('Modo claro', () {
    test(
      'texto principal y secundario se leen (4,5:1) sobre crema y blanco',
      () {
        expect(ratio(BarrioPalette.ink, light.cream), greaterThanOrEqualTo(7));
        expect(ratio(light.muted, light.cream), greaterThanOrEqualTo(4.5));
        expect(ratio(light.muted, white), greaterThanOrEqualTo(4.5));
      },
    );

    test('el texto verde sobre su fondo suave llega a 4,5:1', () {
      expect(
        ratio(light.trustText, light.trustSoft),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('los bordes de campos y chips se ven (3:1) sobre blanco y crema', () {
      expect(ratio(light.control, white), greaterThanOrEqualTo(3));
      expect(ratio(light.control, light.cream), greaterThanOrEqualTo(3));
    });

    test(
      'el botón desactivado se distingue del activo y su texto se lee (4,5:1)',
      () {
        expect(
          ratio(light.disabledFg, light.disabledBg),
          greaterThanOrEqualTo(4.5),
        );
        expect(light.disabledBg, isNot(BarrioPalette.violet));
      },
    );

    test('texto de los botones principales', () {
      expect(ratio(white, BarrioPalette.violet), greaterThanOrEqualTo(4.5));
      expect(
        ratio(BarrioPalette.ink, BarrioPalette.coral),
        greaterThanOrEqualTo(4.5),
      );
      expect(ratio(white, BarrioPalette.emergency), greaterThanOrEqualTo(4.5));
    });

    test('las etiquetas de estado se leen sobre su fondo suave', () {
      expect(
        ratio(BarrioPalette.violet, light.violetSoft),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        ratio(light.emergency, light.emergencySoft),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        ratio(BarrioPalette.ink, light.sunSoft),
        greaterThanOrEqualTo(4.5),
      );
    });
  });

  test(
    'el texto blanco del encabezado de Vecinos se lee sobre el coral oscuro',
    () {
      expect(ratio(white, light.coralDeep), greaterThanOrEqualTo(4.5));
      expect(
        ratio(white.withValues(alpha: 0.92), light.coralDeep),
        greaterThanOrEqualTo(4.5),
      );
    },
  );

  group('Modo oscuro', () {
    test(
      'texto secundario y bordes de control se ven sobre el fondo oscuro',
      () {
        expect(ratio(dark.muted, dark.cream), greaterThanOrEqualTo(4.5));
        expect(ratio(dark.control, dark.cream), greaterThanOrEqualTo(3));
        // El fondo desactivado es translúcido: primero se mezcla con la superficie.
        final disabledSurface = Color.alphaBlend(dark.disabledBg, dark.cream);
        expect(
          ratio(dark.disabledFg, disabledSurface),
          greaterThanOrEqualTo(3),
        );
      },
    );
  });

  test('alto contraste sube el gris y los bordes', () {
    final high = BarrioTones.light(highContrast: true);
    expect(ratio(high.muted, white), greaterThan(ratio(light.muted, white)));
    expect(
      ratio(high.control, white),
      greaterThan(ratio(light.control, white)),
    );
  });
}
