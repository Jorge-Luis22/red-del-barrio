enum ListingKind { service, product }

/// Un servicio o producto visible en "Explorar cerca".
class Listing {
  const Listing({
    required this.id,
    required this.providerId,
    required this.title,
    required this.trade,
    required this.kind,
    required this.availability,
    required this.reference,
    required this.requestText,
    this.latitude,
    this.longitude,
    this.nominalMeters,
  });

  final String id;
  final String providerId;

  /// Nombre mostrado (puede ser el del producto o el del negocio).
  final String title;

  /// Rubro: Gasfitería, Bodega, De un vecino…
  final String trade;
  final ListingKind kind;
  final String availability;

  /// Ej.: "Cotiza según tu pedido" o "Bidón de agua S/ 12".
  final String reference;

  /// Texto con el que se precarga el pedido ("Pedir este servicio").
  final String requestText;

  /// Posición real (en la etapa 2 viene de la base de datos). Nula si no se conoce.
  final double? latitude;
  final double? longitude;

  /// Distancia aproximada de ejemplo cuando no hay ubicación del usuario.
  final double? nominalMeters;
}
