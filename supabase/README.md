# Supabase — Red del barrio

**Estado: el esquema está escrito pero NO aplicado ni probado.** La app Flutter todavía usa solo los adaptadores locales (Drift); los adaptadores remotos son el siguiente paso.

## Qué hay
| Archivo | Qué hace |
|---|---|
| `migrations/20261108000000_init.sql` | Tablas, PostGIS, funciones del ciclo del trato y **RLS en todas las tablas** |
| `migrations/20261108010000_reglas_app_v12.sql` | Alinea el servidor con la app (esquema local v12): categorías, capacidades, contraofertas (máx. 2), cancelación con motivo, calificación bidireccional, chat y muro |
| `migrations/20261108020000_corrige_recursion_politicas.sql` | Corrige la recursión infinita entre las políticas de `needs` y `proposals` (hallada al probar en Supabase real) |
| `migrations/20261108030000_client_stats_privada.sql` | `client_stats` solo muestra a cada persona su propio promedio como cliente (regla 4) |
| `tests/client_stats_privada.sql` | Comprueba que nadie más ve ese promedio |
| `tests/reglas_trato.sql` | Prueba con tres usuarios: un solo trato, contraofertas, tercera bloqueada, calificaciones |
| `tests/rls_two_users.sql` | Prueba con dos usuarios: zona redondeada, ubicación exacta solo para quien aceptó, caso privado ilegible para otros |
| `../scripts/check_secrets.py` | Revisa que no haya claves en el repositorio antes de cada push |

## Reglas inviolables y dónde se fuerzan
| Regla | Dónde se fuerza (servidor, no solo pantalla) |
|---|---|
| 3. La ubicación exacta nunca es pública | `needs.zone` se redondea con un *trigger* (~1 km); la exacta está en `need_exact_locations`, legible solo por su dueño y por quien aceptó (`exact_read`) |
| 4. Sin puntos ni puestos públicos | No hay columnas de puntos; solo la vista `provider_stats` con conteos |
| 5. Violencia es privada | `emergency_force_private_trg` la marca privada y `emergency_read` impide que otros la lean |
| Anti-inflado del Visto Bueno | Índice único `interactions_one_recommendation_per_rater` + `rate_participant` exige un servicio terminado |
| Un solo trato por pedido | `accept_proposal` bloquea la fila del pedido (`FOR UPDATE`): dos aceptaciones simultáneas se atienden de a una; las demás propuestas quedan `discarded` |
| Contraofertas (máx. 2) | `propose_price_change`: solo el prestador, solo con el trato `in_progress`, motivo obligatorio, una pendiente a la vez, tope de 2 (función + *trigger* + índice único) |
| Calificación bidireccional | `rate_participant`: una por rol y trato, sin autoevaluación; el cliente no recibe Visto Bueno |
| Idempotencia de la cola | Claves primarias UUID del cliente; `accept_proposal` y `rate_participant` se pueden repetir sin duplicar |

## Pasos para aplicarlo (los haces tú; yo no uso tus claves)
1. Crea un proyecto gratuito en supabase.com. Anota la **URL** y la clave **anon** (pública).
2. En *Database → Extensions* activa **postgis** (la migración también lo intenta).
3. Pega las **cuatro** migraciones en el *SQL Editor*, en orden de nombre (`...000000_init`, `...010000_reglas_app_v12`, `...020000_corrige_recursion_politicas`, `...030000_client_stats_privada`), y ejecútalas. Aplicadas y probadas el 2026-11-08 en un proyecto real.
4. Ejecuta `tests/reglas_trato.sql` y `tests/rls_two_users.sql` (cada una en una consulta nueva). Crean sus propios usuarios de prueba y terminan en `rollback`: no dejan datos. Si algún `assert` falla, hay una fuga: **no se usa en la demo** hasta corregirla.
5. En *Authentication* activa el acceso por correo para las cuentas reales de la app.
6. Ejecuta la app con las claves por `--dart-define` (nunca en el código):
   ```bash
   flutter run --dart-define=SUPABASE_URL=https://xxxx.supabase.co --dart-define=SUPABASE_ANON_KEY=TU_CLAVE_ANON
   ```

## Nunca
- Poner la clave `service_role` ni tokens de Synapse en la app o en el repositorio.
- Mostrar la ubicación exacta en logs, listas o respuestas.
- Antes de cada push: `python scripts/check_secrets.py`.

## Falta (siguiente trabajo)
- Adaptadores remotos (`SupabaseNeedRepository`, `SupabaseSyncGateway`…) detrás de los puertos existentes; solo cambia `lib/app/di/providers.dart`.
- Cuentas en la app (Auth), sincronización real de la cola (upsert por UUID) y Realtime.
- Datos de demostración (seed) marcados como ejemplo (`needs.is_demo`).
- Conectar el chat (`messages`, Realtime); Matrix queda como mejora futura.
- Pruebas de reglas del servidor: **pasaron** en un proyecto real (2026-11-08). Falta probar la sincronización real desde la app.
- Alinear con el esquema local de `app/src/db/schema.sql` del equipo si se usa ese cliente.
