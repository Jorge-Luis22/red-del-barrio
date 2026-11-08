import 'package:flutter/material.dart';

import '../theme/brand.dart';

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
