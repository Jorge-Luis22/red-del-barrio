import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../core/result.dart';
import '../domain/location_provider.dart';
import '../domain/usecases/get_location.dart';
import '../domain/zone.dart';

enum LocationStatus { idle, loading, ready, failed }

class LocationState {
  const LocationState({
    this.status = LocationStatus.idle,
    this.location,
    this.source,
    this.message,
    this.availability,
  });

  final LocationStatus status;

  /// Posición en memoria (nunca se guarda exacta). Puede ser solo la zona recordada.
  final ExactLocation? location;

  /// De dónde salió [location]: GPS en vivo, última posición del sistema o zona guardada.
  final LocationSource? source;

  /// Mensaje estable del dominio (en español) que la interfaz traduce.
  final String? message;

  /// Qué impide usar el GPS ahora mismo, para ofrecer la acción correcta.
  final LocationAvailability? availability;

  bool get hasLocation => location != null;

  /// `true` cuando hay un problema que la persona puede resolver (permiso, GPS apagado…).
  bool get needsAttention =>
      availability != null && availability != LocationAvailability.ready;
}

class LocationController extends Notifier<LocationState> {
  @override
  LocationState build() {
    // Si la persona ya pidió usar su ubicación, se actualiza al abrir la app, sin preguntar.
    ref.listen(appSettingsProvider.select((s) => s.useLocation), (prev, wants) {
      if (wants && prev != true && state.status == LocationStatus.idle) {
        refresh();
      }
      if (!wants) state = const LocationState();
    }, fireImmediately: true);
    return const LocationState();
  }

  /// La persona toca "Usar mi ubicación": se pide permiso si hace falta y se recuerda su elección.
  Future<void> request() async {
    await refresh(askPermission: true);
    await ref
        .read(settingsRepositoryProvider)
        .update((s) => s.copyWith(useLocation: true));
  }

  /// Actualiza la posición. Sin [askPermission] nunca muestra un cuadro de permiso.
  Future<void> refresh({bool askPermission = false}) async {
    if (state.status == LocationStatus.loading) return;
    state = LocationState(
      status: LocationStatus.loading,
      location: state.location,
      source: state.source,
    );
    final result = await ref.read(getLocationProvider)(
      askPermission: askPermission,
    );
    final availability = await ref.read(locationProvider).availability();
    state = switch (result) {
      Ok(:final value) => LocationState(
        status: LocationStatus.ready,
        location: value.location,
        source: value.source,
        message: value.reason?.message,
        availability: availability,
      ),
      Err(:final failure) => LocationState(
        status: LocationStatus.failed,
        message: failure.message,
        availability: availability,
      ),
    };
  }

  /// Al volver a la app se refresca la posición, si la persona la tenía activada.
  Future<void> refreshIfEnabled() async {
    if (ref.read(appSettingsProvider).useLocation) await refresh();
  }

  /// Apaga la ubicación y olvida la zona guardada.
  Future<void> disable() async {
    await ref
        .read(settingsRepositoryProvider)
        .update((s) => s.copyWith(useLocation: false, clearLastZone: true));
    state = const LocationState();
  }

  /// Olvida la zona guardada (la ubicación en uso no cambia).
  Future<void> forgetZone() => ref.read(zoneMemoryProvider).clear();

  Future<void> openSettings() async {
    await ref
        .read(locationProvider)
        .openSettings(state.availability ?? LocationAvailability.denied);
  }
}

final locationControllerProvider =
    NotifierProvider<LocationController, LocationState>(LocationController.new);
