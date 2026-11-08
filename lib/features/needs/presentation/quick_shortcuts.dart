import 'package:flutter/material.dart';

import '../../../app/l10n.dart';
import '../../../app/theme/brand.dart';
import '../../../app/ui/components.dart';
import '../../assistant/presentation/tr.dart';
import 'composer_sheet.dart';
import 'need_labels.dart';
import '../domain/need.dart';

typedef _Shortcut = ({NeedKind kind, String text, String label, IconData icon});

/// Atajos base (con sus textos traducidos) más otros oficios y favores frecuentes.
List<_Shortcut> _shortcuts(BuildContext context) {
  final base = [
    for (final q in NeedLabels.quick(context.l))
      (
        kind: q.kind,
        text: q.text,
        label: q.label,
        icon: NeedLabels.icon(q.kind),
      ),
  ];
  final extra = <_Shortcut>[
    (
      kind: NeedKind.service,
      text: tr(context, 'Necesito un carpintero', 'I need a carpenter'),
      label: tr(context, 'Carpintero', 'Carpenter'),
      icon: Icons.carpenter_rounded,
    ),
    (
      kind: NeedKind.service,
      text: tr(context, 'Necesito un cerrajero', 'I need a locksmith'),
      label: tr(context, 'Cerrajero', 'Locksmith'),
      icon: Icons.key_rounded,
    ),
    (
      kind: NeedKind.service,
      text: tr(
        context,
        'Necesito arreglar un dobladillo',
        'I need a hem fixed',
      ),
      label: tr(context, 'Costurera', 'Seamstress'),
      icon: Icons.content_cut_rounded,
    ),
    (
      kind: NeedKind.service,
      text: tr(
        context,
        'Necesito clases de matemática para mi hijo',
        'I need math lessons for my child',
      ),
      label: tr(context, 'Clases', 'Lessons'),
      icon: Icons.school_rounded,
    ),
    (
      kind: NeedKind.service,
      text: tr(
        context,
        'Necesito que alguien pasee a mi perro',
        'I need someone to walk my dog',
      ),
      label: tr(context, 'Pasear mascota', 'Pet walking'),
      icon: Icons.pets_rounded,
    ),
    (
      kind: NeedKind.loan,
      text: tr(
        context,
        '¿Alguien me presta un taladro?',
        'Can someone lend me a drill?',
      ),
      label: tr(context, 'Pedir prestado', 'Borrow'),
      icon: Icons.build_rounded,
    ),
    (
      kind: NeedKind.help,
      text: tr(
        context,
        'Necesito que me acompañen al médico',
        'I need someone to go with me to the doctor',
      ),
      label: tr(context, 'Compañía', 'Company'),
      icon: Icons.volunteer_activism_rounded,
    ),
  ];
  return [...base, ...extra];
}

/// Atajos: fila deslizable de baldosas grandes (icono + frase corta).
class QuickShortcuts extends StatelessWidget {
  const QuickShortcuts({super.key});

  @override
  Widget build(BuildContext context) {
    final shortcuts = _shortcuts(context);
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
                        q.icon,
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
