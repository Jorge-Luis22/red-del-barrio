/// Configuración que llega por `--dart-define` al compilar. NUNCA se escribe aquí una clave real.
/// La clave pública (anon/publishable) es pública por diseño: la seguridad la dan las políticas RLS.
class AppConfig {
  const AppConfig._();

  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Hay datos para conectarse. Sin ellos la app funciona igual, en modo demostración.
  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  /// Lo pone `main()` solo si `Supabase.initialize` terminó bien.
  static bool supabaseReady = false;
}
