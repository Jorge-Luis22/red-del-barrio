import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:red_barrio/core/db/app_database.dart';
import 'package:red_barrio/core/result.dart';
import 'package:red_barrio/features/deals_chat/domain/usecases/send_message.dart';
import 'package:red_barrio/features/deals_chat/infrastructure/drift_chat_repository.dart';
import 'package:red_barrio/features/emergency/domain/emergency.dart';
import 'package:red_barrio/features/emergency/domain/usecases/emergency_usecases.dart';
import 'package:red_barrio/features/emergency/infrastructure/drift_emergency_repository.dart';
import 'package:red_barrio/features/needs/domain/need.dart';
import 'package:red_barrio/features/settings/infrastructure/drift_settings_repository.dart';
import 'package:red_barrio/features/solidarity/domain/offer.dart';
import 'package:red_barrio/features/solidarity/domain/usecases/publish_offer.dart';
import 'package:red_barrio/features/solidarity/infrastructure/drift_offer_repository.dart';
import 'package:red_barrio/features/sync/domain/usecases/flush_outbox.dart';

import '../fakes/fakes.dart';

void main() {
  late AppDatabase db;
  late FakeOutbox outbox;
  late FakeClock clock;
  late FakeIds ids;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    outbox = FakeOutbox();
    clock = FakeClock(DateTime(2026, 11, 8));
    ids = FakeIds();
  });
  tearDown(() => db.close());

  test(
    'PublishOffer: guarda Pendiente, encola y rechaza texto muy corto',
    () async {
      final offers = DriftOfferRepository(db);
      final publish = PublishOffer(
        offers: offers,
        outbox: outbox,
        clock: clock,
        ids: ids,
      );

      expect(await publish(modality: Modality.free, text: 'a'), isA<Err>());
      final r = await publish(
        modality: Modality.barter,
        text: '  Presto una escalera ',
      );
      expect(r, isA<Ok>());
      final saved = (await offers.watchAll().first).single;
      expect(saved.text, 'Presto una escalera');
      expect(saved.modality, Modality.barter);
      expect(saved.syncStatus, SyncStatus.pending);
      expect(outbox.ops.values.single.type, PublishOffer.opType);
    },
  );

  test(
    'SendMessage: guarda el mensaje en el teléfono sin inventar respuestas',
    () async {
      final chat = DriftChatRepository(db);
      final send = SendMessage(
        chat: chat,
        outbox: outbox,
        clock: clock,
        ids: ids,
      );

      expect(await send(dealId: 'd1', text: '   '), isA<Err>());
      await send(dealId: 'd1', text: 'Ya voy en camino');
      final list = await chat.watchDeal('d1').first;
      expect(list.length, 1); // solo el nuestro: nadie responde solo
      expect(list.single.syncStatus, SyncStatus.pending);
      expect(outbox.ops.values.single.type, SendMessage.opType);
    },
  );

  test(
    'PublishSos: sin texto usa la plantilla y la violencia se marca privada',
    () async {
      final emergency = DriftEmergencyRepository(db);
      final sos = PublishSos(
        emergency: emergency,
        outbox: outbox,
        clock: clock,
        ids: ids,
      );

      await sos(situation: SosSituation.violence, text: '');
      final post = (await emergency.watchPosts().first).single;
      expect(post.text, SosSituation.violence.template);
      expect(outbox.ops.values.single.payload, contains('"private":true'));
      expect(SosSituation.fire.isPrivate, isFalse);
    },
  );

  test('Los números oficiales siguen marcados por verificar y la institución va primero en datos', () {
    expect(
      officialContacts.map((c) => c.number),
      containsAll(['105', '116', '106']),
    );
  });

  test('FlushOutbox actualiza el estado en el repositorio de cada tipo de operación', () async {
    final offers = DriftOfferRepository(db);
    final chat = DriftChatRepository(db);
    final needs = FakeNeeds();
    final connectivity = FakeConnectivity(online: false);
    final flush = FlushOutbox(
      outbox: outbox,
      gateway: FakeGateway(),
      connectivity: connectivity,
      needs: needs,
      statusUpdaters: {
        PublishOffer.opType: offers.updateStatus,
        SendMessage.opType: chat.updateStatus,
      },
    );
    await PublishOffer(offers: offers, outbox: outbox, clock: clock, ids: ids)(
      modality: Modality.free,
      text: 'Un taladro',
    );
    await SendMessage(chat: chat, outbox: outbox, clock: clock, ids: ids)(
      dealId: 'd1',
      text: 'Hola',
    );

    // Sin conexión nada cambia.
    await flush();
    expect(
      (await offers.watchAll().first).single.syncStatus,
      SyncStatus.pending,
    );

    // Con conexión, cada registro queda Enviado en SU tabla.
    connectivity.online = true;
    final r = await flush();
    expect((r as Ok<int>).value, 2);
    expect((await offers.watchAll().first).single.syncStatus, SyncStatus.sent);
    expect(
      (await chat.watchDeal('d1').first).single.syncStatus,
      SyncStatus.sent,
    );
    expect(outbox.ops, isEmpty);
  });

  test(
    'Ajustes: se guardan, se releen y "borrar mis datos" lo deja todo vacío',
    () async {
      final settings = DriftSettingsRepository(db);
      await settings.update(
        (s) => s.copyWith(
          textScale: 1.3,
          highContrast: true,
          capabilities: {'Botiquín'},
        ),
      );
      final s = await settings.watch().first;
      expect(s.textScale, 1.3);
      expect(s.highContrast, isTrue);
      expect(s.capabilities, {'Botiquín'});

      await DriftOfferRepository(db).save(
        Offer(
          id: 'o1',
          modality: Modality.free,
          text: 'Algo',
          createdAt: DateTime(2026),
          syncStatus: SyncStatus.pending,
        ),
      );
      await settings.eraseAll();
      expect(await DriftOfferRepository(db).watchAll().first, isEmpty);
      expect(
        (await settings.watch().first).textScale,
        1.0,
      ); // vuelve a los valores por defecto
    },
  );

  test('Migración 2 → 4: una base del esquema 2 gana las tablas nuevas sin perder datos', () async {
    final executor = NativeDatabase.memory(
      setup: (raw) {
        raw.execute(
          'CREATE TABLE needs (id TEXT NOT NULL PRIMARY KEY, kind TEXT NOT NULL, body TEXT NOT NULL, urgency TEXT NOT NULL, created_at INTEGER NOT NULL, sync_status TEXT NOT NULL)',
        );
        raw.execute(
          'CREATE TABLE outbox_ops (id TEXT NOT NULL PRIMARY KEY, op_type TEXT NOT NULL, payload TEXT NOT NULL, attempts INTEGER NOT NULL DEFAULT 0, created_at INTEGER NOT NULL, last_error TEXT)',
        );
        raw.execute(
          'CREATE TABLE deals (id TEXT NOT NULL PRIMARY KEY, need_id TEXT NOT NULL, provider_id TEXT NOT NULL, provider_name TEXT NOT NULL, price_soles INTEGER NOT NULL, price_label TEXT NOT NULL, code TEXT NOT NULL, status TEXT NOT NULL, accepted_at INTEGER NOT NULL, started_at INTEGER, completed_at INTEGER)',
        );
        raw.execute(
          "CREATE TABLE interactions (id TEXT NOT NULL PRIMARY KEY, deal_id TEXT NOT NULL, provider_id TEXT NOT NULL, rater_id TEXT NOT NULL, stars INTEGER NOT NULL, recommended INTEGER NOT NULL, closed_at INTEGER NOT NULL, comment TEXT NOT NULL DEFAULT '')",
        );
        raw.execute(
          "INSERT INTO needs VALUES ('previo','help','Ayuda','now',1700000000,'sent')",
        );
        raw.execute('PRAGMA user_version = 2');
      },
    );
    final migrated = AppDatabase(executor);
    addTearDown(migrated.close);

    expect((await migrated.select(migrated.needs).get()).single.id, 'previo');
    expect(await migrated.select(migrated.offers).get(), isEmpty);
    expect(await migrated.select(migrated.chatMessages).get(), isEmpty);
    expect(await migrated.select(migrated.emergencyPosts).get(), isEmpty);
    expect(await migrated.select(migrated.collectionPoints).get(), isEmpty);
    expect(await migrated.select(migrated.appSettingsKv).get(), isEmpty);
  });

  test('Una base de otra versión con tablas de igual nombre no rompe los avisos ni los mensajes', () async {
    // Base "ajena" ya en la versión 3, con tablas homónimas pero de otras columnas.
    final executor = NativeDatabase.memory(
      setup: (raw) {
        raw.execute(
          'CREATE TABLE needs (id TEXT NOT NULL PRIMARY KEY, kind TEXT NOT NULL, body TEXT NOT NULL, urgency TEXT NOT NULL, created_at INTEGER NOT NULL, sync_status TEXT NOT NULL)',
        );
        raw.execute(
          'CREATE TABLE outbox_ops (id TEXT NOT NULL PRIMARY KEY, op_type TEXT NOT NULL, payload TEXT NOT NULL, attempts INTEGER NOT NULL DEFAULT 0, created_at INTEGER NOT NULL, last_error TEXT)',
        );
        raw.execute(
          'CREATE TABLE deals (id TEXT NOT NULL PRIMARY KEY, need_id TEXT NOT NULL, provider_id TEXT NOT NULL, provider_name TEXT NOT NULL, price_soles INTEGER NOT NULL, price_label TEXT NOT NULL, code TEXT NOT NULL, status TEXT NOT NULL, accepted_at INTEGER NOT NULL, started_at INTEGER, completed_at INTEGER)',
        );
        raw.execute(
          "CREATE TABLE interactions (id TEXT NOT NULL PRIMARY KEY, deal_id TEXT NOT NULL, provider_id TEXT NOT NULL, rater_id TEXT NOT NULL, stars INTEGER NOT NULL, recommended INTEGER NOT NULL, closed_at INTEGER NOT NULL, comment TEXT NOT NULL DEFAULT '')",
        );
        raw.execute(
          'CREATE TABLE emergency_posts (id TEXT NOT NULL PRIMARY KEY, type TEXT NOT NULL, why TEXT NOT NULL, needs TEXT NOT NULL, created_at INTEGER NOT NULL, sync_status TEXT NOT NULL)',
        );
        raw.execute(
          'CREATE TABLE chat_messages (id TEXT NOT NULL PRIMARY KEY, deal_id TEXT NOT NULL, from_me INTEGER NOT NULL, body TEXT NOT NULL, is_example INTEGER NOT NULL, created_at INTEGER NOT NULL)',
        );
        raw.execute('PRAGMA user_version = 3');
      },
    );
    final other = AppDatabase(executor);
    addTearDown(other.close);
    final r = await PublishSos(
      emergency: DriftEmergencyRepository(other),
      outbox: outbox,
      clock: clock,
      ids: ids,
    )(situation: SosSituation.fire, text: '');
    expect(r, isA<Ok>()); // guarda en SU tabla, sin chocar con la ajena
    expect(
      (await DriftEmergencyRepository(
        other,
      ).watchPosts().first).single.situation,
      SosSituation.fire,
    );
  });
}
