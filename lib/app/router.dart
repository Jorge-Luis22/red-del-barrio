import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/needs/presentation/home_screen.dart';
import 'shell_scaffold.dart';

/// Rutas declarativas: las cinco pestañas del PWA (Inicio, Vecinos, Mensajes, Emergencia, Perfil).
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => ShellScaffold(shell: shell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/vecinos', builder: (_, _) => const _Pending('Vecinos')),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/mensajes', builder: (_, _) => const _Pending('Mensajes')),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/emergencia', builder: (_, _) => const _Pending('Emergencia')),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/perfil', builder: (_, _) => const _Pending('Perfil')),
        ]),
      ],
    ),
  ],
);

class _Pending extends StatelessWidget {
  const _Pending(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const Center(child: Text('Esta pantalla se migra en las siguientes partes.')),
      );
}
