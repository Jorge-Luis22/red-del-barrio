import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/brand.dart';
import '../../../app/ui/components.dart';
import 'my_needs.dart';
import 'need_labels.dart';

enum _Filter { active, done, all }

/// Todos mis pedidos, con filtro simple: En curso / Resueltos / Todos.
class MyNeedsScreen extends ConsumerStatefulWidget {
  const MyNeedsScreen({super.key});

  @override
  ConsumerState<MyNeedsScreen> createState() => _MyNeedsScreenState();
}

class _MyNeedsScreenState extends ConsumerState<MyNeedsScreen> {
  _Filter _filter = _Filter.active;

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(myNeedsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Mis pedidos')),
      body: SafeArea(
        top: false,
        child: items.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: BvSkeletonRows(),
          ),
          error: (_, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: BvErrorState(
              message: 'No pudimos leer tus pedidos.',
              onRetry: () => ref.invalidate(myNeedsProvider),
            ),
          ),
          data: (all) {
            final active = all.where((n) => !n.isDone).toList();
            final done = all.where((n) => n.isDone).toList();
            final shown = switch (_filter) {
              _Filter.active => active,
              _Filter.done => done,
              _Filter.all => all,
            };
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              children: [
                BvSegmented<_Filter>(
                  options: [
                    (
                      value: _Filter.active,
                      label: 'En curso',
                      icon: Icons.pending_actions_rounded,
                    ),
                    (
                      value: _Filter.done,
                      label: 'Resueltos',
                      icon: Icons.check_circle_rounded,
                    ),
                    (
                      value: _Filter.all,
                      label: 'Todos',
                      icon: Icons.list_alt_rounded,
                    ),
                  ],
                  selected: _filter,
                  onChanged: (f) => setState(() => _filter = f),
                ),
                const SizedBox(height: 12),
                Text(
                  '${active.length} en curso · ${done.length} resueltos',
                  style: context.tt.bodySmall?.copyWith(
                    color: context.tones.muted,
                  ),
                ),
                const SizedBox(height: 12),
                if (shown.isEmpty)
                  BvPanel(
                    child: BvEmptyState(
                      title: _filter == _Filter.done
                          ? 'Aún no resolviste ninguno'
                          : 'No tienes pedidos en curso',
                      message: _filter == _Filter.done
                          ? 'Cuando cierres un trato y lo califiques, aparecerá aquí.'
                          : 'Pide algo desde Inicio y tu barrio te propone cómo resolverlo.',
                    ),
                  )
                else
                  BvRows(
                    children: [
                      for (final n in shown)
                        MyNeedRow(
                          item: n,
                          onTap: () => context.push('/need/${n.need.id}'),
                        ),
                    ],
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Fila de un pedido: tipo, texto, para cuándo y en qué punto está.
class MyNeedRow extends StatelessWidget {
  const MyNeedRow({super.key, required this.item, required this.onTap});

  final MyNeed item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final need = item.need;
    final badge = item.badge;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            BvIconBadge(
              NeedLabels.icon(need.kind),
              tone: NeedLabels.tone(need.kind),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    need.text,
                    style: context.tt.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${NeedLabels.kind(need.kind)} · Para: ${NeedLabels.urgency(need.urgency)}',
                    style: context.tt.bodySmall?.copyWith(
                      color: context.tones.muted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  BvPill(badge.label, icon: badge.icon, tone: badge.tone),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: context.tones.muted),
          ],
        ),
      ),
    );
  }
}
