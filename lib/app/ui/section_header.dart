import 'package:flutter/material.dart';

import '../theme/brand.dart';
import 'components.dart';

/// Cabecera de color de una sección (Vecinos, Mensajes, Emergencia, Perfil).
/// Cada sección tiene su propio color de la paleta, pero comparten forma y tipografía.
class BvSectionHeader extends StatelessWidget {
  const BvSectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.fromLTRB(
      20,
      MediaQuery.paddingOf(context).top + 20,
      20,
      28,
    ),
    decoration: BoxDecoration(
      color: background,
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  title,
                  style: context.tt.headlineMedium?.copyWith(color: foreground),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: context.tt.bodyMedium?.copyWith(
                  color: foreground.withValues(alpha: 0.92),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: foreground.withValues(alpha: 0.16),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 32, color: foreground),
        ),
      ],
    ),
  );
}

/// Pantalla de una sección que todavía no se migró a esta versión. Dice la verdad:
/// no promete funciones ni muestra datos inventados.
class BvComingSoonScreen extends StatelessWidget {
  const BvComingSoonScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tone,
    required this.message,
    this.notice,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final BvTone tone;
  final String message;

  /// Aviso extra (p. ej. que en una urgencia se llama primero a los servicios oficiales).
  final String? notice;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (tone) {
      BvTone.coral => (context.tones.coral, context.cs.onSecondary),
      BvTone.trust => (context.tones.trust, context.cs.onTertiary),
      BvTone.emergency => (context.tones.emergency, context.cs.onError),
      _ => (context.cs.primary, context.cs.onPrimary),
    };
    final accent = tone == BvTone.emergency
        ? context.tones.emergency
        : (tone == BvTone.trust ? context.tones.trust : null);
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          BvSectionHeader(
            title: title,
            subtitle: subtitle,
            icon: icon,
            background: bg,
            foreground: fg,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              children: [
                BvEmptyState(
                  title: 'Esta sección llega pronto',
                  message: message,
                  accent: accent,
                ),
                if (notice != null)
                  BvBanner(
                    icon: Icons.info_outline_rounded,
                    tone: tone == BvTone.emergency
                        ? BvTone.emergency
                        : BvTone.sun,
                    message: notice!,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
