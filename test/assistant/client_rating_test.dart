import 'package:flutter_test/flutter_test.dart';
import 'package:red_barrio/core/result.dart';
import 'package:red_barrio/features/assistant/domain/barrio_stats.dart';
import 'package:red_barrio/features/proposals/domain/deal.dart';
import 'package:red_barrio/features/proposals/domain/usecases/deal_usecases.dart';
import 'package:red_barrio/features/reputation/domain/interaction.dart';

import '../fakes/fakes.dart';

void main() {
  Deal deal(DealStatus status) => Deal(
    id: 'd1',
    needId: 'n1',
    providerId: 'carlos',
    providerName: 'Carlos',
    priceSoles: 40,
    priceLabel: 'S/ 40',
    code: '1234',
    status: status,
    acceptedAt: DateTime(2026, 11, 8),
  );

  late FakeDeals deals;
  late FakeReputation reputation;
  late RateClient rate;

  setUp(() {
    deals = FakeDeals();
    reputation = FakeReputation();
    rate = RateClient(
      deals: deals,
      reputation: reputation,
      clock: FakeClock(DateTime(2026, 11, 8, 18)),
    );
  });

  test('con el trato cerrado se guarda la calificación al cliente', () async {
    deals.store['d1'] = deal(DealStatus.closed);
    final r = await rate('d1', stars: 5, comment: ' Puntual ');
    expect(r, isA<Ok<Interaction>>());
    final saved = reputation.store.single;
    expect(saved.isClientRating, isTrue);
    expect(saved.raterId, 'carlos');
    expect(saved.comment, 'Puntual');
  });

  test('no cuenta para la reputación de quien presta el servicio', () async {
    deals.store['d1'] = deal(DealStatus.closed);
    await rate('d1', stars: 1);
    expect(await reputation.forProvider('carlos'), isEmpty);
  });

  test('no se puede calificar antes de cerrar el trato', () async {
    deals.store['d1'] = deal(DealStatus.awaitingRating);
    expect(await rate('d1', stars: 4), isA<Err<Interaction>>());
    expect(reputation.store, isEmpty);
  });

  test('las estrellas deben ir de 1 a 5', () async {
    deals.store['d1'] = deal(DealStatus.closed);
    expect(await rate('d1', stars: 0), isA<Err<Interaction>>());
    expect(await rate('d1', stars: 6), isA<Err<Interaction>>());
  });

  test('las estadísticas del barrio ignoran las calificaciones al cliente', () {
    final provider = Interaction(
      id: 'a',
      dealId: 'd1',
      providerId: 'carlos',
      raterId: 'me',
      stars: 4,
      recommended: false,
      closedAt: DateTime(2026, 11, 8),
    );
    final client = Interaction(
      id: Interaction.clientRatingId('d1'),
      dealId: 'd1',
      providerId: '${Interaction.clientPrefix}d1',
      raterId: 'carlos',
      stars: 1,
      recommended: false,
      closedAt: DateTime(2026, 11, 8),
    );
    final s = BarrioStats.fromData(
      needs: const [],
      offers: const [],
      deals: const [],
      interactions: [provider, client],
    );
    expect(s.averageStars, 4);
  });
}
