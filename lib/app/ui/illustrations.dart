import 'package:flutter/material.dart';

import '../theme/brand.dart';

/// Ilustraciones comunitarias dibujadas con vectores (sin imágenes externas, funcionan sin internet).
/// Usan solo colores de la paleta.

/// Calle del barrio: casas de distintos tamaños, un árbol y dos vecinos. Va sobre fondo violeta.
class BarrioSkyline extends StatelessWidget {
  const BarrioSkyline({super.key, this.height = 84});

  final double height;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: _SkylinePainter()),
    ),
  );
}

class _SkylinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final paint = Paint()..style = PaintingStyle.fill;

    // Sol detrás de las casas.
    paint.color = BarrioPalette.sun;
    canvas.drawCircle(Offset(w * 0.80, h * 0.34), h * 0.20, paint);

    // Suelo.
    paint.color = BarrioPalette.tint(
      BarrioPalette.white,
      0.16,
      base: BarrioPalette.violet,
    );
    canvas.drawRRect(
      RRect.fromRectAndCorners(Rect.fromLTWH(0, h * 0.86, w, h * 0.14)),
      paint,
    );

    void house(
      double x,
      double bw,
      double bh,
      Color body,
      Color roof, {
      bool door = true,
    }) {
      final base = h * 0.88;
      paint.color = body;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, base - bh, bw, bh),
          const Radius.circular(6),
        ),
        paint,
      );
      paint.color = roof;
      final path = Path()
        ..moveTo(x - 6, base - bh + 2)
        ..lineTo(x + bw / 2, base - bh - bw * 0.34)
        ..lineTo(x + bw + 6, base - bh + 2)
        ..close();
      canvas.drawPath(path, paint);
      paint.color = BarrioPalette.cream;
      final win = bw * 0.2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x + bw * 0.18, base - bh * 0.78, win, win),
          const Radius.circular(3),
        ),
        paint,
      );
      if (door) {
        paint.color = BarrioPalette.ink.withValues(alpha: 0.55);
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTWH(
              x + bw * 0.58,
              base - bh * 0.46,
              bw * 0.24,
              bh * 0.46,
            ),
            topLeft: const Radius.circular(6),
            topRight: const Radius.circular(6),
          ),
          paint,
        );
      }
    }

    house(
      w * 0.04,
      w * 0.17,
      h * 0.46,
      BarrioPalette.coral,
      BarrioPalette.cream,
    );
    house(
      w * 0.25,
      w * 0.15,
      h * 0.62,
      BarrioPalette.cream,
      BarrioPalette.coral,
    );
    house(w * 0.45, w * 0.18, h * 0.40, BarrioPalette.sun, BarrioPalette.cream);

    // Árbol.
    paint.color = BarrioPalette.trust;
    canvas.drawCircle(Offset(w * 0.70, h * 0.58), h * 0.17, paint);
    paint.color = BarrioPalette.ink.withValues(alpha: 0.55);
    canvas.drawRect(Rect.fromLTWH(w * 0.70 - 2, h * 0.62, 4, h * 0.26), paint);

    // Dos vecinos saludándose.
    void person(double cx, Color body) {
      paint.color = BarrioPalette.cream;
      canvas.drawCircle(Offset(cx, h * 0.56), h * 0.075, paint);
      paint.color = body;
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromCenter(
            center: Offset(cx, h * 0.76),
            width: h * 0.17,
            height: h * 0.26,
          ),
          topLeft: const Radius.circular(12),
          topRight: const Radius.circular(12),
        ),
        paint,
      );
    }

    person(w * 0.89, BarrioPalette.coral);
    person(w * 0.95, BarrioPalette.trust);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Casa con un corazón: estados vacíos y secciones que todavía no están disponibles.
class BarrioHouse extends StatelessWidget {
  const BarrioHouse({super.key, this.size = 120, this.accent});

  final double size;

  /// Color del corazón/puerta. Por defecto, coral.
  final Color? accent;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _HousePainter(
          context.tones,
          context.cs.primary,
          accent ?? BarrioPalette.coral,
        ),
      ),
    ),
  );
}

class _HousePainter extends CustomPainter {
  _HousePainter(this.tones, this.primary, this.accent);

  final BarrioTones tones;
  final Color primary;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final p = Paint()..style = PaintingStyle.fill;

    p.color = tones.violetSoft;
    canvas.drawCircle(Offset(s / 2, s / 2), s * 0.48, p);

    p.color = tones.sun;
    canvas.drawCircle(Offset(s * 0.78, s * 0.24), s * 0.08, p);

    // Cuerpo.
    p.color = BarrioPalette.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.26, s * 0.46, s * 0.48, s * 0.34),
        Radius.circular(s * 0.04),
      ),
      p,
    );
    // Techo.
    p.color = primary;
    final roof = Path()
      ..moveTo(s * 0.20, s * 0.49)
      ..lineTo(s * 0.50, s * 0.22)
      ..lineTo(s * 0.80, s * 0.49)
      ..close();
    canvas.drawPath(roof, p);
    // Puerta.
    p.color = accent;
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(s * 0.43, s * 0.60, s * 0.14, s * 0.20),
        topLeft: Radius.circular(s * 0.05),
        topRight: Radius.circular(s * 0.05),
      ),
      p,
    );
    // Ventanas.
    p.color = tones.violetSoft;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.31, s * 0.54, s * 0.08, s * 0.08),
        Radius.circular(s * 0.015),
      ),
      p,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.61, s * 0.54, s * 0.08, s * 0.08),
        Radius.circular(s * 0.015),
      ),
      p,
    );
    // Suelo.
    p.color = tones.trust;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.18, s * 0.80, s * 0.64, s * 0.04),
        Radius.circular(s * 0.02),
      ),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant _HousePainter old) =>
      old.primary != primary || old.accent != accent || old.tones != tones;
}
