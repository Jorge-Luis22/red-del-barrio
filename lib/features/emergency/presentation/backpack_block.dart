import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../app/l10n.dart';
import '../../../app/theme/brand.dart';
import '../../../app/ui/components.dart';
import '../domain/emergency.dart';

String backpackLabel(AppLocalizations l, String id) => switch (id) {
  'water' => l.bpWater,
  'food' => l.bpFood,
  'flashlight' => l.bpFlashlight,
  'radio' => l.bpRadio,
  'firstAid' => l.bpFirstAid,
  'meds' => l.bpMeds,
  'docs' => l.bpDocs,
  'cash' => l.bpCash,
  'charger' => l.bpCharger,
  'whistle' => l.bpWhistle,
  _ => l.bpClothes,
};

/// Lista de la mochila de emergencia: se marca lo que ya está guardado, con avance visible.
class BackpackBlock extends ConsumerWidget {
  const BackpackBlock({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final packed = ref.watch(appSettingsProvider).packedItems;
    final repo = ref.read(settingsRepositoryProvider);
    final done = backpackItems.where(packed.contains).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BvSectionTitle(l.backpackTitle, subtitle: l.backpackHint),
        const SizedBox(height: 12),
        BvPanel(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: done / backpackItems.length,
                        minHeight: 10,
                        color: context.tones.trust,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l.backpackProgress(done, backpackItems.length),
                    style: context.tt.labelMedium,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final id in backpackItems)
                    FilterChip(
                      label: Text(backpackLabel(l, id)),
                      selected: packed.contains(id),
                      showCheckmark: true,
                      onSelected: (on) => repo.update(
                        (s) => s.copyWith(
                          packedItems: on
                              ? {...s.packedItems, id}
                              : ({...s.packedItems}..remove(id)),
                        ),
                      ),
                      labelStyle: context.tt.labelMedium?.copyWith(
                        color: packed.contains(id)
                            ? context.cs.onPrimary
                            : context.cs.onSurface,
                      ),
                      checkmarkColor: context.cs.onPrimary,
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
