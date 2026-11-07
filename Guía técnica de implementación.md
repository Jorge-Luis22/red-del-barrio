# Guía técnica de implementación — Red Vecinal

**Versión:** 1.0 · **Fecha:** sábado 7 de noviembre de 2026, 18:30 (America/Lima)
**Insumos:** `Simulador Red Vecinal (Copy).html` + `Informe técnico y funcional Red de capacidades y confianza vecinal.md`
**Meta:** llevar la simulación a una app real, demostrable en dos teléfonos y con chat Matrix interoperable con Element, antes del domingo 8 a las 6:30 p. m.

> **Regla de oro:** el simulador es la **especificación** y el banco de pruebas, no el código base. Se reutilizan diseño, textos y los 10 casos; se reemplaza la lógica simulada por servicios reales. Todo lo que siga siendo ficticio se dice en el pitch (el propio simulador ya tiene la lista "Simulado y se dice").

---

## 0. Resumen ejecutivo

| Capa | Elección | Por qué |
|---|---|---|
| App | **React + TypeScript + Vite** (PWA instalable) | El simulador ya es HTML/CSS/JS: se porta el diseño casi tal cual. Corre en cualquier teléfono del jurado sin instalar nada. |
| APK Android | **Capacitor 7** sobre el mismo build | Un comando y Android Studio; no se reescribe nada. |
| UI | **CSS del simulador** (variables y clases) + componentes propios | Ya está probado en 360 px, modo oscuro, alto contraste y texto grande. Cero UI kit que pelee con el diseño. |
| Estado | **Zustand** | Refleja el objeto `S` del simulador; menos ceremonia que Redux. |
| Persistencia local | **Dexie** (IndexedDB) | Cola `outbox` + caché de necesidades; sobrevive recargas y modo avión. |
| Backend | **Supabase** (Postgres + Auth + Storage + Realtime + Edge Functions) | Free tier, RLS, sin servidor que mantener. |
| Chat | **Synapse** (Matrix) + **matrix-js-sdk** | Un room por trato; el mismo SDK que usa Element. |
| Interoperabilidad | **Element Web / Element X** | El jurado escribe desde Element y aparece en la app. |
| Mapas | **Leaflet + OpenStreetMap** | Sin API key ni factura. |
| Deploy | **Vercel** (web) + **Supabase Cloud** + **VPS Hetzner CX22 o Cloudflare Tunnel** (Synapse) | USD 0–5 al mes. |

**Por qué no Flutter ahora:** el simulador entregado es HTML/CSS/JS. Reescribirlo en Dart duplica trabajo y elimina la ventaja de tener el diseño y los 10 flujos ya validados. Además, `matrix-js-sdk` es la implementación de referencia de Matrix (la que corre Element), mientras que el SDK de Dart tiene menos ejemplos y menos gente que pueda ayudar a las 3 a. m. Si el equipo tuviera dos personas con Flutter en producción, la balanza cambiaría; con un simulador web, no.

**Lo que no se hace:** React Native (no hay SDK de Matrix maduro), Kotlin nativo (solo Android y más lento), microservicios, Kubernetes, pagos, E2EE, push notifications.

---

## 1. Qué se reutiliza del simulador

| Activo del simulador | Uso en la app real |
|---|---|
| Variables CSS (`--accent`, `--alert`, `--mark`, modo oscuro, alto contraste) | Se copian a `src/styles/tokens.css`. El modo emergencia solo cambia el acento a rojo, igual que hoy. |
| Clases `.item`, `.card`, `.chip`, `.btn`, `.sheet`, `.chatpanel`, `.tabbar` | Base de los componentes; se convierten en JSX sin rediseñar. |
| Textos y microcopy en español | Se mueven a `src/i18n/es.json`; no se reescriben. |
| Los 10 casos de la guía | Se convierten en **criterios de aceptación** y en el guion de demo (ver §16). |
| Forma del estado `S` | Es el borrador del store de Zustand. |
| Datos ficticios (Carlos, María, precios, distancias) | Solo para el `seed` de demo, nunca para producción. |

**Lo que no se reutiliza:** el JavaScript embebido, los `setTimeout` que simulan respuestas, las traducciones de ejemplo (quechua/francés/etc.), los números de emergencia sin verificar y el "chat" guionizado.

**Contrato de honestidad:** en la app real, el chat es Matrix de verdad; la geolocalización es real (redondeada); la verificación de identidad sigue simulada si no hay tiempo; los números oficiales se marcan "por verificar" hasta contrastarlos con la fuente.

---

## 2. Arquitectura

```
┌──────────────────────────────┐
│  PWA React (Vercel)          │
│  · 5 pestañas                │
│  · Dexie: caché + outbox     │
│  · Leaflet + OSM             │
└───────┬──────────────┬───────┘
        │ REST/Realtime│ Matrix Client-Server API
        ▼              ▼
┌───────────────┐  ┌──────────────────┐
│ Supabase      │  │ Synapse          │
│ · Auth        │  │ · rooms por trato│
│ · Postgres+RLS│  │ · /sync          │
│ · Storage     │  │ · media          │
│ · Edge Fn     │  └────────┬─────────┘
└───────────────┘           │
        │                   ▼
        │            Element (jurado)
        └── Edge Function `register-matrix-user`
            (crea la cuenta Matrix con HMAC)
```

**Principio:** una sola fuente de verdad por dominio.

- Identidad, necesidades, propuestas, tratos, calificaciones, emergencias → **Postgres**.
- Mensajes → **Matrix** (no se duplican en Postgres; solo se guarda `room_id` en el trato).
- Fotos → **Supabase Storage** (bucket privado, URLs firmadas), sin EXIF.
- Ubicación exacta → tabla aparte con RLS para las dos partes, nunca en la necesidad pública.

---

## 3. Estructura del repositorio

