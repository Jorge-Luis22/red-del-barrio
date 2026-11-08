import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/di/providers.dart';
import '../../../app/theme/brand.dart';
import '../../../app/ui/components.dart';
import '../../../core/result.dart';
import '../../assistant/presentation/tr.dart';
import '../domain/meeting_point.dart';

/// Centro de Lima: se usa solo si el teléfono no conoce ninguna posición.
const _fallbackCenter = LatLng(-12.0464, -77.0428);

const _tileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
const _userAgent = 'pe.redbarrio.red_barrio';

Widget _attribution() => const RichAttributionWidget(
  attributions: [TextSourceAttribution('© OpenStreetMap contributors')],
);

/// Hoja con un mapa para marcar el lugar de encuentro. Devuelve el punto elegido o `null`.
Future<MeetingPoint?> showMeetingPicker(BuildContext context) =>
    showModalBottomSheet<MeetingPoint>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => const _PickerSheet(),
    );

/// Hoja de solo lectura con el punto acordado.
Future<void> showMeetingViewer(BuildContext context, MeetingPoint point) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _ViewerSheet(point: point),
    );

class _PickerSheet extends ConsumerStatefulWidget {
  const _PickerSheet();

  @override
  ConsumerState<_PickerSheet> createState() => _PickerSheetState();
}

class _PickerSheetState extends ConsumerState<_PickerSheet> {
  final _map = MapController();
  LatLng _center = _fallbackCenter;
  LatLng? _picked;
  bool _ready = false;
  bool _locating = false;
  int _labelIndex = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final last = await ref.read(locationProvider).lastKnown();
      if (last != null) _center = LatLng(last.lat, last.lng);
    } catch (_) {
      // Sin posición conocida: se usa el centro de Lima.
    }
    if (mounted) setState(() => _ready = true);
  }

  Future<void> _useMyLocation() async {
    setState(() => _locating = true);
    try {
      final r = await ref.read(locationProvider).currentLocation();
      if (!mounted) return;
      switch (r) {
        case Ok(:final value):
          _map.move(LatLng(value.lat, value.lng), 17);
        case Err():
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                tr(
                  context,
                  'No pudimos obtener tu ubicación. Mueve el mapa a mano.',
                  'We could not get your location. Move the map by hand.',
                ),
              ),
            ),
          );
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  List<String> _labels(BuildContext context) => [
    tr(context, 'Plaza o parque', 'Square or park'),
    tr(context, 'Bodega o tienda', 'Shop'),
    tr(context, 'Paradero', 'Bus stop'),
    tr(context, 'Puerta de mi casa', 'My front door'),
    tr(context, 'Otro lugar público', 'Other public place'),
  ];

  @override
  Widget build(BuildContext context) {
    final labels = _labels(context);
    final picked = _picked;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tr(context, 'Proponer lugar de encuentro', 'Suggest a meeting place'),
              style: context.tt.headlineSmall,
            ),
            const SizedBox(height: 8),
            BvBanner(
              icon: Icons.shield_outlined,
              tone: BvTone.sun,
              message: tr(
                context,
                'Elige un lugar público y con gente. Toca el mapa para poner el punto.',
                'Pick a public, busy place. Tap the map to drop the pin.',
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 300,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: !_ready
                    ? const Center(child: CircularProgressIndicator())
                    : FlutterMap(
                        mapController: _map,
                        options: MapOptions(
                          initialCenter: _center,
                          initialZoom: 16,
                          onTap: (_, point) => setState(() => _picked = point),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: _tileUrl,
                            userAgentPackageName: _userAgent,
                          ),
                          if (picked != null)
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: picked,
                                  width: 48,
                                  height: 48,
                                  alignment: Alignment.topCenter,
                                  child: Icon(
                                    Icons.location_on_rounded,
                                    size: 48,
                                    color: context.tones.emergency,
                                  ),
                                ),
                              ],
                            ),
                          _attribution(),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _locating || !_ready ? null : _useMyLocation,
                icon: _locating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location_rounded),
                label: Text(tr(context, 'Ir a mi ubicación', 'Go to my location')),
              ),
            ),
            Text(
              tr(
                context,
                'Si no ves el mapa, revisa tu internet: igual puedes marcar el punto.',
                'If you cannot see the map, check your internet: you can still drop the pin.',
              ),
              style: context.tt.bodySmall?.copyWith(color: context.tones.muted),
            ),
            const SizedBox(height: 12),
            Text(
              tr(context, '¿Qué lugar es?', 'What place is it?'),
              style: context.tt.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < labels.length; i++)
                  ChoiceChip(
                    label: Text(labels[i]),
                    selected: _labelIndex == i,
                    onSelected: (_) => setState(() => _labelIndex = i),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: picked == null
                    ? null
                    : () => Navigator.pop(
                        context,
                        MeetingPoint(
                          label: labels[_labelIndex],
                          lat: picked.latitude,
                          lng: picked.longitude,
                        ),
                      ),
                icon: const Icon(Icons.place_rounded),
                label: Text(
                  picked == null
                      ? tr(context, 'Toca el mapa para elegir', 'Tap the map to choose')
                      : tr(context, 'Proponer este lugar', 'Suggest this place'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewerSheet extends StatelessWidget {
  const _ViewerSheet({required this.point});

  final MeetingPoint point;

  Future<void> _openInMaps(BuildContext context) async {
    final label = Uri.encodeComponent(point.label);
    final uri = Uri.parse(
      'geo:${point.lat},${point.lng}?q=${point.lat},${point.lng}($label)',
    );
    var ok = false;
    try {
      ok = await launchUrl(uri);
    } catch (_) {
      ok = false;
    }
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(
              context,
              'No encontramos una app de mapas en este teléfono.',
              'No maps app found on this phone.',
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final here = LatLng(point.lat, point.lng);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tr(context, 'Punto de encuentro', 'Meeting point'),
              style: context.tt.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(point.label, style: context.tt.titleMedium),
            const SizedBox(height: 12),
            SizedBox(
              height: 300,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: FlutterMap(
                  options: MapOptions(initialCenter: here, initialZoom: 17),
                  children: [
                    TileLayer(
                      urlTemplate: _tileUrl,
                      userAgentPackageName: _userAgent,
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: here,
                          width: 48,
                          height: 48,
                          alignment: Alignment.topCenter,
                          child: Icon(
                            Icons.location_on_rounded,
                            size: 48,
                            color: context.tones.emergency,
                          ),
                        ),
                      ],
                    ),
                    _attribution(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${point.lat.toStringAsFixed(5)}, ${point.lng.toStringAsFixed(5)}',
              style: context.tt.bodySmall?.copyWith(color: context.tones.muted),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: () => _openInMaps(context),
                icon: const Icon(Icons.map_rounded),
                label: Text(
                  tr(context, 'Abrir en la app de mapas', 'Open in maps app'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
