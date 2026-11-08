import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/brand.dart';
import '../../../app/ui/components.dart';
import '../../../app/ui/illustrations.dart';
import '../../explore/presentation/explore_section.dart';
import '../../location/presentation/location_controller.dart';
import 'composer_sheet.dart';
import 'my_needs.dart';
import 'my_needs_screen.dart' show MyNeedRow;
import 'need_labels.dart';

/// Inicio: pedir, lo que necesita atención de mis pedidos y un adelanto de Explorar cerca.
/// Cada bloque es corto; lo demás vive en su propia pantalla ("Ver todos").
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = ref.watch(locationControllerProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _Hero(loc: loc)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            sliver: SliverList.list(
              children: [
                if (loc.status != LocationStatus.ready) ...[
                  _LocationBanner(state: loc),
                  const SizedBox(height: 24),
                ],
                const BvSectionTitle(
                  'Atajos',
                  subtitle: 'Un toque abre el pedido ya escrito',
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          const SliverToBoxAdapter(child: _QuickShortcuts()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 28, 16, 32),
            sliver: SliverList.list(
              children: const [
                _MyNeedsPreview(),
                ExploreSection(compact: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Cabecera violeta: marca, zona, pregunta principal y el botón grande de pedir.
class _Hero extends StatelessWidget {
  const _Hero({required this.loc});

  final LocationState loc;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final zone = loc.location == null
        ? 'Zona aproximada · sin dirección exacta'
        : 'Zona ${loc.location!.zone.lat.toStringAsFixed(2)}, ${loc.location!.zone.lng.toStringAsFixed(2)} (aprox. 1 km)';
    return Container(
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.paddingOf(context).top + 16,
              20,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: context.tones.coral,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.home_rounded,
                        size: 20,
                        color: cs.onSecondary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Red del barrio',
                      style: context.tt.titleMedium?.copyWith(
                        color: cs.onPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.place_outlined,
                      size: 16,
                      color: cs.onPrimary.withValues(alpha: 0.85),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        zone,
                        style: context.tt.bodySmall?.copyWith(
                          color: cs.onPrimary.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Semantics(
                  header: true,
                  child: Text(
                    '¿Qué necesitas hoy?',
                    style: context.tt.headlineLarge?.copyWith(
                      color: cs.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Cuéntalo y los vecinos y negocios de tu zona te proponen cómo resolverlo.',
                  style: context.tt.bodyMedium?.copyWith(
                    color: cs.onPrimary.withValues(alpha: 0.92),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => showComposer(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: context.tones.coral,
                      foregroundColor: cs.onSecondary,
                      minimumSize: const Size(64, 60),
                      textStyle: context.tt.titleMedium,
                    ),
                    icon: const Icon(Icons.add_circle_rounded, size: 26),
                    label: const Text('Pedir algo'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const BarrioSkyline(height: 88),
        ],
      ),
    );
  }
}

/// Aviso de ubicación en una sola franja: qué hacemos con ella y un botón claro.
class _LocationBanner extends ConsumerWidget {
  const _LocationBanner({required this.state});

  final LocationState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = state.status == LocationStatus.loading;
    final failed = state.status == LocationStatus.failed;
    return BvBanner(
      icon: failed ? Icons.location_off_rounded : Icons.my_location_rounded,
      tone: failed ? BvTone.sun : BvTone.violet,
      title: failed ? 'No pudimos ver dónde estás' : 'Ve qué hay cerca de ti',
      message: failed
          ? (state.message ?? 'Revisa que la ubicación esté activada.')
          : 'Tu ubicación se queda en tu teléfono. Los vecinos solo verán una zona de unos 1000 m.',
      action: FilledButton.icon(
        onPressed: loading
            ? null
            : () => ref.read(locationControllerProvider.notifier).request(),
        style: FilledButton.styleFrom(minimumSize: const Size(64, 48)),
        icon: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            : const Icon(Icons.near_me_rounded),
        label: Text(loading ? 'Buscando…' : 'Usar mi ubicación'),
      ),
    );
  }
}

/// Atajos: fila deslizable de baldosas grandes (icono + frase corta).
class _QuickShortcuts extends StatelessWidget {
  const _QuickShortcuts();

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 112,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: NeedLabels.quick.length,
      separatorBuilder: (_, _) => const SizedBox(width: 12),
      itemBuilder: (context, i) {
        final q = NeedLabels.quick[i];
        final tone = NeedLabels.tone(q.kind);
        final c = toneColors(context, tone);
        return Semantics(
          button: true,
          label: 'Pedir: ${q.label}',
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () => showComposer(context, kind: q.kind, text: q.text),
            child: Ink(
              width: 148,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: c.bg,
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

/// Adelanto de "Mis pedidos": solo lo que pide atención (hasta 3) y un acceso a todos.
class _MyNeedsPreview extends ConsumerWidget {
  const _MyNeedsPreview();

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
          message: 'No pudimos leer tus pedidos. Cierra y abre la app.',
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
                'Mis pedidos',
                subtitle: active.isEmpty
                    ? 'Todo al día · $done ${done == 1 ? 'resuelto' : 'resueltos'}'
                    : '${active.length} en curso${done > 0 ? ' · $done resueltos' : ''}',
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
                    label: Text('Ver todos mis pedidos (${all.length})'),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
