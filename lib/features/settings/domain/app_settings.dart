enum ThemePreference { system, light, dark }

/// Ajustes de la persona: accesibilidad, apariencia y lo que preparó para emergencias.
/// Viven en el teléfono (no hay cuentas todavía).
class AppSettings {
  const AppSettings({
    this.textScale = 1.0,
    this.highContrast = false,
    this.theme = ThemePreference.system,
    this.vibration = true,
    this.tutorialSeen = false,
    this.volunteer = false,
    this.capabilities = const {},
    this.languageCode,
  });

  /// 1.0 normal · 1.15 grande · 1.3 muy grande.
  final double textScale;
  final bool highContrast;
  final ThemePreference theme;

  /// Vibración corta como confirmación de acciones importantes.
  final bool vibration;
  final bool tutorialSeen;

  /// "Brigadista vecinal voluntario": solo una etiqueta sin verificar (no hay cuentas).
  final bool volunteer;

  /// Capacidades que la persona podría ofrecer en una emergencia.
  final Set<String> capabilities;

  /// Idioma elegido: `es`, `en` o `null` para seguir al sistema.
  final String? languageCode;

  AppSettings copyWith({
    double? textScale,
    bool? highContrast,
    ThemePreference? theme,
    bool? vibration,
    bool? tutorialSeen,
    bool? volunteer,
    Set<String>? capabilities,
    String? languageCode,
    bool useSystemLanguage = false,
  }) => AppSettings(
    textScale: textScale ?? this.textScale,
    highContrast: highContrast ?? this.highContrast,
    theme: theme ?? this.theme,
    vibration: vibration ?? this.vibration,
    tutorialSeen: tutorialSeen ?? this.tutorialSeen,
    volunteer: volunteer ?? this.volunteer,
    capabilities: capabilities ?? this.capabilities,
    languageCode: useSystemLanguage
        ? null
        : (languageCode ?? this.languageCode),
  );
}

/// Capacidades que se pueden marcar para "Un barrio preparado".
const emergencyCapabilities = [
  'firstAid',
  'medkit',
  'vehicle',
  'tools',
  'supplies',
  'care',
];
