import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di/providers.dart';
import '../../../app/theme/brand.dart';
import '../../../app/ui/components.dart';
import '../../../core/result.dart';
import '../domain/deal.dart';
import 'deal_providers.dart';

/// Línea de tiempo del trato: Aceptada → En curso → Falta calificar → Resuelta.
class DealPanel extends ConsumerStatefulWidget {
  const DealPanel({super.key, required this.deal});

  final Deal deal;

  @override
  ConsumerState<DealPanel> createState() => _DealPanelState();
}

class _DealPanelState extends ConsumerState<DealPanel> {
  int _stars = 0;
  bool _recommend = false;
  final _comment = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(duration: const Duration(seconds: 6), content: Text(msg)),
  );

  Future<void> _run(
    Future<Result<Object?>> Function() action, {
    String? ok,
  }) async {
    setState(() => _busy = true);
    final r = await action();
    if (!mounted) return;
    setState(() => _busy = false);
    switch (r) {
      case Ok():
        if (ok != null) _toast(ok);
      case Err(:final failure):
        _toast(failure.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.deal;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BvPanel(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              BvAvatar(d.providerName, size: 52),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.providerName, style: context.tt.titleMedium),
                    Text(
                      'Trato: ${d.priceLabel}',
                      style: context.tt.bodyMedium?.copyWith(
                        color: context.tones.muted,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                tooltip: 'Abrir el chat de este trato',
                onPressed: () => context.push('/mensajes/${d.id}'),
                icon: const Icon(Icons.chat_bubble_rounded),
                style: IconButton.styleFrom(minimumSize: const Size(52, 52)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _Timeline(current: d.status.index),
        const SizedBox(height: 20),
        switch (d.status) {
          DealStatus.accepted => _accepted(context, d),
          DealStatus.inProgress => _inProgress(context, d),
          DealStatus.awaitingRating => _rating(context, d),
          DealStatus.closed => _closed(context, d),
        },
      ],
    );
  }

  Widget _accepted(BuildContext context, Deal d) => BvPanel(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.pin_rounded, color: context.cs.primary),
            const SizedBox(width: 8),
            Text('Tu código de encuentro', style: context.tt.titleMedium),
          ],
        ),
        const SizedBox(height: 16),
        Semantics(
          label: 'Código ${d.code.split('').join(' ')}',
          child: ExcludeSemantics(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final digit in d.code.split(''))
                  Container(
                    width: 60,
                    height: 76,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: context.tones.violetSoft,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      digit,
                      style: context.tt.displayMedium?.copyWith(
                        color: context.cs.primary,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Díselo a ${d.providerName.split(' ').first} cuando llegue. Así confirmamos que se encontraron de verdad '
          'y el trato cuenta para la reputación.',
          style: context.tt.bodyMedium,
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _busy
                ? null
                : () => _run(
                    () => ref.read(validateMeetingCodeProvider)(d.id, d.code),
                    ok: 'Código validado. Encuentro confirmado.',
                  ),
            icon: const Icon(Icons.science_outlined),
            label: const Text('Demo: la otra persona ingresa el código'),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Todavía no hay cuentas: este botón hace de la otra persona solo para la demostración.',
          style: context.tt.bodySmall?.copyWith(color: context.tones.muted),
        ),
      ],
    ),
  );

  Widget _inProgress(BuildContext context, Deal d) => BvPanel(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BvPill(
          'Encuentro confirmado con código',
          icon: Icons.verified_rounded,
          tone: BvTone.trust,
        ),
        const SizedBox(height: 16),
        Text('En curso', style: context.tt.titleMedium),
        _Elapsed(since: d.startedAt!),
        Text(
          'Tiempo desde que se validó el código. Es informativo, no es un cobro.',
          style: context.tt.bodySmall?.copyWith(color: context.tones.muted),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _busy
                ? null
                : () => _run(
                    () => ref.read(completeDealProvider)(d.id),
                    ok: 'Servicio marcado como hecho.',
                  ),
            icon: const Icon(Icons.task_alt_rounded),
            label: const Text('Servicio hecho'),
          ),
        ),
      ],
    ),
  );

  Widget _rating(BuildContext context, Deal d) => BvPanel(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Servicio realizado${d.duration != null ? ' en ${_fmt(d.duration!)}' : ''}',
          style: context.tt.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          '¿Cómo te fue?',
          style: context.tt.bodyMedium?.copyWith(color: context.tones.muted),
        ),
        const SizedBox(height: 8),
        Center(
          child: BvStars(
            value: _stars,
            size: 40,
            onChanged: (s) => setState(() => _stars = s),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _comment,
          maxLength: 200,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(labelText: 'Comentario (opcional)'),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            'Recomendar a ${d.providerName.split(' ').first}',
            style: context.tt.titleSmall,
          ),
          subtitle: const Text(
            'Suma a "vecinos que lo recomiendan". Solo cuenta porque hubo un trato contigo.',
          ),
          value: _recommend,
          onChanged: (v) => setState(() => _recommend = v),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: (_busy || _stars == 0)
                ? null
                : () => _run(
                    () => ref.read(closeAndRateProvider)(
                      d.id,
                      stars: _stars,
                      comment: _comment.text,
                      recommend: _recommend,
                    ),
                    ok: 'Gracias. Tu calificación quedó guardada en tu teléfono.',
                  ),
            icon: const Icon(Icons.send_rounded),
            label: const Text('Enviar calificación'),
          ),
        ),
      ],
    ),
  );

  Widget _closed(BuildContext context, Deal d) {
    final summary = ref.watch(
      closedSummaryProvider((dealId: d.id, providerId: d.providerId)),
    );
    final resolved =
        ref
            .watch(dealsStreamProvider)
            .value
            ?.where((x) => x.status == DealStatus.closed)
            .length ??
        1;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.tones.trustSoft,
        borderRadius: BorderRadius.circular(22),
      ),
      child: summary.when(
        loading: () => const LinearProgressIndicator(),
        error: (_, _) => const Text('Trato cerrado.'),
        data: (s) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: context.tones.trust,
                  size: 30,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Trato resuelto y calificado',
                    style: context.tt.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (d.duration != null)
              _row(context, 'Servicio realizado en', _fmt(d.duration!)),
            _row(context, 'Precio final', d.priceLabel),
            if (s != null) ...[
              _row(
                context,
                'Reputación de ${d.providerName.split(' ').first}',
                '${s.before.average.toStringAsFixed(2)} → ${s.after.average.toStringAsFixed(2)} ★',
              ),
              _row(context, 'Calificaciones tuyas', '${s.after.realCount}'),
              _row(
                context,
                'Vecinos que lo recomiendan',
                '${s.vistoBueno.example} (ejemplo) + ${s.vistoBueno.confirmed} tuya${s.vistoBueno.confirmed == 1 ? '' : 's'}',
              ),
            ],
            _row(context, 'Necesidades resueltas', '$resolved'),
            const SizedBox(height: 12),
            Text(
              'Cada necesidad resuelta deja al barrio mejor preparado para la siguiente. '
              'La calificación de la otra persona hacia ti se mostrará cuando haya cuentas.',
              style: context.tt.bodySmall?.copyWith(color: context.tones.muted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String a, String b) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(a, style: context.tt.bodyMedium)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            b,
            textAlign: TextAlign.end,
            style: context.tt.titleSmall,
          ),
        ),
      ],
    ),
  );

  static String _fmt(Duration d) {
    final m = d.inMinutes, s = d.inSeconds % 60;
    if (m == 0) return '${d.inSeconds.clamp(1, 59)} s';
    return '$m min${s > 0 ? ' $s s' : ''}';
  }
}

