import '../../../core/geo/geo_math.dart';

/// Posición exacta del dispositivo. Nunca se muestra a terceros.
class ExactLocation {
  const ExactLocation(this.lat, this.lng, {this.accuracyMeters});

  final double lat;
  final double lng;
  final double? accuracyMeters;

  /// Zona aproximada (~1 km) que sí puede verse en público.
  Zone get zone => Zone(roundToZone(lat), roundToZone(lng));
}

/// Zona aproximada (~1 km). Es lo único de la ubicación que ven los demás vecinos.
class Zone {
  const Zone(this.lat, this.lng);

  final double lat;
  final double lng;
}
