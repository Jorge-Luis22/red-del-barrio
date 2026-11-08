import 'package:geolocator/geolocator.dart';

import '../../../core/failure.dart';
import '../../../core/result.dart';
import '../domain/location_provider.dart';
import '../domain/zone.dart';

/// Ubicación del teléfono con el paquete `geolocator`.
/// Mensajes de error estables (en español): la interfaz los traduce al idioma elegido.
class GeolocatorLocationProvider implements LocationProvider {
  const GeolocatorLocationProvider();

  static const serviceOffMessage =
      'Activa la ubicación del teléfono para ver lo que hay cerca.';
  static const deniedMessage =
      'Sin permiso de ubicación. Puedes elegir tu zona a mano.';
  static const blockedMessage =
      'El permiso de ubicación está bloqueado. Actívalo en los ajustes del teléfono.';
  static const unknownMessage =
      'No pudimos obtener tu ubicación. Inténtalo otra vez.';

  @override
  Future<LocationAvailability> availability() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return LocationAvailability.serviceOff;
      }
      return _fromPermission(await Geolocator.checkPermission());
    } catch (_) {
      return LocationAvailability.denied;
    }
  }

  @override
  Future<Result<ExactLocation>> currentLocation({
    bool askPermission = true,
  }) async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const Err(PermissionFailure(serviceOffMessage));
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied && askPermission) {
        permission = await Geolocator.requestPermission();
      }
      switch (_fromPermission(permission)) {
        case LocationAvailability.deniedForever:
          return const Err(PermissionFailure(blockedMessage));
        case LocationAvailability.denied:
          return const Err(PermissionFailure(deniedMessage));
        case LocationAvailability.serviceOff:
          return const Err(PermissionFailure(serviceOffMessage));
        case LocationAvailability.ready:
          break;
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
      return const Err(UnknownFailure(unknownMessage));
    }
  }

  @override
  Future<ExactLocation?> lastKnown() async {
    try {
      if (await availability() != LocationAvailability.ready) return null;
      final p = await Geolocator.getLastKnownPosition();
      if (p == null) return null;
      return ExactLocation(p.latitude, p.longitude, accuracyMeters: p.accuracy);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> openSettings(LocationAvailability reason) async {
    try {
      if (reason == LocationAvailability.serviceOff) {
        await Geolocator.openLocationSettings();
      } else {
        await Geolocator.openAppSettings();
      }
    } catch (_) {
      // Sin ajustes disponibles: la interfaz ya explica qué hacer a mano.
    }
  }

  static LocationAvailability _fromPermission(LocationPermission p) =>
      switch (p) {
        LocationPermission.always ||
        LocationPermission.whileInUse => LocationAvailability.ready,
        LocationPermission.deniedForever => LocationAvailability.deniedForever,
        _ => LocationAvailability.denied,
      };
}
