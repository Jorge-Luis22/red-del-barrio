import '../../../core/result.dart';
import 'zone.dart';

/// Puerto de ubicación: GPS real del teléfono.
abstract interface class LocationProvider {
  Future<Result<ExactLocation>> currentLocation();
}
