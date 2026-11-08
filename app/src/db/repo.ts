import { all, count, one, persist, run, sizeBytes, wipeDb } from '../db/sqlite';
import { distanceKm, getCurrentPoint, jitter, roundZone, type Point } from '../lib/geo';
import { hashMeetCode, meetCode as makeMeetCode, txnId, uid } from '../lib/ids';
import { chat } from '../lib/matrix';
import { enqueue, pendingOutbox } from '../lib/outbox';
import { computeLevel, type LevelInfo } from '../lib/level';
import { markDirty } from '../lib/sync';
import {
  PROXY_PREFIX,
  RESOURCE_PREFIX,
  RESOURCE_WINDOW_HOURS,
  directionOf,
  isSolidary,
  resourceName,
  type Direction,
} from '../lib/solidarity';
import type {
  Conversation,
  DirectoryEntry,
  Emergency,
  EmergencyKind,
  EmergencyWallItem,
  Message,
  ServiceOffer,
  UrgentRequest,
  UrgentService,
  Need,
  NeedType,
  Proposal,
  Provider,
  ResourcePost,
  Stats,
  User,
} from '../types';

const DEFAULT_POINT: Point = {
  lat: Number(import.meta.env.VITE_DEFAULT_LAT ?? -11.989),
  lng: Number(import.meta.env.VITE_DEFAULT_LNG ?? -77.071),
};

const now = () => new Date().toISOString();

/* ------------------------------------------------------------------ */
/* Filas (snake_case, tal como viven en SQLite)                        */
/* ------------------------------------------------------------------ */

interface UserRow {
  id: string;
  display_name: string;
  zone: string;
  lat: number | null;
  lng: number | null;
  solid_level: string;
  avatar_color: string;
}

interface NeedRow {
  id: string;
  author_id: string;
  author_name: string;
  author_color: string;
  type: NeedType;
  title: string;
  description: string;
  category: string;
  zone: string;
  lat_public: number | null;
  lng_public: number | null;
  status: Need['status'];
  is_emergency: number;
  created_at: string;
  recs: number;
}

interface ProposalRow {
  id: string;
  need_id: string;
  provider_id: string;
  provider_name: string;
  price_cents: number;
  message: string;
  eta: string;
  status: Proposal['status'];
  created_at: string;
}

interface ConversationRow {
  id: string;
  need_id: string;
  need_title: string;
  other_id: string;
  other_name: string;
  other_color: string;
  room_id: string | null;
  price_cents: number;
  status: string;
  created_at: string;
  last_body: string | null;
  last_at: string | null;
  pending: number;
}

interface MessageRow {
  id: string;
  interaction_id: string;
  room_id: string;
  sender_id: string;
  body: string;
  txn_id: string;
  status: Message['status'];
  created_at: string;
}

interface EmergencyRow {
  id: string;
  author_id: string;
  kind: EmergencyKind;
  description: string;
  zone: string;
  lat_public: number | null;
  lng_public: number | null;
  status: Emergency['status'];
  institution_called: number;
  created_at: string;
}

/* ------------------------------------------------------------------ */
/* Mapeo                                                               */
/* ------------------------------------------------------------------ */

const toUser = (row: UserRow): User => ({
  id: row.id,
  name: row.display_name,
  zone: row.zone,
  lat: row.lat,
  lng: row.lng,
  level: levelOf(row.id).name,
  color: row.avatar_color,
});

function toNeed(row: NeedRow, viewer: Point): Need {
  const point =
    row.lat_public !== null && row.lng_public !== null
      ? { lat: row.lat_public, lng: row.lng_public }
      : null;
  return {
    id: row.id,
    authorId: row.author_id,
    authorName: row.author_name,
    authorColor: row.author_color,
    type: row.type,
    title: row.title,
    description: row.description,
    category: row.category,
    zone: row.zone,
    latPublic: row.lat_public,
    lngPublic: row.lng_public,
    status: row.status,
    isEmergency: Boolean(row.is_emergency),
    createdAt: row.created_at,
    recommendations: Number(row.recs ?? 0),
    distanceKm: point ? distanceKm(viewer, point) : null,
  };
}

const toProposal = (row: ProposalRow): Proposal => ({
  id: row.id,
  needId: row.need_id,
  providerId: row.provider_id,
  providerName: row.provider_name,
  priceCents: Number(row.price_cents),
  message: row.message,
  eta: row.eta,
  status: row.status,
  createdAt: row.created_at,
});

const toMessage = (row: MessageRow, viewerId: string): Message => ({
  id: row.id,
  interactionId: row.interaction_id,
  roomId: row.room_id,
  senderId: row.sender_id,
  body: row.body,
  txnId: row.txn_id,
  status: row.status,
  createdAt: row.created_at,
  mine: row.sender_id === viewerId,
  system: row.sender_id === 'system',
});

/* ------------------------------------------------------------------ */
/* Usuarios                                                            */
/* ------------------------------------------------------------------ */

export function getUser(userId: string): User | null {
  const row = one<UserRow>(`SELECT * FROM users WHERE id = ?`, [userId]);
  return row ? toUser(row) : null;
}

export function listUsers(): User[] {
  return all<UserRow>(`SELECT * FROM users ORDER BY display_name`).map(toUser);
}

/** Posición real del GPS si el usuario la permitió; si no, el punto de ejemplo. */
export function defaultPoint(): Point {
  return getCurrentPoint() ?? DEFAULT_POINT;
}

export async function saveProfile(userId: string, patch: { name?: string; zone?: string }): Promise<void> {
  if (patch.name !== undefined) {
    run(`UPDATE users SET display_name = ? WHERE id = ?`, [patch.name.trim() || 'Vecino', userId]);
  }
  if (patch.zone !== undefined) {
    run(`UPDATE users SET zone = ? WHERE id = ?`, [patch.zone.trim(), userId]);
  }
  await persist();
}

