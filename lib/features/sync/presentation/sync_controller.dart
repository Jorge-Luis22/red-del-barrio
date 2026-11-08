import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';

/// Vacía la cola de pendientes al abrir la app, al volver la conexión y cada 30 segundos
/// mientras quede algo (así un envío que falló se reintenta solo).
/// No depende de tareas en segundo plano (R14).
class SyncController extends Notifier<bool> {
  static const retryEvery = Duration(seconds: 30);

  @override
  bool build() {
    final sub = ref.read(connectivityProvider).onlineChanges.listen((online) {
      if (online) flushNow();
    });
    final retry = Timer.periodic(retryEvery, (_) => flushNow());
    ref.onDispose(() {
      sub.cancel();
      retry.cancel();
    });
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
