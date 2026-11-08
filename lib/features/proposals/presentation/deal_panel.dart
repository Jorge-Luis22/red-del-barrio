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
import '../../../app/l10n.dart';
import '../../../app/ui/failure_text.dart';

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
        _toast(failureText(context.l, failure));
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
                      context.l.trato(d.priceLabel),
                      style: context.tt.bodyMedium?.copyWith(
                        color: context.tones.muted,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                tooltip: context.l.abrirElChatDe,
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
            Text(context.l.tuCodigoDeEncuentro, style: context.tt.titleMedium),
          ],
        ),
        const SizedBox(height: 16),
        Semantics(
          label: context.l.codigoDigitos(d.code.split('').join(' ')),
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
          context.l.diselo(d.providerName.split(' ').first),
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
                    ok: context.l.codigoValidadoEncuentroConfirmado,
                  ),
            icon: const Icon(Icons.science_outlined),
            label: Text(context.l.demoLaOtraPersona),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          context.l.todaviaNoHayCuentas,
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
        BvPill(
          context.l.encuentroConfirmadoConCodigo,
          icon: Icons.verified_rounded,
          tone: BvTone.trust,
        ),
        const SizedBox(height: 16),
        Text(context.l.enCurso, style: context.tt.titleMedium),
        _Elapsed(since: d.startedAt!),
        Text(
          context.l.tiempoDesdeQueSe,
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
                    ok: context.l.servicioMarcadoComoHecho,
                  ),
            icon: const Icon(Icons.task_alt_rounded),
            label: Text(context.l.servicioHecho),
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
          d.duration != null
              ? context.l.servicioRealizadoEnTiempo(
                  _fmt(context.l, d.duration!),
                )
              : context.l.servicioRealizado,
          style: context.tt.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          context.l.comoTeFue,
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
          decoration: InputDecoration(labelText: context.l.comentarioOpcional),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            context.l.recomendarA(d.providerName.split(' ').first),
            style: context.tt.titleSmall,
          ),
          subtitle: Text(context.l.sumaAVecinosQue),
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
                    ok: context.l.graciasTuCalificacionQuedo,
                  ),
            icon: const Icon(Icons.send_rounded),
            label: Text(context.l.enviarCalificacion),
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
        error: (_, _) => Text(context.l.tratoCerrado),
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
                    context.l.tratoResueltoYCalificado,
                    style: context.tt.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (d.duration != null)
              _row(
                context,
                context.l.servicioRealizadoEn,
                _fmt(context.l, d.duration!),
              ),
            _row(context, context.l.precioFinal, d.priceLabel),
            if (s != null) ...[
              _row(
                context,
                context.l.reputacionDe(d.providerName.split(' ').first),
                '${s.before.average.toStringAsFixed(2)} → ${s.after.average.toStringAsFixed(2)} ★',
              ),
              _row(
                context,
                context.l.calificacionesTuyas,
                '${s.after.realCount}',
              ),
              _row(
                context,
                context.l.vecinosQueLoRecomiendan,
                context.l.vecinosRecomiendanResumen(
                  s.vistoBueno.example,
                  s.vistoBueno.confirmed,
                ),
              ),
            ],
            _row(context, context.l.necesidadesResueltas, '$resolved'),
            const SizedBox(height: 12),
            Text(
              context.l.cadaNecesidadResueltaDeja,
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

  static String _fmt(AppLocalizations l, Duration d) {
    final m = d.inMinutes, s = d.inSeconds % 60;
    if (m == 0) return l.duracionSegundos(d.inSeconds.clamp(1, 59));
    return s > 0 ? l.duracionMinutosSegundos(m, s) : l.duracionMinutos(m);
  }
}

/// Cuatro etapas con círculos unidos por una línea: hecho, actual y pendiente se distinguen
/// por icono y color (no solo por color).
class _Timeline extends StatelessWidget {
  const _Timeline({required this.current});

  final int current;

  static List<String> _stepNames(AppLocalizations l) => [
    l.aceptada,
    l.enCurso,
    l.faltaCalificar,
    l.resuelta,
  ];

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final steps = _stepNames(context.l);
    return Semantics(
      label: context.l.etapaDe(current + 1, steps.length, steps[current]),
      child: ExcludeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < steps.length; i++) ...[
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
                          child: i == steps.length - 1
                              ? const SizedBox()
                              : _line(context, i < current),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      steps[i],
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
