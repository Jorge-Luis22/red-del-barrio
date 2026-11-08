/// ÚNICO lugar que decide qué adaptador implementa cada puerto, repartido por módulo.
/// mobile-ux: adaptadores locales (Drift) y datos de demostración.
/// Con servidor se cambian aquí, sin tocar dominio ni pantallas.
///
/// Las pantallas importan solo este archivo.
library;

export 'chat_providers.dart';
export 'core_providers.dart';
export 'deals_providers.dart';
export 'directory_providers.dart';
export 'emergency_providers.dart';
export 'location_providers.dart';
export 'needs_providers.dart';
export 'settings_providers.dart';
export 'solidarity_providers.dart';
export 'sync_providers.dart';
