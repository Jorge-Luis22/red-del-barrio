import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../app/l10n.dart';
import '../../../app/theme/brand.dart';
import '../../../app/ui/components.dart';
import '../../assistant/presentation/tr.dart';
import '../../reputation/domain/interaction.dart';
import '../domain/deal.dart';
import 'deal_action_runner.dart';
import 'deal_providers.dart';
import 'deal_timeline.dart';

/// Tarjeta de cada etapa del trato. El panel muestra solo la que corresponde.

String _firstName(Deal d) => d.providerName.split(' ').first;

/// "2 min 5 s", "45 s"…
String formatDealDuration(AppLocalizations l, Duration d) {
  final m = d.inMinutes, s = d.inSeconds % 60;
  if (m == 0) return l.duracionSegundos(d.inSeconds.clamp(1, 59));
  return s > 0 ? l.duracionMinutosSegundos(m, s) : l.duracionMinutos(m);
}

/// Etapa 1: código de encuentro de 4 dígitos para decírselo a la otra persona.
class MeetingCodeCard extends ConsumerStatefulWidget {
  const MeetingCodeCard({super.key, required this.deal});

  final Deal deal;

  @override
  ConsumerState<MeetingCodeCard> createState() => _MeetingCodeCardState();
}

class _MeetingCodeCardState extends ConsumerState<MeetingCodeCard>
    with DealActionRunner {
  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final d = widget.deal;
    return BvPanel(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pin_rounded, color: context.cs.primary),
              const SizedBox(width: 8),
              Text(l.tuCodigoDeEncuentro, style: context.tt.titleMedium),
            ],
          ),
          const SizedBox(height: 16),
          Semantics(
            label: l.codigoDigitos(d.code.split('').join(' ')),
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
          Text(l.diselo(_firstName(d)), style: context.tt.bodyMedium),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: busy
                  ? null
                  : () => run(
                      () => ref.read(validateMeetingCodeProvider)(d.id, d.code),
                      ok: l.codigoValidadoEncuentroConfirmado,
                    ),
              icon: const Icon(Icons.science_outlined),
              label: Text(l.demoLaOtraPersona),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l.todaviaNoHayCuentas,
            style: context.tt.bodySmall?.copyWith(color: context.tones.muted),
          ),
        ],
      ),
    );
  }
}

/// Etapa 2: servicio en curso con cronómetro y botón "Servicio hecho".
class InProgressCard extends ConsumerStatefulWidget {
  const InProgressCard({super.key, required this.deal});

  final Deal deal;

  @override
  ConsumerState<InProgressCard> createState() => _InProgressCardState();
}

class _InProgressCardState extends ConsumerState<InProgressCard>
    with DealActionRunner {
  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final d = widget.deal;
    return BvPanel(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BvPill(
            l.encuentroConfirmadoConCodigo,
            icon: Icons.verified_rounded,
            tone: BvTone.trust,
          ),
          const SizedBox(height: 16),
          Text(l.enCurso, style: context.tt.titleMedium),
          DealElapsed(since: d.startedAt!),
          Text(
            l.tiempoDesdeQueSe,
            style: context.tt.bodySmall?.copyWith(color: context.tones.muted),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: busy
                  ? null
                  : () => run(
                      () => ref.read(completeDealProvider)(d.id),
                      ok: l.servicioMarcadoComoHecho,
                    ),
              icon: const Icon(Icons.task_alt_rounded),
              label: Text(l.servicioHecho),
            ),
          ),
        ],
      ),
    );
  }
}

/// Etapa 3: calificar con estrellas, comentario y recomendación.
class RatingCard extends ConsumerStatefulWidget {
  const RatingCard({super.key, required this.deal});

  final Deal deal;

  @override
  ConsumerState<RatingCard> createState() => _RatingCardState();
}

class _RatingCardState extends ConsumerState<RatingCard> with DealActionRunner {
  int _stars = 0;
  bool _recommend = false;
  final _comment = TextEditingController();

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final d = widget.deal;
    return BvPanel(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            d.duration != null
                ? l.servicioRealizadoEnTiempo(
                    formatDealDuration(l, d.duration!),
                  )
                : l.servicioRealizado,
            style: context.tt.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            l.comoTeFue,
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
            decoration: InputDecoration(labelText: l.comentarioOpcional),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              l.recomendarA(_firstName(d)),
              style: context.tt.titleSmall,
            ),
            subtitle: Text(l.sumaAVecinosQue),
            value: _recommend,
            onChanged: (v) => setState(() => _recommend = v),
          ),
          const SizedBox(height: 12),
          if (_stars == 0 && !busy) ...[
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 18,
                  color: context.tones.muted,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l.hintStars,
                    style: context.tt.bodySmall?.copyWith(
                      color: context.tones.muted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: (busy || _stars == 0)
                  ? null
                  : () => run(
                      () => ref.read(closeAndRateProvider)(
                        d.id,
                        stars: _stars,
                        comment: _comment.text,
                        recommend: _recommend,
                      ),
                      ok: l.graciasTuCalificacionQuedo,
                    ),
              icon: const Icon(Icons.send_rounded),
              label: Text(l.enviarCalificacion),
            ),
          ),
        ],
      ),
    );
  }
}

