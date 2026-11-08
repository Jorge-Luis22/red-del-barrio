import 'package:flutter_test/flutter_test.dart';
import 'package:red_barrio/core/result.dart';
import 'package:red_barrio/features/directory/domain/listing.dart';
import 'package:red_barrio/features/directory/infrastructure/demo_directory_repository.dart';
import 'package:red_barrio/features/explore/domain/explore_nearby.dart';
import 'package:red_barrio/features/location/domain/zone.dart';
import 'package:red_barrio/features/needs/domain/need.dart';
import 'package:red_barrio/features/proposals/domain/deal.dart';
import 'package:red_barrio/features/proposals/domain/usecases/deal_usecases.dart';
import 'package:red_barrio/features/proposals/domain/usecases/list_proposals.dart';
import 'package:red_barrio/features/proposals/infrastructure/demo_proposal_repository.dart';

import '../fakes/fakes.dart';

void main() {
  late FakeDeals deals;
  late FakeReputation reputation;
  late FakeClock clock;
  late FakeIds ids;
  const directory = DemoDirectoryRepository();

  Need need({SyncStatus status = SyncStatus.sent}) => Need(
    id: 'need-1',
    kind: NeedKind.service,
    text: 'Necesito un gasfitero',
    urgency: Urgency.today,
    createdAt: DateTime(2026, 11, 8),
    syncStatus: status,
  );

  setUp(() {
    deals = FakeDeals();
    reputation = FakeReputation();
    clock = FakeClock(DateTime(2026, 11, 8, 10));
    ids = FakeIds();
  });

  AcceptProposal accept() =>
      AcceptProposal(deals: deals, clock: clock, ids: ids);
  ValidateMeetingCode validate() =>
      ValidateMeetingCode(deals: deals, clock: clock);
  CompleteDeal complete() => CompleteDeal(deals: deals, clock: clock);
  CloseAndRate close() => CloseAndRate(
    deals: deals,
    reputation: reputation,
    directory: directory,
    clock: clock,
    ids: ids,
  );

  Future<Deal> acceptedDeal() async {
    final props = await ListProposals(const DemoProposalRepository())(need());
    final r = await accept()(need(), props.first);
    return (r as Ok<Deal>).value;
  }

  group('propuestas', () {
    test('una necesidad Pendiente NO recibe propuestas', () async {
      final r = await ListProposals(const DemoProposalRepository())(
        need(status: SyncStatus.pending),
      );
      expect(r, isEmpty);
    });

    test('una necesidad Enviada recibe varias propuestas de ejemplo', () async {
      final r = await ListProposals(const DemoProposalRepository())(need());
      expect(r.length, greaterThanOrEqualTo(3));
      expect(r.every((p) => p.isExample), isTrue);
    });

    test('no se acepta una propuesta si el pedido no está enviado', () async {
      final props = await ListProposals(const DemoProposalRepository())(need());
      final r = await accept()(need(status: SyncStatus.pending), props.first);
      expect(r, isA<Err<Deal>>());
    });
  });

  group('ciclo del trato', () {
    test(
      'aceptar genera código de 4 dígitos y no permite aceptar dos veces',
      () async {
        final d = await acceptedDeal();
        expect(d.code, '1234');
        expect(d.status, DealStatus.accepted);
        final props = await ListProposals(const DemoProposalRepository())(
          need(),
        );
        expect(await accept()(need(), props.last), isA<Err<Deal>>());
      },
    );

    test('código incorrecto no inicia el servicio; el correcto sí', () async {
      final d = await acceptedDeal();
      expect(await validate()(d.id, '0000'), isA<Err<Deal>>());
      expect((await deals.byId(d.id))!.status, DealStatus.accepted);
      final ok = await validate()(d.id, '1234') as Ok<Deal>;
      expect(ok.value.status, DealStatus.inProgress);
      expect(ok.value.startedAt, clock.current);
    });

    test(
      'no se puede terminar sin validar el código ni calificar sin terminar',
      () async {
        final d = await acceptedDeal();
        expect(await complete()(d.id), isA<Err<Deal>>());
        expect(await close()(d.id, stars: 5), isA<Err<CloseOutcome>>());
      },
    );

    test(
      'ciclo completo: reputación antes → después y Visto Bueno real',
      () async {
        final d = await acceptedDeal();
        await validate()(d.id, '1234');
        clock.current = clock.current.add(const Duration(minutes: 20));
        final done = await complete()(d.id) as Ok<Deal>;
        expect(done.value.duration, const Duration(minutes: 20));
        final out = await close()(
          d.id,
          stars: 5,
          comment: 'Muy bien',
          recommend: true,
        ) as Ok<CloseOutcome>;
        expect(out.value.deal.status, DealStatus.closed);
        expect(out.value.after.average, greaterThan(out.value.before.average));
        expect(out.value.after.realCount, 1);
        expect(out.value.vistoBueno.confirmed, 1);
        expect(out.value.vistoBueno.example, 14);
      },
    );

    test('estrellas fuera de 1 a 5 se rechazan', () async {
      final d = await acceptedDeal();
      await validate()(d.id, '1234');
      await complete()(d.id);
      expect(await close()(d.id, stars: 0), isA<Err<CloseOutcome>>());
      expect(await close()(d.id, stars: 6), isA<Err<CloseOutcome>>());
    });
  });

  group('Visto Bueno (regla anti-inflado)', () {
    test('calificar SIN recomendar no suma al Visto Bueno', () async {
      final d = await acceptedDeal();
      await validate()(d.id, '1234');
      await complete()(d.id);
      final out =
          await close()(d.id, stars: 4, recommend: false) as Ok<CloseOutcome>;
      expect(out.value.vistoBueno.confirmed, 0);
    });

    test('la misma persona no suma dos veces al mismo proveedor', () async {
      for (var n = 0; n < 2; n++) {
        final props = await ListProposals(const DemoProposalRepository())(
          need(),
        );
        final needN = Need(
          id: 'need-$n',
          kind: NeedKind.service,
          text: 'otro',
          urgency: Urgency.today,
          createdAt: DateTime(2026, 11, 8),
          syncStatus: SyncStatus.sent,
        );
        final dl = (await accept()(needN, props.first) as Ok<Deal>).value;
        await validate()(dl.id, '1234');
        await complete()(dl.id);
        await close()(dl.id, stars: 5, recommend: true);
      }
      final explored = await ExploreNearby(
        directory: directory,
        reputation: reputation,
      )(kind: ListingKind.service);
      final carlos = explored.firstWhere((e) => e.provider.id == 'carlos');
      expect(carlos.vistoBueno.confirmed, 1);
      expect(carlos.recommendedByMe, isTrue);
    });
  });

  group('explorar cerca', () {
    test('sin ubicación usa distancias de ejemplo; con ubicación calcula distancias reales', () async {
      final uc = ExploreNearby(directory: directory, reputation: reputation);
      final sin = await uc(
        kind: ListingKind.service,
        sort: ExploreSort.nearest,
      );
      expect(sin.first.distanceIsReal, isFalse);
      final con = await uc(
        kind: ListingKind.service,
        sort: ExploreSort.nearest,
        near: const ExactLocation(-12.0464, -77.0428),
      );
      expect(con.every((e) => e.distanceIsReal), isTrue);
      final carlos = con.firstWhere((e) => e.provider.id == 'carlos');
      expect(
        carlos.distanceMeters,
        closeTo(500, 5),
      ); // el seed ubica a Carlos a 500 m
      expect(con.first.distanceMeters! <= con.last.distanceMeters!, isTrue);
    });

    test('filtra por rubro y por tipo', () async {
      final uc = ExploreNearby(directory: directory, reputation: reputation);
      final gas = await uc(kind: ListingKind.service, trade: 'Gasfitería');
      expect(gas.length, 4);
      final prod = await uc(kind: ListingKind.product, trade: 'De un vecino');
      expect(prod.length, 7);
    });

    test('más recomendados: ordena por Visto Bueno', () async {
      final uc = ExploreNearby(directory: directory, reputation: reputation);
      final r = await uc(kind: ListingKind.service);
      final totals = r.map((e) => e.vistoBueno.total).toList();
      expect(totals, [...totals]..sort((a, b) => b.compareTo(a)));
    });
  });
}
