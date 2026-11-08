import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';

import '../router.dart';
import '../theme/app_theme.dart';
import '../theme/brand.dart';

/// Pantalla de recuperación: sustituye a cualquier pantalla que falle al dibujarse.
/// Se usa dentro de `ErrorWidget.builder`, donde puede no haber tema, así que solo usa
/// colores de la paleta y no depende de `Theme`.
class RecoveryPanel extends StatelessWidget {
  const RecoveryPanel({super.key, this.detail});

  final String? detail;

  @override
  Widget build(BuildContext context) {
    // Aquí puede no haber tema ni traducciones cargadas: se usa el idioma del dispositivo.
    final t = _texts(PlatformDispatcher.instance.locale.languageCode);
    TextStyle style(
      double size,
      FontWeight w, [
      Color color = BarrioPalette.ink,
    ]) => TextStyle(
      fontFamily: AppTheme.fontFamily,
      fontSize: size,
      fontWeight: w,
      height: 1.4,
      color: color,
      decoration: TextDecoration.none,
      fontVariations: [FontVariation.weight(w.value.toDouble())],
    );
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Material(
        color: BarrioPalette.cream,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: BarrioPalette.tint(
                      BarrioPalette.sun,
                      0.45,
                      base: BarrioPalette.cream,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.healing_rounded,
                    size: 36,
                    color: BarrioPalette.ink,
                  ),
                ),
                const SizedBox(height: 20),
                Text(t.title, style: style(24, FontWeight.w800)),
                const SizedBox(height: 8),
                Text(t.body, style: style(17, FontWeight.w400)),
                if (detail != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    '${t.detail}: $detail',
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: style(
                      14,
                      FontWeight.w400,
                      BarrioPalette.ink.withValues(alpha: 0.72),
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => appRouter.go('/'),
                    style: FilledButton.styleFrom(
                      backgroundColor: BarrioPalette.violet,
                      foregroundColor: BarrioPalette.white,
                      minimumSize: const Size(64, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: style(16, FontWeight.w700),
                    ),
                    icon: const Icon(Icons.home_rounded),
                    label: Text(t.button),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

({String title, String body, String detail, String button}) _texts(
  String lang,
) => lang == 'en'
    ? (
        title: 'This screen could not be shown',
        body: 'Your data is still saved on your phone. Go back to Home; if it keeps happening, close and reopen the app.',
        detail: 'Technical detail',
        button: 'Go to Home',
      )
    : (
        title: 'Esta pantalla no se pudo mostrar',
        body: 'Tus datos siguen guardados en tu teléfono. Vuelve a Inicio; si sigue igual, cierra y abre la app.',
        detail: 'Detalle técnico',
        button: 'Ir a Inicio',
      );
