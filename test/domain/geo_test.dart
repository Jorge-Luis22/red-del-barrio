import 'package:flutter_test/flutter_test.dart';
import 'package:red_barrio/core/geo/geo_math.dart';
import 'package:red_barrio/features/location/domain/zone.dart';

void main() {
  test('destinationPoint y haversine son coherentes (500 m a 40°)', () {
    final p = destinationPoint(-12.0464, -77.0428, 500, 40);
    expect(haversineMeters(-12.0464, -77.0428, p.lat, p.lng), closeTo(500, 1));
  });

  test('la zona pública se redondea a ~1 km y nunca es la posición exacta', () {
    const loc = ExactLocation(-12.04637, -77.04281);
    expect(loc.zone.lat, -12.05);
    expect(loc.zone.lng, -77.04);
    expect(haversineMeters(loc.lat, loc.lng, loc.zone.lat, loc.zone.lng), lessThan(1000));
  });

  test('formatDistance en español', () {
    expect(formatDistance(304), '300 m');
    expect(formatDistance(1240), '1,2 km');
  });
}
