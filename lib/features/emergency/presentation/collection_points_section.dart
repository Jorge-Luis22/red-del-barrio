import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../app/l10n.dart';
import '../../../app/theme/brand.dart';
import '../../../app/ui/components.dart';
import '../../../app/ui/failure_text.dart';
import '../../../app/ui/sheet.dart';
import '../../../core/result.dart';
import '../domain/emergency.dart';

/// Puntos de acopio: lugares para reunir ayuda. Los que propone la persona quedan sin verificar.
class CollectionPointsSection extends ConsumerWidget {
  const CollectionPointsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final points =
        ref.watch(collectionPointsStreamProvider).value ??
        const <CollectionPoint>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BvSectionTitle(
          l.puntosDeAcopio,
          subtitle: l.lugaresParaReunirAyuda,
          trailing: TextButton.icon(
            onPressed: () => showBvSheet<void>(
              context,
              builder: (_) => const _CollectionPointSheet(),
            ),
            icon: const Icon(Icons.add_location_alt_rounded),
            label: Text(l.proponer),
          ),
        ),
        const SizedBox(height: 12),
        if (points.isEmpty)
          BvBanner(
            icon: Icons.place_outlined,
            tone: BvTone.violet,
            message: l.aunNoHayPuntos,
          )
        else
          BvRows(children: [for (final p in points) _PointRow(point: p)]),
      ],
    );
  }
}

class _PointRow extends StatelessWidget {
  const _PointRow({required this.point});

  final CollectionPoint point;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BvIconBadge(Icons.inventory_2_rounded, tone: BvTone.trust),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(point.name, style: context.tt.titleSmall),
              if (point.reference.isNotEmpty)
                Text(
                  point.reference,
                  style: context.tt.bodySmall?.copyWith(
                    color: context.tones.muted,
                  ),
                ),
              const SizedBox(height: 8),
              BvPill(
                context.l.propuestoPorTiSin,
                icon: Icons.help_outline_rounded,
                tone: BvTone.sun,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _CollectionPointSheet extends ConsumerStatefulWidget {
  const _CollectionPointSheet();

  @override
  ConsumerState<_CollectionPointSheet> createState() =>
      _CollectionPointSheetState();
}

class _CollectionPointSheetState extends ConsumerState<_CollectionPointSheet> {
  final _name = TextEditingController();
  final _reference = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _reference.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final r = await ref.read(proposeCollectionPointProvider)(
      name: _name.text,
      reference: _reference.text,
    );
    if (!mounted) return;
    switch (r) {
      case Ok():
        Navigator.of(context).pop();
      case Err(:final failure):
        setState(() => _error = failureText(context.l, failure));
    }
  }

  @override
  Widget build(BuildContext context) => BvSheetScaffold(
    title: context.l.proponerUnPuntoDe,
    subtitle: context.l.unLugarDelBarrio,
    actionLabel: context.l.guardarPunto,
    actionIcon: Icons.add_location_alt_rounded,
    onAction: _name.text.trim().length >= 3 ? _save : null,
    children: [
      TextField(
        controller: _name,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: context.l.nombreDelLugar,
          errorText: _error,
        ),
        onChanged: (_) => setState(() => _error = null),
      ),
      const SizedBox(height: 14),
      TextField(
        controller: _reference,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: context.l.referenciaOpcional,
          helperText: context.l.porEjemploFrenteAl,
        ),
      ),
    ],
  );
}
