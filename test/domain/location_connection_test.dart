import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:red_barrio/core/db/app_database.dart';
import 'package:red_barrio/core/failure.dart';
import 'package:red_barrio/core/result.dart';
import 'package:red_barrio/core/storage_guard.dart';
import 'package:red_barrio/features/directory/domain/listing.dart';
import 'package:red_barrio/features/directory/infrastructure/demo_directory_repository.dart';
import 'package:red_barrio/features/explore/domain/explore_nearby.dart';
import 'package:red_barrio/features/location/domain/location_provider.dart';
import 'package:red_barrio/features/location/domain/usecases/get_location.dart';
import 'package:red_barrio/features/location/domain/zone.dart';
import 'package:red_barrio/features/location/domain/zone_memory.dart';
import 'package:red_barrio/features/location/infrastructure/settings_zone_memory.dart';
import 'package:red_barrio/features/reputation/domain/interaction.dart';
import 'package:red_barrio/features/reputation/domain/reputation_repository.dart';
import 'package:red_barrio/features/settings/infrastructure/drift_settings_repository.dart';
import 'package:red_barrio/features/sync/domain/connection_banner.dart';

class _FakeLocation implements LocationProvider {
  _FakeLocation({this.live, this.cached});

  /// `null` = el GPS falla.
  ExactLocation? live;
  ExactLocation? cached;
  bool askedPermission = false;

  @override
  Future<LocationAvailability> availability() async =>
      LocationAvailability.ready;

  @override
  Future<Result<ExactLocation>> currentLocation({
    bool askPermission = true,
  }) async {
    askedPermission = askPermission;
    final v = live;
    return v == null
        ? const Err(
            PermissionFailure(
              'Sin permiso de ubicación. Puedes elegir tu zona a mano.',
            ),
          )
        : Ok(v);
  }

  @override
  Future<ExactLocation?> lastKnown() async => cached;

  @override
  Future<void> openSettings(LocationAvailability reason) async {}
}

class _MemoryZone implements ZoneMemory {
  Zone? zone;

  @override
  Future<Zone?> load() async => zone;

  @override
  Future<void> save(Zone z) async => zone = z;

  @override
  Future<void> clear() async => zone = null;
}

class _NoReputation implements ReputationRepository {
  @override
  Future<List<Interaction>> forProvider(String providerId) async => const [];

  @override
  Future<Result<void>> record(Interaction interaction) async => const Ok(null);

  @override
  Stream<List<Interaction>> watchAll() => Stream.value(const []);
}

