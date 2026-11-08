import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/error/recovery_panel.dart';

void main() {
  // Manejador global: ningún error (de dibujado o de una acción) deja la app en blanco.
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();
    FlutterError.onError = FlutterError.presentError;
    ErrorWidget.builder = (details) => RecoveryPanel(detail: details.exceptionAsString());
    runApp(const ProviderScope(child: RedBarrioApp()));
  }, (error, stack) {
    debugPrint('Error no capturado: $error\n$stack');
  });
}
