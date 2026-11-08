import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n.dart';
import '../../../app/theme/brand.dart';
import '../../../app/ui/components.dart';
import '../../../app/ui/section_header.dart';
import '../../assistant/presentation/tablero_screen.dart';
import '../../assistant/presentation/tr.dart';
import '../../profile/presentation/my_profile_section.dart';
import 'data_actions.dart';
import 'help_summary.dart';

/// Perfil: tu ayuda al barrio, tus ajustes y tus datos.
class PerfilScreen extends ConsumerWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final help = ref.watch(helpSummaryProvider);

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          BvSectionHeader(
            title: l.perfil,
            subtitle: l.tuAyudaAlBarrio,
            icon: Icons.person_rounded,
            background: context.tones.trust,
            foreground: context.cs.onTertiary,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MyProfileSection(),
                const SizedBox(height: 28),
                BvSectionTitle(l.tuAyudaAlBarrio2, subtitle: l.soloTuVesEste),
                const SizedBox(height: 12),
                HelpGrid(help: help),
                const SizedBox(height: 8),
                Text(
                  l.esEvidenciaDeLo,
                  style: context.tt.bodySmall?.copyWith(
                    color: context.tones.muted,
                  ),
                ),
                const SizedBox(height: 28),
                const SizedBox(height: 28),
                BvSectionTitle(
                  tr(context, 'Para la municipalidad', 'For the municipality'),
                ),
                const SizedBox(height: 12),
                const TableroEntry(),
                const SizedBox(height: 28),
                BvSectionTitle(l.ayudaYDatos),
                const SizedBox(height: 12),
                const DataActions(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
