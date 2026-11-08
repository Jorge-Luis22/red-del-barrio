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

@DriftDatabase(tables: [Needs, OutboxOps])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// Base real en el teléfono.
  AppDatabase.open() : super(driftDatabase(name: 'red_barrio'));

  /// Versión del esquema. Cada cambio exige subirla y escribir su migración + prueba (R28).
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // Aquí irán las migraciones numeradas (from → to). Sin cambios todavía.
        },
      );
}
