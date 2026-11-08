import 'package:flutter/material.dart';

import '../router.dart';

/// Pantalla de recuperación (paridad con el panel de error del PWA, pero también
/// para errores dentro de acciones, no solo de dibujado).
class RecoveryPanel extends StatelessWidget {
  const RecoveryPanel({super.key, this.detail});

  final String? detail;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Material(
        color: const Color(0xFFFFF0C2),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Esta pantalla no se pudo mostrar',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF5A3B00)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tus datos siguen guardados en tu teléfono. Vuelve a Inicio; si sigue igual, cierra y abre la app.',
                  style: TextStyle(fontSize: 16, color: Color(0xFF5A3B00)),
                ),
                if (detail != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Detalle técnico: $detail',
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF5A3B00)),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => appRouter.go('/'),
                  child: const Text('Ir a Inicio'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