```
red-vecinal/
├─ public/
│  ├─ manifest.webmanifest
│  └─ icons/
├─ src/
│  ├─ main.tsx
│  ├─ App.tsx
│  ├─ styles/
│  │  ├─ tokens.css          # copiado del simulador
│  │  └─ components.css
│  ├─ components/            # Button, Card, Sheet, Chip, Avatar, TabBar…
│  ├─ features/
│  │  ├─ auth/
│  │  ├─ needs/              # publicar, listar, detalle, propuestas
│  │  ├─ deals/              # aceptar, código, cronómetro, ajustes, cierre
│  │  ├─ chat/               # Matrix
│  │  ├─ emergency/
│  │  ├─ wall/               # muro de pedidos y ofertas
│  │  ├─ profile/            # roles, capacidades, nivel solidario
│  │  └─ settings/           # idioma, accesibilidad, verificación
│  ├─ lib/
│  │  ├─ supabase.ts
│  │  ├─ matrix.ts
│  │  ├─ outbox.ts
│  │  ├─ geo.ts              # Haversine, redondeo, geohash
│  │  ├─ image.ts            # re-encode + borrado de EXIF
│  │  └─ validation.ts       # zod
│  ├─ store/                 # Zustand
│  └─ i18n/                  # es.json, en.json, …
├─ supabase/
│  ├─ migrations/
│  └─ functions/register-matrix-user/index.ts
├─ infra/
│  ├─ docker-compose.yml     # Synapse + Caddy
│  ├─ homeserver.yaml
│  └─ Caddyfile
├─ tests/
│  ├─ unit/                  # Vitest: puntos, cancelaciones, ajustes
│  └─ e2e/                   # Playwright: 3 rutas críticas
├─ capacitor.config.ts
└─ vite.config.ts
```

---

## 4. Herramientas, versiones y costo

| Área | Herramienta | Versión | Costo |
|---|---|---|---|
| Runtime | Node.js LTS | 22.x | — |
| Gestor | pnpm | 9+ | — |
| Build | Vite | 6.x | — |
| UI | React + TypeScript | 19 / 5.7 | — |
| Estado | Zustand | 5.x | — |
| Formularios | React Hook Form + Zod | 7 / 3 | — |
| DB local | Dexie | 4.x | — |
| Fechas | date-fns | 4.x | — |
| i18n | i18next + react-i18next | 24 / 15 | — |
| Mapas | Leaflet + react-leaflet | 1.9 | gratis |
| Backend | Supabase | Cloud Free | USD 0 |
| SDK backend | @supabase/supabase-js | 2.x | — |
| Chat | matrix-js-sdk | última | — |
| Homeserver | Synapse (Docker) | última | VPS ~USD 4.5/mes |
| Proxy TLS | Caddy | 2.x | — |
| PWA | vite-plugin-pwa (Workbox) | 0.21 | — |
| APK | Capacitor + Android Studio | 7 / Ladybug | — |
| Tests | Vitest + Playwright | 3 / 1.5 | — |
| Deploy web | Vercel Hobby | — | USD 0 |
| Túnel alternativo | Cloudflare Tunnel | — | USD 0 |

**Costo total del stack:** USD 0 si se usa `matrix.org` o un túnel; ~USD 5/mes con VPS propio y dominio. Ese número entra directo en la diapositiva de "costos mínimos".

---

## 5. Modelo de datos (Postgres / Supabase)

