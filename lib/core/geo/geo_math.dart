import 'dart:math' as math;

/// Distancia en metros entre dos puntos (fórmula de Haversine).
double haversineMeters(double lat1, double lng1, double lat2, double lng2) {
  const earthRadius = 6371000.0;
  const toRad = math.pi / 180;
  final dLat = (lat2 - lat1) * toRad;
  final dLng = (lng2 - lng1) * toRad;
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(lat1 * toRad) *
          math.cos(lat2 * toRad) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);
  return 2 * earthRadius * math.asin(math.sqrt(a));
}

/// Redondea a 2 decimales (~1,1 km): es la "zona aproximada" que ven terceros
/// (regla inviolable 3: la ubicación exacta nunca es pública).
double roundToZone(double degrees) => (degrees * 100).round() / 100;
