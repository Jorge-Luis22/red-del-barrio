import '../../../core/result.dart';
import 'zone.dart';

/// Qué puede hacer la app con la ubicación en este momento.
enum LocationAvailability {
  /// Servicio activado y permiso concedido.
  ready,

  /// La ubicación del teléfono está apagada.
  serviceOff,

  /// Sin permiso, pero se puede volver a preguntar.
  denied,

  /// Permiso bloqueado: solo se puede cambiar desde los ajustes del teléfono.
  deniedForever,
}

abstract interface class LocationProvider {
  /// Estado actual SIN mostrar ningún cuadro de permiso.
  Future<LocationAvailability> availability();

  /// Posición actual. Con [askPermission] puede pedir el permiso si falta.
  Future<Result<ExactLocation>> currentLocation({bool askPermission = true});

  /// Última posición que conoce el sistema (sirve sin señal de GPS). `null` si no hay.
  Future<ExactLocation?> lastKnown();

  /// Abre los ajustes del teléfono que corresponden al problema.
  Future<void> openSettings(LocationAvailability reason);
}