```sql
-- Extensiones
create extension if not exists pgcrypto;

-- 1. Perfiles (1:1 con auth.users)
create table profiles (
  id uuid primary key references auth.users on delete cascade,
  alias text not null,
  zone_label text,                 -- "Barrio Primavera, zona 3" (nunca dirección)
  lat_aprox numeric(8,3),          -- 3 decimales ≈ 110 m
  lng_aprox numeric(8,3),
  role text not null default 'demanda'
    check (role in ('demanda','oferta','ambos')),
  comm_pref text default 'texto'
    check (comm_pref in ('texto','voz','lengua_senas','otro')),
  verified boolean default false,  -- simulado en el MVP
  created_at timestamptz default now()
);

-- 2. Capacidades declaradas (para emergencias)
create table capabilities (
  user_id uuid references profiles on delete cascade,
  key text not null,               -- primeros_auxilios, movilidad, herramientas…
  primary key (user_id, key)
);

-- 3. Necesidades
create type need_type as enum ('servicio','producto','prestamo','ayuda');
create type need_status as enum
  ('publicada','aceptada','en_curso','completada','cancelada','expirada');

create table needs (
  id uuid primary key default gen_random_uuid(),
  author_id uuid not null references profiles,
  type need_type not null,
  title text not null,
  description text,
  details jsonb default '{}',      -- preguntas guiadas del simulador
  photo_path text,                 -- Storage, sin EXIF
  zone_label text,
  lat_aprox numeric(8,3),
  lng_aprox numeric(8,3),
  when_label text,                 -- "Ahora mismo", "Hoy"…
  status need_status default 'publicada',
  created_at timestamptz default now(),
  expires_at timestamptz
);

-- 4. Propuestas
create table proposals (
  id uuid primary key default gen_random_uuid(),
  need_id uuid not null references needs on delete cascade,
  provider_id uuid not null references profiles,
  price_label text,                -- "S/ 35", "Préstamo gratis", "Trueque"
  price_value numeric,
  distance_m int,
  availability text,
  message text,
  status text default 'enviada'
    check (status in ('enviada','aceptada','rechazada','retirada')),
  created_at timestamptz default now(),
  unique (need_id, provider_id)
);

-- 5. Tratos (la interacción confirmada)
create type deal_status as enum
  ('aceptado','en_curso','completado','cancelado');

create table deals (
  id uuid primary key default gen_random_uuid(),
  need_id uuid not null references needs,
  proposal_id uuid not null references proposals,
  requester_id uuid not null references profiles,
  provider_id uuid not null references profiles,
  status deal_status default 'aceptado',
  meeting_code_hash text not null, -- pgcrypto crypt()
  code_attempts int default 0,
  accepted_at timestamptz default now(),
  started_at timestamptz,          -- al validar el código
  completed_at timestamptz,
  cancelled_at timestamptz,
  cancel_reason text,
  cancel_penalty int default 0,
  room_id text,                    -- room de Matrix
  matrix_room_created boolean default false
);

-- 6. Ajustes de precio (máx. 2 rondas, con motivo)
create table price_adjustments (
  id uuid primary key default gen_random_uuid(),
  deal_id uuid not null references deals on delete cascade,
  proposed_by uuid not null references profiles,
  new_price numeric not null,
  motive text not null,
  status text default 'pendiente'
    check (status in ('pendiente','aceptado','rechazado')),
  created_at timestamptz default now()
);

-- 7. Calificaciones de dos vías
create table ratings (
  id uuid primary key default gen_random_uuid(),
  deal_id uuid not null references deals on delete cascade,
  rater_id uuid not null references profiles,
  ratee_id uuid not null references profiles,
  role text not null check (role in ('proveedor','cliente')),
  stars int not null check (stars between 1 and 5),
  tags text[] default '{}',
  comment text,
  created_at timestamptz default now(),
  unique (deal_id, rater_id)
);

-- 8. Puntos solidarios (privados)
create table solidarity_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profiles,
  deal_id uuid not null references deals,
  points int not null,
  reason text not null,
  created_at timestamptz default now(),
  unique (deal_id, user_id, reason)
);

-- 9. Emergencias
create table emergency_events (
  id uuid primary key default gen_random_uuid(),
  kind text not null,              -- sismo, incendio, inundacion, medico…
  active boolean default true,
  started_at timestamptz default now()
);

create table emergency_posts (
  id uuid primary key default gen_random_uuid(),
  event_id uuid references emergency_events,
  author_id uuid not null references profiles,
  situation text not null,
  title text not null,
  what_happened text not null,
  needs text[] default '{}',
  zone_label text,
  lat_aprox numeric(8,3),
  lng_aprox numeric(8,3),
  sensitive boolean default false, -- violencia/acoso: NO se publica
  status text default 'abierta'
    check (status in ('abierta','atendida','cerrada')),
  confirmations int default 0,
  created_at timestamptz default now()
);

create table help_offers (
  id uuid primary key default gen_random_uuid(),
  post_id uuid references emergency_posts on delete cascade,
  helper_id uuid references profiles,
  message text,
  status text default 'ofrecida'
    check (status in ('ofrecida','aceptada','completada')),
  created_at timestamptz default now(),
  unique (post_id, helper_id)
);

-- 10. Acopio y donativos (sin dinero)
create table collection_points (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  zone_label text,
  lat_aprox numeric(8,3),
  lng_aprox numeric(8,3),
  items text[] default '{}',
  active boolean default true
);

create table donations (
  id uuid primary key default gen_random_uuid(),
  point_id uuid references collection_points,
  donor_id uuid references profiles,
  item text not null,
  qty int default 1,
  status text default 'comprometido'
    check (status in ('comprometido','entregado')),
  anonymous boolean default false,
  created_at timestamptz default now()
);

-- 11. Ubicación exacta (solo las dos partes del trato)
create table deal_locations (
  deal_id uuid primary key references deals on delete cascade,
  exact_lat numeric(9,6),
  exact_lng numeric(9,6),
  shared_by uuid references profiles,
  expires_at timestamptz default now() + interval '24 hours'
);

-- 12. Mapeo Supabase ↔ Matrix (sin guardar contraseñas)
create table matrix_accounts (
  user_id uuid primary key references profiles on delete cascade,
  matrix_user_id text not null unique,
  created_at timestamptz default now()
);

-- 13. Reportes y contactos oficiales
create table reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid references profiles,
  target_type text not null,
  target_id uuid not null,
  reason text not null,
  status text default 'abierto',
  created_at timestamptz default now()
);

create table official_contacts (
  id uuid primary key default gen_random_uuid(),
  emergency_kind text not null,
  name text not null,
  phone text,
  source_url text,
  verified_at timestamptz        -- null = "por verificar"
);
```

**RLS mínima obligatoria** (sin esto, cualquiera lee todo):

```sql
alter table profiles enable row level security;
alter table needs enable row level security;
alter table proposals enable row level security;
alter table deals enable row level security;
alter table ratings enable row level security;
alter table matrix_accounts enable row level security; -- solo la Edge Function (service role)

-- Perfiles: todos leen alias/zona; solo el dueño edita
create policy "perfiles legibles" on profiles for select to authenticated using (true);
create policy "perfil propio" on profiles for update to authenticated
  using (id = auth.uid()) with check (id = auth.uid());

-- Necesidades: visibles para autenticados; solo el autor escribe
create policy "necesidades legibles" on needs for select to authenticated using (true);
create policy "necesidad propia" on needs for all to authenticated
  using (author_id = auth.uid()) with check (author_id = auth.uid());

-- Propuestas: las ve el autor de la necesidad y el ofertante
create policy "propuestas visibles" on proposals for select to authenticated
  using (
    provider_id = auth.uid()
    or exists (select 1 from needs n where n.id = need_id and n.author_id = auth.uid())
  );

-- Tratos: solo las dos partes
create policy "trato visible" on deals for select to authenticated
  using (requester_id = auth.uid() or provider_id = auth.uid());

-- Ubicación exacta: solo las dos partes y mientras no expire
create policy "ubicacion del trato" on deal_locations for select to authenticated
  using (
    expires_at > now()
    and exists (
      select 1 from deals d
      where d.id = deal_id
        and (d.requester_id = auth.uid() or d.provider_id = auth.uid())
    )
  );
```

**Distancia aproximada** sin PostGIS (suficiente para el MVP):

```sql
create or replace function distance_m(
  lat1 numeric, lng1 numeric, lat2 numeric, lng2 numeric
) returns int language sql immutable as $$
  select round(
    6371000 * 2 * asin(sqrt(
      power(sin(radians(lat2 - lat1) / 2), 2) +
      cos(radians(lat1)) * cos(radians(lat2)) *
      power(sin(radians(lng2 - lng1) / 2), 2)
    ))
  )::int;
$$;
```

Se muestra como `"a ~400 m"` o `"a ~1,2 km"`, nunca la coordenada.

---

## 6. Lógica de negocio

### 6.1 Máquina de estados del trato

```
publicada ──aceptar propuesta──▶ aceptado
                                   │ validar código (4 dígitos)
                                   ▼
                                en_curso ──confirmar──▶ completado
                                   │                        │
                                   │ cancelar               └─▶ calificar (2 vías)
                                   ▼
                               cancelado
```

| Transición | Quién | Regla |
|---|---|---|
| `publicada → aceptado` | Autor de la necesidad | Una sola propuesta aceptada; las demás pasan a `rechazada` en una transacción. |
| `aceptado → en_curso` | Proveedor ingresa código | Código de 4 dígitos, hash en DB, máximo 5 intentos; arranca cronómetro. |
| `en_curso → completado` | Autor confirma | Registra `completed_at`; habilita calificaciones. |
| Cualquiera → `cancelado` | Cualquiera | Ver §6.3. |

