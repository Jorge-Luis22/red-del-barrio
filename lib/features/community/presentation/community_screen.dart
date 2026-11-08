import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di/community_providers.dart';
import '../../../app/l10n.dart';
import '../../../app/ui/components.dart';
import '../../assistant/presentation/tr.dart';
import '../../needs/presentation/need_labels.dart';
import '../domain/community_need.dart';

/// Tarjeta de la portada que lleva a «Pedidos del barrio» (lo que publican otros celulares).
class CommunityEntry extends ConsumerWidget {
  const CommunityEntry({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(communityFeedProvider).isAvailable;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: ListTile(
          leading: const Icon(Icons.groups_rounded),
          title: Text(tr(context, 'Pedidos del barrio', 'Neighborhood requests')),
          subtitle: Text(
            online
                ? tr(
                    context,
                    'Mira lo que piden otros vecinos con la app.',
                    'See what other neighbors are asking for.',
                  )
                : tr(
                    context,
                    'Modo demostración: sin conexión al servidor.',
                    'Demo mode: no server connection.',
                  ),
          ),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => context.push('/barrio'),
        ),
      ),
    );
  }
}

/// Pedidos abiertos publicados desde cualquier celular (vienen del servidor).
class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(communityFeedProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(tr(context, 'Pedidos del barrio', 'Neighborhood requests')),
        actions: [
          IconButton(
            tooltip: tr(context, 'Actualizar', 'Refresh'),
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(communityNeedsProvider),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: !feed.isAvailable
            ? Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    tr(
                      context,
                      'Esta versión no está conectada al servidor. Instala la versión con servidor para ver los pedidos de otros vecinos.',
                      'This build is not connected to the server.',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : ref
                  .watch(communityNeedsProvider)
                  .when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(16),
                      child: BvSkeletonRows(),
                    ),
                    error: (e, _) => Padding(
                      padding: const EdgeInsets.all(16),
                      child: BvErrorState(
                        message: tr(
                          context,
                          'No pudimos leer los pedidos del barrio. Revisa tu internet.',
                          'Could not load requests. Check your internet.',
                        ),
                        onRetry: () => ref.invalidate(communityNeedsProvider),
                      ),
                    ),
                    data: (items) => items.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(24),
                            child: Center(
                              child: Text(
                                tr(
                                  context,
                                  'Aún no hay pedidos abiertos. Publica el primero desde la portada.',
                                  'No open requests yet.',
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async =>
                                ref.refresh(communityNeedsProvider.future),
                            child: ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                              itemCount: items.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (_, i) => _NeedTile(items[i]),
                            ),
                          ),
                  ),
      ),
    );
  }
}

class _NeedTile extends StatelessWidget {
  const _NeedTile(this.need);
  final CommunityNeed need;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Card(
      child: ListTile(
        leading: Icon(NeedLabels.icon(need.kind)),
        title: Text(need.text),
        subtitle: Text(
          '${NeedLabels.kind(l, need.kind)} · ${NeedLabels.urgency(l, need.urgency)}'
          '${need.isMine ? ' · ${tr(context, 'Tuyo', 'Yours')}' : ''}',
        ),
      ),
    );
  }
}
