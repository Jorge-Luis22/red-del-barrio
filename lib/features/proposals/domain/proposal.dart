/// Propuesta de un proveedor a una necesidad. El PRECIO lo pone el proveedor
/// al ver el pedido (nunca se publica de antemano).
class Proposal {
  const Proposal({
    required this.providerId,
    required this.providerName,
    required this.role,
    required this.priceSoles,
    required this.priceLabel,
    required this.distanceMeters,
    required this.availability,
    required this.etaHours,
    required this.isExample,
    this.diagnosticVisitSoles,
  });

  final String providerId;
  final String providerName;
  final String role;

  /// 0 si es gratis, trueque o favor.
  final int priceSoles;

  /// Texto mostrado: "S/ 35", "Préstamo gratis", "Trueque"…
  final String priceLabel;
  final double distanceMeters;
  final String availability;

  /// Horas hasta que puede atender (para "Llega a tiempo para: Hoy").
  final double etaHours;

  /// `true` mientras no haya vecinos reales: la interfaz debe decir "ejemplo".
  final bool isExample;
  final int? diagnosticVisitSoles;
}