**El código de encuentro nunca se escribe en el chat ni se muestra al proveedor.** Se genera al aceptar, se muestra solo al solicitante y el proveedor lo ingresa en la app. En el simulador aparece como "código de demo"; en la app real se obtiene del backend.

```ts
// supabase/functions/... o RPC
const code = String(crypto.getRandomValues(new Uint32Array(1))[0] % 9000 + 1000);
await supabase.rpc('create_deal', { p_proposal_id, p_code: code });
// DB guarda crypt(code, gen_salt('bf')) y devuelve el código una sola vez al solicitante
```

### 6.2 Ajuste de precio

- Solo mediante registro estructurado (`price_adjustments`), **nunca** por chat.
- Motivo obligatorio de una lista cerrada + "otro".
- Máximo **2 rondas** por trato.
- El otro lado acepta, rechaza o contraoferta; si rechaza, se puede cancelar sin penalización.
- Historial visible en el perfil del proveedor ("2 ajustes, 2 aceptados").

### 6.3 Cancelaciones y cumplimiento

| Situación | Penalización |
|---|---|
| Dentro de la ventana de gracia (real: 5 min; en la demo: 30 s) | 0 |
| Después de la gracia, antes de validar código | −5 puntos de cumplimiento |
| Trabajo ya iniciado (`en_curso`) | −10 puntos + aviso a la otra parte |
| Con causa (no responde, problema distinto, sin acuerdo de precio) | 0 |
| "No llegó" tras ETA + 15 min | 0 para quien espera; afecta al ausente |

`compliance_pct` empieza en 100 y se muestra en el perfil. **No hay pagos**: la consecuencia es reputacional, no económica. Eso se dice explícitamente en el pitch.

### 6.4 Reputación de dos vías

- Solo se califica un trato `completado`.
- Proveedor califica al cliente y cliente al proveedor; **contextual** (no un solo número global).
- Etiquetas: Puntual, Claro con el problema, Buen trato, Cumplió lo acordado.
- Comentario opcional, texto plano, moderable.
- Promedio + número de interacciones; se muestran ambos (`4,8 · 12`), nunca solo el promedio.

### 6.5 Nivel solidario (privado)

```ts
// Solo cuenta: trato completado + código validado + calificación 4–5
const base = stars === 5 ? 10 : 6;
const unique = firstHelpTo(providerId, counterpartId) ? 1 : 0.5;
const points = Math.round(base * unique);
// tope diario configurable (propuesta: 12)
```

- Niveles propuestos: **Semilla (0) → Colaborador (10) → Solidario (25) → Brigadista (50)**; umbrales en tabla `config` y marcados "por validar".
- Los puntos y el puesto son **privados**; en público solo se ve el nombre del nivel.
- Beneficios: visibilidad de ofertas, prioridad en pedidos no urgentes, peso al confirmar reportes, rol de brigadista, constancia.
- **Nunca** se bloquea pedir ayuda ni los contactos de emergencia por nivel.

### 6.6 Anti-abuso mínimo

- Un voto por trato y por persona (`unique (deal_id, rater_id)`).
- No auto-calificación; no calificar sin código validado.
- Límite de intentos del código y de propuestas por hora.
- Reportes con motivo; cola de moderación manual (no IA en 48 h).
- Detección simple de "intercambio de favores": si A y B se califican mutuamente más de 3 veces en 24 h, los puntos de las repeticiones valen 0.

---

## 7. Matrix + Element, paso a paso

### 7.1 Decisión

| Opción | Veredicto |
|---|---|
| **Synapse propio** | ✅ Elegido. Permite crear cuentas por API y rooms por trato. |
| matrix.org | ⚠️ Plan B. Gratis, pero sin auto-registro y con rate limits. Sirve para la demo si no hay VPS. |
| Conduit | ❌ Menos documentación y sin el endpoint de registro con HMAC. |
| E2EE | ❌ Fuera del MVP. Rooms sin cifrar; se declara como limitación y ruta futura. |

### 7.2 Infraestructura con Docker

`infra/docker-compose.yml`:

```yaml
services:
  synapse:
    image: matrixdotorg/synapse:latest
    restart: unless-stopped
    volumes:
      - ./data:/data
    environment:
      - SYNAPSE_CONFIG_PATH=/data/homeserver.yaml
    expose:
      - "8008"

  caddy:
    image: caddy:2
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile:ro
      - caddy_data:/data
    depends_on:
      - synapse

volumes:
  caddy_data:
```

`infra/Caddyfile`:

```
matrix.tudominio.com {
    reverse_proxy synapse:8008
}
```

`infra/homeserver.yaml` (mínimo para demo, **sin federación**):

```yaml
server_name: "matrix.tudominio.com"
public_baseurl: "https://matrix.tudominio.com/"
pid_file: /data/homeserver.pid

listeners:
  - port: 8008
    tls: false
    type: http
    bind_addresses: ["0.0.0.0"]
    resources:
      - names: [client, media]
        compress: false

database:
  name: sqlite3
  args:
    database: /data/homeserver.db

media_store_path: /data/media_store
registration_shared_secret: "CAMBIA_ESTO_POR_32_BYTES_ALEATORIOS"
enable_registration: false
report_stats: false

rc_login:
  address:
    per_second: 0.5
    burst_count: 10
  account:
    per_second: 0.3
    burst_count: 10
```

> SQLite alcanza para una demo de 10–30 usuarios. No se activa federación: no hace falta `/.well-known` ni el puerto 8448, y se elimina una fuente enorme de fallos.

**Alternativa sin VPS ni dominio (si van justos de tiempo):**

```bash
cloudflared tunnel --url http://localhost:8008
```

Devuelve una URL `https://…trycloudflare.com` que se usa como `baseUrl`. Es gratis y tarda 2 minutos; la desventaja es que la URL cambia si se reinicia el túnel. Se levanta una vez y no se toca hasta después del pitch.

### 7.3 Crear cuentas Matrix al registrarse

**Camino rápido (sábado):** crear 6 cuentas a mano y mapearlas en la tabla `matrix_accounts`.

