import 'package:flutter/material.dart';

import '../catalog.dart';
import '../store.dart';
import '../theme.dart';
import '../util.dart';
import 'moderation.dart';
import 'publish_sheet.dart';

/// Directorio de vecinos: quién ofrece qué, con recomendaciones y nivel.
class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  final TextEditingController _q = TextEditingController();
  String _trade = 'todos';
  bool _nowOnly = false;

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  Future<void> _askHelp(String category) async {
    final String? message = await showPublishSheet(context, dir: 'necesito', category: category);
    if (message != null && mounted) toast(context, message);
  }

  Widget _offerLine(Rec o) {
    final String trade = sv(o, 'trade');
    final String desc = sv(o, 'description');
    final String schedule = sv(o, 'schedule');
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 6,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Text('${tileFor(trade).icon} $trade', style: const TextStyle(fontWeight: FontWeight.w700, color: ink)),
              if (iv(o, 'available_now') == 1) const Pill('Disponible ahora'),
              if (iv(o, 'urgent') == 1) const Pill('Urgencias', bg: warmSoft, fg: warm),
              if (schedule.isNotEmpty) Pill(schedule, bg: const Color(0xFFEFEDE6), fg: muted),
            ],
          ),
          if (desc.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 2), child: Text(desc, style: const TextStyle(color: muted, height: 1.3))),
        ],
      ),
    );
  }

  Widget _entry(DirEntry e) {
    final String id = sv(e.user, 'id');
    final String name = sv(e.user, 'display_name', 'Vecino');
    final String zone = sv(e.user, 'zone');
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Avatar(name: name, color: sv(e.user, 'avatar_color', '#0a6b66')),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: ink)),
                    Text(
                      '${e.level.name}${zone.isEmpty ? '' : ' · $zone'}',
                      style: const TextStyle(color: muted, fontSize: 13),
                    ),
                  ],
                ),
              ),
              PersonMenu(userId: id, name: name, entity: 'user', entityId: id),
            ],
          ),
          if (e.offers.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('Todavía no ofrece servicios.', style: TextStyle(color: muted)),
            )
          else
            for (final Rec o in e.offers) _offerLine(o),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(48, 42),
                  foregroundColor: e.mine ? brand : ink,
                  backgroundColor: e.mine ? brandSoft : null,
                ),
                onPressed: () => store.toggleRecommendation(id),
                icon: Icon(e.mine ? Icons.thumb_up : Icons.thumb_up_outlined, size: 18),
                label: Text(e.recs == 0 ? 'Recomendar' : '${e.recs}'),
              ),
              const Spacer(),
              if (e.offers.isNotEmpty)
                FilledButton(
                  style: FilledButton.styleFrom(minimumSize: const Size(48, 42)),
                  onPressed: () => _askHelp(sv(e.offers.first, 'trade')),
                  child: const Text('Pedirle ayuda'),
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
        final List<MapEntry<String, int>> trades = store.tradesInUse();
        final List<DirEntry> list = store.directory(q: _q.text, trade: _trade, nowOnly: _nowOnly);
        return RefreshIndicator(
          onRefresh: () async {
            await store.sync();
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            physics: const AlwaysScrollableScrollPhysics(),
            children: <Widget>[
              const Text('Vecinos', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: ink)),
              const SizedBox(height: 4),
              const Text('Quién ofrece qué en tu barrio, con recomendaciones de otros vecinos.', style: TextStyle(color: muted)),
              const SizedBox(height: 12),
              TextField(
                controller: _q,
                onChanged: (String _) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Buscar nombre u oficio',
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
                  ChoiceChipBtn(label: 'Todos', on: _trade == 'todos', onTap: () => setState(() => _trade = 'todos')),
                  for (final MapEntry<String, int> t in trades)
                    ChoiceChipBtn(
                      label: '${tileFor(t.key).icon} ${t.key} (${t.value})',
                      on: _trade == t.key,
                      onTap: () => setState(() => _trade = _trade == t.key ? 'todos' : t.key),
                    ),
                  ChoiceChipBtn(
                    label: '🟢 Disponible ahora',
                    on: _nowOnly,
                    onTap: () => setState(() => _nowOnly = !_nowOnly),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (list.isEmpty)
                EmptyState(
                  icon: '🧑‍🤝‍🧑',
                  title: _q.text.isNotEmpty || _trade != 'todos' || _nowOnly ? 'Nadie coincide' : 'Aún no hay vecinos aquí',
                  text: _q.text.isNotEmpty || _trade != 'todos' || _nowOnly
                      ? 'Prueba quitando algún filtro.'
                      : 'Cuando otros vecinos entren con el código, aparecerán aquí.',
                )
              else
                for (final DirEntry e in list) _entry(e),
            ],
          ),
        );
      },
    );
  }
}
