/// Configuración que llega por `--dart-define` al compilar. NUNCA se escribe aquí una clave real.
/// La clave pública (anon/publishable) es pública por diseño: la seguridad la dan las políticas RLS.
class AppConfig {
  const AppConfig._();

  static const _rawUrl = String.fromEnvironment('SUPABASE_URL');

  /// Limpia la URL por si se pegó con espacios, barras o el sufijo `/rest/v1`
  /// (con ese sufijo el inicio de sesión daba 404 y los pedidos no se enviaban).
  static String get supabaseUrl {
    var u = _rawUrl.trim();
    while (u.endsWith('/')) {
      u = u.substring(0, u.length - 1);
    }
    for (final suffix in const ['/rest/v1', '/auth/v1']) {
      if (u.endsWith(suffix)) u = u.substring(0, u.length - suffix.length);
    }
    return u;
  }
  static const _rawKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static String get supabaseAnonKey => _rawKey.trim();

  /// Hay datos para conectarse. Sin ellos la app funciona igual, en modo demostración.
  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  /// Lo pone `main()` solo si `Supabase.initialize` terminó bien.
  static bool supabaseReady = false;
}