```bash
docker compose exec synapse register_new_matrix_user \
  -c /data/homeserver.yaml \
  -u vecino01 -p 'ClaveLarga123' --no-admin \
  http://localhost:8008
```

**Camino automatizado (domingo, si hay tiempo):** Edge Function `register-matrix-user`.

```ts
// supabase/functions/register-matrix-user/index.ts (Deno)
import { createClient } from 'npm:@supabase/supabase-js@2';

const SYNAPSE = Deno.env.get('SYNAPSE_URL')!;          // https://matrix...
const SECRET  = Deno.env.get('MATRIX_SHARED_SECRET')!;

async function hmacHex(key: string, msg: string) {
  const enc = new TextEncoder();
  const k = await crypto.subtle.importKey(
    'raw', enc.encode(key), { name: 'HMAC', hash: 'SHA-256' }, false, ['sign']
  );
  const sig = await crypto.subtle.sign('HMAC', k, enc.encode(msg));
  return [...new Uint8Array(sig)].map(b => b.toString(16).padStart(2, '0')).join('');
}

Deno.serve(async (req) => {
  const auth = req.headers.get('Authorization') ?? '';
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  );
  const { data: { user } } = await supabase.auth.getUser(auth.replace('Bearer ', ''));
  if (!user) return new Response('no autorizado', { status: 401 });

  const { data: existing } = await supabase
    .from('matrix_accounts').select('*').eq('user_id', user.id).maybeSingle();
  if (existing) return Response.json(existing);

  const username = 'u_' + user.id.replace(/-/g, '').slice(0, 12);
  const password = await hmacHex(SECRET, 'pw:' + user.id); // determinista, no se guarda

  const nonce = await (await fetch(`${SYNAPSE}/_synapse/admin/v1/register`)).json()
    .then((r: any) => r.nonce);

  const mac = await hmacHex(
    SECRET,
    `${nonce}\x00${username}\x00${password}\x00notadmin`
  );

  const res = await fetch(`${SYNAPSE}/_synapse/admin/v1/register`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ nonce, username, password, admin: false, mac })
  });
  if (!res.ok) return new Response(await res.text(), { status: 502 });

  const { user_id } = await res.json();
  await supabase.from('matrix_accounts')
    .insert({ user_id: user.id, matrix_user_id: user_id });
  return Response.json({ user_id, password, base_url: SYNAPSE });
});
```

> La contraseña se deriva con HMAC para poder reemitirla al mismo usuario autenticado; no se guarda en la base. Es una simplificación de hackathon, no un diseño de producción.

### 7.4 Un room por trato

```ts
import { createClient, Preset } from 'matrix-js-sdk';

const mx = createClient({ baseUrl: import.meta.env.VITE_MATRIX_URL });
await mx.loginRequest({
  type: 'm.login.password',
  identifier: { type: 'm.id.user', user: matrixUserId },
  password
});
await mx.startClient({ initialSyncLimit: 20 });

// Al aceptar la propuesta:
const { room_id } = await mx.createRoom({
  preset: Preset.PrivateChat,
  is_direct: true,
  invite: [counterpartMatrixId],
  name: `Necesidad #${shortId}`,
  topic: `deal:${dealId}`,
  initial_state: []           // sin m.room.encryption
});

await supabase.from('deals').update({ room_id, matrix_room_created: true }).eq('id', dealId);
```

**Mensajes:**

```ts
await mx.sendEvent(roomId, 'm.room.message', {
  msgtype: 'm.text',
  body: text
}, txnId); // mismo txnId al reintentar → Matrix no duplica
```

Si el SDK falla en el navegador, el plan B es un wrapper REST de ~250 líneas con estos cuatro endpoints:

| Acción | Endpoint |
|---|---|
| Crear room | `POST /_matrix/client/v3/createRoom` |
| Enviar | `PUT /_matrix/client/v3/rooms/{roomId}/send/m.room.message/{txnId}` |
| Sincronizar | `GET /_matrix/client/v3/sync?since={token}&timeout=30000` |
| Invitar | `POST /_matrix/client/v3/rooms/{roomId}/invite` |

**Fricción conocida:** `matrix-js-sdk` en Vite a veces pide `global`. Si aparece `global is not defined`, agregar en `vite.config.ts`:

```ts
define: { global: 'globalThis' }
```

### 7.5 El truco de interoperabilidad

1. En el teléfono A, la app crea el room al aceptar la propuesta.
2. En el teléfono B (o una pestaña), Element Web → "Editar homeserver" → la URL de Synapse → login con la cuenta del vecino.
3. El jurado escribe desde Element; el mensaje aparece en la app.
4. La app responde; Element lo recibe.

Eso demuestra que el chat no es un mock: es Matrix real. Ningún competidor va a mostrarlo.

**Checklist antes de la demo:**

- [ ] El room se crea sin `m.room.encryption`.
- [ ] Ambos usuarios están invitados y el room aparece en Element.
- [ ] Los mensajes de ida y vuelta llegan en <2 s.
- [ ] El badge de "Pendiente de envío" funciona sin red.
- [ ] El token de Matrix persiste tras recargar.
- [ ] Hay un video de respaldo con el flujo completo.

---

## 8. Offline-first

El simulador ya define el comportamiento: la app abre sin internet, guarda la solicitud como pendiente y la envía al volver. Se implementa así:

1. **Caché de lectura:** Dexie guarda necesidades, propuestas y el último timeline de cada room.
2. **Cola de escritura (`outbox`):**

```ts
type OutboxItem =
  | { id: string; kind: 'need'; payload: NeedDraft; createdAt: number }
  | { id: string; kind: 'message'; roomId: string; body: string; txnId: string; createdAt: number }
  | { id: string; kind: 'offer'; payload: OfferDraft; createdAt: number };
