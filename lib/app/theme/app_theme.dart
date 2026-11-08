import 'package:flutter/material.dart';

/// Tema base (Material 3). El sistema de diseño completo llega en la Fase 3;
/// aquí solo queda la estructura: tema normal, tema de emergencia y tamaños táctiles de 48 dp.
class AppTheme {
  AppTheme._();

  static const _seed = Color(0xFF0A6B66); // verde azulado del PWA
  static const _emergencySeed = Color(0xFFC42B1A); // rojo de emergencia del PWA

  static ThemeData light() => _build(_seed, Brightness.light);
  static ThemeData dark() => _build(_seed, Brightness.dark);

  /// Modo emergencia claramente diferenciado (acento rojo).
  static ThemeData emergency() => _build(_emergencySeed, Brightness.light);

  static ThemeData _build(Color seed, Brightness brightness) {
    final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
    );
  }
}
