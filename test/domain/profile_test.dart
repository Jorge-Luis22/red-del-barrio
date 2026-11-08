import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:red_barrio/core/db/app_database.dart';
import 'package:red_barrio/core/result.dart';
import 'package:red_barrio/features/location/domain/zone.dart';
import 'package:red_barrio/features/profile/domain/profile.dart';
import 'package:red_barrio/features/profile/domain/usecases/profile_usecases.dart';
import 'package:red_barrio/features/profile/infrastructure/drift_profile_repository.dart';

import '../fakes/fakes.dart';

void main() {
  late AppDatabase db;
  late DriftProfileRepository repo;
  late FakeClock clock;
  late FakeIds ids;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftProfileRepository(db);
    clock = FakeClock(DateTime(2026, 11, 8));
    ids = FakeIds();
  });
  tearDown(() => db.close());

  group('SaveProfile', () {
    SaveProfile save() => SaveProfile(profiles: repo, clock: clock);

    test('guarda usuario y correo y los devuelve al releer', () async {
      final r = await save()(
        username: '  jose_hurtado ',
        email: 'jose@correo.com',
      );
      expect(r, isA<Ok>());
      final p = (await repo.watchProfile().first)!;
      expect(p.username, 'jose_hurtado');
      expect(p.email, 'jose@correo.com');
    });

    test('el correo es opcional y vacío se guarda como nulo', () async {
      await save()(username: 'vecina.ana', email: '   ');
      expect((await repo.watchProfile().first)!.email, isNull);
    });

    test('rechaza usuarios cortos, largos o con espacios y símbolos', () async {
      for (final bad in ['ab', 'a' * 21, 'con espacio', 'raro!', '']) {
        final r = await save()(username: bad);
        expect(r, isA<Err>(), reason: bad);
      }
      expect(await repo.watchProfile().first, isNull);
    });

    test('acepta letras con tilde y la eñe', () async {
      expect(await save()(username: 'María_Núñez'), isA<Ok>());
    });

    test('rechaza un correo mal escrito', () async {
      expect(await save()(username: 'jose', email: 'sin-arroba'), isA<Err>());
      expect(await save()(username: 'jose', email: 'a@b'), isA<Err>());
    });

    test('al editar conserva la fecha de creación', () async {
      final first = (await save()(username: 'jose')) as Ok<UserProfile>;
      clock.current = DateTime(2027);
      await save()(username: 'jose2', current: first.value);
      final p = (await repo.watchProfile().first)!;
      expect(p.username, 'jose2');
      expect(p.createdAt, DateTime(2026, 11, 8));
    });
  });

  group('AddAddress', () {
    AddAddress add() => AddAddress(profiles: repo, clock: clock, ids: ids);
    const here = ExactLocation(-11.98903, -77.07123);

    test('sin ubicación o sin nombre no guarda nada', () async {
      expect(await add()(name: 'Casa', location: null), isA<Err>());
      expect(await add()(name: ' ', location: here), isA<Err>());
      expect(await repo.addresses(), isEmpty);
    });

    test('la primera dirección queda activa y las siguientes no', () async {
      await add()(name: 'Casa', location: here);
      await add()(
        name: 'Trabajo',
        location: const ExactLocation(-12.05, -77.04),
      );
      final all = await repo.addresses();
      expect(all.map((a) => a.name), ['Casa', 'Trabajo']);
      expect(all.map((a) => a.isActive), [true, false]);
    });

    test(
      'la dirección exacta queda en el teléfono y la zona sale redondeada',
      () async {
        await add()(
          name: 'Casa',
          location: here,
          reference: ' frente al parque ',
        );
        final a = (await repo.addresses()).single;
        expect(a.lat, -11.98903);
        expect(a.reference, 'frente al parque');
        expect((a.zone.lat, a.zone.lng), (-11.99, -77.07));
      },
    );
  });

  group('Direcciones: activa y eliminación', () {
    Future<void> three() async {
      for (final n in ['Casa', 'Trabajo', 'Otra']) {
        await AddAddress(profiles: repo, clock: clock, ids: ids)(
          name: n,
          location: const ExactLocation(-12, -77),
        );
        clock.current = clock.current.add(const Duration(minutes: 1));
      }
    }

    test(
      'activar una desactiva las demás: siempre hay una sola activa',
      () async {
        await three();
        final all = await repo.addresses();
        await repo.setActive(all[2].id);
        final after = await repo.addresses();
        expect(after.where((a) => a.isActive).map((a) => a.name), ['Otra']);
      },
    );

    test('eliminar la activa deja activa a la primera que queda', () async {
      await three();
      final all = await repo.addresses();
      await repo.deleteAddress(all[0].id); // Casa, la activa
      final after = await repo.addresses();
      expect(after.map((a) => a.name), ['Trabajo', 'Otra']);
      expect(after.where((a) => a.isActive).map((a) => a.name), ['Trabajo']);
    });

    test('eliminar una que no es la activa no cambia la activa', () async {
      await three();
      final all = await repo.addresses();
      await repo.deleteAddress(all[2].id);
      expect(
        (await repo.addresses()).firstWhere((a) => a.isActive).name,
        'Casa',
      );
    });

    test('eliminar la última deja la lista vacía sin errores', () async {
      await AddAddress(profiles: repo, clock: clock, ids: ids)(
        name: 'Casa',
        location: const ExactLocation(-12, -77),
      );
      final id = (await repo.addresses()).single.id;
      expect(await repo.deleteAddress(id), isA<Ok>());
      expect(await repo.addresses(), isEmpty);
    });
  });

  group('pickOrigin: desde dónde se miden las distancias', () {
    const gps = ExactLocation(-12.0, -77.0);
    final active = SavedAddress(
      id: 'a',
      name: 'Casa',
      lat: -11.5,
      lng: -77.5,
      createdAt: DateTime(2026),
      isActive: true,
    );

    test('con dirección activa se usa esa, aunque haya GPS', () {
      expect(pickOrigin(active: active, gps: gps)!.lat, -11.5);
    });

    test('sin dirección activa se usa el GPS', () {
      expect(pickOrigin(gps: gps)!.lat, -12.0);
    });

    test('sin nada no hay origen', () {
      expect(pickOrigin(), isNull);
    });
  });

  test(
    'Migración 4 → 5: gana las tablas de perfil y direcciones sin perder datos',
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
          raw.execute('PRAGMA user_version = 4');
        },
      );
      final migrated = AppDatabase(executor);
      addTearDown(migrated.close);
      expect((await migrated.select(migrated.needs).get()).single.id, 'viejo');
      expect(await migrated.select(migrated.personProfile).get(), isEmpty);
      expect(await migrated.select(migrated.personAddresses).get(), isEmpty);
    },
  );
}
