import 'package:flutter/material.dart';

import 'brand.dart';

/// Sistema visual Barrio Vivo: `ColorScheme` + tipografía Nunito Sans + componentes base.
/// Todo el aspecto de la app sale de aquí; las pantallas no definen colores propios.
class AppTheme {
  AppTheme._();

  static const fontFamily = 'NunitoSans';

  static ThemeData light({bool highContrast = false}) =>
      _build(Brightness.light, highContrast);
  static ThemeData dark({bool highContrast = false}) =>
      _build(Brightness.dark, highContrast);

  static TextStyle _t(
    double size,
    FontWeight w, {
    double height = 1.3,
    double letter = 0,
  }) => TextStyle(
    fontFamily: fontFamily,
    fontSize: size,
    fontWeight: w,
    height: height,
    letterSpacing: letter,
    fontVariations: [FontVariation.weight(w.value.toDouble())],
  );

  static ThemeData _build(Brightness b, bool highContrast) {
    final isLight = b == Brightness.light;
    final tones = isLight
        ? BarrioTones.light(highContrast: highContrast)
        : BarrioTones.dark(highContrast: highContrast);
    final ink = isLight ? BarrioPalette.ink : BarrioPalette.cream;
    final surface = isLight
        ? BarrioPalette.white
        : Color.alphaBlend(
            BarrioPalette.white.withValues(alpha: 0.06),
            tones.cream,
          );
    final primary = isLight
        ? BarrioPalette.violet
        : BarrioPalette.tint(BarrioPalette.violet, 0.55);

    final scheme = ColorScheme(
      brightness: b,
      primary: primary,
      onPrimary: isLight ? BarrioPalette.white : BarrioPalette.ink,
      primaryContainer: tones.violetSoft,
      onPrimaryContainer: isLight ? BarrioPalette.violet : BarrioPalette.cream,
      secondary: BarrioPalette.coral,
      onSecondary: BarrioPalette.ink,
      secondaryContainer: tones.coralSoft,
      onSecondaryContainer: ink,
      tertiary: tones.trust,
      onTertiary: isLight ? BarrioPalette.white : BarrioPalette.ink,
      tertiaryContainer: tones.trustSoft,
      onTertiaryContainer: ink,
      error: tones.emergency,
      onError: isLight ? BarrioPalette.white : BarrioPalette.ink,
      errorContainer: tones.emergencySoft,
      onErrorContainer: ink,
      surface: surface,
      onSurface: ink,
      onSurfaceVariant: tones.muted,
      outline: ink.withValues(alpha: 0.45),
      outlineVariant: tones.hairline,
      surfaceContainerLowest: surface,
      surfaceContainerLow: surface,
      surfaceContainer: tones.violetSoft,
      surfaceContainerHigh: tones.violetSoft,
      surfaceContainerHighest: tones.violetSoft,
      inverseSurface: BarrioPalette.ink,
      onInverseSurface: BarrioPalette.cream,
      scrim: BarrioPalette.ink,
    );

    final text = TextTheme(
      displayMedium: _t(44, FontWeight.w800, height: 1.1, letter: 2),
      headlineLarge: _t(30, FontWeight.w800, height: 1.15),
      headlineMedium: _t(26, FontWeight.w800, height: 1.2),
      headlineSmall: _t(22, FontWeight.w800, height: 1.25),
      titleLarge: _t(20, FontWeight.w800, height: 1.25),
      titleMedium: _t(17, FontWeight.w700, height: 1.3),
      titleSmall: _t(15, FontWeight.w700, height: 1.3),
      bodyLarge: _t(17, FontWeight.w400, height: 1.45),
      bodyMedium: _t(16, FontWeight.w400, height: 1.45),
      bodySmall: _t(15, FontWeight.w400, height: 1.4),
      labelLarge: _t(16, FontWeight.w700),
      labelMedium: _t(15, FontWeight.w700),
      labelSmall: _t(14, FontWeight.w700),
    ).apply(bodyColor: ink, displayColor: ink);

    const radius = 16.0;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: b,
      colorScheme: scheme,
      fontFamily: fontFamily,
      textTheme: text,
      scaffoldBackgroundColor: tones.cream,
      extensions: [tones],
      materialTapTargetSize: MaterialTapTargetSize.padded,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: tones.cream,
        foregroundColor: ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 56),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: shape,
          textStyle: text.labelLarge,
          // Desactivado se distingue del activo pero se sigue leyendo (~4,5:1).
          disabledBackgroundColor: tones.disabledBg,
          disabledForegroundColor: tones.disabledFg,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: shape,
          side: BorderSide(color: scheme.primary, width: 1.5),
          foregroundColor: scheme.primary,
          textStyle: text.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: scheme.primary,
          textStyle: text.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: text.bodyMedium?.copyWith(color: tones.muted),
        hintStyle: text.bodyMedium?.copyWith(color: tones.muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: tones.control, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: tones.control, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: scheme.primary,
        disabledColor: tones.hairline,
        side: BorderSide(color: tones.control),
        shape: const StadiumBorder(),
        labelStyle: text.labelMedium,
        secondaryLabelStyle: text.labelMedium?.copyWith(
          color: scheme.onPrimary,
        ),
        checkmarkColor: scheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        showCheckmark: false,
      ),
      dividerTheme: DividerThemeData(
        color: tones.hairline,
        thickness: 1,
        space: 1,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: tones.cream,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: tones.hairline.withValues(alpha: 0.3),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: BarrioPalette.ink,
        contentTextStyle: text.bodyMedium?.copyWith(color: BarrioPalette.cream),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: tones.violetSoft,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => text.labelSmall?.copyWith(
            fontSize: 13,
            color: s.contains(WidgetState.selected)
                ? scheme.primary
                : tones.muted,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            size: 26,
            color: s.contains(WidgetState.selected)
                ? scheme.primary
                : tones.muted,
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? BarrioPalette.white
              : tones.muted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? scheme.tertiary
              : tones.hairline,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: tones.violetSoft,
      ),
    );
  }
}
