import 'dart:math' as math;

const _toRad = math.pi / 180;
const _earthRadius = 6371000.0;

/// Distancia en metros entre dos puntos (fórmula de Haversine).
double haversineMeters(double lat1, double lng1, double lat2, double lng2) {
  final dLat = (lat2 - lat1) * _toRad;
  final dLng = (lng2 - lng1) * _toRad;
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(lat1 * _toRad) *
          math.cos(lat2 * _toRad) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);
  return 2 * _earthRadius * math.asin(math.sqrt(a));
}

/// Punto a [meters] metros de (lat, lng) en dirección [bearingDegrees] (0° = norte, 90° = este).
/// Sirve para ubicar vecinos de ejemplo alrededor de una posición.
({double lat, double lng}) destinationPoint(
  double lat,
  double lng,
  double meters,
  double bearingDegrees,
) {
  final d = meters / _earthRadius;
  final b = bearingDegrees * _toRad;
  final lat1 = lat * _toRad;
  final lng1 = lng * _toRad;
  final lat2 = math.asin(math.sin(lat1) * math.cos(d) + math.cos(lat1) * math.sin(d) * math.cos(b));
  final lng2 = lng1 +
      math.atan2(
        math.sin(b) * math.sin(d) * math.cos(lat1),
        math.cos(d) - math.sin(lat1) * math.sin(lat2),
      );
  return (lat: lat2 / _toRad, lng: lng2 / _toRad);
}

/// Redondea a 2 decimales (~1,1 km): es la "zona aproximada" que ven terceros
/// (regla inviolable 3: la ubicación exacta nunca es pública).
double roundToZone(double degrees) => (degrees * 100).round() / 100;

/// Texto de distancia en español: "300 m" o "1,2 km".
String formatDistance(double meters) {
  final m = (meters / 10).round() * 10;
  if (m < 1000) return '$m m';
  return '${(m / 1000).toStringAsFixed(1).replaceAll('.', ',')} km';
}