```

3. **Identidad idempotente:** el `id` se genera en el cliente (UUID v4) y se usa como PK en Supabase (`upsert`) y como `txnId` en Matrix. Reintentar no duplica.
4. **Disparadores de flush:** evento `online`, `visibilitychange`, intervalo de 30 s y arranque de la app.
5. **UI:** cada elemento pendiente muestra "Pendiente de envío"; al sincronizar, "Enviado". Nunca se borra de la vista.
6. **Service worker:** `vite-plugin-pwa` precachea el shell y los íconos; las imágenes de OSM se cachean con `StaleWhileRevalidate` y un límite.
7. **Conflicto:** el servidor manda en estados (`aceptado`, `completado`); el cliente manda en borradores propios. Si un trato cambió mientras estabas offline, se muestra el estado real y se descarta la acción obsoleta.

**Prueba obligatoria:** modo avión → publicar necesidad → ver "Pendiente" → volver online → ver "Sincronizado". Es el Caso 4 del simulador.

**Lo que no se promete:** comunicación entre celulares sin red (BLE, malla). El simulador ya lo aclara; mantener esa honestidad.

---

## 9. Modo emergencia

### 9.1 Preparación (antes)

- Perfil: capacidades declaradas (primeros auxilios, movilidad, herramientas, ayuda a adultos mayores), toggle "disponible ahora".
- Contactos oficiales por tipo de emergencia, con fuente y fecha de verificación. Si no están verificados, la UI dice "por verificar" y no se inventan números.
- Puntos de acopio y qué se necesita en cada uno.

### 9.2 Activación (durante)

- Botón rojo "Modo emergencia" en Perfil y en la pestaña Emergencia.
- El acento global pasa a rojo (igual que el simulador).
- Tres estados de un toque: **Estoy bien / Necesito ayuda / Puedo ayudar**.
- Estado "Necesito ayuda" → elegir situación: sismo, incendio, inundación, médico, violencia o acoso, otro.
- **Institución primero:** antes de publicar, se muestra el contacto oficial y la recomendación de llamar. La app no reemplaza a bomberos, serenazgo ni salud.
- Publicar: qué pasó + qué se necesita + zona aproximada. Sin dirección exacta.
- Los casos **sensibles** (violencia/acoso) **no se publican en el muro**; se ofrece el canal privado y el contacto oficial.
- Vecinos ofrecen ayuda; al aceptar, se abre chat Matrix y recién ahí el solicitante puede compartir su ubicación exacta (con expiración de 24 h).
- Muro de emergencia con filtro por tipo; confirmaciones de vecinos (peso mayor según nivel, una por persona).
- Donativos: objetos y cantidades a un punto de acopio; **sin dinero**.

### 9.3 Reglas de UI

- Todo debe funcionar con una mano y en menos de 3 toques.
- Nada depende del audio: texto, frases rápidas, alertas visuales y vibración.
- El estado "Estoy bien" no oculta las necesidades de otros.
- Si no hay red, el estado y la publicación quedan en `outbox` y se muestran como pendientes.

### 9.4 Después

- Cerrar la emergencia (solo quien la activó o un admin).
- Las publicaciones quedan en modo lectura y se archivan.
- Constancia de ayuda vecinal para quien participó.

---

## 10. Privacidad y seguridad

| Riesgo | Mitigación |
|---|---|
| Dirección exacta expuesta | Solo `lat_aprox`/`lng_aprox` (3 decimales ≈ 110 m) en necesidades y muro. Coordenada exacta en `deal_locations` con RLS y expiración. |
| EXIF en fotos | Re-encodear en el cliente con `canvas` antes de subir (eso borra GPS, cámara y fecha). Bucket privado + URLs firmadas. |
| Casos sensibles | `sensitive = true` → nunca en el muro público; solo canal privado y contacto oficial. |
| Suplantación | Verificación simulada en el MVP; se declara. No se promete "identidad validada". |
| Chat sin cifrar | Se declara: rooms sin E2EE por tiempo; ruta futura con `matrix-js-sdk` + cifrado y verificación de dispositivos. |
| Datos de menores | No se piden edades ni datos de niños; los pedidos de cuidado se describen sin datos del menor. |
| Moderación | Reportes + revisión manual; no IA. Términos y aviso de privacidad mínimos. |
| Tokens | El token de Matrix vive en el almacenamiento local del cliente; nunca en Postgres. |
| Secretos | `MATRIX_SHARED_SECRET` y `SERVICE_ROLE_KEY` solo en Edge Functions, nunca en el bundle. |

**Sobre pagos:** no hay. Si alguien intenta coordinar un pago por chat, se muestra el aviso disuasorio (el simulador ya lo tiene) y se reporta. Eso evita lavado de activos, comisiones y cumplimiento normativo en 48 h.

---

## 11. Idiomas y accesibilidad

- `i18next` con JSON por idioma. **Español completo**; inglés completo si alcanza; portugués, quechua, francés, chino y japonés solo si están realmente traducidos. Si no, se muestran como "en progreso" y se dice en el pitch.
- El cambio de idioma no debe romper el layout: probar con textos 30 % más largos.
- Accesibilidad:
  - Objetivos táctiles ≥ 44 px (el simulador ya los cumple).
  - Contraste AA; modo alto contraste.
  - Texto grande (zoom 1.18 como en el simulador).
  - Foco visible y navegación por teclado.
  - `aria-live` en el chat y en los avisos.
  - Nada depende del audio; frases rápidas para el chat; preferencia de comunicación en el perfil.
  - `prefers-reduced-motion`.
- Prueba con TalkBack (Android) y VoiceOver (iOS) en las 3 pantallas críticas: publicar, aceptar, chat.

---

## 12. Variables de entorno

**Frontend (`.env.local`, expuesto en el bundle):**

```bash
VITE_SUPABASE_URL=https://xxxx.supabase.co
VITE_SUPABASE_ANON_KEY=eyJ...
VITE_MATRIX_URL=https://matrix.tudominio.com
VITE_MAP_TILES=https://tile.openstreetmap.org/{z}/{x}/{y}.png
VITE_APP_VERSION=0.1.0
```

**Edge Functions (secretos, nunca en el frontend):**

```bash
supabase secrets set \
  SYNAPSE_URL=https://matrix.tudominio.com \
  MATRIX_SHARED_SECRET=... \
  SUPABASE_SERVICE_ROLE_KEY=...
