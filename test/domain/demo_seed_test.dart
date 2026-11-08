import 'package:flutter_test/flutter_test.dart';
import 'package:red_barrio/features/assistant/domain/request_assistant.dart';
import 'package:red_barrio/features/directory/domain/trades.dart';
import 'package:red_barrio/features/directory/infrastructure/demo_seed.dart';
import 'package:red_barrio/features/needs/domain/need.dart';

void main() {
  final listings = [for (final d in demoListings) d.listing];

  test('cada rubro de servicio tiene al menos 3 opciones cerca', () {
    for (final t in serviceTrades.where((t) => t != 'Todos')) {
      final n = listings.where((l) => l.trade == t).length;
      expect(n, greaterThanOrEqualTo(3), reason: t);
    }
  });

  test('cada rubro de producto tiene al menos 3 opciones cerca', () {
    for (final t in productTrades.where((t) => t != 'Todos')) {
      final n = listings.where((l) => l.trade == t).length;
      expect(n, greaterThanOrEqualTo(3), reason: t);
    }
  });

  test('cada oficio da al menos 3 propuestas al pedir ese servicio', () {
    for (final t in serviceTrades.where((t) => t != 'Todos')) {
      expect(
        demoServiceProposalsByTrade[t]?.length ?? 0,
        greaterThanOrEqualTo(3),
        reason: t,
      );
    }
    for (final k in NeedKind.values) {
      expect(
        demoProposals[k]?.length ?? 0,
        greaterThanOrEqualTo(3),
        reason: '$k',
      );
    }
  });

  test('los identificadores no se repiten y todo prestador existe', () {
    final ids = listings.map((l) => l.id).toList();
    expect(ids.toSet().length, ids.length);
    for (final l in listings) {
      expect(demoProviders.containsKey(l.providerId), isTrue, reason: l.id);
    }
    for (final list in demoServiceProposalsByTrade.values) {
      for (final p in list) {
        expect(
          demoProviders.containsKey(p.providerId),
          isTrue,
          reason: p.providerId,
        );
      }
    }
  });

  test('cada atajo de servicio reconoce su oficio y tiene propuestas', () {
    const assistant = RequestAssistant();
    const atajos = {
      'Necesito un gasfitero para arreglar una fuga': 'Gasfitería',
      'Necesito un electricista, se fue la luz en la cocina': 'Electricidad',
      'Necesito un carpintero': 'Carpintería',
      'Necesito un cerrajero': 'Cerrajería',
      'Necesito arreglar un dobladillo': 'Costura',
      'Necesito clases de matemática para mi hijo': 'Clases',
      'Necesito que alguien pasee a mi perro': 'Mascotas',
    };
    atajos.forEach((texto, oficio) {
      expect(assistant.detectTrade(texto), oficio, reason: texto);
      expect(
        demoServiceProposalsByTrade[oficio]!.length,
        greaterThanOrEqualTo(3),
      );
    });
  });
}
