import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n.dart';
import '../../../app/ui/components.dart';
import '../../../app/ui/failure_text.dart';
import '../domain/location_provider.dart';
import '../domain/usecases/get_location.dart';
import 'location_controller.dart';

/// Texto de la zona actual con su origen (GPS, última posición o zona guardada).
String zoneLine(BuildContext context, LocationState loc) {
  final l = context.l;
  final location = loc.location;
  if (location == null) return l.zonaAproximadaSinDireccion;
  final zone = l.zonaAprox1Km(
    location.zone.lat.toStringAsFixed(2),
    location.zone.lng.toStringAsFixed(2),
  );
  final source = switch (loc.source) {
    LocationSource.live || null => l.locSourceLive,
    LocationSource.lastKnown => l.locSourceLast,
    LocationSource.savedZone => l.locSourceSaved,
  };
  return l.locZoneLine(zone, source);
}

/// ¿Hay algo que decirle a la persona sobre su ubicación? (invitar, error o ubicación aproximada)
bool locationNeedsBanner(LocationState loc) =>
    loc.status != LocationStatus.ready ||
    (loc.source != null && loc.source != LocationSource.live);

/// Aviso de ubicación: según el caso ofrece la acción que sí resuelve el problema.
class LocationBanner extends ConsumerWidget {
  const LocationBanner({super.key, required this.state});

  final LocationState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final ctl = ref.read(locationControllerProvider.notifier);
    final loading = state.status == LocationStatus.loading;
    final failed = state.status == LocationStatus.failed;
    final approximate =
        state.status == LocationStatus.ready &&
        state.source != LocationSource.live;

    // Qué botón corresponde a cada situación.
    final (
      String label,
      IconData icon,
      VoidCallback onTap,
    ) = switch (state.availability) {
      LocationAvailability.serviceOff when failed || approximate => (
        l.locEnable,
        Icons.location_on_rounded,
        ctl.openSettings,
      ),
      LocationAvailability.deniedForever when failed || approximate => (
        l.locOpenSettings,
        Icons.settings_rounded,
        ctl.openSettings,
      ),
      _ when approximate => (
        l.locRefresh,
        Icons.refresh_rounded,
        () => ctl.refresh(askPermission: true),
      ),
      _ when failed => (l.intentarOtraVez, Icons.refresh_rounded, ctl.request),
      _ => (l.usarMiUbicacion, Icons.near_me_rounded, ctl.request),
    };

    final title = approximate
        ? l.locBannerLastTitle
        : (failed ? l.noPudimosVerDonde : l.veQueHayCerca);
    final message = approximate
        ? (state.message == null
              ? l.locBannerLastBody
              : '${l.locBannerLastBody}\n${messageText(l, state.message!)}')
        : (failed
              ? (state.message == null
                    ? l.revisaQueLaUbicacion
                    : messageText(l, state.message!))
              : l.tuUbicacionSeQueda);

    return BvBanner(
      icon: failed
          ? Icons.location_off_rounded
          : (approximate
                ? Icons.location_searching_rounded
                : Icons.my_location_rounded),
      tone: failed || approximate ? BvTone.sun : BvTone.violet,
      title: title,
      message: message,
      action: FilledButton.icon(
        onPressed: loading ? null : onTap,
        style: FilledButton.styleFrom(minimumSize: const Size(64, 48)),
        icon: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            : Icon(icon),
        label: Text(loading ? l.buscando : label),
      ),
    );
  }
}