```

**Regla:** si una variable empieza con `VITE_`, es pública. Los secretos de Matrix y la service role no llevan ese prefijo.

---

## 13. Deploy y costos

### 13.1 Web (Vercel)

```bash
pnpm build
npx vercel --prod
```

- Build: `vite build`; output: `dist`.
- HTTPS automático; URL estable para el jurado.
- `vercel.json` con rewrites solo si se agrega router.

### 13.2 Android (Capacitor)

```bash
pnpm add -D @capacitor/cli
pnpm add @capacitor/core @capacitor/android
npx cap init "Red Vecinal" com.equipo.redvecinal --web-dir=dist
pnpm build
npx cap add android
npx cap sync
npx cap open android
```

- En Android Studio: `Build > Generate Signed Bundle / APK`.
- **Hacerlo el domingo por la mañana, no a las 5 p. m.** Un build de Android puede fallar por SDK, JDK 17 o Gradle y comerse una hora.
- El APK es un bonus: la PWA ya corre en cualquier teléfono sin instalar.

### 13.3 Synapse

| Opción | Costo | Riesgo | Cuándo |
|---|---|---|---|
| VPS Hetzner CX22 + Caddy + dominio | ~USD 4.5/mes + dominio | Bajo | Si hay 1 persona de infra |
| Cloudflare Tunnel desde una laptop | USD 0 | Medio (la laptop debe quedar encendida) | Si no hay VPS |
| matrix.org con cuentas manuales | USD 0 | Medio (rate limits, sin auto-registro) | Plan de emergencia |

### 13.4 Costos para la diapositiva

| Ítem | Mensual |
|---|---|
| Supabase Free | USD 0 |
| Vercel Hobby | USD 0 |
| Synapse VPS | ~USD 4.5 |
| Dominio | ~USD 1/mes |
| **Total** | **~USD 5.5/mes** |

---

## 14. Plan de 48 horas

> Corte de features: **domingo 12:00 p. m.** Después de esa hora solo se corrige, se ensaya y se graba. Si una feature no está lista, se corta; no se "arregla" a las 4 p. m.

| Bloque | Objetivo | Entregable verificable | Rol sugerido |
|---|---|---|---|
| **Sáb 18:30–19:30** | Kickoff técnico | Repo, Supabase, esquema aplicado, Vercel con "hola mundo", `.env` | Todos |
| **Sáb 19:30–22:30** | Shell + publicar | Login, 5 pestañas, publicar necesidad en 3 pasos, lista y detalle | Frontend + Backend |
| **Sáb 22:30–00:30** | Propuestas + trato | Comparar, aceptar, máquina de estados, código de 4 dígitos, cronómetro | Backend + Frontend |
| **Dom 06:00–09:00** | Matrix | Synapse arriba, cuentas, room por trato, enviar/recibir, Element interop | Infra + Frontend |
| **Dom 09:00–11:00** | Emergencia | Activación, 3 estados, muro, filtro, ubicación aproximada, casos sensibles | Frontend + Backend |
| **Dom 11:00–12:00** | Offline + PWA | Outbox, service worker, manifest, sync al volver | Frontend |
| **Dom 12:00** | **Feature freeze** | Tag `v0.9-demo`; solo bugs | Lead |
| **Dom 12:00–14:00** | Estabilización | Datos seed, pruebas en 2 teléfonos, accesibilidad, textos | QA + Todos |
| **Dom 14:00–16:00** | Builds | APK firmado, deploy web final, video de respaldo | Infra |
| **Dom 16:00–16:30** | Carga | OneDrive/Drive, QR, APK, URL, video | QA |
| **Dom 16:30–18:30** | Ensayo | 2 ensayos cronometrados + pitch | Todos |

**Reparto sugerido para 4–5 personas:**

- **Lead/Producto:** prioriza, corta, revisa el diff final, cronometra el ensayo.
- **Frontend A:** navegación, publicar, propuestas, trato.
- **Frontend B:** emergencia, muro, perfil, accesibilidad.
- **Backend:** Supabase, RLS, RPCs, Edge Function, seed.
- **Infra/QA:** Synapse, Caddy, deploy, APK, pruebas en dispositivos.

Si son 3: frontend, backend y "todo lo demás" (infra + QA + demo). El plan se recorta a los casos P0.

**Prioridad si el tiempo aprieta:**

- **P0 (imprescindible):** publicar necesidad, propuestas, aceptar, código, chat Matrix, calificar, emergencia básica, offline.
- **P1:** muro de pedidos/ofertas, nivel solidario, cancelaciones, idioma, accesibilidad avanzada.
- **P2:** vender producto, donativos, brigadista, constancia. Si no llega, se muestra en el simulador y se dice "siguiente iteración".

---

## 15. Criterios de aceptación (los 10 casos, traducidos)

| # | Caso del simulador | Implementación real mínima | Prioridad |
|---|---|---|---|
| 1 | Servicio de principio a fin | Publicar → propuesta → aceptar → código → chat → confirmar → calificar (2 vías) | P0 |
| 2 | Préstamo entre vecinos | Mismo motor con tipos de necesidad; entrega y devolución | P0 |
| 3 | Emergencia | Modo, 3 estados, muro, mapa aproximado | P0 |
| 4 | Sin internet | Outbox + sync + indicador "Pendiente/Enviado" | P0 |
| 5 | Ofrezco un servicio | Rol oferta, ver detalles, cotizar, código, ajuste, calificar | P0 |
| 6 | Cancelaciones | Gracia, causa, no-show, penalización de cumplimiento | P1 |
| 7 | Vender producto | Precio de lista, contraoferta (2 rondas), cierre | P2 |
| 8 | Nivel solidario | Puntos privados, umbrales, tope diario, visibilidad | P1 |
| 9 | Emergencia ampliada | Institución primero, sensibles privados, ubicación compartida, acopio | P1 |
| 10 | Muro, idiomas, accesibilidad | Filtros, ofertas, i18n, alto contraste, frases rápidas | P1 |

**Definition of Done por feature:**

- Funciona en Chrome Android y Safari iOS (o se documenta la limitación).
- Funciona a 360 px de ancho y con texto grande.
- Tiene estado vacío, estado de error y estado de carga.
- Tiene al menos una prueba unitaria si es lógica pura (puntos, penalización, ajuste).
- Está en el guion de demo o se corta.

---

## 16. Guion de demo (7 minutos)

| Tiempo | Qué se muestra | Qué se dice |
|---|---|---|
| 0:00–0:40 | Problema y propuesta | "No buscamos entre cientos de publicaciones: el vecino dice qué necesita y su barrio propone." |
| 0:40–2:30 | Caso 1 completo | Publicar en 3 toques, comparar propuestas, aceptar, código, cronómetro, chat, calificar. |
| 2:30–3:30 | **Element** | "El chat no es simulado: es Matrix. Escribo desde Element y aparece en la app." |
| 3:30–4:30 | Emergencia | Activar, "Necesito ayuda", institución primero, muro, caso sensible privado. |
| 4:30–5:15 | Offline | Modo avión, publicar, reconectar, sync. |
| 5:15–6:00 | Muro y nivel solidario | Filtros, ofertas, puntos privados, visibilidad. |
| 6:00–7:00 | Cierre honesto | Costos (~USD 5/mes), qué es real, qué sigue simulado, hoja de ruta. |

**Antes del pitch:**

- [ ] Dos teléfonos cargados al 100 % + power bank.
- [ ] Hotspot propio con las dos SIM; no depender del wifi del venue.
- [ ] Element ya logueado en el segundo teléfono (no hacer login en vivo).
- [ ] Datos seed cargados (3 necesidades, 2 tratos, 1 emergencia).
- [ ] Video de respaldo de 3 minutos, descargado en el teléfono.
- [ ] URL de la PWA y QR impreso.
- [ ] APK instalado en al menos un teléfono.

---

## 17. Pruebas

**Unitarias (Vitest), lógica pura:**

- Puntos solidarios: 5★ vs 4★ vs 3★; primera ayuda vs repetida; tope diario.
- Penalización: gracia, tarde, en curso, con causa, no-show.
- Ajuste de precio: máximo 2 rondas; rechazo no penaliza.
- Transiciones de estado inválidas (no se puede completar sin código).

**E2E (Playwright), 3 rutas:**

1. Publicar necesidad → recibir propuesta seed → aceptar → ver room creado.
2. Emergencia → marcar "Necesito ayuda" → publicar → ver en el muro.
3. Offline → publicar → reconectar → ver "Enviado".

**Manual, en dos teléfonos:**

- [ ] Chat de ida y vuelta con Element.
- [ ] Código incorrecto 5 veces → bloqueo.
- [ ] Foto con GPS → subir → verificar que el EXIF desapareció.
- [ ] Ubicación exacta no visible antes de aceptar.
- [ ] Caso sensible no aparece en el muro.
- [ ] Rotación, modo oscuro, texto grande, TalkBack/VoiceOver.
- [ ] Recarga completa sin perder sesión ni mensajes pendientes.

---

## 18. Riesgos y planes B

| Riesgo | Señal temprana | Plan B |
|---|---|---|
| Synapse no levanta | Domingo 8:00 sin `/sync` | matrix.org con cuentas manuales; o rooms simulados con aviso "modo demo" |
| `matrix-js-sdk` rompe el build | Error de `global`/`buffer` | Wrapper REST propio (4 endpoints) |
| El túnel se cae | Element no conecta | Reiniciar túnel y actualizar `VITE_MATRIX_URL`; tener VPS de respaldo |
| Android Studio falla | Gradle/JDK | Entregar PWA; el APK es bonus |
| El wifi del venue falla | Latencia o timeout | Hotspot propio; datos móviles; video de respaldo |
| Se acaba el tiempo | 12:00 con P0 incompleto | Cortar P1/P2; congelar; ensayar con lo que hay |
| El jurado pide una feature no implementada | — | "Está en el simulador y en la hoja de ruta; hoy priorizamos X." |

**Regla:** la pestaña Mensajes nunca queda en blanco ni rota en vivo. Si Matrix falla, muestra el historial cacheado y un aviso claro; el resto de la app sigue funcionando.

---

## 19. Arranque del repositorio (comandos)

```bash
# 1. Proyecto
pnpm create vite@latest red-vecinal -- --template react-ts
cd red-vecinal
pnpm install

