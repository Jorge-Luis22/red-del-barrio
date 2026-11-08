/// Persona o negocio que ofrece algo en el barrio.
///
/// Los valores `example*` son datos de DEMOSTRACIÓN (no hay vecinos reales todavía)
/// y la interfaz debe rotularlos como "ejemplo".
class ProviderProfile {
  const ProviderProfile({
    required this.id,
    required this.name,
    required this.role,
    required this.exampleRating,
    required this.exampleRatingCount,
    required this.exampleVistoBueno,
  });

  final String id;
  final String name;
  final String role;

  /// Calificación y cantidad de ejemplo (de demostración).
  final double exampleRating;
  final int exampleRatingCount;

  /// "Vecinos que lo recomiendan" de ejemplo (de demostración).
  final int exampleVistoBueno;
}
