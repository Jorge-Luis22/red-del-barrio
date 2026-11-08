import 'zone.dart';

/// Recuerda la última zona (de ~1 km) para poder mostrar algo cuando no hay GPS ni internet.
/// Jamás guarda coordenadas exactas.
abstract interface class ZoneMemory {
  Future<Zone?> load();

  Future<void> save(Zone zone);

  Future<void> clear();
}