/// Cuatro etapas con círculos unidos por una línea: hecho, actual y pendiente se distinguen
/// por icono y color (no solo por color).
class _Timeline extends StatelessWidget {
  const _Timeline({required this.current});

  final int current;

  static const _steps = ['Aceptada', 'En curso', 'Falta calificar', 'Resuelta'];

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Semantics(
      label: 'Etapa ${current + 1} de ${_steps.length}: ${_steps[current]}',
      child: ExcludeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < _steps.length; i++) ...[
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: i == 0
                              ? const SizedBox()
                              : _line(context, i <= current),
                        ),
                        _dot(context, i),
                        Expanded(
                          child: i == _steps.length - 1
                              ? const SizedBox()
                              : _line(context, i < current),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _steps[i],
                      textAlign: TextAlign.center,
                      style: context.tt.labelSmall?.copyWith(
                        color: i == current ? cs.primary : context.tones.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _line(BuildContext context, bool done) => Container(
    height: 4,
    color: done ? context.tones.trust : context.tones.hairline,
  );

  Widget _dot(BuildContext context, int i) {
    final cs = context.cs;
    if (i < current) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: context.tones.trust,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.check_rounded, size: 20, color: cs.onTertiary),
      );
    }
    if (i == current) {
      return Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
        child: Text(
          '${i + 1}',
          style: context.tt.labelMedium?.copyWith(color: cs.onPrimary),
        ),
      );
    }
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.tones.hairline,
        shape: BoxShape.circle,
      ),
      child: Text(
        '${i + 1}',
        style: context.tt.labelMedium?.copyWith(color: context.tones.muted),
      ),
    );
  }
}

class _Elapsed extends StatefulWidget {
  const _Elapsed({required this.since});

  final DateTime since;

  @override
  State<_Elapsed> createState() => _ElapsedState();
}

class _ElapsedState extends State<_Elapsed> {
  late final Timer _t = Timer.periodic(
    const Duration(seconds: 1),
    (_) => setState(() {}),
  );

  @override
  void dispose() {
    _t.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final e = DateTime.now().difference(widget.since);
    final mm = e.inMinutes.toString().padLeft(2, '0');
    final ss = (e.inSeconds % 60).toString().padLeft(2, '0');
    return Text(
      '$mm:$ss',
      style: context.tt.displayMedium?.copyWith(
        color: context.cs.primary,
        letterSpacing: 0,
      ),
    );
  }
}
