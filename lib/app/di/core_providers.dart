import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clock.dart';
import '../../core/db/app_database.dart';
import '../../core/ids.dart';
import '../../core/infrastructure/uuid_id_generator.dart';

/// Piezas comunes: base de datos, reloj e identificadores.

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.open();
  ref.onDispose(db.close);
  return db;
});

final clockProvider = Provider<Clock>((_) => const SystemClock());
final idGeneratorProvider = Provider<IdGenerator>((_) => UuidIdGenerator());
