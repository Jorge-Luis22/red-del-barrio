# Arquitectura — Red del barrio

## 1. Decisión en una frase

**PWA con React + TypeScript, SQLite local en el dispositivo, Supabase como fuente de verdad cuando hay red, y Matrix/Synapse para el chat con interoperabilidad real con Element; APK Android con Capacitor sin reescribir nada.**

Elegimos esto porque:

- El simulador ya es HTML/CSS/JS: el equipo no cambia de lenguaje ni de modelo mental.
- `matrix-js-sdk` es la misma librería que corre Element, y aquí además usamos la API REST directa (sin SDK) para no depender de una versión.
- SQLite en el cliente es requisito real de “funciona sin internet”, y el APK se genera con Capacitor.
- Flutter habría obligado a duplicar el diseño y a un equipo que quizá no escribe Dart.

## 2. Vista general

```
┌──────────────────────────────┐
│  App (React + TS + Vite)     │
│  ┌────────────────────────┐  │
│  │ 5 pantallas            │  │
│  └──────────┬─────────────┘  │
│  ┌──────────▼─────────────┐  │
│  │ repo.ts (contratos)    │  │
│  └───┬────────────┬───────┘  │
│      │            │          │
│  ┌───▼─────┐  ┌───▼───────┐  │
│  │ SQLite  │  │ outbox    │  │
│  │ local   │  │ idempotente│ │
│  └─────────┘  └───┬───────┘  │
└───────────────────┼──────────┘
                    │
        ┌───────────┴────────────┐
        │                        │
┌───────▼────────┐      ┌────────▼─────────┐
│ Supabase       │      │ Synapse (Matrix) │
│ Postgres + RLS │      │ rooms por trato  │
│ Auth + Storage │      │ Element interoper.│
└────────────────┘      └──────────────────┘
```

**Regla de dependencia:** la UI nunca habla con Supabase ni con Matrix directamente. Habla con `app/src/db/repo.ts`. Así se puede cambiar el backend sin tocar pantallas.

## 3. Estructura de carpetas

```
Proyecto_Hackaton_Comercio_2026/
├─ app/                        # la aplicación real
│  ├─ src/
│  │  ├─ db/
│  │  │  ├─ schema.sql         # esquema SQLite (espejo del servidor)
│  │  │  ├─ seed.sql           # datos de demo
│  │  │  ├─ sqlite.ts          # motor + persistencia en IndexedDB
│  │  │  └─ repo.ts            # ÚNICA puerta a los datos
│  │  ├─ lib/
│  │  │  ├─ geo.ts             # Haversine + redondeo de zona
│  │  │  ├─ ids.ts             # uuid, txnId, hash del código
│  │  │  ├─ matrix.ts          # transporte Matrix / local
│  │  │  └─ outbox.ts          # cola idempotente
│  │  ├─ state/store.tsx       # sesión, conexión, revisión
│  │  ├─ screens/              # Inicio, Vecinos, Mensajes, Emergencia, Perfil
│  │  ├─ ui/                   # Icon, TabBar, Sheet, NeedCard
│  │  ├─ types.ts
│  │  ├─ App.tsx
│  │  └─ styles.css
│  ├─ public/                  # manifest, sw, íconos, vendor/sql.js
│  ├─ scripts/                 # copia de sql.js + prueba de humo
│  └─ capacitor.config.ts
├─ supabase/
│  ├─ migrations/0001_init.sql # esquema servidor + RLS
│  └─ functions/matrix-register/ # alta automática en Synapse
├─ infra/                      # Synapse + Caddy en un VPS
│  ├─ docker-compose.yml
│  ├─ Caddyfile
│  └─ .env.example
├─ docs/
│  ├─ PLAN-48H.md
│  └─ ARQUITECTURA.md
├─ index.html                  # simulador original (no se toca)
└─ Simulador Red Vecinal.html  # prototipo (no se toca)
```

## 4. Flujo de datos

### 4.1 Publicar una necesidad

1. La pantalla llama `createNeed()`.
2. `repo.ts` redondea la coordenada a 3 decimales (~110 m) y guarda la exacta en columnas privadas.
3. Escribe en SQLite y persiste en IndexedDB.
4. Si hay Supabase, encola en `outbox` y sube.
5. La UI se refresca por el contador `revision` del store.

### 4.2 Aceptar una propuesta

1. `acceptProposal()` genera un código de 4 dígitos.
2. Crea el room en Matrix (`createRoom`, `preset: private_chat`).
3. Guarda **solo el hash** del código y el `room_id`.
4. Marca la propuesta como aceptada y la necesidad como `en_curso`.
5. Devuelve el código en claro **una sola vez** a la UI.

El código no se escribe en el chat: si estuviera en el historial, el proveedor podría validarlo sin reunirse.

### 4.3 Enviar un mensaje sin señal

1. Se inserta el mensaje como `pendiente` con un `txn_id` único.
2. Se encola en `outbox`.
3. Se intenta `PUT /rooms/{roomId}/send/m.room.message/{txnId}`.
4. Si falla, queda pendiente. Al volver la conexión se reintenta **con el mismo `txnId`**, así el servidor no duplica.
5. La UI muestra “Pendiente de envío” y luego la hora.