/* ------------------------------------------------------------------ */
/* Necesidades                                                         */
/* ------------------------------------------------------------------ */

const NEED_SELECT = `
  SELECT n.*, u.display_name AS author_name, u.avatar_color AS author_color,
         (SELECT COUNT(*) FROM recommendations r WHERE r.provider_id = n.author_id) AS recs
    FROM needs n
    JOIN users u ON u.id = n.author_id
`;

export function listNeeds(
  viewer: Point,
  opts: { q?: string; type?: NeedType | 'todos'; authorId?: string } = {},
): Need[] {
  const rows = all<NeedRow>(
    `${NEED_SELECT}
     WHERE n.is_emergency = 0 AND n.status IN ('abierta','en_curso')
       ${opts.authorId ? 'AND n.author_id = ?' : ''}
     ORDER BY n.created_at DESC`,
    opts.authorId ? [opts.authorId] : [],
  );

  let needs = rows.map((row) => toNeed(row, viewer));
  if (opts.type && opts.type !== 'todos') {
    needs = needs.filter((need) => need.type === opts.type);
  }
  const query = opts.q?.trim().toLowerCase();
  if (query) {
    needs = needs.filter((need) =>
      `${need.title} ${need.description} ${need.category} ${need.authorName}`
        .toLowerCase()
        .includes(query),
    );
  }
  return needs.sort((a, b) => (a.distanceKm ?? 99) - (b.distanceKm ?? 99));
}

export function getNeed(needId: string, viewer: Point): Need | null {
  const row = one<NeedRow>(`${NEED_SELECT} WHERE n.id = ?`, [needId]);
  return row ? toNeed(row, viewer) : null;
}

export async function createNeed(input: {
  authorId: string;
  type: NeedType;
  title: string;
  description: string;
  category: string;
  zone: string;
  point: Point;
  /** Pedido urgente (servicio con costo en una emergencia). La zona pública es de ~1 km. */
  isEmergency?: boolean;
}): Promise<Need> {
  const id = uid('n');
  const published = input.isEmergency ? roundZone(input.point, 2) : roundZone(jitter(input.point, 30));
  run(
    `INSERT INTO needs
       (id, author_id, type, title, description, category, zone,
        lat_public, lng_public, lat_exact, lng_exact, status, is_emergency, created_at)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'abierta', ?, ?)`,
    [
      id,
      input.authorId,
      input.type,
      input.title.trim(),
      input.description.trim(),
      input.category,
      input.zone,
      published.lat,
      published.lng,
      input.point.lat,
      input.point.lng,
      input.isEmergency ? 1 : 0,
      now(),
    ],
  );
  markDirty('need', id);
  await persist();
  const created = getNeed(id, input.point);
  if (!created) throw new Error('No se pudo guardar la necesidad');
  return created;
}

/** El autor da por resuelta (o cubierta) su publicación. Solo avanza: nunca reabre una cerrada. */
export async function closeNeed(needId: string): Promise<void> {
  run(`UPDATE needs SET status = 'cerrada' WHERE id = ? AND status IN ('abierta','en_curso')`, [needId]);
  markDirty('need', needId);
  await persist();
}

/** Muro "Sin dinero": publicaciones solidarias (préstamo, ayuda, donación, intercambio, movilidad). */
export function listSolidary(
  viewer: Point,
  opts: { category?: string; direction?: Direction | 'todas' } = {},
): Need[] {
  return listNeeds(viewer, {}).filter((need) => {
    if (!isSolidary(need.category)) return false;
    if (opts.category && opts.category !== 'todas' && need.category !== opts.category) return false;
    if (opts.direction && opts.direction !== 'todas' && directionOf(need.title) !== opts.direction) return false;
    return true;
  });
}

/* ------------------------------------------------------------------ */
/* Propuestas y trato                                                  */
/* ------------------------------------------------------------------ */

export function listProposals(needId: string): Proposal[] {
  const rows = all<ProposalRow>(
    `SELECT p.*, u.display_name AS provider_name
       FROM proposals p
       JOIN users u ON u.id = p.provider_id
      WHERE p.need_id = ?
      ORDER BY p.created_at DESC`,
    [needId],
  );
  return rows.map(toProposal);
}

export async function createProposal(input: {
  needId: string;
  providerId: string;
  priceCents: number;
  message: string;
  eta: string;
}): Promise<Proposal> {
  const id = uid('p');
  run(
    `INSERT INTO proposals (id, need_id, provider_id, price_cents, message, eta, status, created_at)
     VALUES (?, ?, ?, ?, ?, ?, 'enviada', ?)`,
    [
      id,
      input.needId,
      input.providerId,
      Math.max(0, Math.round(input.priceCents)),
      input.message.trim(),
      input.eta.trim(),
      now(),
    ],
  );
  markDirty('proposal', id);
  await persist();
  const row = one<ProposalRow>(
    `SELECT p.*, u.display_name AS provider_name
       FROM proposals p JOIN users u ON u.id = p.provider_id
      WHERE p.id = ?`,
    [id],
  );
  if (!row) throw new Error('No se pudo guardar la propuesta');
  return toProposal(row);
}

export interface AcceptedDeal {
  interactionId: string;
  code: string;
  roomId: string;
}

/**
 * Aceptar una propuesta: crea el trato, el room de Matrix y el código de
 * encuentro (que se devuelve una sola vez y se guarda hasheado).
 */
