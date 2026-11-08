# Red del barrio — app móvil (Flutter)

Misma app que la web del piloto (muro, publicar en 3 toques, propuestas, chat del trato, directorio de vecinos,
niveles, reportar/bloquear, borrar mi cuenta), hecha en Flutter para Android. Usa **el mismo servidor** (Supabase)
que el piloto web: lo que publica alguien desde el celular lo ve quien entra por la web, y al revés.

## Cómo se compila
No hace falta instalar nada: GitHub lo compila.
1. Entra a **Actions → "Celular (APK Android)"** en el repositorio.
2. Abre la última ejecución verde y baja el archivo **red-del-barrio-apk** (es un .zip con `app-release.apk`).
3. Pásalo al teléfono, ábrelo y permite "instalar apps desconocidas" cuando Android lo pida.

La carpeta `android/` no se guarda en el repositorio: el flujo de GitHub la genera con `flutter create`
y le agrega el permiso de internet.

## Probarlo en tu computadora (opcional)
```bash
cd mobile
flutter create --org pe.redbarrio --project-name red_barrio --platforms=android .
flutter run
```
Para apuntar a otro servidor: `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`.

## Qué incluye y qué no (esta primera versión)
Incluye: entrar con el código del piloto, muro con búsqueda y filtros, publicar Necesito/Ofrezco con botones **y
texto libre**, propuestas, aceptar y código de encuentro, chat, confirmar el trato, calificar, directorio con
recomendaciones, perfil con nivel, bloqueo, reporte, y borrar la cuenta.

Todavía no: módulo de Emergencia, ubicación (GPS), favores "sin dinero" y recursos, y guardar datos sin conexión
entre aperturas de la app (lo que escribes sin señal se envía al volver la red mientras la app siga abierta).

## Estructura
- `lib/api.dart` — cuenta anónima (Supabase Auth) y llamadas al servidor.
- `lib/store.dart` — datos en memoria, sincronización (subir/bajar), consultas y acciones.
- `lib/catalog.dart` — botones de oficios y reglas de títulos (igual que `app/src/lib/publish.ts`).
- `lib/screens/` — pantallas.
