import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';

/// Vacía la cola de pendientes al abrir la app y cada vez que cambia la conexión
/// (R14: no depender de tareas en segundo plano).
class SyncController extends Notifier<bool> {
  @override
  bool build() {
    final sub = ref.read(connectivityProvider).onlineChanges.listen((online) {
      if (online) flushNow();
    });
    ref.onDispose(sub.cancel);
    Future.microtask(flushNow);
    return false; // true mientras se está enviando
  }

  Future<void> flushNow() async {
    if (state) return;
    state = true;
    try {
      await ref.read(flushOutboxProvider)();
    } finally {
      state = false;
    }
  }
}

final syncControllerProvider = NotifierProvider<SyncController, bool>(
  SyncController.new,
);
