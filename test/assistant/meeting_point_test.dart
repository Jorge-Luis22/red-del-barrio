import 'package:flutter_test/flutter_test.dart';
import 'package:red_barrio/features/meeting/domain/meeting_point.dart';

void main() {
  test('ida y vuelta: el mensaje se vuelve a leer como punto', () {
    const p = MeetingPoint(label: 'Plaza o parque', lat: -12.04642, lng: -77.04281);
    final back = MeetingPoint.tryParse(p.toMessage())!;
    expect(back.label, 'Plaza o parque');
    expect(back.lat, closeTo(-12.04642, 1e-5));
    expect(back.lng, closeTo(-77.04281, 1e-5));
  });

  test('un mensaje normal no es un punto de encuentro', () {
    expect(MeetingPoint.tryParse('Voy en camino'), isNull);
  });

  test('coordenadas fuera de rango se rechazan', () {
    expect(
      MeetingPoint.tryParse('📍 Punto de encuentro: Algo (95.00000, 10.00000)'),
      isNull,
    );
  });

  test('los paréntesis del nombre no rompen el formato', () {
    const p = MeetingPoint(label: 'Parque (norte)', lat: -12.1, lng: -77.0);
    expect(MeetingPoint.tryParse(p.toMessage()), isNotNull);
  });
}