export async function acceptProposal(proposalId: string): Promise<AcceptedDeal> {
  const proposal = one<ProposalRow & { need_title: string; requester_id: string }>(
    `SELECT p.*, u.display_name AS provider_name, n.title AS need_title, n.author_id AS requester_id
       FROM proposals p
       JOIN users u ON u.id = p.provider_id
       JOIN needs n ON n.id = p.need_id
      WHERE p.id = ?`,
    [proposalId],
  );
  if (!proposal) throw new Error('Propuesta no encontrada');
  if (proposal.status !== 'enviada') throw new Error('Esta propuesta ya fue respondida');

  const interactionId = uid('i');
  const code = makeMeetCode();
  const roomName = `Trato: ${proposal.need_title}`;

  let roomId = `!local:${interactionId}`;
  try {
    roomId = await chat.ensureRoom({
      interactionId,
      name: roomName,
      invite: undefined,
    });
  } catch (error) {
    // El chat nunca debe bloquear el trato: seguimos en local y la cola reintenta.
    console.warn('[matrix] no se pudo crear el room, se usa chat local', error);
  }

  const hash = await hashMeetCode(code, interactionId);
  const createdAt = now();

  run(`UPDATE proposals SET status = 'aceptada' WHERE id = ?`, [proposalId]);
  run(`UPDATE needs SET status = 'en_curso' WHERE id = ?`, [proposal.need_id]);
  run(
    `INSERT INTO interactions
       (id, need_id, proposal_id, requester_id, provider_id, room_id,
        meet_code_hash, meet_code_expires_at, price_cents, status,
        confirmed_by_requester, confirmed_by_provider, created_at)
     VALUES (?, ?, ?, ?, ?, ?, ?, NULL, ?, 'acordado', 0, 0, ?)`,
    [
      interactionId,
      proposal.need_id,
      proposalId,
      proposal.requester_id,
      proposal.provider_id,
      roomId,
      hash,
      Number(proposal.price_cents),
      createdAt,
    ],
  );
  const sysMsgId = uid('m');
  run(
    `INSERT INTO messages (id, interaction_id, room_id, sender_id, body, txn_id, status, created_at)
     VALUES (?, ?, ?, 'system', ?, ?, 'enviado', ?)`,
    [
      sysMsgId,
      interactionId,
      roomId,
      `Trato acordado por S/ ${(Number(proposal.price_cents) / 100).toFixed(2)}. Coordinen aquí la hora y el lugar. El código de encuentro se muestra solo a quien pidió el servicio.`,
      txnId(),
      createdAt,
    ],
  );

  markDirty('proposal', proposalId);
  markDirty('need', proposal.need_id);
  markDirty('interaction', interactionId);
  markDirty('message', sysMsgId);
  await persist();
  return { interactionId, code, roomId };
}

/* ------------------------------------------------------------------ */
/* Conversaciones y mensajes                                           */
/* ------------------------------------------------------------------ */

const CONVERSATION_SELECT = `
  SELECT i.id, i.need_id, n.title AS need_title,
         CASE WHEN i.requester_id = ? THEN i.provider_id ELSE i.requester_id END AS other_id,
         ou.display_name AS other_name, ou.avatar_color AS other_color,
         i.room_id, i.price_cents, i.status, i.created_at,
         (SELECT body FROM messages m WHERE m.interaction_id = i.id ORDER BY m.created_at DESC LIMIT 1) AS last_body,
         (SELECT created_at FROM messages m WHERE m.interaction_id = i.id ORDER BY m.created_at DESC LIMIT 1) AS last_at,
         (SELECT COUNT(*) FROM messages m WHERE m.interaction_id = i.id AND m.status = 'pendiente') AS pending
    FROM interactions i
    JOIN needs n ON n.id = i.need_id
    JOIN users ou ON ou.id = CASE WHEN i.requester_id = ? THEN i.provider_id ELSE i.requester_id END
   WHERE i.requester_id = ? OR i.provider_id = ?
`;

export function listConversations(userId: string): Conversation[] {
  const rows = all<ConversationRow>(`${CONVERSATION_SELECT} ORDER BY i.created_at DESC`, [
    userId,
    userId,
    userId,
    userId,
  ]);
  return rows.map((row) => ({
    id: row.id,
    needId: row.need_id,
    needTitle: row.need_title,
    otherId: row.other_id,
    otherName: row.other_name,
    otherColor: row.other_color,
    roomId: row.room_id,
    priceCents: Number(row.price_cents),
    status: row.status,
    createdAt: row.created_at,
    lastBody: row.last_body,
    lastAt: row.last_at,
    pending: Number(row.pending ?? 0),
  }));
}

export function getConversation(conversationId: string, userId: string): Conversation | null {
  const rows = all<ConversationRow>(`${CONVERSATION_SELECT} AND i.id = ?`, [
    userId,
    userId,
    userId,
    userId,
    conversationId,
  ]);
  const row = rows[0];
  if (!row) return null;
  return {
    id: row.id,
    needId: row.need_id,
    needTitle: row.need_title,
    otherId: row.other_id,
    otherName: row.other_name,
    otherColor: row.other_color,
    roomId: row.room_id,
    priceCents: Number(row.price_cents),
    status: row.status,
    createdAt: row.created_at,
    lastBody: row.last_body,
    lastAt: row.last_at,
    pending: Number(row.pending ?? 0),
  };
}

export function listMessages(interactionId: string, viewerId: string): Message[] {
  const rows = all<MessageRow>(
    `SELECT * FROM messages WHERE interaction_id = ? ORDER BY created_at ASC`,
    [interactionId],
  );
  return rows.map((row) => toMessage(row, viewerId));
}

