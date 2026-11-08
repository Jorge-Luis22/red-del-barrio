import 'package:flutter/foundation.dart';

/// Registro solo para desarrollo: el detalle técnico nunca va a la pantalla.
void logError(String where, Object error, [StackTrace? stack]) {
  debugPrint('[$where] $error${stack == null ? '' : '\n$stack'}');
}
