/// Un trato cerrado y calificado. Es la ÚNICA fuente de reputación confirmada
/// y de Visto Bueno real.
class Interaction {
  const Interaction({
    required this.id,
    required this.dealId,
    required this.providerId,
    required this.raterId,
    required this.stars,
    required this.recommended,
    required this.closedAt,
    this.comment = '',
  });

  final String id;
  final String dealId;
  final String providerId;

  /// Quién califica. Hoy es siempre la persona de este teléfono; con cuentas será el id del usuario.
  final String raterId;
  final int stars;
  final bool recommended;
  final DateTime closedAt;
  final String comment;
}
