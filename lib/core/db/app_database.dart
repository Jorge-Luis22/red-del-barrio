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
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// Base real en el teléfono.
  AppDatabase.open() : super(driftDatabase(name: 'red_barrio'));

  /// Versión del esquema. Cada cambio exige subirla y escribir su migración + prueba (R28).
  /// 1: needs, outbox_ops · 2: + deals, interactions
  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(deals);
        await m.createTable(interactions);
      }
      if (from < 4) {
        await m.createTable(offers);
        await m.createTable(chatMessages);
        await m.createTable(emergencyPosts);
        await m.createTable(collectionPoints);
        await m.createTable(appSettingsKv);
      }
    },
  );
}
