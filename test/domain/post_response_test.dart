import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:red_barrio/core/db/app_database.dart';
import 'package:red_barrio/core/result.dart';
import 'package:red_barrio/features/needs/domain/need.dart';
import 'package:red_barrio/features/solidarity/domain/offer.dart';
import 'package:red_barrio/features/solidarity/domain/post_response.dart';
import 'package:red_barrio/features/solidarity/domain/wall_demo.dart';
import 'package:red_barrio/features/solidarity/infrastructure/drift_post_response_repository.dart';

import '../fakes/fakes.dart';

void main() {
  WallEntry byId(String id) => demoWall.firstWhere((e) => e.id == id);

  group('classifyOffer', () {
    test('cada modalidad de oferta tiene su tipo', () {
      expect(classifyOffer(byId('w2')), PostKind.loanOffer); // gratis
      expect(classifyOffer(byId('w3')), PostKind.barter); // trueque
      expect(classifyOffer(byId('w5')), PostKind.rentOffer); // alquiler
    });

    test('un pedido gratis o de trueque se responde sin dinero', () {
      expect(classifyOffer(byId('w1')), PostKind.helpFree);
      expect(classifyOffer(byId('w4')), PostKind.barterRequest);
    });

    test(
      'un pedido de alquiler se oferta con precio, no con este formulario',
      () {
        expect(classifyOffer(byId('w11')), isNull);
      },
    );

    test('una oferta propia no se puede responder', () {
      const mine = WallEntry(
        id: 'mia',
        author: 'Yo',
        text: 'Presto algo',
        modality: Modality.free,
        isRequest: false,
        isExample: false,
        syncStatus: SyncStatus.pending,
      );
      expect(classifyOffer(mine), isNull);
    });
  });

  test('el precio solo aparece donde hay alquiler', () {
    expect(fieldsFor(PostKind.rentOffer), contains(ResponseField.price));
    for (final k in PostKind.values.where((k) => k != PostKind.rentOffer)) {
      expect(fieldsFor(k), isNot(contains(ResponseField.price)), reason: '$k');
    }
  });

  test('el trueque siempre pide algo a cambio', () {
    expect(
      requiredFor(PostKind.barter),
      contains(ResponseField.offeredResource),
    );
    expect(
      requiredFor(PostKind.barterRequest),
      contains(ResponseField.inExchange),
    );
  });

  test('el muro tiene al menos 3 publicaciones por modalidad y por lado', () {
    for (final m in Modality.values) {
      for (final pide in [true, false]) {
        final n = demoWall
            .where((e) => e.modality == m && e.isRequest == pide)
            .length;
        expect(n, greaterThanOrEqualTo(3), reason: '$m pide=$pide');
      }
    }
    final ids = demoWall.map((e) => e.id).toList();
    expect(ids.toSet().length, ids.length);
    expect(demoWall.every((e) => (e.textEn ?? '').isNotEmpty), isTrue);
  });

  group('SendPostResponse', () {
    late AppDatabase db;
    late DriftPostResponseRepository repo;
    late FakeOutbox outbox;
    late SendPostResponse send;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = DriftPostResponseRepository(db);
      outbox = FakeOutbox();
      send = SendPostResponse(
        responses: repo,
        outbox: outbox,
        clock: FakeClock(DateTime(2026, 11, 8)),
        ids: FakeIds(),
      );
    });
    tearDown(() => db.close());

    test('guarda la propuesta como Pendiente y la encola', () async {
      final r = await send(byId('w2'), PostKind.loanOffer, {
        ResponseField.duration: ' 2 días ',
        ResponseField.message: 'Gracias',
      });
      expect(r, isA<Ok>());
      final saved = (await repo.watchMine().first).single;
      expect(saved.postId, 'w2');
      expect(saved.values['duration'], '2 días');
      expect(saved.syncStatus, SyncStatus.pending);
      expect(outbox.ops.values.single.type, SendPostResponse.opType);
    });

    test('exige los datos obligatorios del tipo', () async {
      final r = await send(byId('w3'), PostKind.barter, {});
      expect(r, isA<Err>());
      expect(await repo.watchMine().first, isEmpty);
      expect(outbox.ops, isEmpty);
    });

    test('el alquiler pide un precio válido', () async {
      final r = await send(byId('w5'), PostKind.rentOffer, {
        ResponseField.price: '0',
        ResponseField.duration: '1 día',
      });
      expect(r, isA<Err>());
    });

    test('no se responde dos veces a la misma publicación', () async {
      final input = {ResponseField.duration: '1 día'};
      expect(await send(byId('w2'), PostKind.loanOffer, input), isA<Ok>());
      expect(await send(byId('w2'), PostKind.loanOffer, input), isA<Err>());
      expect((await repo.watchMine().first).length, 1);
    });
  });
}
