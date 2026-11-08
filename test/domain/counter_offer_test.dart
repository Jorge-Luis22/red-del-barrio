import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:red_barrio/core/db/app_database.dart';
import 'package:red_barrio/core/result.dart';
import 'package:red_barrio/features/proposals/domain/deal.dart';
import 'package:red_barrio/features/proposals/domain/price_change.dart';
import 'package:red_barrio/features/proposals/infrastructure/drift_deal_repository.dart';
import 'package:red_barrio/features/proposals/infrastructure/drift_price_change_repository.dart';

import '../fakes/fakes.dart';

void main() {
  late AppDatabase db;
  late DriftDealRepository deals;
  late DriftPriceChangeRepository changes;
  late CounterOfferService service;
  late CancelDeal cancel;

  Deal deal({DealStatus status = DealStatus.inProgress, int price = 40}) =>
      Deal(
        id: 'd1',
        needId: 'n1',
        providerId: 'carlos',
        providerName: 'Carlos',
        priceSoles: price,
        priceLabel: 'S/ $price',
        code: '1234',
        status: status,
        acceptedAt: DateTime(2026, 11, 8),
      );

  Future<Result<PriceChange>> propose({int price = 50, String by = 'carlos'}) =>
      service.propose(
        'd1',
        by: by,
        newPrice: price,
        reason: 'Más trabajo del previsto',
      );

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    deals = DriftDealRepository(db);
    changes = DriftPriceChangeRepository(db);
    final clock = FakeClock(DateTime(2026, 11, 8, 12));
    service = CounterOfferService(
      deals: deals,
      changes: changes,
      clock: clock,
      ids: FakeIds(),
    );
    cancel = CancelDeal(deals: deals, clock: clock);
    await deals.save(deal());
  });
  tearDown(() => db.close());

  group('contraofertas', () {
    test('solo se habilitan con el trato en curso', () async {
      await deals.save(deal(status: DealStatus.accepted));
      expect(await propose(), isA<Err>());
    });

    test('solo las inicia el prestador del trato', () async {
      expect(await propose(by: 'otra-persona'), isA<Err>());
    });

    test('el precio no cambia hasta que la persona acepta', () async {
      final r = await propose();
      expect(r, isA<Ok>());
      expect((await deals.byId('d1'))!.priceSoles, 40);
      final id = (r as Ok<PriceChange>).value.id;
      final accepted = await service.respond('d1', id, accept: true);
      expect(accepted, isA<Ok>());
      expect((await deals.byId('d1'))!.priceSoles, 50);
      expect((await deals.byId('d1'))!.priceLabel, 'S/ 50');
    });

    test('rechazar deja el precio vigente y no tiene penalidad', () async {
      final id = ((await propose()) as Ok<PriceChange>).value.id;
      await service.respond('d1', id, accept: false);
      expect((await deals.byId('d1'))!.priceSoles, 40);
      expect(
        (await changes.forDeal('d1')).single.status,
        PriceChangeStatus.rejected,
      );
    });

    test('no se envía otra mientras hay una pendiente', () async {
      await propose();
      expect(await propose(price: 55), isA<Err>());
    });

    test('máximo 2 por trato', () async {
      for (final p in [50, 60]) {
        final id = ((await propose(price: p)) as Ok<PriceChange>).value.id;
        await service.respond('d1', id, accept: false);
      }
      expect(await service.remaining('d1'), 0);
      expect(await propose(price: 70), isA<Err>());
    });

    test('exige monto nuevo y motivo', () async {
      expect(await propose(price: 40), isA<Err>());
      final sinMotivo = await service.propose(
        'd1',
        by: 'carlos',
        newPrice: 50,
        reason: ' ',
      );
      expect(sinMotivo, isA<Err>());
    });

    test('no se negocian los tratos sin precio (favores, trueques)', () async {
      await deals.save(deal(price: 0));
      expect(await propose(), isA<Err>());
    });
  });

  group('cancelar trato', () {
    test('guarda el motivo y el estado cancelado', () async {
      final r = await cancel('d1', reason: 'Ya no lo necesito');
      expect(r, isA<Ok>());
      final d = (await deals.byId('d1'))!;
      expect(d.status, DealStatus.cancelled);
      expect(d.cancelReason, 'Ya no lo necesito');
      expect(d.cancelledAt, isNotNull);
    });

    test('exige un motivo', () async {
      expect(await cancel('d1', reason: ' '), isA<Err>());
      expect((await deals.byId('d1'))!.status, DealStatus.inProgress);
    });

    test('un trato cerrado ya no se cancela', () async {
      await deals.save(deal(status: DealStatus.closed));
      expect(await cancel('d1', reason: 'Tarde'), isA<Err>());
    });
  });
}
