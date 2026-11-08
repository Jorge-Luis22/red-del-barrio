import '../../settings/domain/settings_repository.dart';
import '../domain/zone.dart';
import '../domain/zone_memory.dart';

/// Guarda la última zona junto con los demás ajustes de la persona.
class SettingsZoneMemory implements ZoneMemory {
  const SettingsZoneMemory(this._settings);

  final SettingsRepository _settings;

  @override
  Future<Zone?> load() async {
    final s = await _settings.watch().first;
    final lat = s.lastZoneLat;
    final lng = s.lastZoneLng;
    return (lat == null || lng == null) ? null : Zone(lat, lng);
  }

  @override
  Future<void> save(Zone zone) => _settings.update(
    (s) => s.copyWith(lastZoneLat: zone.lat, lastZoneLng: zone.lng),
  );

  @override
  Future<void> clear() =>
      _settings.update((s) => s.copyWith(clearLastZone: true));
}
