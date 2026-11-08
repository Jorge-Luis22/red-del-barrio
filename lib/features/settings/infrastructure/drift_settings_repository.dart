import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../domain/app_settings.dart';
import '../domain/settings_repository.dart';

/// Ajustes como pares clave-valor en la base local.
class DriftSettingsRepository implements SettingsRepository {
  DriftSettingsRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<AppSettings> watch() =>
      _db.select(_db.appSettingsKv).watch().map(_fromRows);

  @override
  Future<void> update(AppSettings Function(AppSettings current) change) async {
    final rows = await _db.select(_db.appSettingsKv).get();
    final next = change(_fromRows(rows));
    final values = <String, String>{
      'textScale': next.textScale.toString(),
      'highContrast': next.highContrast.toString(),
      'theme': next.theme.name,
      'vibration': next.vibration.toString(),
      'tutorialSeen': next.tutorialSeen.toString(),
      'volunteer': next.volunteer.toString(),
      'capabilities': next.capabilities.join('|'),
      'language': next.languageCode ?? '',
      'welcomeDone': next.welcomeDone.toString(),
      'useLocation': next.useLocation.toString(),
      'lastZoneLat': next.lastZoneLat?.toString() ?? '',
      'lastZoneLng': next.lastZoneLng?.toString() ?? '',
    };
    await _db.batch((b) {
      values.forEach((k, v) {
        b.insert(
          _db.appSettingsKv,
          AppSettingsKvCompanion.insert(key: k, value: v),
          mode: InsertMode.insertOrReplace,
        );
      });
    });
  }

  @override
  Future<void> eraseAll() async {
    await _db.transaction(() async {
      for (final table in _db.allTables) {
        await _db.delete(table).go();
      }
    });
  }

  AppSettings _fromRows(List<SettingRow> rows) {
    final m = {for (final r in rows) r.key: r.value};
    return AppSettings(
      textScale: double.tryParse(m['textScale'] ?? '') ?? 1.0,
      highContrast: m['highContrast'] == 'true',
      theme: ThemePreference.values.firstWhere(
        (t) => t.name == m['theme'],
        orElse: () => ThemePreference.system,
      ),
      vibration: m['vibration'] != 'false',
      tutorialSeen: m['tutorialSeen'] == 'true',
      volunteer: m['volunteer'] == 'true',
      languageCode: (m['language'] ?? '').isEmpty ? null : m['language'],
      welcomeDone: m['welcomeDone'] == 'true',
      useLocation: m['useLocation'] == 'true',
      lastZoneLat: double.tryParse(m['lastZoneLat'] ?? ''),
      lastZoneLng: double.tryParse(m['lastZoneLng'] ?? ''),
      capabilities: (m['capabilities'] ?? '')
          .split('|')
          .where((e) => e.isNotEmpty)
          .toSet(),
    );
  }
}
