import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../app/l10n.dart';
import '../../../app/theme/brand.dart';
import '../../../app/ui/components.dart';
import 'tutorial_sheet.dart';

/// "Ayuda y datos": tutorial, información del prototipo y borrado de datos.
class DataActions extends ConsumerWidget {
  const DataActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    return BvRows(
      children: [
        _ActionRow(
          icon: Icons.school_rounded,
          title: l.verElTutorial,
          subtitle: l.tresPantallasParaEmpezar,
          onTap: () => showTutorial(context),
        ),
        _ActionRow(
          icon: Icons.info_outline_rounded,
          title: l.sobreEstePrototipo,
          subtitle: l.queEsRealY,
          onTap: () => _showAbout(context),
        ),
        _ActionRow(
          icon: Icons.delete_forever_rounded,
          title: l.borrarMisDatosDe,
          subtitle: l.pedidosTratosMensajesY,
          danger: true,
          onTap: () => _confirmErase(context, ref),
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          BvIconBadge(icon, tone: danger ? BvTone.emergency : BvTone.violet),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.tt.titleSmall?.copyWith(
                    color: danger ? context.tones.emergency : null,
                  ),
                ),
                Text(
                  subtitle,
                  style: context.tt.bodySmall?.copyWith(
                    color: context.tones.muted,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: context.tones.muted),
        ],
      ),
    ),
  );
}

void _showAbout(BuildContext context) => showDialog<void>(
  context: context,
  builder: (ctx) => AlertDialog(
    title: Text(context.l.sobreEstePrototipo),
    content: SingleChildScrollView(child: Text(context.l.esRealTusPedidos)),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(ctx),
        child: Text(context.l.entendido),
      ),
    ],
  ),
);

/// Borrar todo pide dos confirmaciones: no se puede deshacer.
Future<void> _confirmErase(BuildContext context, WidgetRef ref) async {
  final l = context.l;
  final first = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l.borrarTusDatos),
      content: Text(l.seBorraranTusPedidos),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l.cancelar),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(l.continuar),
        ),
      ],
    ),
  );
  if (first != true || !context.mounted) return;
  final second = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l.ultimaConfirmacion),
      content: Text(l.estoNoSePuede),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l.noConservar),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: FilledButton.styleFrom(
            backgroundColor: context.tones.emergency,
            foregroundColor: context.cs.onError,
          ),
          child: Text(l.siBorrarTodo),
        ),
      ],
    ),
  );
  if (second != true) return;
  await ref.read(settingsRepositoryProvider).eraseAll();
  if (context.mounted) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l.listoBorramosTusDatos)));
  }
}
