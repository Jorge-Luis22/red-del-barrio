import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/l10n.dart';
import '../../../app/theme/brand.dart';

/// Cuatro etapas con círculos unidos por una línea: hecho, actual y pendiente se distinguen
/// por icono y color (no solo por color).
class DealTimeline extends StatelessWidget {
  const DealTimeline({super.key, required this.current});

  /// Índice de la etapa actual (0 a 3).
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
            for (var i = 0; i < steps.length; i++)
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
    final Color bg;
    final Widget child;
    if (i < current) {
      bg = context.tones.trust;
      child = Icon(Icons.check_rounded, size: 20, color: cs.onTertiary);
    } else if (i == current) {
      bg = cs.primary;
      child = Text(
        '${i + 1}',
        style: context.tt.labelMedium?.copyWith(color: cs.onPrimary),
      );
    } else {
      bg = context.tones.hairline;
      child = Text(
        '${i + 1}',
        style: context.tt.labelMedium?.copyWith(color: context.tones.muted),
      );
    }
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: child,
    );
  }
}

/// Cronómetro informativo del servicio en curso (no es un cobro).
class DealElapsed extends StatefulWidget {
  const DealElapsed({super.key, required this.since});

  final DateTime since;

  @override
  State<DealElapsed> createState() => _DealElapsedState();
}

class _DealElapsedState extends State<DealElapsed> {
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
