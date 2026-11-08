import 'package:flutter/material.dart';

import '../store.dart';
import '../theme.dart';

const List<String> _reasons = <String>[
  'Es spam o publicidad',
  'Me trató con falta de respeto',
  'Parece una estafa',
  'Contenido inapropiado',
  'Otro motivo',
];

/// Reporta a un vecino a quien organiza el piloto.
Future<void> showReportDialog(
  BuildContext context, {
  required String entity,
  required String entityId,
  required String targetId,
  required String targetName,
}) async {
  if (!looksLikeUuid(targetId)) {
    toast(context, 'No se puede reportar a esta cuenta.');
    return;
  }
  final String? reason = await showDialog<String>(
    context: context,
    builder: (BuildContext ctx) => SimpleDialog(
      title: Text('Reportar a $targetName'),
      children: <Widget>[
        for (final String r in _reasons)
          SimpleDialogOption(
            onPressed: () => Navigator.of(ctx).pop(r),
            child: Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Text(r)),
          ),
      ],
    ),
  );
  if (reason == null || !context.mounted) return;
  try {
    await store.report(entity, entityId, targetId, reason);
    if (context.mounted) toast(context, 'Gracias. Tu reporte llegó a quien organiza el piloto.');
  } catch (_) {
    if (context.mounted) toast(context, 'No se pudo enviar el reporte. Revisa tu conexión e inténtalo otra vez.');
  }
}

/// Bloquea a un vecino en este teléfono: ya no verás sus pedidos ni mensajes. Devuelve true si se bloqueó.
Future<bool> confirmBlock(BuildContext context, {required String userId, required String name}) async {
  final bool? ok = await showDialog<bool>(
    context: context,
    builder: (BuildContext ctx) => AlertDialog(
      title: Text('¿Bloquear a $name?'),
      content: const Text(
        'Dejarás de ver sus pedidos, propuestas y mensajes en este teléfono. '
        'Puedes desbloquearlo después desde Perfil.',
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(48, 44)),
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Bloquear'),
        ),
      ],
    ),
  );
  if (ok != true) return false;
  await store.blockUser(userId);
  if (context.mounted) toast(context, '$name quedó bloqueado.');
  return true;
}

/// Menú "⋮" con Reportar y Bloquear para otro vecino.
class PersonMenu extends StatelessWidget {
  const PersonMenu({
    super.key,
    required this.userId,
    required this.name,
    required this.entity,
    required this.entityId,
    this.onBlocked,
  });

  final String userId;
  final String name;
  final String entity;
  final String entityId;
  final VoidCallback? onBlocked;

  @override
  Widget build(BuildContext context) {
    if (userId == store.meId || userId == 'system') return const SizedBox.shrink();
    return PopupMenuButton<String>(
      tooltip: 'Más opciones',
      onSelected: (String value) async {
        if (value == 'report') {
          await showReportDialog(context, entity: entity, entityId: entityId, targetId: userId, targetName: name);
        } else if (value == 'block') {
          final bool done = await confirmBlock(context, userId: userId, name: name);
          if (done && onBlocked != null) onBlocked!();
        }
      },
      itemBuilder: (BuildContext _) => const <PopupMenuEntry<String>>[
        PopupMenuItem<String>(value: 'report', child: Text('Reportar')),
        PopupMenuItem<String>(value: 'block', child: Text('Bloquear')),
      ],
    );
  }
}