export async function sendChatMessage(
  interactionId: string,
  senderId: string,
  body: string,
): Promise<void> {
  const text = body.trim();
  if (!text) return;

  const interaction = one<{ room_id: string | null }>(
    `SELECT room_id FROM interactions WHERE id = ?`,
    [interactionId],
  );
  if (!interaction) throw new Error('Trato no encontrado');

  const roomId = interaction.room_id || `!local:${interactionId}`;
  const id = uid('m');
  const txn = txnId();

  run(
    `INSERT INTO messages (id, interaction_id, room_id, sender_id, body, txn_id, status, created_at)
     VALUES (?, ?, ?, ?, ?, ?, 'pendiente', ?)`,
    [id, interactionId, roomId, senderId, text, txn, now()],
  );
  enqueue({
    entity: 'message',
    entityId: id,
    op: 'send',
    txnId: txn,
    payload: { roomId, body: text },
  });
  markDirty('message', id);
  await persist();

  try {
    await chat.send(roomId, text, txn);
    run(`UPDATE messages SET status = 'enviado' WHERE id = ?`, [id]);
    run(`UPDATE outbox SET status = 'enviado', attempts = attempts + 1 WHERE txn_id = ?`, [txn]);
  } catch {
    // Queda "pendiente"; se reintenta al recuperar conexión o al abrir el chat.
  }
  await persist();
}

/** Reintenta los mensajes pendientes (idempotente por txn_id). */
export async function retryPending(interactionId?: string): Promise<number> {
  const rows = all<MessageRow>(
    `SELECT * FROM messages WHERE status = 'pendiente'
       ${interactionId ? 'AND interaction_id = ?' : ''}
     ORDER BY created_at LIMIT 20`,
    interactionId ? [interactionId] : [],
  );
  let delivered = 0;
  for (const row of rows) {
    try {
      await chat.send(row.room_id, row.body, row.txn_id);
      run(`UPDATE messages SET status = 'enviado' WHERE id = ?`, [row.id]);
      run(`UPDATE outbox SET status = 'enviado', attempts = attempts + 1 WHERE txn_id = ?`, [row.txn_id]);
      delivered += 1;
    } catch {
      // sigue pendiente
    }
  }
  if (rows.length) await persist();
  return delivered;
}

/* ------------------------------------------------------------------ */
/* Vecinos y recomendaciones                                           */
/* ------------------------------------------------------------------ */

interface ProviderRow extends UserRow {
  category: string | null;
  latest: string | null;
  recs: number;
  mine: number;
}

export function listProviders(viewerId: string, viewer: Point): Provider[] {
  const rows = all<ProviderRow>(
    `SELECT u.*,
            (SELECT n.category FROM needs n WHERE n.author_id = u.id ORDER BY n.created_at DESC LIMIT 1) AS category,
            (SELECT n.title FROM needs n WHERE n.author_id = u.id ORDER BY n.created_at DESC LIMIT 1) AS latest,
            (SELECT COUNT(*) FROM recommendations r WHERE r.provider_id = u.id) AS recs,
            EXISTS(SELECT 1 FROM recommendations r WHERE r.provider_id = u.id AND r.voter_id = ?) AS mine
       FROM users u
      WHERE u.id <> ?
      ORDER BY recs DESC`,
    [viewerId, viewerId],
  );
  return rows.map((row) => ({
    id: row.id,
    name: row.display_name,
    zone: row.zone,
    color: row.avatar_color,
    level: levelOf(row.id).name,
    category: row.category,
    latest: row.latest,
    recommendations: Number(row.recs ?? 0),
    recommendedByMe: Boolean(row.mine),
    distanceKm:
      row.lat !== null && row.lng !== null
        ? distanceKm(viewer, { lat: row.lat, lng: row.lng })
        : null,
  }));
}

/** Directorio: todos los vecinos (menos tú) con los oficios que ofrecen, estén o no marcados como urgentes. */
export function listDirectory(viewerId: string, viewer: Point): DirectoryEntry[] {
  const offers = all<OfferRow>(`SELECT * FROM service_offers WHERE active = 1 ORDER BY created_at, id`).map(toOffer);
  const byProvider = new Map<string, ServiceOffer[]>();
  for (const offer of offers) byProvider.set(offer.providerId, [...(byProvider.get(offer.providerId) ?? []), offer]);
  return listProviders(viewerId, viewer)
    .map((p) => ({ ...p, offers: byProvider.get(p.id) ?? [] }))
    .sort(
      (a, b) =>
        b.recommendations - a.recommendations ||
        Number(b.offers.some((o) => o.availableNow)) - Number(a.offers.some((o) => o.availableNow)) ||
        (a.distanceKm ?? 99) - (b.distanceKm ?? 99),
    );
}

/** Un voto por vecino y por proveedor. Devuelve true si quedó recomendado. */
export async function toggleRecommendation(providerId: string, voterId: string): Promise<boolean> {
  const existing = one<{ id: string }>(
    `SELECT id FROM recommendations WHERE provider_id = ? AND voter_id = ?`,
    [providerId, voterId],
  );
  if (existing) {
    run(`DELETE FROM recommendations WHERE id = ?`, [existing.id]);
    markDirty('recommendation', existing.id, { id: existing.id, provider_id: providerId, voter_id: voterId, _deleted: true });
    await persist();
    return false;
  }
  const recId = uid('r');
  run(`INSERT INTO recommendations (id, provider_id, voter_id, created_at) VALUES (?, ?, ?, ?)`, [
    recId,
    providerId,
    voterId,
    now(),
  ]);
  markDirty('recommendation', recId);
  await persist();
  return true;
}

/* ------------------------------------------------------------------ */
/* Emergencia                                                          */
/* ------------------------------------------------------------------ */

const toEmergency = (row: EmergencyRow): Emergency => ({
  id: row.id,
  authorId: row.author_id,
  kind: row.kind,
  description: row.description,
  zone: row.zone,
  latPublic: row.lat_public,
  lngPublic: row.lng_public,
  status: row.status,
  institutionCalled: Boolean(row.institution_called),
  createdAt: row.created_at,
});

