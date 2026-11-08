import 'package:flutter/material.dart';

import '../catalog.dart';
import '../store.dart';
import '../theme.dart';
import '../util.dart';
import 'need_detail.dart';
import 'publish_sheet.dart';

/// Texto del pedido sin el "Necesito: " / "Ofrezco: " del principio.
String plainTitle(String title) {
  if (title.startsWith(prefixOfrezco)) return title.substring(prefixOfrezco.length);
  if (title.startsWith(prefixNecesito)) return title.substring(prefixNecesito.length);
  return title;
}

const List<List<String>> _filters = <List<String>>[
  <String>['todos', 'Todo'],
  <String>['servicio', 'Servicios'],
  <String>['producto', 'Productos'],
  <String>['prestamo', 'Préstamos'],
  <String>['ayuda', 'Ayudas'],
];

/// Muro del barrio: pedidos de los vecinos y los dos botones grandes para publicar.
class WallScreen extends StatefulWidget {
  const WallScreen({super.key});

  @override
  State<WallScreen> createState() => _WallScreenState();
}

class _WallScreenState extends State<WallScreen> {
  final TextEditingController _q = TextEditingController();
  String _type = 'todos';

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  Future<void> _publish(String dir) async {
    final String? message = await showPublishSheet(context, dir: dir);
    if (message != null && mounted) toast(context, message);
  }

  Widget _pubButton(String label, String sub, String dir, bool primary) {
    return Expanded(
      child: Material(
        color: primary ? brand : warm,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _publish(dir),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(label, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(sub, style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _card(Rec n) {
    final String id = sv(n, 'id');
    final String title = sv(n, 'title');
    final String? dir = directionOf(title);
    final String authorId = sv(n, 'author_id');
    final bool mine = authorId == store.meId;
    final int proposals = store.proposalsFor(id).length;
    final bool inProgress = sv(n, 'status') == 'en_curso';
    final String description = sv(n, 'description');
    return Panel(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (BuildContext _) => NeedDetailScreen(needId: id)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 6,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              if (dir == 'ofrezco') const Pill('Ofrece', bg: warmSoft, fg: warm) else const Pill('Necesita'),
              Pill(needLabel[sv(n, 'type')] ?? sv(n, 'type'), bg: const Color(0xFFEFEDE6), fg: muted),
              if (inProgress) const Pill('En curso', bg: warmSoft, fg: warm),
              if (mine) const Pill('Tuyo', bg: Color(0xFFE5E1F3), fg: Color(0xFF4A3B8C)),
              Text(timeAgo(sv(n, 'created_at')), style: const TextStyle(color: muted, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Text(plainTitle(title), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: ink)),
          if (description.isNotEmpty) ...<Widget>[
            const SizedBox(height: 4),
            Text(description, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: ink, height: 1.35)),
          ],
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Avatar(name: store.nameOf(authorId), color: store.colorOf(authorId), size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${store.nameOf(authorId)} · ${store.levelOf(authorId).name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: muted, fontSize: 13),
                ),
              ),
              Text(
                proposals == 0 ? 'Sin propuestas' : (proposals == 1 ? '1 propuesta' : '$proposals propuestas'),
                style: const TextStyle(color: brand, fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (BuildContext context, Widget? child) {
        final List<Rec> list = store.wall(q: _q.text, type: _type);
        return RefreshIndicator(
          onRefresh: () async {
            await store.sync();
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            physics: const AlwaysScrollableScrollPhysics(),
            children: <Widget>[
              const Text(
                'Muro del barrio',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: ink),
              ),
              const SizedBox(height: 2),
              Text(
                'Hola, ${store.nameOf(store.meId ?? '')}. ¿Qué necesitas o qué sabes hacer?',
                style: const TextStyle(color: muted),
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  _pubButton('Necesito', 'Pedir ayuda', 'necesito', true),
                  const SizedBox(width: 10),
                  _pubButton('Ofrezco', 'Ofrecer lo que sé', 'ofrezco', false),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _q,
                onChanged: (String _) => setState(() {}),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Buscar en el muro',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _q.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Borrar búsqueda',
                          icon: const Icon(Icons.close),
                          onPressed: () => setState(() => _q.clear()),
                        ),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  for (final List<String> f in _filters)
                    ChoiceChipBtn(label: f[1], on: _type == f[0], onTap: () => setState(() => _type = f[0])),
                ],
              ),
              const SizedBox(height: 14),
              if (list.isEmpty)
                EmptyState(
                  icon: '🏘️',
                  title: _q.text.isNotEmpty || _type != 'todos' ? 'No hay pedidos así' : 'El muro empieza vacío',
                  text: _q.text.isNotEmpty || _type != 'todos'
                      ? 'Prueba con otra búsqueda o toca "Todo".'
                      : 'Sé el primero: toca "Necesito" u "Ofrezco" y publica en unos toques.',
                )
              else
                for (final Rec n in list) _card(n),
            ],
          ),
        );
      },
    );
  }
}
