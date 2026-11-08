import '../../../core/geo/geo_math.dart';

/// Posición del teléfono. NUNCA se envía ni se guarda tal cual: solo se usa en memoria
/// para calcular distancias; lo único que se conserva es la [zone] redondeada.
class ExactLocation {
  const ExactLocation(
    this.lat,
    this.lng, {
    this.accuracyMeters,
    this.isApproximate = false,
  });

  final double lat;
  final double lng;
  final double? accuracyMeters;

  /// `true` cuando solo se conoce la zona guardada (no una lectura real del GPS):
  /// las distancias calculadas a partir de ella son aproximadas.
  final bool isApproximate;

  /// Zona de unos 1000 m: lo único que ven los demás y lo único que se recuerda.
  Zone get zone => Zone(roundToZone(lat), roundToZone(lng));
}

class Zone {
  const Zone(this.lat, this.lng);

  final double lat;
  final double lng;
}