# 2. Dependencias
pnpm add @supabase/supabase-js zustand dexie date-fns zod react-hook-form \
  i18next react-i18next leaflet react-leaflet matrix-js-sdk
pnpm add -D vite-plugin-pwa @capacitor/cli @capacitor/core @capacitor/android \
  vitest @playwright/test

# 3. Supabase
pnpm dlx supabase init
pnpm dlx supabase login
pnpm dlx supabase link --project-ref <ref>
pnpm dlx supabase db push

# 4. Synapse
cd infra && docker compose up -d

# 5. Desarrollo
pnpm dev

# 6. Build y deploy
pnpm build
npx vercel --prod
```

**Orden de lectura para el equipo:**

1. `Informe técnico y funcional...md` — el qué y el porqué.
2. Esta guía — el cómo.
3. `Simulador Red Vecinal (Copy).html` — el diseño y los 10 flujos.

---

## 20. Lo que no se hace en 48 horas

- Pagos, billeteras, comisiones, Yape/Plin.
- Verificación de identidad real (RENIEC, selfie con prueba de vida).
- E2EE y verificación de dispositivos en Matrix.
- Push notifications (FCM/APNs). Solo badge en la app y aviso al abrir.
- Comunicación sin internet entre celulares (BLE/malla).
- IA para precios o moderación. Precio estimado = rangos por categoría; moderación = manual.
- Microservicios, Kubernetes, colas, event sourcing.
- App nativa iOS (la PWA cubre la demo; App Store no entra en 48 h).
- Traducciones completas a 6 idiomas.
- Federación de Matrix.

---

## Anexo A: decisiones que el equipo debe cerrar hoy

1. **¿VPS o túnel?** Si hay alguien que ya haya usado Docker y SSH → VPS. Si no → túnel.
2. **¿Quién es el dueño de Matrix?** Una sola persona; nadie más toca `homeserver.yaml` ni el túnel.
3. **¿APK o solo PWA?** Recomendado: PWA primero, APK el domingo si el build sale en <1 h. No sacrificar el ensayo por el APK.
4. **¿Qué se declara como simulado?** Verificación de identidad, números oficiales sin verificar, traducciones parciales, datos seed. Todo lo demás debe ser real o no mostrarse.
5. **¿Quién ensaya el pitch?** Una persona, no tres. Las otras dos manejan los teléfonos.

---

*Documento vivo: si una decisión cambia, se actualiza aquí y se avisa al equipo. La versión que vale es la del repo, no la del chat.*
