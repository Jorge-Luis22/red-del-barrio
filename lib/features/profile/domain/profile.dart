import '../../location/domain/zone.dart';

/// Perfil de la persona. Vive solo en el teléfono: todavía no hay cuentas ni verificación.
class UserProfile {
  const UserProfile({
    required this.username,
    required this.createdAt,
    this.email,
  });

  final String username;

  /// Opcional y sin verificar: solo se guarda en este teléfono.
  final String? email;
  final DateTime createdAt;
}

/// Un lugar que la persona marcó ("Casa", "Trabajo"…).
/// La posición exacta se queda en el teléfono; lo único que se comparte es la [zone].
class SavedAddress {
  const SavedAddress({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.createdAt,
    this.reference = '',
    this.isActive = false,
  });

  final String id;
  final String name;
  final String reference;
  final double lat;
  final double lng;
  final DateTime createdAt;

  /// La dirección desde la que se miden las distancias. Solo una a la vez.
  final bool isActive;

  ExactLocation get location => ExactLocation(lat, lng);

  /// Zona de ~1 km: lo único que ven los demás.
  Zone get zone => location.zone;

  SavedAddress copyWith({bool? isActive}) => SavedAddress(
    id: id,
    name: name,
    lat: lat,
    lng: lng,
    createdAt: createdAt,
    reference: reference,
    isActive: isActive ?? this.isActive,
  );
}

/// Desde dónde se miden las distancias: la dirección activa si la hay, y si no, el GPS.
ExactLocation? pickOrigin({SavedAddress? active, ExactLocation? gps}) =>
    active?.location ?? gps;
