/**
 * Sincronización con Supabase (tabla `records`, ver supabase/migrations/0001_records.sql).
 *
 * - La base local (SQLite) es la fuente de verdad del teléfono; esto solo la espeja.
 * - Subir: `sync_queue` guarda qué filas cambiaron. Si no hay red, se queda en cola y
 *   se reintenta. Subir es idempotente (upsert por entity+id), reintentar no duplica.
 * - Bajar: se piden las filas nuevas por `updated_at` del servidor y se aplican con
 *   reglas que nunca retroceden un estado (un trato completado no vuelve a "acordado").
 * - Privacidad: nunca se sube lat_exact/lng_exact ni meet_code_hash, y las alertas de
 *   violencia no salen del teléfono. El servidor además lo rechaza con un CHECK.
 */
import { all, count, one, persist, run } from '../db/sqlite';

const URL = ((import.meta.env.VITE_SUPABASE_URL as string | undefined) ?? '').replace(/\/+$/, '');
const KEY = (import.meta.env.VITE_SUPABASE_ANON_KEY as string | undefined) ?? '';

export const syncConfigured = Boolean(URL && KEY);

export type SyncState = 'apagado' | 'sincronizando' | 'ok' | 'sin_conexion' | 'error';
export interface SyncStatus {
  state: SyncState;
  pendingUp: number;
  lastOkAt: string | null;
  detail: string;
}

const TABLES: Record<string, string> = {
  need: 'needs',
  proposal: 'proposals',
  interaction: 'interactions',
  message: 'messages',
  rating: 'ratings',
  recommendation: 'recommendations',
  emergency: 'emergency_alerts',
};
/** Orden de dependencias: primero lo que otras filas referencian. */
const ORDER = ['need', 'proposal', 'interaction', 'message', 'rating', 'recommendation', 'emergency'];
const STRIP = ['lat_exact', 'lng_exact', 'meet_code_hash', 'meet_code_expires_at'];

let status: SyncStatus = {
  state: syncConfigured ? 'ok' : 'apagado',
  pendingUp: 0,
  lastOkAt: null,
  detail: syncConfigured ? 'Listo' : 'Sin servidor configurado',
};
const listeners = new Set<() => void>();
let running = false;
let again = false;

export function getSyncStatus(): SyncStatus {
  return status;
}
export function onSyncStatus(fn: () => void): () => void {
  listeners.add(fn);
  return () => listeners.delete(fn);
}
function setStatus(patch: Partial<SyncStatus>): void {
  status = { ...status, ...patch };
  listeners.forEach((fn) => fn());
}

/** Marca una fila local para subirla al servidor. */
export function markDirty(entity: string, entityId: string, payload?: Record<string, unknown>): void {
  if (!TABLES[entity]) return;
  run(`INSERT OR REPLACE INTO sync_queue (entity, entity_id, payload) VALUES (?, ?, ?)`, [
    entity,
    entityId,
    payload ? JSON.stringify(payload) : null,
  ]);
}

function headers(extra?: Record<string, string>): Record<string, string> {
  const h: Record<string, string> = { apikey: KEY, 'Content-Type': 'application/json', ...(extra ?? {}) };
  if (KEY.startsWith('eyJ')) h.Authorization = `Bearer ${KEY}`;
  return h;
}

async function http(path: string, init: RequestInit): Promise<Response> {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), 12000);
  try {
    const res = await fetch(`${URL}/rest/v1/${path}`, { ...init, signal: controller.signal });
    if (!res.ok) {
      const text = await res.text().catch(() => '');
      throw new Error(`Servidor ${res.status}: ${text.slice(0, 140)}`);
    }
    return res;
  } finally {
    clearTimeout(timer);
  }
}

interface QueueRow {
  entity: string;
  entity_id: string;
  payload: string | null;
}

