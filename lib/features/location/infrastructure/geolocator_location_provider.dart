import 'package:geolocator/geolocator.dart';

import '../../../core/failure.dart';
import '../../../core/result.dart';
import '../domain/location_provider.dart';
import '../domain/zone.dart';

class GeolocatorLocationProvider implements LocationProvider {
  const GeolocatorLocationProvider();

  @override
  Future<Result<ExactLocation>> currentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const Err(
          PermissionFailure(
            'Activa la ubicación del teléfono para ver lo que hay cerca.',
          ),
        );
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return const Err(
          PermissionFailure(
            'Sin permiso de ubicación. Puedes elegir tu zona a mano.',
          ),
        );
      }
      final p = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return Ok(
        ExactLocation(p.latitude, p.longitude, accuracyMeters: p.accuracy),
      );
    } catch (_) {
      return const Err(
        UnknownFailure('No pudimos obtener tu ubicación. Inténtalo otra vez.'),
      );
    }
  }
}
