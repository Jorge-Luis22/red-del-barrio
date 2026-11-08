import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:red_barrio/core/db/app_database.dart';
import 'package:red_barrio/core/result.dart';
import 'package:red_barrio/features/emergency/domain/emergency.dart';
import 'package:red_barrio/features/emergency/domain/usecases/emergency_usecases.dart';
import 'package:red_barrio/features/emergency/infrastructure/drift_emergency_repository.dart';
import 'package:red_barrio/features/emergency/presentation/alert_sms.dart';
import 'package:red_barrio/features/location/domain/zone.dart';
import 'package:red_barrio/features/settings/infrastructure/drift_settings_repository.dart';
import 'package:red_barrio/l10n/app_localizations_en.dart';
import 'package:red_barrio/l10n/app_localizations_es.dart';

import '../fakes/fakes.dart';

void main() {
  late AppDatabase db;
  late DriftEmergencyRepository repo;
  late AddContact add;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftEmergencyRepository(db);
    add = AddContact(
      emergency: repo,
      clock: FakeClock(DateTime(2026, 11, 8)),
      ids: FakeIds(),
    );
  });
  tearDown(() => db.close());

  group('Teléfono del contacto', () {
    test('acepta formatos comunes y los deja solo con dígitos', () {
      expect(AddContact.normalizePhone('987 654 321'), '987654321');
      expect(AddContact.normalizePhone('+51 987-654-321'), '+51987654321');
      expect(AddContact.normalizePhone('(01) 234 5678'), '012345678');
    });

    test('rechaza lo que no parece un teléfono', () {
      for (final bad in [
        '',
        'abc',
        '123',
        '12345678901234567',
        '98765x321',
        '++51987654321',
      ]) {
        expect(AddContact.normalizePhone(bad), isNull, reason: bad);
      }
    });
  });

  group('AddContact', () {
    test('guarda nombre y teléfono normalizado', () async {
      final r = await add(name: '  Mamá ', phone: '987 654 321');
      expect(r, isA<Ok>());
      final c = (await repo.contacts()).single;
      expect(c.name, 'Mamá');
      expect(c.phone, '987654321');
    });

    test('exige nombre y un teléfono válido', () async {
      expect(await add(name: ' ', phone: '987654321'), isA<Err>());
      expect(await add(name: 'Ana', phone: 'abc'), isA<Err>());
      expect(await repo.contacts(), isEmpty);
    });

    test('no repite el mismo teléfono aunque venga con otro formato', () async {
      await add(name: 'Ana', phone: '987654321');
      final r = await add(name: 'Ana otra vez', phone: '987 654 321');
      expect(r, isA<Err>());
      expect((r as Err).failure.message, AddContact.duplicate);
      expect(await repo.contacts(), hasLength(1));
    });

    test('limita la cantidad de contactos', () async {
      for (var i = 0; i < maxTrustedContacts; i++) {
        expect(await add(name: 'Contacto $i', phone: '98765432$i'), isA<Ok>());
      }
      final r = await add(name: 'Uno más', phone: '911111111');
      expect((r as Err).failure.message, AddContact.tooMany);
    });

    test('eliminar quita solo ese contacto', () async {
      await add(name: 'Ana', phone: '987654321');
      await add(name: 'Beto', phone: '912345678');
      final id = (await repo.contacts()).first.id;
      await repo.deleteContact(id);
      expect((await repo.contacts()).map((c) => c.name), ['Beto']);
    });
  });

  group('Mensaje de SMS de aviso', () {
    final es = AppLocalizationsEs();
    final en = AppLocalizationsEn();
    const zone = Zone(-11.99, -77.07);

    test(
      'lleva la situación, el texto, la zona de ~1 km y el pie de seguridad',
      () {
        final sms = buildAlertSms(
          es,
          situation: SosSituation.medical,
          text: 'Mi abuela se cayó',
          zone: zone,
          reference: 'frente al parque',
        );
        expect(sms, contains('ALERTA (Médico): Mi abuela se cayó'));
        expect(sms, contains('-11.99, -77.07 (~1 km)'));
        expect(sms, contains('https://maps.google.com/?q=-11.99,-77.07'));
        expect(sms, contains('Referencia: frente al parque'));
        expect(sms, contains('llama a emergencias'));
      },
    );

    test(
      'PRIVACIDAD: solo puede llevar la zona redondeada, nunca más decimales',
      () {
        final sms = buildAlertSms(
          es,
          situation: SosSituation.fire,
          text: 'Incendio',
          zone: const ExactLocation(-11.98903, -77.07123).zone,
        );
        expect(sms, contains('-11.99, -77.07'));
        expect(sms, isNot(contains('98903')));
        expect(sms, isNot(contains('07123')));
      },
    );

    test(
      'sin texto usa la frase de la situación y sin zona omite esa línea',
      () {
        final sms = buildAlertSms(
          es,
          situation: SosSituation.earthquake,
          text: '  ',
        );
        expect(sms, contains('Hubo un sismo y necesito ayuda.'));
        expect(sms, isNot(contains('zona aprox')));
      },
    );

    test('sin referencia no agrega esa línea', () {
      final sms = buildAlertSms(
        es,
        situation: SosSituation.fire,
        text: 'x',
        zone: zone,
      );
      expect(sms, isNot(contains('Referencia')));
    });

    test('sale en inglés cuando el idioma es inglés', () {
      final sms = buildAlertSms(
        en,
        situation: SosSituation.medical,
        text: 'Help',
        zone: zone,
      );
      expect(sms, startsWith('ALERT (Medical): Help'));
      expect(sms, contains('My approx. area'));
    });
  });

  group('URI de SMS', () {
    test(
      'junta a todos los contactos y codifica el espacio como %20 (no como +)',
      () {
        final uri = buildSmsUri([
          '+51987654321',
          '912345678',
        ], 'Hola, ayuda\nya');
        final text = uri.toString();
        expect(text, startsWith('sms:+51987654321,912345678?body='));
        expect(text, contains('Hola%2C%20ayuda%0Aya'));
        expect(text, isNot(contains('+ayuda')));
      },
    );
  });

  group('Plan: mochila y punto de encuentro', () {
    test('se guardan en los ajustes, se releen y se pueden borrar', () async {
      final settings = DriftSettingsRepository(db);
      await settings.update(
        (s) => s.copyWith(
          packedItems: {'water', 'radio'},
          meetingPoint: 'Parque de la esquina',
        ),
      );
      var s = await settings.watch().first;
      expect(s.packedItems, {'water', 'radio'});
      expect(s.meetingPoint, 'Parque de la esquina');

      await settings.update(
        (s) => s.copyWith(packedItems: {'water'}, meetingPoint: ''),
      );
      s = await settings.watch().first;
      expect(s.packedItems, {'water'});
      expect(s.meetingPoint, isEmpty);
    });

    test('la mochila tiene 11 cosas, sin repetidos', () {
      expect(backpackItems.toSet(), hasLength(backpackItems.length));
      expect(backpackItems, hasLength(11));
    });

    test('borrar mis datos también borra los contactos', () async {
      await add(name: 'Ana', phone: '987654321');
      await DriftSettingsRepository(db).eraseAll();
      expect(await repo.contacts(), isEmpty);
    });
  });

  test(
    'Migración 5 → 6: gana la tabla de contactos sin perder datos',
    () async {
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
          raw.execute('PRAGMA user_version = 5');
        },
      );
      final migrated = AppDatabase(executor);
      addTearDown(migrated.close);
      expect((await migrated.select(migrated.needs).get()).single.id, 'viejo');
      expect(await migrated.select(migrated.trustedContacts).get(), isEmpty);
    },
  );
}
