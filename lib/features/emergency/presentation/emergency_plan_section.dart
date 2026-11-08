import 'package:flutter/material.dart';

import '../../../app/l10n.dart';
import '../../../app/theme/brand.dart';
import '../../assistant/presentation/tr.dart';
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
      const SizedBox(height: 8),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.sms_outlined, size: 16, color: context.tones.muted),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              tr(
                context,
                'El SMS puede funcionar sin internet, pero necesita cobertura y servicio celular.',
                'SMS can work without internet, but it needs cell coverage and service.',
              ),
              style: context.tt.bodySmall?.copyWith(color: context.tones.muted),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      const ContactsBlock(),
      const SizedBox(height: 24),
      const MeetingPointBlock(),
      const SizedBox(height: 24),
      const BackpackBlock(),
    ],
  );
}
