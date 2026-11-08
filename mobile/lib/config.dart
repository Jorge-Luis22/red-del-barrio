/// Configuración de la app móvil. El servidor es el mismo del piloto web (Supabase).
/// La llave `anon` es pública por diseño (también va dentro de la web publicada): lo que protege los datos
/// son las reglas del servidor (RLS) y el código del barrio, no esta llave.
/// Se puede cambiar al compilar con --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
class Config {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://ifoqgytaikdzqqjyfbpl.supabase.co',
  );
  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_CAQ5rdrmz0QX_m95E6VGzw_yv4HxU93',
  );
  static const String contactEmail = 'jorgeluisvalderramasoto2@gmail.com';
  static const String defaultZone = 'Los Olivos, Lima';
}