export async function createEmergency(input: {
  authorId: string;
  kind: EmergencyKind;
  description: string;
  zone: string;
  point: Point;
  /** Reportada por un vecino en nombre de otra persona (adulto mayor, alguien sin celular). */
  forOther?: boolean;
}): Promise<Emergency> {
  const id = uid('e');
  // Zona pública de ~1 km (2 decimales): el muro lo ven todos, la ubicación exacta no sale del teléfono.
  const published = roundZone(input.point, 2);
  run(
    `INSERT INTO emergency_alerts
       (id, author_id, kind, description, zone, lat_public, lng_public,
        lat_exact, lng_exact, status, institution_called, created_at)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'activa', 0, ?)`,
    [
      id,
      input.authorId,
      input.kind,
      (input.forOther ? PROXY_PREFIX : '') + input.description.trim(),
      input.zone,
      published.lat,
      published.lng,
      input.point.lat,
      input.point.lng,
      now(),
    ],
  );
  markDirty('emergency', id);
  await persist();
  const row = one<EmergencyRow>(`SELECT * FROM emergency_alerts WHERE id = ?`, [id]);
  if (!row) throw new Error('No se pudo crear la alerta');
  return toEmergency(row);
}

export function activeEmergency(userId: string): Emergency | null {
  const row = one<EmergencyRow>(
    `SELECT * FROM emergency_alerts
      WHERE author_id = ? AND status = 'activa'
      ORDER BY created_at DESC LIMIT 1`,
    [userId],
  );
  return row ? toEmergency(row) : null;
}

export async function closeEmergency(id: string): Promise<void> {
  run(`UPDATE emergency_alerts SET status = 'atendida' WHERE id = ?`, [id]);
  markDirty('emergency', id);
  await persist();
}

export async function markInstitutionCalled(id: string): Promise<void> {
  run(`UPDATE emergency_alerts SET institution_called = 1 WHERE id = ?`, [id]);
  markDirty('emergency', id);
  await persist();
}

/* ---- Muro de emergencia: alertas de otros vecinos ------------------ */

/** Una alerta que sigue "activa" más tiempo que esto se considera olvidada y sale del muro. */
export const WALL_WINDOW_HOURS = 12;

interface WallRow extends EmergencyRow {
  author_name: string;
  author_color: string;
}

/**
 * Un aviso de seguridad que varios vecinos marcan como "no es real o ya pasó" se oculta del muro de los demás:
 * así un rumor o una acusación falsa no se queda circulando. Con 2 o más marcas y más marcas que confirmaciones.
 */
const SECURITY_HIDE_DISPUTES = 2;

/** Alertas activas de OTROS vecinos (las de violencia nunca llegan aquí: son privadas). */
export function listEmergencyWall(viewerId: string, viewer: Point): EmergencyWallItem[] {
  const since = new Date(Date.now() - WALL_WINDOW_HOURS * 3_600_000).toISOString();
  const rows = all<WallRow>(
    `SELECT e.*, u.display_name AS author_name, u.avatar_color AS author_color
       FROM emergency_alerts e JOIN users u ON u.id = e.author_id
      WHERE e.status = 'activa' AND e.author_id != ? AND e.kind != 'violencia' AND e.created_at >= ?
      ORDER BY e.created_at DESC`,
    [viewerId, since],
  );
  const items: EmergencyWallItem[] = [];
  for (const row of rows) {
    const helpers = all<{ id: string; name: string; zone: string }>(
      `SELECT r.helper_id AS id, u.display_name AS name, u.zone AS zone
         FROM emergency_responses r JOIN users u ON u.id = r.helper_id
        WHERE r.alert_id = ? AND r.status = 'ofrece' ORDER BY r.updated_at`,
      [row.id],
    );
    const disputers = all<{ id: string }>(
      `SELECT helper_id AS id FROM emergency_responses WHERE alert_id = ? AND status = 'disputa'`,
      [row.id],
    );
    if (row.kind === 'seguridad' && disputers.length >= SECURITY_HIDE_DISPUTES && disputers.length > helpers.length) {
      continue;
    }
    const point =
      row.lat_public !== null && row.lng_public !== null ? { lat: row.lat_public, lng: row.lng_public } : null;
    items.push({
      ...toEmergency(row),
      authorName: row.author_name,
      authorColor: row.author_color,
      distanceKm: point ? distanceKm(viewer, point) : null,
      helpers,
      iOffered: helpers.some((h) => h.id === viewerId),
      disputes: disputers.length,
      iDisputed: disputers.some((d) => d.id === viewerId),
    });
  }
  return items;
}

export function countWallAlerts(viewerId: string): number {
  return listEmergencyWall(viewerId, DEFAULT_POINT).length;
}

/** Vecinos que dijeron "puedo ayudar" en la alerta del propio usuario. */
export function helpersOf(alertId: string): { id: string; name: string; zone: string }[] {
  return all<{ id: string; name: string; zone: string }>(
    `SELECT r.helper_id AS id, u.display_name AS name, u.zone AS zone
       FROM emergency_responses r JOIN users u ON u.id = r.helper_id
      WHERE r.alert_id = ? AND r.status = 'ofrece' ORDER BY r.updated_at`,
    [alertId],
  );
}

async function setHelp(alertId: string, helperId: string, status: 'ofrece' | 'retirado' | 'disputa'): Promise<void> {
  const id = `er_${alertId}_${helperId}`;
  const ts = now();
  run(
    `INSERT INTO emergency_responses (id, alert_id, helper_id, status, created_at, updated_at)
     VALUES (?, ?, ?, ?, ?, ?)
     ON CONFLICT(id) DO UPDATE SET status = excluded.status, updated_at = excluded.updated_at`,
    [id, alertId, helperId, status, ts, ts],
  );
  markDirty('emergency_response', id);
  await persist();
}

export const offerHelp = (alertId: string, helperId: string) => setHelp(alertId, helperId, 'ofrece');
export const withdrawHelp = (alertId: string, helperId: string) => setHelp(alertId, helperId, 'retirado');
/** Aviso de seguridad: "yo también lo vi" (reutiliza la respuesta 'ofrece') y "no es real o ya pasó". */
export const confirmSecurity = offerHelp;
export const disputeSecurity = (alertId: string, helperId: string) => setHelp(alertId, helperId, 'disputa');

