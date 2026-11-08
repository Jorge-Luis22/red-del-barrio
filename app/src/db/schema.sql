-- ============================================================
--  Red del barrio — esquema LOCAL (SQLite)
--  Espejo de lo que luego vive en Supabase (ver /supabase/migrations).
--  Se ejecuta al abrir la app; todo es idempotente.
-- ============================================================

PRAGMA foreign_keys = ON;
PRAGMA journal_mode = WAL;

CREATE TABLE IF NOT EXISTS users (
  id            TEXT PRIMARY KEY,
  display_name  TEXT NOT NULL,
  zone          TEXT NOT NULL DEFAULT '',
  lat           REAL,
  lng           REAL,
  solid_level   TEXT NOT NULL DEFAULT 'Vecino',
  avatar_color  TEXT NOT NULL DEFAULT '#0a6b66',
  created_at    TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS needs (
  id            TEXT PRIMARY KEY,
  author_id     TEXT NOT NULL REFERENCES users(id),
  type          TEXT NOT NULL CHECK (type IN ('servicio','producto','prestamo','ayuda')),
  title         TEXT NOT NULL,
  description   TEXT NOT NULL DEFAULT '',
  category      TEXT NOT NULL DEFAULT 'Otros',
  zone          TEXT NOT NULL DEFAULT '',
  lat_public    REAL,
  lng_public    REAL,
  lat_exact     REAL,
  lng_exact     REAL,
  status        TEXT NOT NULL DEFAULT 'abierta'
                CHECK (status IN ('abierta','en_curso','cerrada','cancelada')),
  is_emergency  INTEGER NOT NULL DEFAULT 0,
  created_at    TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_needs_status ON needs (status, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_needs_author ON needs (author_id, created_at DESC);

CREATE TABLE IF NOT EXISTS proposals (
  id            TEXT PRIMARY KEY,
  need_id       TEXT NOT NULL REFERENCES needs(id) ON DELETE CASCADE,
  provider_id   TEXT NOT NULL REFERENCES users(id),
  price_cents   INTEGER NOT NULL CHECK (price_cents >= 0),
  message       TEXT NOT NULL DEFAULT '',
  eta           TEXT NOT NULL DEFAULT '',
  status        TEXT NOT NULL DEFAULT 'enviada'
                CHECK (status IN ('enviada','aceptada','rechazada','retirada')),
  created_at    TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_proposals_need ON proposals (need_id, created_at DESC);

CREATE TABLE IF NOT EXISTS interactions (
  id                   TEXT PRIMARY KEY,
  need_id              TEXT NOT NULL REFERENCES needs(id),
  proposal_id          TEXT NOT NULL REFERENCES proposals(id),
  requester_id         TEXT NOT NULL REFERENCES users(id),
  provider_id          TEXT NOT NULL REFERENCES users(id),
  room_id              TEXT,
  meet_code_hash       TEXT,
  meet_code_expires_at TEXT,
  price_cents          INTEGER NOT NULL,
  status               TEXT NOT NULL DEFAULT 'acordado'
                       CHECK (status IN ('acordado','en_curso','completado','cancelado')),
  confirmed_by_requester INTEGER NOT NULL DEFAULT 0,
  confirmed_by_provider  INTEGER NOT NULL DEFAULT 0,
  created_at           TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_interactions_users ON interactions (requester_id, provider_id);

CREATE TABLE IF NOT EXISTS messages (
  id             TEXT PRIMARY KEY,
  interaction_id TEXT NOT NULL REFERENCES interactions(id) ON DELETE CASCADE,
  room_id        TEXT NOT NULL,
  sender_id      TEXT NOT NULL,
  body           TEXT NOT NULL,
  txn_id         TEXT NOT NULL,
  status         TEXT NOT NULL DEFAULT 'enviado'
                 CHECK (status IN ('pendiente','enviado','fallido')),
  created_at     TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_messages_room ON messages (room_id, created_at);
CREATE UNIQUE INDEX IF NOT EXISTS idx_messages_txn ON messages (txn_id);

CREATE TABLE IF NOT EXISTS ratings (
  id             TEXT PRIMARY KEY,
  interaction_id TEXT NOT NULL REFERENCES interactions(id) ON DELETE CASCADE,
  from_user      TEXT NOT NULL REFERENCES users(id),
  to_user        TEXT NOT NULL REFERENCES users(id),
  stars          INTEGER NOT NULL CHECK (stars BETWEEN 1 AND 5),
  comment        TEXT NOT NULL DEFAULT '',
  created_at     TEXT NOT NULL,
  UNIQUE (interaction_id, from_user)
);

CREATE TABLE IF NOT EXISTS recommendations (
  id          TEXT PRIMARY KEY,
  provider_id TEXT NOT NULL REFERENCES users(id),
  voter_id    TEXT NOT NULL REFERENCES users(id),
  created_at  TEXT NOT NULL,
  UNIQUE (provider_id, voter_id)
);

CREATE TABLE IF NOT EXISTS emergency_alerts (
  id                TEXT PRIMARY KEY,
  author_id         TEXT NOT NULL REFERENCES users(id),
  kind              TEXT NOT NULL
                    CHECK (kind IN ('sismo','incendio','medico','persona_mayor','seguridad','violencia')),
  description       TEXT NOT NULL DEFAULT '',
  zone              TEXT NOT NULL DEFAULT '',
  lat_public        REAL,
  lng_public        REAL,
  lat_exact         REAL,
  lng_exact         REAL,
  status            TEXT NOT NULL DEFAULT 'activa'
                    CHECK (status IN ('activa','atendida','cerrada')),
  institution_called INTEGER NOT NULL DEFAULT 0,
  created_at        TEXT NOT NULL
);

-- Servicios que un vecino ofrece (oficio). Si `urgent` = 1 aparece en Emergencia → Servicios de
-- urgencia (con costo: el precio lo propone el vecino cuando le piden, nunca se publica de antemano).
CREATE TABLE IF NOT EXISTS service_offers (
  id            TEXT PRIMARY KEY,
  provider_id   TEXT NOT NULL REFERENCES users(id),
  trade         TEXT NOT NULL,
  description   TEXT NOT NULL DEFAULT '',
  urgent        INTEGER NOT NULL DEFAULT 0,
  available_now INTEGER NOT NULL DEFAULT 0,
  schedule      TEXT NOT NULL DEFAULT '',
  active        INTEGER NOT NULL DEFAULT 1,
  created_at    TEXT NOT NULL,
  updated_at    TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_service_offers_urgent ON service_offers (urgent, active, trade);

-- Respuesta de un vecino a una alerta del muro. Una fila por (alerta, vecino): el id es
-- determinista, así dos teléfonos nunca duplican la misma respuesta y cambiarla es un UPDATE.
--   'ofrece'  = "Puedo ayudar" (en un aviso de seguridad: "Yo también lo vi")
--   'disputa' = "No es real o ya pasó" (solo avisos de seguridad)
--   'retirado'= el vecino se echó atrás
CREATE TABLE IF NOT EXISTS emergency_responses (
  id          TEXT PRIMARY KEY,
  alert_id    TEXT NOT NULL REFERENCES emergency_alerts(id) ON DELETE CASCADE,
  helper_id   TEXT NOT NULL REFERENCES users(id),
  status      TEXT NOT NULL DEFAULT 'ofrece' CHECK (status IN ('ofrece','retirado','disputa')),
  created_at  TEXT NOT NULL,
  updated_at  TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_emergency_resp_alert ON emergency_responses (alert_id, status);

-- Vecinos que bloqueé (solo en este teléfono): no veo sus publicaciones, propuestas, alertas ni chats.
CREATE TABLE IF NOT EXISTS blocked_users (
  user_id    TEXT PRIMARY KEY,
  created_at TEXT NOT NULL
);

-- Cola de salida idempotente: si se reintenta, el txn_id evita duplicados.
CREATE TABLE IF NOT EXISTS outbox (
  id          TEXT PRIMARY KEY,
  entity      TEXT NOT NULL,
  entity_id   TEXT NOT NULL,
  op          TEXT NOT NULL,
  payload     TEXT NOT NULL DEFAULT '{}',
  txn_id      TEXT NOT NULL UNIQUE,
  attempts    INTEGER NOT NULL DEFAULT 0,
  status      TEXT NOT NULL DEFAULT 'pendiente'
              CHECK (status IN ('pendiente','enviado','fallido')),
  last_error  TEXT,
  created_at  TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_outbox_status ON outbox (status, created_at);

CREATE TABLE IF NOT EXISTS sync_state (
  key   TEXT PRIMARY KEY,
  value TEXT NOT NULL
);

-- Filas locales que faltan por subir al servidor (se vacía en lib/sync.ts).
CREATE TABLE IF NOT EXISTS sync_queue (
  entity    TEXT NOT NULL,
  entity_id TEXT NOT NULL,
  payload   TEXT,
  PRIMARY KEY (entity, entity_id)
);