void main() {
  group('GetLocation: de la ubicación más precisa a la más vaga', () {
    test(
      'con GPS usa la lectura en vivo y recuerda SOLO la zona redondeada',
      () async {
        final memory = _MemoryZone();
        final r = await GetLocation(
          provider: _FakeLocation(
            live: const ExactLocation(-11.98903, -77.07123),
          ),
          memory: memory,
        )();
        final fix = (r as Ok<LocationFix>).value;
        expect(fix.source, LocationSource.live);
        expect(fix.location.isApproximate, isFalse);
        // Privacidad: lo guardado nunca es la coordenada exacta.
        expect(memory.zone!.lat, -11.99);
        expect(memory.zone!.lng, -77.07);
      },
    );

    test(
      'sin GPS usa la última posición del sistema y explica por qué',
      () async {
        final memory = _MemoryZone();
        final r = await GetLocation(
          provider: _FakeLocation(cached: const ExactLocation(-12.04, -77.03)),
          memory: memory,
        )();
        final fix = (r as Ok<LocationFix>).value;
        expect(fix.source, LocationSource.lastKnown);
        expect(fix.reason, isA<PermissionFailure>());
        expect(memory.zone, isNotNull);
      },
    );

    test('sin GPS ni posición del sistema usa la zona guardada y la marca aproximada', () async {
      final memory = _MemoryZone()..zone = const Zone(-12.05, -77.04);
      final r = await GetLocation(provider: _FakeLocation(), memory: memory)();
      final fix = (r as Ok<LocationFix>).value;
      expect(fix.source, LocationSource.savedZone);
      expect(fix.location.isApproximate, isTrue);
      expect(fix.location.lat, -12.05);
      expect(fix.reason, isNotNull);
    });

    test('sin nada de lo anterior devuelve el error original', () async {
      final r = await GetLocation(
        provider: _FakeLocation(),
        memory: _MemoryZone(),
      )();
      expect(r, isA<Err>());
      expect((r as Err<LocationFix>).failure, isA<PermissionFailure>());
    });

    test('sin permiso pedido no se muestra ningún cuadro de permiso', () async {
      final provider = _FakeLocation(live: const ExactLocation(-12, -77));
      await GetLocation(provider: provider, memory: _MemoryZone())(
        askPermission: false,
      );
      expect(provider.askedPermission, isFalse);
    });
  });

  group('Explorar cerca con la zona guardada', () {
    Future<List<ExploreItem>> explore(ExactLocation? near) => ExploreNearby(
      directory: const DemoDirectoryRepository(),
      reputation: _NoReputation(),
    )(kind: ListingKind.service, near: near);

    test('con lectura real las distancias son reales', () async {
      final items = await explore(const ExactLocation(-12.0, -77.0));
      expect(items, isNotEmpty);
      expect(items.every((i) => i.distanceIsReal), isTrue);
    });

    test(
      'con solo la zona guardada las distancias se rotulan aproximadas',
      () async {
        final items = await explore(
          const ExactLocation(-12.0, -77.0, isApproximate: true),
        );
        expect(items.every((i) => !i.distanceIsReal), isTrue);
        expect(items.every((i) => i.distanceMeters != null), isTrue);
      },
    );
  });

  group('La zona se guarda con los ajustes y se puede olvidar', () {
    test('guarda, relee y olvida la zona; useLocation se conserva', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final settings = DriftSettingsRepository(db);
      final memory = SettingsZoneMemory(settings);

      expect(await memory.load(), isNull);
      await memory.save(const Zone(-11.99, -77.07));
      await settings.update((s) => s.copyWith(useLocation: true));
      final z = (await memory.load())!;
      expect((z.lat, z.lng), (-11.99, -77.07));
      expect((await settings.watch().first).useLocation, isTrue);

      await memory.clear();
      expect(await memory.load(), isNull);
      expect((await settings.watch().first).useLocation, isTrue);
    });
  });

  group('Franja de conexión', () {
    ConnectionBanner b({
      bool online = true,
      int pending = 0,
      bool syncing = false,
      bool just = false,
    }) => deriveBanner(
      online: online,
      pending: pending,
      syncing: syncing,
      justSynced: just,
    );

    test('sin conexión siempre avisa, aunque no haya pendientes', () {
      expect(b(online: false), ConnectionBanner.offline);
      expect(
        b(online: false, pending: 3, syncing: true),
        ConnectionBanner.offline,
      );
    });

    test('con conexión y algo pendiente o enviando muestra "enviando"', () {
      expect(b(pending: 2), ConnectionBanner.syncing);
      expect(b(syncing: true), ConnectionBanner.syncing);
    });

    test('al terminar muestra "todo enviado" un momento y luego se oculta', () {
      expect(b(just: true), ConnectionBanner.synced);
      expect(b(), ConnectionBanner.hidden);
    });

    test('"enviando" tiene prioridad sobre "todo enviado"', () {
      expect(b(pending: 1, just: true), ConnectionBanner.syncing);
    });
  });

  group('guardStorage', () {
    test('devuelve Ok si la escritura funciona', () async {
      expect(await guardStorage('x', () async {}), isA<Ok>());
    });

    test(
      'traduce cualquier excepción a un StorageFailure con el mensaje dado',
      () async {
        final r = await guardStorage(
          'No se pudo guardar',
          () async => throw StateError('boom'),
        );
        expect(r, isA<Err>());
        final f = (r as Err<void>).failure;
        expect(f, isA<StorageFailure>());
        expect(f.message, 'No se pudo guardar');
      },
    );
  });
}