## 5. Modelo de datos local

| Tabla | Para qué | Nota de privacidad |
|---|---|---|
| `users` | perfil, zona, nivel solidario | sin DNI ni teléfono en la demo |
| `needs` | pedidos y ofertas | `lat_public/lng_public` redondeadas; `lat_exact/lng_exact` privadas |
| `proposals` | precio y mensaje del proveedor | el precio lo propone el proveedor, no la app |
| `interactions` | trato aceptado | guarda `room_id` y hash del código |
| `messages` | espejo local del timeline | el original vive en Synapse |
| `ratings` | calificación de dos vías | una por persona y trato |
| `recommendations` | Visto Bueno Vecinal | `UNIQUE(provider_id, voter_id)` |
| `emergency_alerts` | alertas | institución primero; exacta solo tras aceptar |
| `outbox` | cola de salida | `UNIQUE(txn_id)` |
| `sync_state` | última sincronización | — |

**SQLite en el cliente, no en el servidor.** SQLite no acepta conexiones remotas. El servidor usa Postgres (Supabase). Si el equipo prefiere “todo SQLite”, la alternativa es PocketBase en el mismo VPS; implicaría reescribir RLS como API rules.

## 6. Matrix paso a paso

### 6.1 Homeserver

`infra/docker-compose.yml` levanta Synapse con SQLite (suficiente para 10 usuarios de demo) detrás de Caddy con TLS automático. El `.well-known/matrix/client` se sirve desde el mismo dominio.

### 6.2 Alta automática de usuarios

`supabase/functions/matrix-register` usa el secreto compartido de registro:

1. `GET /_synapse/admin/v1/register` → `nonce`.
2. `mac = HMAC-SHA1(secreto, nonce + "\0" + usuario + "\0" + contraseña + "\0" + "notadmin")`.
3. `POST` con `nonce`, `username`, `password`, `mac`.
4. Login para obtener `access_token` y `device_id`.

Así el vecino nunca ve Matrix: se registra en la app y su cuenta existe detrás.

### 6.3 Un room por trato

```http
POST /_matrix/client/v3/createRoom
{
  "name": "Trato: Fuga de agua en el baño",
  "preset": "private_chat",
  "is_direct": true,
  "visibility": "private",
  "invite": ["@u_miguel:matrix.tudominio.pe"]
}
```

El `room_id` se guarda en `interactions`. Un chat global sería más fácil, pero rompe la privacidad del trato y el guion de demo.

### 6.4 Envío idempotente

```http
PUT /_matrix/client/v3/rooms/{roomId}/send/m.room.message/{txnId}
{ "msgtype": "m.text", "body": "Voy en camino" }
```

El `txnId` es la clave: reintentar no duplica. Es el mismo principio que la cola `outbox`.

### 6.5 E2EE fuera, a propósito

En 48 horas, el cifrado extremo a extremo rompe los bots de moderación, el respaldo y las pruebas. Se declara como limitación y ruta futura. No se finge que existe.

## 7. Privacidad y seguridad

- **Ubicación:** pública redondeada a ~110 m; exacta en columnas privadas; se comparte solo al aceptar y expira.
- **Código de encuentro:** hash SHA-256 con sal; nunca en el chat ni en logs.
- **Autorización:** RLS en Postgres para todo lo sensible; en local, el `repo.ts` es la única puerta.
- **Emergencia:** la institución va primero; la app no llama ni promete respuesta.
- **Datos personales:** en la demo no hay DNI, teléfono ni dirección exacta. Si se agrega RENIEC, va con consentimiento explícito.

## 8. Decisiones registradas

| # | Decisión | Alternativa descartada | Motivo |
|---|---|---|---|
| 1 | React + Vite + TS | Flutter | reutiliza el simulador y el equipo es JS |
| 2 | SQLite local + Supabase | PocketBase | RLS y realtime listos; PocketBase queda como plan B |
| 3 | Capacitor | React Native | sin SDK maduro de Matrix en RN |
| 4 | Matrix REST directo | `matrix-js-sdk` | menos peso y control del `txnId`; el SDK queda como mejora |
| 5 | Sin E2EE en la demo | cifrado completo | riesgo alto en 48 h |
| 6 | Chat local de respaldo | depender de Synapse | la demo no se cae |
| 7 | Precio propuesto por el proveedor | precio fijo por categoría | el simulador y el reto lo piden así |
| 8 | Código hasheado en servidor | código en el chat | evita validar sin encuentro |

## 9. Después del hackathon

1. Supabase Auth con magic link + RLS real.
2. Verificación de identidad opcional (RENIEC) para proveedores.
3. Push con FCM y deep link al room.
4. Fotos con borrado de EXIF y compresión en cliente.
5. E2EE en Matrix y respaldo de claves.
6. Moderación: reportes, bloqueo y revisión humana.
7. Métricas de confianza: ayudas confirmadas, no estrellas sueltas.
