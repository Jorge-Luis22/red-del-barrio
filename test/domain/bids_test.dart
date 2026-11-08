import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:red_barrio/core/db/app_database.dart';
import 'package:red_barrio/core/result.dart';
import 'package:red_barrio/features/bids/domain/bid.dart';
import 'package:red_barrio/features/bids/domain/usecases/place_bid.dart';
import 'package:red_barrio/features/bids/infrastructure/drift_bid_repository.dart';
import 'package:red_barrio/features/needs/domain/need.dart';
import 'package:red_barrio/features/sync/domain/usecases/flush_outbox.dart';

import '../fakes/fakes.dart';

Bid bid(String id, int soles, {BidKind kind = BidKind.sale, int minute = 0}) =>
    Bid(
      id: id,
      subjectId: 's1',
      kind: kind,
      bidder: id,
      amountSoles: soles,
      createdAt: DateTime(2026, 11, 8, 12, minute),
    );

void main() {
  group('rankBids: quién gana', () {
    test('en una venta gana la oferta más alta', () {
      final r = rankBids(BidKind.sale, [
        bid('a', 10),
        bid('b', 25),
        bid('c', 15),
      ]);
      expect(r.map((b) => b.id), ['b', 'c', 'a']);
    });

    test(
      'en un pedido gana la propuesta más baja, y 0 (solidario) gana a todas',
      () {
        final r = rankBids(BidKind.request, [
          bid('a', 30),
          bid('b', 0),
          bid('c', 12),
        ]);
        expect(r.map((b) => b.id), ['b', 'c', 'a']);
      },
    );

    test('a igual precio gana quien ofertó primero', () {
      final r = rankBids(BidKind.sale, [
        bid('tarde', 20, minute: 30),
        bid('pronto', 20, minute: 5),
      ]);
      expect(r.first.id, 'pronto');
    });

    test('no modifica la lista original', () {
      final original = [bid('a', 1), bid('b', 9)];
      rankBids(BidKind.sale, original);
      expect(original.first.id, 'a');
    });
  });

  group('Precio de referencia', () {
    test('lo saca del texto del anuncio', () {
      expect(parseReferenceSoles('Bidón de agua S/ 12'), 12);
      expect(parseReferenceSoles('desde S/45 la hora'), 45);
    });

    test('devuelve null si no hay precio', () {
      expect(parseReferenceSoles('Cotiza según tu pedido'), isNull);
    });
  });

  group('Ofertas de ejemplo', () {
    const sale = BidSubject(
      id: 'l-bodega',
      kind: BidKind.sale,
      title: 'Bodega Doña Rosa',
      byline: 'Rosa',
      referenceSoles: 20,
    );

    test(
      'son siempre las mismas para un anuncio y van marcadas como ejemplo',
      () {
        final now = DateTime(2026, 11, 8);
        final a = demoBidsFor(sale, now);
        final b = demoBidsFor(sale, now);
        expect(
          a.map((x) => (x.bidder, x.amountSoles)),
          b.map((x) => (x.bidder, x.amountSoles)),
        );
        expect(a.every((x) => x.isExample && !x.isMine), isTrue);
        expect(a, hasLength(2));
      },
    );

    test(
      'en una venta rodean el precio de referencia (una baja y una alta)',
      () {
        final amounts = demoBidsFor(
          sale,
          DateTime(2026),
        ).map((b) => b.amountSoles).toList();
        expect(amounts.any((a) => a < 20), isTrue);
        expect(amounts.any((a) => a > 20), isTrue);
      },
    );

    test('sin precio de referencia usan uno base y no fallan', () {
      const req = BidSubject(
        id: 'w1',
        kind: BidKind.request,
        title: 't',
        byline: 'x',
      );
      expect(demoBidsFor(req, DateTime(2026)), hasLength(2));
    });
  });

  group('PlaceBid', () {
    late AppDatabase db;
    late DriftBidRepository repo;
    late FakeOutbox outbox;
    late PlaceBid place;
    const subject = BidSubject(
      id: 's1',
      kind: BidKind.sale,
      title: 'Bidón',
      byline: 'Rosa',
    );

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = DriftBidRepository(db);
      outbox = FakeOutbox();
      place = PlaceBid(
        bids: repo,
        outbox: outbox,
        clock: FakeClock(DateTime(2026, 11, 8)),
        ids: FakeIds(),
      );
    });
    tearDown(() => db.close());

    test('guarda la oferta como Pendiente y la encola', () async {
      final r = await place(
        subject: subject,
        bidder: 'jose',
        amountText: ' 15 ',
        message: ' hoy ',
      );
      expect(r, isA<Ok>());
      final saved = (await repo.watchMine().first).single;
      expect(saved.amountSoles, 15);
      expect(saved.message, 'hoy');
      expect(saved.syncStatus, SyncStatus.pending);
      expect(outbox.ops.values.single.type, PlaceBid.opType);
    });

    test('acepta 0 (intercambio solidario)', () async {
      expect(
        await place(subject: subject, bidder: '', amountText: '0'),
        isA<Ok>(),
      );
    });

    test(
      'rechaza precios vacíos, negativos, con letras o demasiado grandes',
      () async {
        for (final bad in ['', 'abc', '-5', '12.5', '100000']) {
          expect(
            await place(subject: subject, bidder: '', amountText: bad),
            isA<Err>(),
            reason: bad,
          );
        }
        expect(await repo.watchMine().first, isEmpty);
      },
    );

    test('solo hay una oferta propia por anuncio: la nueva reemplaza a la anterior', () async {
      await place(subject: subject, bidder: '', amountText: '10');
      await place(subject: subject, bidder: '', amountText: '18');
      final mine = await repo.watchMine().first;
      expect(mine, hasLength(1));
      expect(mine.single.amountSoles, 18);
    });

    test('ofertas en anuncios distintos conviven', () async {
      await place(subject: subject, bidder: '', amountText: '10');
      const other = BidSubject(
        id: 's2',
        kind: BidKind.request,
        title: 'x',
        byline: 'y',
      );
      await place(subject: other, bidder: '', amountText: '30');
      expect(await repo.watchMine().first, hasLength(2));
    });

    test(
      'al volver la conexión la oferta pasa a Enviada en SU tabla',
      () async {
        final connectivity = FakeConnectivity(online: false);
        final flush = FlushOutbox(
          outbox: outbox,
          gateway: FakeGateway(),
          connectivity: connectivity,
          needs: FakeNeeds(),
          statusUpdaters: {PlaceBid.opType: repo.updateStatus},
        );
        await place(subject: subject, bidder: '', amountText: '10');
        await flush();
        expect(
          (await repo.watchMine().first).single.syncStatus,
          SyncStatus.pending,
        );
        connectivity.online = true;
        await flush();
        expect(
          (await repo.watchMine().first).single.syncStatus,
          SyncStatus.sent,
        );
      },
    );
  });

  test('Migración 6 → 7: gana la tabla de ofertas sin perder datos', () async {
    final executor = NativeDatabase.memory(
      setup: (raw) {
        raw.execute(
          'CREATE TABLE needs (id TEXT NOT NULL PRIMARY KEY, kind TEXT NOT NULL, body TEXT NOT NULL, urgency TEXT NOT NULL, created_at INTEGER NOT NULL, sync_status TEXT NOT NULL)',
        );
        raw.execute(
          'CREATE TABLE outbox_ops (id TEXT NOT NULL PRIMARY KEY, op_type TEXT NOT NULL, payload TEXT NOT NULL, attempts INTEGER NOT NULL DEFAULT 0, created_at INTEGER NOT NULL, last_error TEXT)',
        );
        raw.execute(
          "INSERT INTO needs VALUES ('viejo','help','Ayuda','now',1700000000,'sent')",
        );
        raw.execute('PRAGMA user_version = 6');
      },
    );
    final migrated = AppDatabase(executor);
    addTearDown(migrated.close);
    expect((await migrated.select(migrated.needs).get()).single.id, 'viejo');
    expect(await migrated.select(migrated.neighborBids).get(), isEmpty);
  });
}
