import '../../../../core/failure.dart';
import '../../../../core/result.dart';
import '../location_provider.dart';
import '../zone.dart';
import '../zone_memory.dart';

/// De dónde salió la ubicación que se está usando.
enum LocationSource {
  /// Lectura reciente del GPS.
  live,

  /// Última posición que tenía el sistema (sin GPS en este momento).
  lastKnown,

  /// Solo se recuerda la zona de la última vez: distancias aproximadas.
  savedZone,
}

class LocationFix {
  const LocationFix(this.location, this.source, {this.reason});

  final ExactLocation location;
  final LocationSource source;

  /// Por qué no hay una lectura en vivo (permiso, GPS apagado…), si [source] no es `live`.
  final Failure? reason;
}

/// Obtiene la mejor ubicación disponible, de la más precisa a la más vaga:
/// 1) GPS en vivo, 2) última posición del sistema, 3) última zona guardada.
/// Solo falla si no hay ninguna de las tres.
class GetLocation {
  GetLocation({required this.provider, required this.memory});

  final LocationProvider provider;
  final ZoneMemory memory;

  Future<Result<LocationFix>> call({bool askPermission = true}) async {
    final live = await provider.currentLocation(askPermission: askPermission);
    if (live case Ok(:final value)) {
      await memory.save(value.zone);
      return Ok(LocationFix(value, LocationSource.live));
    }
    final failure = (live as Err<ExactLocation>).failure;

    final cached = await provider.lastKnown();
    if (cached != null) {
      await memory.save(cached.zone);
      return Ok(LocationFix(cached, LocationSource.lastKnown, reason: failure));
    }

    final zone = await memory.load();
    if (zone != null) {
      return Ok(
        LocationFix(
          ExactLocation(
            zone.lat,
            zone.lng,
            accuracyMeters: 1100,
            isApproximate: true,
          ),
          LocationSource.savedZone,
          reason: failure,
        ),
      );
    }
    return Err(failure);
  }
}
