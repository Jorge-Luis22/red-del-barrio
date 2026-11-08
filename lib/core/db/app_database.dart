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

@DriftDatabase(tables: [Needs, OutboxOps, Deals, Interactions])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// Base real en el teléfono.
  AppDatabase.open() : super(driftDatabase(name: 'red_barrio'));

  /// Versión del esquema. Cada cambio exige subirla y escribir su migración + prueba (R28).
  /// 1: needs, outbox_ops · 2: + deals, interactions
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(deals);
            await m.createTable(interactions);
          }
        },
      );
}
