import 'package:flutter/material.dart';

import '../../../app/l10n.dart';
import '../../../app/theme/brand.dart';
import '../../../app/ui/components.dart';
import '../../assistant/presentation/tr.dart';
import 'collection_points_section.dart';
import 'emergency_plan_section.dart';
import 'my_alerts_section.dart';
import 'official_contacts_section.dart';
import 'preparedness_section.dart';
import 'sos_sheet.dart';

enum _EmergencyView { help, prepare }

/// Emergencia, en dos vistas: "Necesito ayuda" (llamar o pedir apoyo, y mis avisos) y
/// "Prepararme" (plan, contactos, mochila y preparación comunitaria).
/// En "Necesito ayuda" lo oficial va siempre primero.
class EmergenciaScreen extends StatefulWidget {
  const EmergenciaScreen({super.key});

  @override
  State<EmergenciaScreen> createState() => _EmergenciaScreenState();
}

class _EmergenciaScreenState extends State<EmergenciaScreen> {
  _EmergencyView _view = _EmergencyView.help;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _Header(view: _view, onChanged: (v) => setState(() => _view = v)),
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              20,
              16,
              32 + MediaQuery.paddingOf(context).bottom,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              child: KeyedSubtree(
                key: ValueKey(_view),
                child: _view == _EmergencyView.help
                    ? const _HelpView()
                    : const _PrepareView(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Cabecera compacta de emergencia con el selector de vistas.
class _Header extends StatelessWidget {
  const _Header({required this.view, required this.onChanged});

  final _EmergencyView view;
  final ValueChanged<_EmergencyView> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final fg = context.cs.onError;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.paddingOf(context).top + 16,
        20,
        20,
      ),
      decoration: BoxDecoration(
        color: context.tones.emergency,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.crisis_alert_rounded, color: fg, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    l.emergencia,
                    style: context.tt.headlineMedium?.copyWith(color: fg),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l.ayudaDelBarrioCuando,
            style: context.tt.bodyMedium?.copyWith(
              color: fg.withValues(alpha: 0.92),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: fg.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                _Tab(
                  label: tr(context, 'Necesito ayuda', 'I need help'),
                  icon: Icons.campaign_rounded,
                  selected: view == _EmergencyView.help,
                  onTap: () => onChanged(_EmergencyView.help),
                ),
                _Tab(
                  label: tr(context, 'Prepararme', 'Get prepared'),
                  icon: Icons.checklist_rounded,
                  selected: view == _EmergencyView.prepare,
                  onTap: () => onChanged(_EmergencyView.prepare),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? context.tones.emergency : context.cs.onError;
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: selected ? BarrioPalette.white : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: ExcludeSemantics(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 20, color: color),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: context.tt.labelLarge?.copyWith(color: color),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "Necesito ayuda": llamar a lo oficial, pedir apoyo vecinal y ver mis avisos.
class _HelpView extends StatelessWidget {
  const _HelpView();

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const OfficialContactsSection(),
        const SizedBox(height: 24),
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
            label: Text(
              tr(context, 'Pedir apoyo vecinal', 'Ask neighbors for help'),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 16,
              color: context.tones.muted,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '${l.avisaATusVecinos} ${tr(context, 'El apoyo vecinal no garantiza una respuesta.', 'Neighbor support does not guarantee a response.')}',
                style: context.tt.bodySmall?.copyWith(
                  color: context.tones.muted,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const MyAlertsSection(),
      ],
    );
  }
}

/// "Prepararme": plan del hogar y preparación comunitaria.
class _PrepareView extends StatelessWidget {
  const _PrepareView();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const EmergencyPlanSection(),
      const SizedBox(height: 28),
      BvSectionTitle(
        tr(context, 'Preparación comunitaria', 'Community preparedness'),
        subtitle: tr(
          context,
          'Lo que propones tú queda sin verificar hasta que alguien lo confirme.',
          'What you propose stays unverified until someone confirms it.',
        ),
      ),
      const SizedBox(height: 12),
      const PreparednessSection(),
      const SizedBox(height: 16),
      const CollectionPointsSection(),
    ],
  );
}
