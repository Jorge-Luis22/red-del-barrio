import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
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

  void _toast(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(duration: const Duration(seconds: 6), content: Text(msg)));

  Future<void> _run(Future<Result<Object?>> Function() action, {String? ok}) async {
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
    final theme = Theme.of(context);
    final d = widget.deal;
    const steps = ['Aceptada', 'En curso', 'Falta calificar', 'Resuelta'];
    final current = d.status.index;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Card(
        child: ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person_outline)),
          title: Text(d.providerName),
          subtitle: Text('Trato: ${d.priceLabel}'),
        ),
      ),
      const SizedBox(height: 8),
      Row(children: [
        for (var i = 0; i < steps.length; i++)
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
              decoration: BoxDecoration(
                color: i <= current ? theme.colorScheme.primaryContainer : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
                border: i == current ? Border.all(color: theme.colorScheme.primary, width: 2) : null,
              ),
              child: Text(steps[i], textAlign: TextAlign.center, style: theme.textTheme.labelMedium),
            ),
          ),
      ]),
      const SizedBox(height: 16),
      switch (d.status) {
        DealStatus.accepted => _accepted(theme, d),
        DealStatus.inProgress => _inProgress(theme, d),
        DealStatus.awaitingRating => _rating(theme, d),
        DealStatus.closed => _closed(theme, d),
      },
    ]);
  }

  Widget _accepted(ThemeData theme, Deal d) => Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Tu código de encuentro', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Semantics(
              label: 'Código ${d.code.split('').join(' ')}',
              child: ExcludeSemantics(
                child: Text(d.code, style: theme.textTheme.displayMedium?.copyWith(letterSpacing: 8, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 8),
            Text('Díselo a ${d.providerName.split(' ').first} cuando llegue. Así confirmamos que se encontraron de verdad '
                'y el trato cuenta para la reputación.'),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _busy
                  ? null
                  : () => _run(
                        () => ref.read(validateMeetingCodeProvider)(d.id, d.code),
                        ok: 'Código validado. Encuentro confirmado.',
                      ),
              child: const Text('Demo: la otra persona ingresa el código'),
            ),
            const SizedBox(height: 4),
            Text('Todavía no hay cuentas: este botón hace de la otra persona solo para la demostración.', style: theme.textTheme.bodySmall),
          ]),
        ),
      );

  Widget _inProgress(ThemeData theme, Deal d) => Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Encuentro confirmado con código ✓'),
            const SizedBox(height: 8),
            Text('En curso', style: theme.textTheme.titleMedium),
            _Elapsed(since: d.startedAt!),
            const Text('Tiempo desde que se validó el código. Es informativo, no es un cobro.'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _busy ? null : () => _run(() => ref.read(completeDealProvider)(d.id), ok: 'Servicio marcado como hecho.'),
                child: const Text('Servicio hecho'),
              ),
            ),
          ]),
        ),
      );

  Widget _rating(ThemeData theme, Deal d) => Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Servicio realizado${d.duration != null ? ' en ${_fmt(d.duration!)}' : ''}. ¿Cómo te fue?', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(children: [
              for (var s = 1; s <= 5; s++)
                IconButton(
                  iconSize: 36,
                  tooltip: '$s ${s == 1 ? 'estrella' : 'estrellas'}',
                  onPressed: () => setState(() => _stars = s),
                  icon: Icon(_stars >= s ? Icons.star : Icons.star_border),
                ),
            ]),
            TextField(
              controller: _comment,
              maxLength: 200,
              decoration: const InputDecoration(labelText: 'Comentario (opcional)', border: OutlineInputBorder()),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Recomendar a ${d.providerName.split(' ').first}'),
              subtitle: const Text('Suma a "vecinos que lo recomiendan". Solo cuenta porque hubo un trato contigo.'),
              value: _recommend,
              onChanged: (v) => setState(() => _recommend = v),
            ),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: (_busy || _stars == 0)
                    ? null
                    : () => _run(
                          () => ref.read(closeAndRateProvider)(d.id, stars: _stars, comment: _comment.text, recommend: _recommend),
                          ok: 'Gracias. Tu calificación quedó guardada en tu teléfono.',
                        ),
                child: const Text('Enviar calificación'),
              ),
            ),
          ]),
        ),
      );

  Widget _closed(ThemeData theme, Deal d) {
    final summary = ref.watch(closedSummaryProvider((dealId: d.id, providerId: d.providerId)));
    final resolved = ref.watch(dealsStreamProvider).value?.where((x) => x.status == DealStatus.closed).length ?? 1;
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: summary.when(
          loading: () => const LinearProgressIndicator(),
          error: (_, _) => const Text('Trato cerrado.'),
          data: (s) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Trato resuelto y calificado', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            if (d.duration != null) _row('Servicio realizado en', _fmt(d.duration!)),
            _row('Precio final', d.priceLabel),
            if (s != null) ...[
              _row('Reputación de ${d.providerName.split(' ').first}',
                  '★ ${s.before.average.toStringAsFixed(2)} → ★ ${s.after.average.toStringAsFixed(2)}'),
              _row('Calificaciones tuyas', '${s.after.realCount}'),
              _row('Vecinos que lo recomiendan', '${s.vistoBueno.example} (ejemplo) + ${s.vistoBueno.confirmed} tuya${s.vistoBueno.confirmed == 1 ? '' : 's'}'),
            ],
            _row('Necesidades resueltas', '$resolved'),
            const SizedBox(height: 8),
            Text('Cada necesidad resuelta deja al barrio mejor preparado para la siguiente. '
                'La calificación de la otra persona hacia ti se mostrará cuando haya cuentas.', style: theme.textTheme.bodySmall),
          ]),
        ),
      ),
    );
  }

  Widget _row(String a, String b) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Text(a)),
          const SizedBox(width: 8),
          Flexible(child: Text(b, textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.w700))),
        ]),
      );

  static String _fmt(Duration d) {
    final m = d.inMinutes, s = d.inSeconds % 60;
    if (m == 0) return '${d.inSeconds.clamp(1, 59)} s';
    return '$m min${s > 0 ? ' $s s' : ''}';
  }
}

class _Elapsed extends StatefulWidget {
  const _Elapsed({required this.since});

  final DateTime since;

  @override
  State<_Elapsed> createState() => _ElapsedState();
}

class _ElapsedState extends State<_Elapsed> {
  late final Timer _t = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));

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
    return Text('$mm:$ss', style: Theme.of(context).textTheme.headlineMedium);
  }
}
