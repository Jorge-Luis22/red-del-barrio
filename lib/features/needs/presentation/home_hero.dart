import 'package:flutter/material.dart';

import '../../../app/l10n.dart';
import '../../../app/theme/brand.dart';
import '../../../app/ui/illustrations.dart';
import '../../location/presentation/location_banner.dart';
import '../../location/presentation/location_controller.dart';
import '../../profile/domain/profile.dart';
import 'composer_sheet.dart';

/// Cabecera violeta: marca, zona, pregunta principal y el botón grande de pedir.
class HomeHero extends StatelessWidget {
  const HomeHero({super.key, required this.loc, this.address});

  final LocationState loc;

  /// Dirección activa: si existe, la cabecera muestra su nombre y su zona.
  final SavedAddress? address;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final soft = cs.onPrimary.withValues(alpha: 0.85);
    return Container(
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.paddingOf(context).top + 16,
              20,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: context.tones.coral,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.home_rounded,
                        size: 20,
                        color: cs.onSecondary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      context.l.appName,
                      style: context.tt.titleMedium?.copyWith(
                        color: cs.onPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.place_outlined, size: 16, color: soft),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        address == null
                            ? zoneLine(context, loc)
                            : context.l.addrHeroLine(
                                address!.name,
                                context.l.zonaAprox1Km(
                                  address!.zone.lat.toStringAsFixed(2),
                                  address!.zone.lng.toStringAsFixed(2),
                                ),
                              ),
                        style: context.tt.bodySmall?.copyWith(color: soft),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Semantics(
                  header: true,
                  child: Text(
                    context.l.queNecesitasHoy,
                    style: context.tt.headlineLarge?.copyWith(
                      color: cs.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.l.cuentaloYLosVecinos,
                  style: context.tt.bodyMedium?.copyWith(
                    color: cs.onPrimary.withValues(alpha: 0.92),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => showComposer(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: context.tones.coral,
                      foregroundColor: BarrioPalette.white,
                      minimumSize: const Size(64, 60),
                      textStyle: context.tt.titleMedium,
                    ),
                    icon: const Icon(Icons.add_circle_rounded, size: 26),
                    label: Text(context.l.pedirAlgo),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const BarrioSkyline(height: 88),
        ],
      ),
    );
  }
}
