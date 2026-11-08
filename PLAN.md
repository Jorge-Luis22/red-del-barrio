# PLAN DE TRABAJO — Red del barrio (48 h)

- Ahora: sábado 07 nov, 23:20 (hora Perú)
- Corte de features: domingo 08, 12:00
- Entrega final: domingo 08, 18:30
- Criterio del jurado: el simulador (`Simulador Red Vecinal.html`) es la especificación. Si algo
  no está en el simulador, no se construye.

## Stack (bloqueado, no se discute más)

| Capa | Tecnología |
|---|---|
| Cliente | React 18 + TypeScript + Vite 6 + Capacitor 6 (PWA instalable + APK Android) |
| Base local | SQLite (sql.js WASM) persistido en IndexedDB; `outbox` idempotente para offline |
| Servidor | Supabase (Postgres + RLS + Realtime + Storage). Swap a PocketBase solo si lo decide el equipo antes de F1 |
| Chat | Matrix/Synapse vía Client-Server API (wrapper propio en `src/lib/matrix.ts`), Element como cliente de prueba |
| Infra | VPS con `docker compose` (Synapse + Caddy), dominio DuckDNS |

## Estado real del repo (este commit)

Hecho y funcionando:
- Esquema SQLite + datos demo (`src/db/schema.sql`, `seed.sql`) — 5 vecinos, 5 necesidades, propuestas, trato demo con chat.
- Capa de datos completa (`src/db/repo.ts`): publicar, proponer, aceptar, código de encuentro, chat, recomendaciones, emergencia, stats.
- Cola offline (`src/lib/outbox.ts`) y wrapper Matrix (`src/lib/matrix.ts`) con modo local.
- UI React completa de las 5 pestañas + detalle de necesidad + chat (este commit).
- `infra/` (Synapse + Caddy) y `docs/DECISIONES.md`.

Falta (es el trabajo de las próximas horas):
1. Conectar dos teléfonos: servidor (Supabase/PocketBase) + `sync.ts` que vacía el `outbox`.
2. Matrix real: levantar infra, cuentas, token, room por trato, prueba con Element.
3. GPS real en lugar de `defaultPoint()`.
4. Completar trato + calificación (tabla `ratings` ya existe, falta la UI).
5. Muro de emergencia comunal (hoy cada usuario solo ve su propia alerta).
6. Build APK + deploy web.

## Estructura

```
app/                    # PWA + APK (Capacitor)
  src/db/               # SQLite local: esquema, seed, repo (toda la lógica)
  src/lib/              # outbox, matrix, ids, geo, format
  src/state/app.tsx     # usuario actual, pestañas, navegación
  src/pages/            # Inicio, Vecinos, Mensajes, Emergencia, Perfil, NeedView, ChatView
  src/components/       # TabBar
  src/index.css         # tema (colores del simulador)
infra/                  # docker compose: Synapse + Caddy
docs/                   # decisiones técnicas
Guía técnica de implementación.md   # referencia completa (SQL, Matrix, RLS)
Simulador Red Vecinal.html          # especificación funcional
```

## Fases

### F0 — Ahora → 02:00 (esta noche)
- [ ] `pnpm install` + `pnpm dev`; recorrer las 5 pestañas con los datos demo.
- [ ] Probar el flujo completo en UN teléfono: publicar → proponer (cambiar de vecino en Perfil) → aceptar → código → chat.
- [ ] **Decisión final 23:59:** Supabase (nube, RLS) o PocketBase (SQLite también en servidor). Si no se decide, se va con Supabase: ya está documentado.
- [ ] Subir el repo a GitHub (privado), rama `main`.

### F1 — Domingo 06:00 → 09:00
- [ ] Servidor: proyecto Supabase + migraciones (`supabase/migrations/`) o PocketBase corriendo.
- [ ] `src/lib/sync.ts`: subir entidades del `outbox` al servidor con `txn_id` (idempotente) y jalar cambios (`sync_state.last_pulled_at`).
- [ ] Autenticación mínima (email+contraseña o magic link); mapear `auth.user.id` ↔ `users.id` local.
- [ ] Matrix: `docker compose up -d` en el VPS, crear cuentas, token en `.env.local`, room por trato, mensaje app ↔ Element en otro teléfono.

