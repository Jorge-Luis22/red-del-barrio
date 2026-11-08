import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../domain/need.dart';

/// Inicio provisional: demuestra que la pantalla lee del repositorio por el puerto.
/// La pantalla real (¿Qué necesitas?, Explorar cerca) se migra en la parte B.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static String _label(SyncStatus s) => switch (s) {
        SyncStatus.pending => 'Pendiente',
        SyncStatus.sent => 'Enviada',
        SyncStatus.error => 'Error',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final needs = ref.watch(needsStreamProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Red del barrio')),
      body: needs.when(
        data: (list) => list.isEmpty
            ? const Center(child: Text('Aún no publicaste ninguna necesidad.'))
            : ListView(
                children: [
                  for (final n in list)
                    ListTile(title: Text(n.text), subtitle: Text(_label(n.syncStatus))),
                ],
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('No pudimos leer tus datos. Reinicia la app.')),
      ),
    );
  }
}
