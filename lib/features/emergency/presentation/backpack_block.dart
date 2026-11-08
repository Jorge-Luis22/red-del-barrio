import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../app/l10n.dart';
import '../../../app/theme/brand.dart';
import '../../../app/ui/components.dart';
import '../../assistant/presentation/tr.dart';
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
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
                        backgroundColor: context.tones.trustSoft,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l.backpackProgress(done, backpackItems.length),
                    style: context.tt.labelLarge,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                done == backpackItems.length
                    ? tr(
                        context,
                        'Tu mochila está completa.',
                        'Your backpack is complete.',
                      )
                    : tr(
                        context,
                        'Faltan ${backpackItems.length - done} por guardar.',
                        '${backpackItems.length - done} left to pack.',
                      ),
                style: context.tt.bodySmall?.copyWith(
                  color: context.tones.muted,
                ),
              ),
              const SizedBox(height: 8),
              for (final id in backpackItems)
                _BackpackRow(
                  label: backpackLabel(l, id),
                  packed: packed.contains(id),
                  onChanged: (on) => repo.update(
                    (s) => s.copyWith(
                      packedItems: on
                          ? {...s.packedItems, id}
                          : ({...s.packedItems}..remove(id)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BackpackRow extends StatelessWidget {
  const _BackpackRow({
    required this.label,
    required this.packed,
    required this.onChanged,
  });

  final String label;
  final bool packed;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Semantics(
    checked: packed,
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => onChanged(!packed),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: ExcludeSemantics(
          child: Row(
            children: [
              Icon(
                packed
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: packed ? context.tones.trust : context.tones.muted,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: context.tt.bodyMedium?.copyWith(
                    fontWeight: packed ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
              Text(
                packed
                    ? tr(context, 'Guardado', 'Packed')
                    : tr(context, 'Pendiente', 'Pending'),
                style: context.tt.labelSmall?.copyWith(
                  color: packed ? context.tones.trustText : context.tones.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
