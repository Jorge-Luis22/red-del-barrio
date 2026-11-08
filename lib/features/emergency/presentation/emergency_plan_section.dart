import 'package:flutter/material.dart';

import '../../../app/l10n.dart';
import 'backpack_block.dart';
import 'contacts_block.dart';
import 'meeting_point_block.dart';
import '../../../app/ui/components.dart';

/// "Mi plan de emergencia": contactos de confianza, punto de encuentro y mochila.
/// Todo se guarda en el teléfono y funciona sin internet.
class EmergencyPlanSection extends StatelessWidget {
  const EmergencyPlanSection({super.key});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      BvSectionTitle(context.l.planTitle, subtitle: context.l.planSubtitle),
      const SizedBox(height: 16),
      const ContactsBlock(),
      const SizedBox(height: 24),
      const MeetingPointBlock(),
      const SizedBox(height: 24),
      const BackpackBlock(),
    ],
  );
}
