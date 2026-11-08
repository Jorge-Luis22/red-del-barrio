import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../app/l10n.dart';
import '../../../app/theme/brand.dart';
import '../../../app/ui/components.dart';
import '../../settings/domain/app_settings.dart';
import '../../assistant/presentation/tr.dart';
import 'sos_labels.dart';

/// "Un barrio preparado": qué podría ofrecer la persona y si es brigadista voluntaria.
/// Todo queda guardado en el teléfono y sin verificar.
class PreparednessSection extends ConsumerWidget {
  const PreparednessSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final settings = ref.watch(appSettingsProvider);
    final repo = ref.read(settingsRepositoryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BvSectionTitle(l.unBarrioPreparado, subtitle: l.quePodriasOfrecerSi),
        const SizedBox(height: 12),
        BvPanel(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final cap in emergencyCapabilities)
                    _CapabilityChip(
                      label: capabilityLabel(l, cap),
                      selected: settings.capabilities.contains(cap),
                      onChanged: (on) => repo.update(
                        (s) => s.copyWith(
                          capabilities: on
                              ? {...s.capabilities, cap}
                              : ({...s.capabilities}..remove(cap)),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  l.brigadistaVecinalVoluntario,
                  style: context.tt.titleSmall,
                ),
                subtitle: Text(l.sinVerificarSoloQueda),
                secondary: BvPill(
                  tr(context, 'Sin verificar', 'Unverified'),
                  icon: Icons.help_outline_rounded,
                  tone: BvTone.sun,
                ),
                value: settings.volunteer,
                onChanged: (v) => repo.update((s) => s.copyWith(volunteer: v)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CapabilityChip extends StatelessWidget {
  const _CapabilityChip({
    required this.label,
    required this.selected,
    required this.onChanged,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => FilterChip(
    label: Text(label),
    selected: selected,
    showCheckmark: true,
    onSelected: onChanged,
    labelStyle: context.tt.labelMedium?.copyWith(
      color: selected ? context.cs.onPrimary : context.cs.onSurface,
    ),
    checkmarkColor: context.cs.onPrimary,
  );
}
