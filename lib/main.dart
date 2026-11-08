import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'app/config.dart';
import 'app/error/recovery_panel.dart';

void main() {
  // Manejador global: ningún error (de dibujado o de una acción) deja la app en blanco.
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      FlutterError.onError = FlutterError.presentError;
      ErrorWidget.builder = (details) =>
          RecoveryPanel(detail: details.exceptionAsString());
      await _iniciarServidor();
      runApp(const ProviderScope(child: RedBarrioApp()));
    },
    (error, stack) {
      debugPrint('Error no capturado: $error\n$stack');
    },
  );
}

/// Conecta con Supabase solo si hay claves. Si falla, la app sigue en modo demostración.
Future<void> _iniciarServidor() async {
  if (!AppConfig.hasSupabase) return;
  try {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
    AppConfig.supabaseReady = true;
  } catch (e, st) {
    debugPrint('No se pudo iniciar Supabase: $e\n$st');
  }
}
