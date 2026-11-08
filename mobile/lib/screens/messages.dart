import 'package:flutter/material.dart';

import '../store.dart';
import '../theme.dart';
import '../util.dart';
import 'chat.dart';
import 'wall.dart' show plainTitle;

/// Lista de tratos con su chat. Cada trato es una conversación entre las dos personas.
class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key, required this.onGoWall});

  final VoidCallback onGoWall;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (BuildContext context, Widget? child) {
        final List<Conversation> list = store.conversations();
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          physics: const AlwaysScrollableScrollPhysics(),
          children: <Widget>[
            const Text('Mensajes', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: ink)),
            const SizedBox(height: 4),
            const Text('Aquí coordinas cada trato con la otra persona.', style: TextStyle(color: muted)),
            const SizedBox(height: 14),
            if (list.isEmpty) ...<Widget>[
              const EmptyState(
                icon: '💬',
                title: 'Aún no tienes tratos',
                text: 'Cuando aceptes una propuesta (o te acepten la tuya) se abrirá aquí el chat.',
              ),
              Center(child: OutlinedButton(onPressed: onGoWall, child: const Text('Ir al muro'))),
            ] else
              for (final Conversation c in list)
                Panel(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (BuildContext _) => ChatScreen(interactionId: c.id)),
                  ),
                  child: Row(
                    children: <Widget>[
                      Avatar(name: c.otherName, color: c.otherColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(c.otherName, style: const TextStyle(fontWeight: FontWeight.w800, color: ink, fontSize: 16)),
                            Text(
                              plainTitle(c.needTitle),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: brand, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            if (c.lastBody.isNotEmpty)
                              Text(
                                c.lastBody,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: muted, fontSize: 13),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Pill(
                            dealStatusLabel(c.status),
                            bg: c.status == 'completado' ? brandSoft : warmSoft,
                            fg: c.status == 'completado' ? brand : warm,
                          ),
                          const SizedBox(height: 4),
                          Text(timeAgo(c.lastAt), style: const TextStyle(color: muted, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ),
          ],
        );
      },
    );
  }
}
