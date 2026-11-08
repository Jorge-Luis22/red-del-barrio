import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../app/l10n.dart';
import '../../../app/theme/brand.dart';
import '../../../app/ui/components.dart';
import '../../../app/ui/sheet.dart';

/// Punto de encuentro de la familia. Se guarda en el teléfono y se ve sin internet.
class MeetingPointBlock extends ConsumerWidget {
  const MeetingPointBlock({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final point = ref.watch(appSettingsProvider).meetingPoint;
    final hasPoint = point.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BvSectionTitle(l.meetingTitle, subtitle: l.meetingHint),
        const SizedBox(height: 12),
        BvPanel(
          child: InkWell(
            onTap: () => showBvSheet<void>(
              context,
              builder: (_) => _MeetingSheet(initial: point),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  BvIconBadge(
                    Icons.flag_rounded,
                    tone: hasPoint ? BvTone.trust : BvTone.violet,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      hasPoint ? point : l.meetingEmpty,
                      style: hasPoint
                          ? context.tt.titleSmall
                          : context.tt.bodyMedium?.copyWith(
                              color: context.tones.muted,
                            ),
                    ),
                  ),
                  Icon(Icons.edit_rounded, color: context.tones.muted),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MeetingSheet extends ConsumerStatefulWidget {
  const _MeetingSheet({required this.initial});

  final String initial;

  @override
  ConsumerState<_MeetingSheet> createState() => _MeetingSheetState();
}

class _MeetingSheetState extends ConsumerState<_MeetingSheet> {
  late final _text = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await ref
        .read(settingsRepositoryProvider)
        .update((s) => s.copyWith(meetingPoint: _text.text.trim()));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return BvSheetScaffold(
      title: l.meetingTitle,
      subtitle: l.meetingHint,
      actionLabel: l.meetingSave,
      actionIcon: Icons.flag_rounded,
      onAction: _save,
      children: [
        TextField(
          controller: _text,
          textCapitalization: TextCapitalization.sentences,
          maxLength: 80,
          decoration: InputDecoration(labelText: l.meetingLabel),
        ),
      ],
    );
  }
}