/// Etapa 4: resumen del trato resuelto, con la reputación antes y después.
class ClosedSummaryCard extends ConsumerWidget {
  const ClosedSummaryCard({super.key, required this.deal});

  final Deal deal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final d = deal;
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
        error: (_, _) => Text(l.tratoCerrado),
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
                    l.tratoResueltoYCalificado,
                    style: context.tt.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (d.duration != null)
              _SummaryRow(
                l.servicioRealizadoEn,
                formatDealDuration(l, d.duration!),
              ),
            _SummaryRow(l.precioFinal, d.priceLabel),
            if (s != null) ...[
              _SummaryRow(
                l.reputacionDe(_firstName(d)),
                '${s.before.average.toStringAsFixed(2)} → ${s.after.average.toStringAsFixed(2)} ★',
              ),
              _SummaryRow(l.calificacionesTuyas, '${s.after.realCount}'),
              _SummaryRow(
                l.vecinosQueLoRecomiendan,
                l.vecinosRecomiendanResumen(
                  s.vistoBueno.example,
                  s.vistoBueno.confirmed,
                ),
              ),
            ],
            _SummaryRow(l.necesidadesResueltas, '$resolved'),
            const SizedBox(height: 12),
            Text(
              l.cadaNecesidadResueltaDeja,
              style: context.tt.bodySmall?.copyWith(color: context.tones.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label, style: context.tt.bodyMedium)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: context.tt.titleSmall,
          ),
        ),
      ],
    ),
  );
}

/// Calificación en el otro sentido: quien presta el servicio califica a quien lo pidió.
/// Vive en la pantalla de quien prestó el servicio (`ProviderViewSheet`); en esta versión de un
/// solo teléfono se abre como simulación, y con servidor lo hará cada persona desde la suya.
class ClientRatingCard extends ConsumerStatefulWidget {
  const ClientRatingCard({super.key, required this.deal});

  final Deal deal;

  @override
  ConsumerState<ClientRatingCard> createState() => _ClientRatingCardState();
}

class _ClientRatingCardState extends ConsumerState<ClientRatingCard>
    with DealActionRunner {
  int _stars = 0;
  final _comment = TextEditingController();

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.deal;
    final all = ref.watch(interactionsStreamProvider).value ?? const [];
    final saved = all
        .where((i) => i.id == Interaction.clientRatingId(d.id))
        .firstOrNull;
    return BvPanel(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr(context, 'Califica al cliente', 'Rate the client'),
            style: context.tt.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            tr(
              context,
              'Califica a quien te pidió el servicio. '
                  'Así la confianza va en los dos sentidos.',
              'Rate the person who asked you for the service. '
                  'Trust goes both ways.',
            ),
            style: context.tt.bodyMedium?.copyWith(color: context.tones.muted),
          ),
          const SizedBox(height: 12),
          if (saved != null) ...[
            Row(
              children: [
                BvStars(value: saved.stars, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    tr(
                      context,
                      'Calificación al cliente guardada',
                      'Client rating saved',
                    ),
                    style: context.tt.titleSmall,
                  ),
                ),
              ],
            ),
            if (saved.comment.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(saved.comment, style: context.tt.bodyMedium),
            ],
          ] else ...[
            Center(
              child: BvStars(
                value: _stars,
                size: 36,
                onChanged: (s) => setState(() => _stars = s),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _comment,
              maxLength: 200,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: tr(
                  context,
                  'Comentario sobre el cliente (opcional)',
                  'Comment about the client (optional)',
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: (busy || _stars == 0)
                    ? null
                    : () => run(
                        () => ref.read(rateClientProvider)(
                          d.id,
                          stars: _stars,
                          comment: _comment.text,
                        ),
                        ok: tr(
                          context,
                          'Calificación al cliente guardada.',
                          'Client rating saved.',
                        ),
                      ),
                icon: const Icon(Icons.star_rate_rounded),
                label: Text(
                  tr(context, 'Calificar al cliente', 'Rate the client'),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
