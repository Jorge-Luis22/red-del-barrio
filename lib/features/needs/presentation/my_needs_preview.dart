import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n.dart';
import '../../../app/ui/components.dart';
import 'my_needs.dart';
import 'my_needs_screen.dart' show MyNeedRow;

/// Adelanto de "Mis pedidos": solo lo que pide atención (hasta 3) y un acceso a todos.
class MyNeedsPreview extends ConsumerWidget {
  const MyNeedsPreview({super.key});

  static const _max = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(myNeedsProvider);
    return items.when(
      loading: () => const Padding(
        padding: EdgeInsets.only(bottom: 28),
        child: BvSkeletonRows(count: 2),
      ),
      error: (_, _) => Padding(
        padding: const EdgeInsets.only(bottom: 28),
        child: BvErrorState(
          message: context.l.noPudimosLeerTus,
          onRetry: () => ref.invalidate(myNeedsProvider),
        ),
      ),
      data: (all) {
        if (all.isEmpty) return const SizedBox.shrink();
        final active = all.where((n) => !n.isDone).toList();
        final shown = active.take(_max).toList();
        final done = all.length - active.length;
        return Padding(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BvSectionTitle(
                context.l.misPedidos,
                subtitle: _subtitle(context, active.length, done),
              ),
              const SizedBox(height: 12),
              if (shown.isNotEmpty)
                BvRows(
                  children: [
                    for (final n in shown)
                      MyNeedRow(
                        item: n,
                        onTap: () => context.push('/need/${n.need.id}'),
                      ),
                  ],
                ),
              if (all.length > shown.length) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => context.push('/pedidos'),
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text(context.l.verTodosMisPedidos(all.length)),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  static String _subtitle(BuildContext context, int active, int done) {
    final l = context.l;
    if (active == 0) return l.todoAlDiaResueltos(done);
    return done > 0 ? l.enCursoResueltos(active, done) : l.enCursoSolo(active);
  }
}