/** Cuántos vecinos marcaron como "no es real o ya pasó" el aviso de seguridad del propio usuario. */
export function disputesOf(alertId: string): number {
  return count(`SELECT COUNT(*) AS n FROM emergency_responses WHERE alert_id = ? AND status = 'disputa'`, [alertId]);
}

/* ---- Servicios de urgencia (con costo) ------------------------------ */

interface OfferRow {
  id: string;
  provider_id: string;
  trade: string;
  description: string;
  urgent: number;
  available_now: number;
  schedule: string;
}

const toOffer = (row: OfferRow): ServiceOffer => ({
  id: row.id,
  providerId: row.provider_id,
  trade: row.trade,
  description: row.description,
  urgent: Boolean(row.urgent),
  availableNow: Boolean(row.available_now),
  schedule: row.schedule,
});

const normTrade = (value: string) =>
  value.normalize('NFD').replace(/[̀-ͯ]/g, '').trim().toLowerCase();

export function listMyServices(userId: string): ServiceOffer[] {
  return all<OfferRow>(
    `SELECT * FROM service_offers WHERE provider_id = ? AND active = 1 ORDER BY created_at, id`,
    [userId],
  ).map(toOffer);
}

export async function saveService(input: {
  providerId: string;
  trade: string;
  description: string;
  urgent: boolean;
  availableNow: boolean;
  schedule: string;
}): Promise<void> {
  const id = uid('o');
  const ts = now();
  run(
    `INSERT INTO service_offers
       (id, provider_id, trade, description, urgent, available_now, schedule, active, created_at, updated_at)
     VALUES (?, ?, ?, ?, ?, ?, ?, 1, ?, ?)`,
    [id, input.providerId, input.trade, input.description.trim(), input.urgent ? 1 : 0,
     input.availableNow ? 1 : 0, input.schedule.trim(), ts, ts],
  );
  markDirty('service_offer', id);
  await persist();
}

export async function updateService(id: string, patch: { urgent?: boolean; availableNow?: boolean }): Promise<void> {
  run(
    `UPDATE service_offers
        SET urgent = COALESCE(?, urgent), available_now = COALESCE(?, available_now), updated_at = ?
      WHERE id = ?`,
    [patch.urgent === undefined ? null : patch.urgent ? 1 : 0,
     patch.availableNow === undefined ? null : patch.availableNow ? 1 : 0, now(), id],
  );
  markDirty('service_offer', id);
  await persist();
}

export async function removeService(id: string): Promise<void> {
  run(`UPDATE service_offers SET active = 0, updated_at = ? WHERE id = ?`, [now(), id]);
  markDirty('service_offer', id);
  await persist();
}

interface UrgentServiceRow extends OfferRow {
  name: string;
  color: string;
  level: string;
  lat: number | null;
  lng: number | null;
  recs: number;
}

/** Vecinos que atienden urgencias (otros, no tú). Primero los disponibles ahora y los más recomendados. */
export function listUrgentServices(viewerId: string, viewer: Point, trade?: string): UrgentService[] {
  const rows = all<UrgentServiceRow>(
    `SELECT o.*, u.display_name AS name, u.avatar_color AS color, u.solid_level AS level, u.lat, u.lng,
            (SELECT COUNT(*) FROM recommendations r WHERE r.provider_id = u.id) AS recs
       FROM service_offers o JOIN users u ON u.id = o.provider_id
      WHERE o.urgent = 1 AND o.active = 1 AND o.provider_id <> ?`,
    [viewerId],
  );
  const wanted = trade ? normTrade(trade) : null;
  return rows
    .filter((row) => !wanted || normTrade(row.trade) === wanted)
    .map((row) => ({
      ...toOffer(row),
      providerName: row.name,
      providerColor: row.color,
      level: levelOf(row.provider_id).name,
      recommendations: Number(row.recs ?? 0),
      distanceKm:
        row.lat !== null && row.lng !== null ? distanceKm(viewer, { lat: row.lat, lng: row.lng }) : null,
    }))
    .sort(
      (a, b) =>
        Number(b.availableNow) - Number(a.availableNow) ||
        b.recommendations - a.recommendations ||
        (a.distanceKm ?? 99) - (b.distanceKm ?? 99),
    );
}

export function listUrgentTrades(viewerId: string): string[] {
  const seen = new Map<string, string>();
  for (const s of listUrgentServices(viewerId, DEFAULT_POINT)) seen.set(normTrade(s.trade), s.trade);
  return [...seen.values()].sort((a, b) => a.localeCompare(b, 'es'));
}

function proposalCount(needId: string): number {
  return Number(
    one<{ n: number }>(
      `SELECT COUNT(*) AS n FROM proposals WHERE need_id = ? AND status IN ('enviada','aceptada')`,
      [needId],
    )?.n ?? 0,
  );
}

/** Pedidos urgentes abiertos de otros vecinos. Primero los de tu oficio. */
export function listUrgentRequests(viewerId: string, viewer: Point): UrgentRequest[] {
  const since = new Date(Date.now() - WALL_WINDOW_HOURS * 3_600_000).toISOString();
  const rows = all<NeedRow>(
    `${NEED_SELECT}
      WHERE n.is_emergency = 1 AND n.status = 'abierta' AND n.author_id <> ? AND n.created_at >= ?
        AND n.category NOT LIKE '${RESOURCE_PREFIX}%'
      ORDER BY n.created_at DESC`,
    [viewerId, since],
  );
  const mine = new Set(
    all<{ trade: string }>(
      `SELECT trade FROM service_offers WHERE provider_id = ? AND urgent = 1 AND active = 1`,
      [viewerId],
    ).map((r) => normTrade(r.trade)),
  );
  return rows
    .map((row) => {
      const need = toNeed(row, viewer);
      return { need, matchesMe: mine.has(normTrade(need.category)), proposals: proposalCount(need.id) };
    })
    .sort((a, b) => Number(b.matchesMe) - Number(a.matchesMe));
}

