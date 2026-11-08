import 'package:flutter/material.dart';

import '../../../app/l10n.dart';
import '../../../app/theme/brand.dart';
import '../../../app/ui/components.dart';
import '../../../app/ui/section_header.dart';
import 'collection_points_section.dart';
import 'emergency_plan_section.dart';
import 'my_alerts_section.dart';
import 'official_contacts_section.dart';
import 'preparedness_section.dart';
import 'sos_sheet.dart';

/// Emergencia. Orden fijo e intencional: 1) servicios oficiales, 2) pedir ayuda al barrio,
/// 3) mis avisos, 4) un barrio preparado. La institución oficial siempre va primero.
class EmergenciaScreen extends StatelessWidget {
  const EmergenciaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          BvSectionHeader(
            title: l.emergencia,
            subtitle: l.ayudaDelBarrioCuando,
            icon: Icons.crisis_alert_rounded,
            background: context.tones.emergency,
            foreground: context.cs.onError,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const OfficialContactsSection(),
                const SizedBox(height: 28),
                BvSectionTitle(l.ayudaDelBarrio, subtitle: l.avisaATusVecinos),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => showSosSheet(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: context.tones.emergency,
                      foregroundColor: context.cs.onError,
                      minimumSize: const Size(64, 60),
                    ),
                    icon: const Icon(Icons.campaign_rounded),
                    label: Text(l.necesitoAyuda),
                  ),
                ),
                const SizedBox(height: 16),
                const MyAlertsSection(),
                const SizedBox(height: 28),
                const EmergencyPlanSection(),
                const SizedBox(height: 28),
                const PreparednessSection(),
                const SizedBox(height: 16),
                const CollectionPointsSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
