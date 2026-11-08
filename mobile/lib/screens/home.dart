import 'package:flutter/material.dart';

import '../store.dart';
import '../theme.dart';
import 'directory.dart';
import 'messages.dart';
import 'profile.dart';
import 'wall.dart';

/// Pantalla principal: cuatro pestañas (Muro, Vecinos, Mensajes, Perfil) y un aviso si no hay conexión.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;

  /// Para que otra pestaña pueda pedir cambiar de pestaña (por ejemplo, ir a Mensajes).
  void _go(int tab) => setState(() => _tab = tab);

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      const WallScreen(),
      const DirectoryScreen(),
      MessagesScreen(onGoWall: () => _go(0)),
      const ProfileScreen(),
    ];
    return ListenableBuilder(
      listenable: store,
      builder: (BuildContext context, Widget? child) {
        final int chats = store.conversations().length;
        return Scaffold(
          body: SafeArea(
            bottom: false,
            child: Column(
              children: <Widget>[
                if (store.syncState != 'ok') _SyncBanner(state: store.syncState, detail: store.syncDetail),
                Expanded(child: IndexedStack(index: _tab, children: pages)),
              ],
            ),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _tab,
            onDestinationSelected: _go,
            backgroundColor: Colors.white,
            destinations: <NavigationDestination>[
              const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Muro'),
              const NavigationDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: 'Vecinos',
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: chats > 0,
                  label: Text('$chats'),
                  child: const Icon(Icons.chat_bubble_outline),
                ),
                selectedIcon: const Icon(Icons.chat_bubble),
                label: 'Mensajes',
              ),
              const NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Perfil',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SyncBanner extends StatelessWidget {
  const _SyncBanner({required this.state, required this.detail});
  final String state;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final bool offline = state == 'sin_conexion';
    return Container(
      width: double.infinity,
      color: offline ? warmSoft : const Color(0xFFFBE4E2),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Text(
        offline
            ? 'Sin conexión. Lo que escribas se enviará cuando vuelva la señal.'
            : 'No se pudo sincronizar${detail.isEmpty ? '' : ': $detail'}',
        style: TextStyle(color: offline ? warm : danger, fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }
}