/** Mis pedidos urgentes que siguen vivos (abiertos de las últimas horas, o ya en curso). */
export function listMyUrgentRequests(userId: string, viewer: Point): UrgentRequest[] {
  const since = new Date(Date.now() - WALL_WINDOW_HOURS * 3_600_000).toISOString();
  const rows = all<NeedRow>(
    `${NEED_SELECT}
      WHERE n.is_emergency = 1 AND n.author_id = ?
        AND n.category NOT LIKE '${RESOURCE_PREFIX}%'
        AND (n.status = 'en_curso' OR (n.status = 'abierta' AND n.created_at >= ?))
      ORDER BY n.created_at DESC`,
    [userId, since],
  );
  return rows.map((row) => {
    const need = toNeed(row, viewer);
    return { need, matchesMe: false, proposals: proposalCount(need.id) };
  });
}

export function countUrgentForMe(userId: string): number {
  return listUrgentRequests(userId, DEFAULT_POINT).filter((r) => r.matchesMe).length;
}

/* ---- Recursos críticos (economía solidaria en emergencia, sin dinero) ---- */

/**
 * Lo que los vecinos necesitan u ofrecen en una emergencia (agua, alimentos, abrigo, medicinas, energía,
 * transporte). Son `needs` de emergencia con categoría "Recurso · …": se coordinan por propuestas y chat.
 * La zona pública es de ~1 km, igual que las alertas. Abiertas de otros + las mías mientras sigan vivas.
 */
export function listResourcePosts(
  viewerId: string,
  viewer: Point,
  opts: { resource?: string; direction?: Direction | 'todas' } = {},
): ResourcePost[] {
  const since = new Date(Date.now() - RESOURCE_WINDOW_HOURS * 3_600_000).toISOString();
  const rows = all<NeedRow>(
    `${NEED_SELECT}
      WHERE n.is_emergency = 1 AND n.category LIKE '${RESOURCE_PREFIX}%'
        AND ((n.status = 'abierta' AND n.created_at >= ?) OR (n.author_id = ? AND n.status = 'en_curso'))
      ORDER BY n.created_at DESC`,
    [since, viewerId],
  );
  const posts = rows
    .map((row) => {
      const need = toNeed(row, viewer);
      return {
        need,
        direction: (directionOf(need.title) ?? 'necesito') as Direction,
        resource: resourceName(need.category),
        proposals: proposalCount(need.id),
        mine: need.authorId === viewerId,
        matches: 0,
      };
    })
    // Coincidencias: lo que alguien necesita y otro vecino ofrece (o al revés), del mismo recurso.
    .map((post, _i, all_) => ({
      ...post,
      matches: all_.filter(
        (o) => o.resource === post.resource && o.direction !== post.direction && o.need.authorId !== post.need.authorId,
      ).length,
    }));
  return posts
    .filter((p) => !opts.resource || opts.resource === 'todos' || p.resource === opts.resource)
    .filter((p) => !opts.direction || opts.direction === 'todas' || p.direction === opts.direction)
    .sort(
      (a, b) =>
        Number(b.direction === 'necesito') - Number(a.direction === 'necesito') ||
        (a.need.distanceKm ?? 99) - (b.need.distanceKm ?? 99),
    );
}

/** Cuántos vecinos necesitan algún recurso ahora mismo (cifra de la pestaña). */
export function countResourceNeeds(viewerId: string): number {
  return listResourcePosts(viewerId, DEFAULT_POINT).filter((p) => !p.mine && p.direction === 'necesito').length;
}

/** Lo que muestra el punto rojo del menú: alertas de vecinos + pedidos urgentes de mi oficio. */
export function emergencyBadge(userId: string): number {
  return countWallAlerts(userId) + countUrgentForMe(userId);
}

/** Número que cambia cuando llega algo que merece avisar (vibración): alertas, pedidos de mi oficio o quien ayuda en la mía. */
export function emergencySignal(userId: string): number {
  const mine = activeEmergency(userId);
  return emergencyBadge(userId) + (mine ? helpersOf(mine.id).length : 0);
}

/* ------------------------------------------------------------------ */
/* Perfil                                                              */
/* ------------------------------------------------------------------ */

/** Nivel calculado con lo que ya está en la base (ayudas completadas, recomendaciones, calificaciones). */
export function levelOf(userId: string): LevelInfo {
  const helps = count(
    `SELECT COUNT(*) AS n FROM interactions WHERE status = 'completado' AND (requester_id = ? OR provider_id = ?)`,
    [userId, userId],
  );
  const recs = count(`SELECT COUNT(*) AS n FROM recommendations WHERE provider_id = ?`, [userId]);
  const rated = one<{ avg: number | null; n: number }>(
    `SELECT AVG(stars) AS avg, COUNT(*) AS n FROM ratings WHERE to_user = ?`,
    [userId],
  );
  return computeLevel(
    helps,
    recs,
    rated?.avg === null || rated?.avg === undefined ? null : Number(rated.avg),
    Number(rated?.n ?? 0),
  );
}

export function getStats(userId: string): Stats {
  const helps = count(
    `SELECT COUNT(*) AS n FROM interactions WHERE status = 'completado' AND (requester_id = ? OR provider_id = ?)`,
    [userId, userId],
  );
  const people = count(
    `SELECT COUNT(DISTINCT CASE WHEN requester_id = ? THEN provider_id ELSE requester_id END) AS n
       FROM interactions WHERE status = 'completado' AND (requester_id = ? OR provider_id = ?)`,
    [userId, userId, userId],
  );
  const avg = one<{ avg: number | null }>(`SELECT AVG(stars) AS avg FROM ratings WHERE to_user = ?`, [
    userId,
  ]);
  const recommendations = count(
    `SELECT COUNT(*) AS n FROM recommendations WHERE provider_id = ?`,
    [userId],
  );
  return {
    helps,
    people,
    avgStars: avg?.avg === null || avg?.avg === undefined ? null : Number(avg.avg),
    recommendations,
    pending: pendingOutbox(),
  };
}

