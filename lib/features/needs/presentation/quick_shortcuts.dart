import 'package:flutter/material.dart';

import '../../../app/l10n.dart';
import '../../../app/theme/brand.dart';
import '../../../app/ui/components.dart';
import 'composer_sheet.dart';
import 'need_labels.dart';

/// Atajos: fila deslizable de baldosas grandes (icono + frase corta).
class QuickShortcuts extends StatelessWidget {
  const QuickShortcuts({super.key});

  @override
  Widget build(BuildContext context) {
    final shortcuts = NeedLabels.quick(context.l);
    return SizedBox(
      height: 112,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: shortcuts.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final q = shortcuts[i];
          final tone = NeedLabels.tone(q.kind);
          return Semantics(
            button: true,
            label: context.l.pedir(q.label),
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () => showComposer(context, kind: q.kind, text: q.text),
              child: Ink(
                width: 148,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: toneColors(context, tone).bg,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: ExcludeSemantics(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        NeedLabels.icon(q.kind),
                        size: 30,
                        color: toneIconColor(context, tone),
                      ),
                      Text(
                        q.label,
                        style: context.tt.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