function buildRecord(item: QueueRow): { entity: string; id: string; data: Record<string, unknown> } | null {
  if (item.payload) {
    return { entity: item.entity, id: item.entity_id, data: JSON.parse(item.payload) as Record<string, unknown> };
  }
  const table = TABLES[item.entity];
  const row = one<Record<string, unknown>>(`SELECT * FROM ${table} WHERE id = ?`, [item.entity_id]);
  if (!row) return null;
  if (item.entity === 'emergency' && row.kind === 'violencia') return null; // privado: nunca sale
  const data = { ...row };
  for (const field of STRIP) delete data[field];
  return { entity: item.entity, id: item.entity_id, data };
}

async function push(): Promise<void> {
  const queue = all<QueueRow>(`SELECT * FROM sync_queue`);
  queue.sort((a, b) => ORDER.indexOf(a.entity) - ORDER.indexOf(b.entity));
  if (!queue.length) return;

  const records: { entity: string; id: string; data: Record<string, unknown> }[] = [];
  const skip: QueueRow[] = [];
  for (const item of queue) {
    const record = buildRecord(item);
    if (record) records.push(record);
    else skip.push(item);
  }
  for (let i = 0; i < records.length; i += 100) {
    const chunk = records.slice(i, i + 100);
    await http('records?on_conflict=entity,id', {
      method: 'POST',
      headers: headers({ Prefer: 'resolution=merge-duplicates,return=minimal' }),
      body: JSON.stringify(chunk),
    });
    for (const r of chunk) run(`DELETE FROM sync_queue WHERE entity = ? AND entity_id = ?`, [r.entity, r.id]);
  }
  for (const item of skip) run(`DELETE FROM sync_queue WHERE entity = ? AND entity_id = ?`, [item.entity, item.entity_id]);
}

const RANK_NEED = `CASE %s WHEN 'abierta' THEN 0 WHEN 'en_curso' THEN 1 ELSE 2 END`;
const RANK_DEAL = `CASE %s WHEN 'acordado' THEN 0 WHEN 'en_curso' THEN 1 ELSE 2 END`;
const rank = (tpl: string, col: string) => tpl.replace('%s', col);

type Json = Record<string, unknown>;
const s = (v: unknown) => (v === null || v === undefined ? null : String(v));
const n = (v: unknown) => (v === null || v === undefined ? null : Number(v));