### F2 — Domingo 09:00 → 12:00 (CORTE DE FEATURES)
- [ ] Dos teléfonos reales: publicar en A, proponer en B, aceptar en A, chat fluido en ambos.
- [ ] Offline: modo avión → mensaje "Pendiente de envío" → conexión → enviado sin duplicar.
- [ ] Emergencia: alerta visible para los demás, institución primero, caso sensible privado.
- [ ] Completar trato → calificación de dos vías → sube el nivel solidario.
- [ ] GPS real (`useGeolocation`) con redondeo de zona; ubicación exacta solo tras aceptar.

### F3 — Domingo 12:00 → 14:00 (nada nuevo)
- [ ] Pruebas con el guion de demo (`GUION-DEMO.md`) en 2 teléfonos.
- [ ] Solo fixes P0 y pulido de textos.

### F4 — Domingo 14:00 → 16:30
- [ ] `pnpm exec cap add android` + build APK (o firma debug).
- [ ] Deploy web: `pnpm build` → carpeta `dist/` → Netlify Drop.
- [ ] Ensayo completo cronometrado (7 min), respaldo de todo (zip + OneDrive + GitHub).

## Prioridades

**P0 (sin esto no hay demo):** publicar/ver necesidades entre 2 teléfonos · propuesta → aceptar → chat real · offline con "Pendiente" · modo emergencia · APK instalable.
**P1 (la demo brilla):** GPS real · calificación y nivel solidario · recomendaciones entre usuarios reales · Element en vivo · deploy web.
**P2 (solo si sobra):** idiomas (inglés/quechua ya vienen del simulador) · fotos con EXIF limpio · búsqueda FTS · túnel si no hay VPS.

## Definición de hecho (DoD)

- **Trato:** aceptar en A → aparece en B → chat fluye < 2 s → código de 4 dígitos solo en A, una sola vez.
- **Offline:** sin red, enviar mensaje queda "Pendiente de envío"; al volver la red se envía sin duplicarse (mismo `txn_id`).
- **Emergencia:** institución primero visible; `violencia` nunca aparece en el muro público.
- **Recomendación:** un voto por vecino por proveedor; el botón alterna.
- **Privacidad:** en el servidor nunca se guarda la coordenada exacta de una necesidad abierta.

## Comandos

```bash
cd app
pnpm install          # también copia el motor sql.js a public/vendor
pnpm dev              # http://localhost:5173
pnpm build            # tsc + vite → dist/
pnpm exec cap add android
pnpm run android      # build + sync + abrir Android Studio

cd infra
Copy-Item .env.example .env   # poner DOMAIN real
docker compose up -d
docker compose exec synapse register_new_matrix_user -c /data/homeserver.yaml -u vecino1 -p clave --no-admin http://localhost:8008
```

## Riesgos y plan B

| Riesgo | Plan B |
|---|---|
| No hay VPS ni dominio | Chat local + 2 cuentas manuales en matrix.org (`VITE_MATRIX_HOMESERVER=https://matrix.org`) |
| Supabase da problemas | PocketBase: un binario en el VPS, SQLite, reglas en hooks |
| Android Studio / SDK no disponible a tiempo | Demostrar la PWA instalada (Chrome) + el build web |
| Corte 12:00 sin servidor | Demo en 2 teléfonos contra PocketBase local + túnel Cloudflare Quick Tunnel |
| Se llena el almacenamiento | Ya resuelto: sql.js exporta a IndexedDB; Perfil muestra el tamaño y permite borrar |

## Reparto sugerido (4 personas)

1. **UI/React:** NeedView, ChatView, Emergencia muro, ratings UI.
2. **Datos/servidor:** Supabase/PocketBase + `sync.ts` + RLS/reglas.
3. **Matrix/infra:** VPS, Synapse, cuentas, Element, `.well-known`.
4. **Demo/QA:** guion, pruebas de 2 teléfonos, offline, textos, respaldo.
