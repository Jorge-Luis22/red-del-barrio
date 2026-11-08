import 'app_settings.dart';

abstract interface class SettingsRepository {
  Stream<AppSettings> watch();

  /// Aplica un cambio sobre los ajustes actuales y lo guarda.
  Future<void> update(AppSettings Function(AppSettings current) change);

  /// Borra los datos de la persona en este teléfono (pedidos, tratos, mensajes, ajustes…).
  Future<void> eraseAll();
}