export function dbBytes(): number {
  return sizeBytes();
}

export async function resetAll(): Promise<void> {
  await wipeDb();
}

/* ------------------------------------------------------------------ */
/* Completar el trato y calificar (dos vías)                           */
/* ------------------------------------------------------------------ */

export interface DealState {
  id: string;
  status: 'acordado' | 'en_curso' | 'completado' | 'cancelado';
  otherId: string;
  otherName: string;
  iConfirmed: boolean;
  otherConfirmed: boolean;
  iRated: boolean;
  myStars: number | null;
}

interface DealRow {
  id: string;
  need_id: string;
  requester_id: string;
  provider_id: string;
  status: DealState['status'];
  confirmed_by_requester: number;
  confirmed_by_provider: number;
}

function dealRow(interactionId: string): DealRow | null {
  return one<DealRow>(`SELECT * FROM interactions WHERE id = ?`, [interactionId]);
}

export function getDealState(interactionId: string, userId: string): DealState | null {
  const row = dealRow(interactionId);
  if (!row) return null;
  const isRequester = row.requester_id === userId;
  if (!isRequester && row.provider_id !== userId) return null;
  const otherId = isRequester ? row.provider_id : row.requester_id;
  const other = getUser(otherId);
  const rating = one<{ stars: number }>(
    `SELECT stars FROM ratings WHERE interaction_id = ? AND from_user = ?`,
    [interactionId, userId],
  );
  return {
    id: row.id,
    status: row.status,
    otherId,
    otherName: other?.name ?? 'tu vecino',
    iConfirmed: Boolean(isRequester ? row.confirmed_by_requester : row.confirmed_by_provider),
    otherConfirmed: Boolean(isRequester ? row.confirmed_by_provider : row.confirmed_by_requester),
    iRated: rating !== null,
    myStars: rating ? Number(rating.stars) : null,
  };
}

/**
 * Cada parte confirma que el trato se hizo. Cuando confirman las dos,
 * el trato queda completado y la necesidad se cierra.
 */
export async function confirmDone(
  interactionId: string,
  userId: string,
): Promise<'esperando' | 'completado'> {
  const row = dealRow(interactionId);
  if (!row) throw new Error('Trato no encontrado');
  const isRequester = row.requester_id === userId;
  if (!isRequester && row.provider_id !== userId) throw new Error('No participas en este trato');
  if (row.status === 'completado') return 'completado';
  if (row.status === 'cancelado') throw new Error('Este trato fue cancelado');

  run(
    isRequester
      ? `UPDATE interactions SET confirmed_by_requester = 1, status = 'en_curso' WHERE id = ?`
      : `UPDATE interactions SET confirmed_by_provider = 1, status = 'en_curso' WHERE id = ?`,
    [interactionId],
  );
  const after = dealRow(interactionId)!;
  const both = Boolean(after.confirmed_by_requester) && Boolean(after.confirmed_by_provider);
  const stamp = now();
  const msgId = uid('m');
  const who = getUser(userId)?.name ?? 'Un vecino';

  if (both) {
    run(`UPDATE interactions SET status = 'completado' WHERE id = ?`, [interactionId]);
    run(`UPDATE needs SET status = 'cerrada' WHERE id = ?`, [row.need_id]);
  }
  run(
    `INSERT INTO messages (id, interaction_id, room_id, sender_id, body, txn_id, status, created_at)
     SELECT ?, id, COALESCE(room_id, ''), 'system', ?, ?, 'enviado', ? FROM interactions WHERE id = ?`,
    [
      msgId,
      both
        ? 'Trato completado: las dos partes confirmaron. Ahora pueden calificarse.'
        : `${who} confirmó que el trato se hizo. Falta la confirmación de la otra parte.`,
      txnId(),
      stamp,
      interactionId,
    ],
  );
  enqueue({
    entity: 'interaction',
    entityId: interactionId,
    op: 'confirm_done',
    txnId: txnId(),
    payload: { userId, completed: both },
  });
  markDirty('interaction', interactionId);
  if (both) markDirty('need', row.need_id);
  markDirty('message', msgId);
  await persist();
  return both ? 'completado' : 'esperando';
}

/** Califica a la otra parte (1 a 5). Solo trato completado, una vez por persona. */
export async function rateInteraction(
  interactionId: string,
  fromUser: string,
  stars: number,
  comment: string,
): Promise<void> {
  const row = dealRow(interactionId);
  if (!row) throw new Error('Trato no encontrado');
  if (row.status !== 'completado') throw new Error('El trato todavía no está completado');
  const isRequester = row.requester_id === fromUser;
  if (!isRequester && row.provider_id !== fromUser) throw new Error('No participas en este trato');
  const toUser = isRequester ? row.provider_id : row.requester_id;
  const value = Math.min(5, Math.max(1, Math.round(stars)));
  const ratingId = uid('r');
  run(
    `INSERT OR IGNORE INTO ratings (id, interaction_id, from_user, to_user, stars, comment, created_at)
     VALUES (?, ?, ?, ?, ?, ?, ?)`,
    [ratingId, interactionId, fromUser, toUser, value, comment.trim().slice(0, 200), now()],
  );
  enqueue({
    entity: 'rating',
    entityId: ratingId,
    op: 'create',
    txnId: txnId(),
    payload: { interactionId, fromUser, toUser, stars: value },
  });
  markDirty('rating', ratingId);
  await persist();
}
