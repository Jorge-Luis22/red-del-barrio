import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n.dart';
import '../../../app/theme/brand.dart';
import '../../../app/ui/components.dart';
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
          const ProfileHeader(),
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              24,
              16,
              32 + MediaQuery.paddingOf(context).bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MyZoneSection(),
                const SizedBox(height: 28),
                BvSectionTitle(
                  tr(context, 'Mi aporte al barrio', 'My contribution'),
                  subtitle: l.soloTuVesEste,
                ),
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
                BvSectionTitle(
                  tr(context, 'Para la municipalidad', 'For the municipality'),
                ),
                const SizedBox(height: 12),
                const TableroEntry(),
                const SizedBox(height: 28),
                BvSectionTitle(
                  tr(context, 'Preferencias y ayuda', 'Preferences and help'),
                ),
                const SizedBox(height: 12),
                const PreferencesRows(),
                const SizedBox(height: 28),
                BvSectionTitle(
                  tr(context, 'Privacidad y datos', 'Privacy and data'),
                ),
                const SizedBox(height: 12),
                const PrivacyActions(),
                const SizedBox(height: 12),
                const AboutLink(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
