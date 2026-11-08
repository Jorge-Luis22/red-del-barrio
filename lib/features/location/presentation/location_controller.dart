import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../core/result.dart';
import '../domain/zone.dart';

enum LocationStatus { idle, loading, ready, failed }

class LocationState {
  const LocationState({
    this.status = LocationStatus.idle,
    this.location,
    this.message,
  });

  final LocationStatus status;

  /// Posición exacta: solo vive en memoria de este teléfono y nunca se muestra a terceros.
  final ExactLocation? location;
  final String? message;
}

class LocationController extends Notifier<LocationState> {
  @override
  LocationState build() => const LocationState();

  Future<void> request() async {
    state = const LocationState(status: LocationStatus.loading);
    final result = await ref.read(locationProvider).currentLocation();
    state = switch (result) {
      Ok(:final value) => LocationState(
        status: LocationStatus.ready,
        location: value,
      ),
      Err(:final failure) => LocationState(
        status: LocationStatus.failed,
        message: failure.message,
      ),
    };
  }
}

final locationControllerProvider =
    NotifierProvider<LocationController, LocationState>(LocationController.new);