/** Aplica una fila del servidor a la base local. Devuelve true si cambió algo importante. */
function apply(entity: string, d: Json): boolean {
  switch (entity) {
    case 'need': {
      run(
        `INSERT INTO needs (id, author_id, type, title, description, category, zone, lat_public, lng_public, status, is_emergency, created_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
         ON CONFLICT(id) DO UPDATE SET
           title = excluded.title, description = excluded.description, category = excluded.category,
           zone = excluded.zone, lat_public = excluded.lat_public, lng_public = excluded.lng_public,
           is_emergency = excluded.is_emergency,
           status = CASE WHEN ${rank(RANK_NEED, 'excluded.status')} >= ${rank(RANK_NEED, 'needs.status')}
                         THEN excluded.status ELSE needs.status END`,
        [s(d.id), s(d.author_id), s(d.type), s(d.title), s(d.description) ?? '', s(d.category) ?? 'Otros', s(d.zone) ?? '',
         n(d.lat_public), n(d.lng_public), s(d.status) ?? 'abierta', n(d.is_emergency) ?? 0, s(d.created_at)],
      );
      return true;
    }
    case 'proposal': {
      run(
        `INSERT INTO proposals (id, need_id, provider_id, price_cents, message, eta, status, created_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)
         ON CONFLICT(id) DO UPDATE SET
           status = CASE WHEN proposals.status = 'enviada' THEN excluded.status ELSE proposals.status END`,
        [s(d.id), s(d.need_id), s(d.provider_id), n(d.price_cents) ?? 0, s(d.message) ?? '', s(d.eta) ?? '', s(d.status) ?? 'enviada', s(d.created_at)],
      );
      return true;
    }
    case 'interaction': {
      run(
        `INSERT INTO interactions
           (id, need_id, proposal_id, requester_id, provider_id, room_id, meet_code_hash, meet_code_expires_at,
            price_cents, status, confirmed_by_requester, confirmed_by_provider, created_at)
         VALUES (?, ?, ?, ?, ?, ?, NULL, NULL, ?, ?, ?, ?, ?)
         ON CONFLICT(id) DO UPDATE SET
           confirmed_by_requester = MAX(interactions.confirmed_by_requester, excluded.confirmed_by_requester),
           confirmed_by_provider  = MAX(interactions.confirmed_by_provider,  excluded.confirmed_by_provider),
           status = CASE WHEN ${rank(RANK_DEAL, 'excluded.status')} >= ${rank(RANK_DEAL, 'interactions.status')}
                         THEN excluded.status ELSE interactions.status END`,
        [s(d.id), s(d.need_id), s(d.proposal_id), s(d.requester_id), s(d.provider_id), s(d.room_id), n(d.price_cents) ?? 0,
         s(d.status) ?? 'acordado', n(d.confirmed_by_requester) ?? 0, n(d.confirmed_by_provider) ?? 0, s(d.created_at)],
      );
      // Si las dos partes ya confirmaron (aunque lo hicieran a la vez), el trato queda completado.
      const done = one<{ id: string }>(
        `SELECT id FROM interactions WHERE id = ? AND confirmed_by_requester = 1 AND confirmed_by_provider = 1 AND status IN ('acordado','en_curso')`,
        [s(d.id)],
      );
      if (done) {
        run(`UPDATE interactions SET status = 'completado' WHERE id = ?`, [done.id]);
        run(`UPDATE needs SET status = 'cerrada' WHERE id = ? AND status != 'cancelada'`, [s(d.need_id)]);
        markDirty('interaction', done.id);
        markDirty('need', String(d.need_id));
      }
      return true;
    }
    case 'message': {
      run(
        `INSERT OR IGNORE INTO messages (id, interaction_id, room_id, sender_id, body, txn_id, status, created_at)
         VALUES (?, ?, ?, ?, ?, ?, 'enviado', ?)`,
        [s(d.id), s(d.interaction_id), s(d.room_id) ?? '', s(d.sender_id), s(d.body) ?? '', s(d.txn_id), s(d.created_at)],
      );
      return true;
    }
    case 'rating': {
      run(
        `INSERT OR IGNORE INTO ratings (id, interaction_id, from_user, to_user, stars, comment, created_at)
         VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [s(d.id), s(d.interaction_id), s(d.from_user), s(d.to_user), n(d.stars) ?? 5, s(d.comment) ?? '', s(d.created_at)],
      );
      return true;
    }
    case 'recommendation': {
      if (d._deleted) {
        run(`DELETE FROM recommendations WHERE provider_id = ? AND voter_id = ?`, [s(d.provider_id), s(d.voter_id)]);
      } else {
        run(
          `INSERT OR IGNORE INTO recommendations (id, provider_id, voter_id, created_at) VALUES (?, ?, ?, ?)`,
          [s(d.id), s(d.provider_id), s(d.voter_id), s(d.created_at)],
        );
      }
      return true;
    }
    case 'emergency': {
      run(
        `INSERT INTO emergency_alerts
           (id, author_id, kind, description, zone, lat_public, lng_public, lat_exact, lng_exact, status, institution_called, created_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, NULL, NULL, ?, ?, ?)
         ON CONFLICT(id) DO UPDATE SET
           status = excluded.status,
           institution_called = MAX(emergency_alerts.institution_called, excluded.institution_called)`,
        [s(d.id), s(d.author_id), s(d.kind), s(d.description) ?? '', s(d.zone) ?? '', n(d.lat_public), n(d.lng_public),
         s(d.status) ?? 'activa', n(d.institution_called) ?? 0, s(d.created_at)],
      );
      return true;
    }
    default:
      return false;
  }
}

/** Huella del contenido visible: sirve para saber si llegó algo nuevo de otro teléfono. */
function fingerprint(): string {
  return (
    one<{ f: string }>(
      `SELECT (SELECT COUNT(*) FROM messages) || '|' || (SELECT COUNT(*) FROM needs) || '|' ||
              (SELECT COUNT(*) FROM proposals) || '|' || (SELECT COUNT(*) FROM ratings) || '|' ||
              (SELECT COUNT(*) FROM recommendations) || '|' || (SELECT COUNT(*) FROM emergency_alerts) || '|' ||
              COALESCE((SELECT GROUP_CONCAT(status || confirmed_by_requester || confirmed_by_provider) FROM interactions), '') || '|' ||
              COALESCE((SELECT GROUP_CONCAT(status) FROM needs), '') || '|' ||
              COALESCE((SELECT GROUP_CONCAT(status) FROM proposals), '') || '|' ||
              COALESCE((SELECT GROUP_CONCAT(status) FROM emergency_alerts), '') AS f`,
    )?.f ?? ''
  );
}

function getCursor(): string | null {
  return one<{ value: string }>(`SELECT value FROM sync_state WHERE key = 'last_pulled_at'`)?.value ?? null;
}
function setCursor(value: string): void {
  run(`INSERT OR REPLACE INTO sync_state (key, value) VALUES ('last_pulled_at', ?)`, [value]);
}

/** Devuelve cuántas filas del servidor se aplicaron. */
async function pull(): Promise<number> {
  const cursor = getCursor();
  let applied = 0;
  let from = cursor ? new Date(new Date(cursor).getTime() - 5000).toISOString() : null; // solape de 5 s
  for (let page = 0; page < 20; page += 1) {
    const filter = from ? `&updated_at=gte.${encodeURIComponent(from)}` : '';
    const res = await http(`records?select=entity,id,data,updated_at&order=updated_at.asc&limit=500${filter}`, {
      method: 'GET',
      headers: headers(),
    });
    const rows = (await res.json()) as { entity: string; id: string; data: Json; updated_at: string }[];
    if (!rows.length) break;
    rows.sort((a, b) => ORDER.indexOf(a.entity) - ORDER.indexOf(b.entity) || a.updated_at.localeCompare(b.updated_at));
    run('PRAGMA foreign_keys = OFF');
    try {
      for (const row of rows) {
        try {
          if (apply(row.entity, { ...row.data, id: row.id })) applied += 1;
        } catch (error) {
          console.warn('[sync] fila ignorada', row.entity, row.id, error);
        }
      }
    } finally {
      run('PRAGMA foreign_keys = ON');
    }
    const last = rows[rows.length - 1].updated_at;
    setCursor(last);
    if (rows.length < 500) break;
    from = last;
  }
  return applied;
}

/** Sube lo pendiente y baja lo nuevo. Devuelve true si llegaron cambios de otros teléfonos. */
export async function syncNow(): Promise<boolean> {
  if (!syncConfigured) return false;
  if (running) {
    again = true;
    return false;
  }
  running = true;
  let changed = false;
  try {
    if (typeof navigator !== 'undefined' && navigator.onLine === false) {
      setStatus({ state: 'sin_conexion', detail: 'Sin conexión', pendingUp: count(`SELECT COUNT(*) AS n FROM sync_queue`) });
      return false;
    }
    setStatus({ state: 'sincronizando', detail: 'Sincronizando…' });
    await push();
    const before = fingerprint();
    await pull();
    changed = fingerprint() !== before;
    await persist();
    setStatus({
      state: 'ok',
      detail: 'Conectado',
      lastOkAt: new Date().toISOString(),
      pendingUp: count(`SELECT COUNT(*) AS n FROM sync_queue`),
    });
    return changed;
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    const offline = /abort|failed to fetch|network|load failed/i.test(message);
    setStatus({
      state: offline ? 'sin_conexion' : 'error',
      detail: offline ? 'Sin conexión con el servidor' : message,
      pendingUp: count(`SELECT COUNT(*) AS n FROM sync_queue`),
    });
    return false;
  } finally {
    running = false;
    if (again) {
      again = false;
      void syncNow();
    }
  }
}
