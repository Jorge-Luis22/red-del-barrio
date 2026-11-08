import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// Necesidades publicadas por esta persona (copia local).
@DataClassName('NeedRow')
class Needs extends Table {
  TextColumn get id => text()();
  TextColumn get kind => text()();
  TextColumn get body => text()();
  TextColumn get urgency => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get syncStatus => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cola de pendientes. La clave primaria es el UUID de cliente: encolar dos veces no duplica.
@DataClassName('OutboxRow')
class OutboxOps extends Table {
  TextColumn get id => text()();
  TextColumn get opType => text()();
  TextColumn get payload => text()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tratos (propuesta aceptada → código → servicio → calificación). Desde el esquema 2.
@DataClassName('DealRow')
class Deals extends Table {
  TextColumn get id => text()();
  TextColumn get needId => text()();
  TextColumn get providerId => text()();
  TextColumn get providerName => text()();
  IntColumn get priceSoles => integer()();
  TextColumn get priceLabel => text()();
  TextColumn get code => text()();
  TextColumn get status => text()();
  DateTimeColumn get acceptedAt => dateTime()();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get cancelReason => text().nullable()();
  DateTimeColumn get cancelledAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tratos cerrados y calificados: única fuente de reputación y Visto Bueno reales. Desde el esquema 2.
@DataClassName('InteractionRow')
class Interactions extends Table {
  TextColumn get id => text()();
  TextColumn get dealId => text()();
  TextColumn get providerId => text()();
  TextColumn get raterId => text()();
  IntColumn get stars => integer()();
  BoolColumn get recommended => boolean()();
  DateTimeColumn get closedAt => dateTime()();
  TextColumn get comment => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('OfferRow')
class Offers extends Table {
  @override
  String get tableName => 'neighbor_offers';

  TextColumn get id => text()();
  TextColumn get modality => text()();
  TextColumn get body => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get syncStatus => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ChatMessageRow')
class ChatMessages extends Table {
  @override
  String get tableName => 'deal_messages';

  TextColumn get id => text()();
  TextColumn get dealId => text()();
  TextColumn get body => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get syncStatus => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('EmergencyPostRow')
class EmergencyPosts extends Table {
  @override
  String get tableName => 'sos_posts';

  TextColumn get id => text()();
  TextColumn get situation => text()();
  TextColumn get body => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get syncStatus => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CollectionPointRow')
class CollectionPoints extends Table {
  @override
  String get tableName => 'acopio_points';

  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get reference => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SettingRow')
class AppSettingsKv extends Table {
  @override
  String get tableName => 'person_settings';

  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DataClassName('ProfileRow')
class PersonProfile extends Table {
  @override
  String get tableName => 'person_profile';

  TextColumn get id => text()();
  TextColumn get username => text()();
  TextColumn get email => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get photoPath => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('AddressRow')
class PersonAddresses extends Table {
  @override
  String get tableName => 'person_addresses';

  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get reference => text().withDefault(const Constant(''))();
  RealColumn get lat => real()();
  RealColumn get lng => real()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TrustedContactRow')
class TrustedContacts extends Table {
  @override
  String get tableName => 'trusted_contacts';

  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get phone => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('BidRow')
class NeighborBids extends Table {
  @override
  String get tableName => 'neighbor_bids';

  TextColumn get id => text()();
  TextColumn get subjectId => text()();
  TextColumn get kind => text()();
  TextColumn get bidder => text()();
  IntColumn get amount => integer()();
  TextColumn get message => text().withDefault(const Constant(''))();
  TextColumn get whenText => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get syncStatus => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PostResponseRow')
class PostResponses extends Table {
  @override
  String get tableName => 'post_responses';

  TextColumn get id => text()();
  TextColumn get postId => text()();
  TextColumn get kind => text()();
  TextColumn get valuesJson => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get syncStatus => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Contraofertas presenciales del prestador (máximo 2 por trato). Desde el esquema 10.
@DataClassName('PriceChangeRow')
class PriceChanges extends Table {
  @override
  String get tableName => 'price_changes';

  TextColumn get id => text()();
  TextColumn get dealId => text()();
  IntColumn get previousPrice => integer()();
  IntColumn get newPrice => integer()();
  TextColumn get reason => text()();
  TextColumn get status => text()();
  TextColumn get author => text().withDefault(const Constant('provider'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get resolvedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    Needs,
    OutboxOps,
    Deals,
    Interactions,
    Offers,
    ChatMessages,
    EmergencyPosts,
    CollectionPoints,
    AppSettingsKv,
    PersonProfile,
    PersonAddresses,
    TrustedContacts,
    NeighborBids,
    PostResponses,
    PriceChanges,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// Base real en el teléfono.
  AppDatabase.open() : super(driftDatabase(name: 'red_barrio'));

  /// Versión del esquema. Cada cambio exige subirla y escribir su migración + prueba (R28).
  /// 1: needs, outbox_ops · 2: + deals, interactions
  @override
  int get schemaVersion => 10;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(deals);
        await m.createTable(interactions);
      }
      if (from < 7) {
        await m.createTable(neighborBids);
      }
      if (from < 6) {
        await m.createTable(trustedContacts);
      }
      if (from < 5) {
        await m.createTable(personProfile);
        await m.createTable(personAddresses);
      }
      if (from < 4) {
        await m.createTable(offers);
        await m.createTable(chatMessages);
        await m.createTable(emergencyPosts);
        await m.createTable(collectionPoints);
        await m.createTable(appSettingsKv);
      }
      if (from < 10) {
        await m.createTable(priceChanges);
        // Los tratos ganan el motivo de cancelación (si la tabla ya existía sin ellas).
        final cols = await customSelect("PRAGMA table_info('deals')").get();
        final names = cols.map((c) => c.read<String>('name')).toSet();
        if (names.isNotEmpty && !names.contains('cancel_reason')) {
          await m.addColumn(deals, deals.cancelReason);
          await m.addColumn(deals, deals.cancelledAt);
        }
      }
      if (from < 9) {
        await m.createTable(postResponses);
      }
      if (from < 8) {
        // El perfil gana la foto. Si la tabla se acaba de crear ya la trae.
        final cols = await customSelect("PRAGMA table_info('person_profile')")
            .get();
        final hasPhoto = cols.any(
          (c) => c.read<String>('name') == 'photo_path',
        );
        if (cols.isNotEmpty && !hasPhoto) {
          await m.addColumn(personProfile, personProfile.photoPath);
        }
      }
    },
  );
}
