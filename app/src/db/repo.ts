import { all, count, one, persist, run, sizeBytes, wipeDb } from '../db/sqlite';
import { distanceKm, jitter, roundZone, type Point } from '../lib/geo';
import { hashMeetCode, meetCode as makeMeetCode, txnId, uid } from '../lib/ids';
import { chat } from '../lib/matrix';
import { enqueue, pendingOutbox } from '../lib/outbox';
import type {
  Conversation,
  Emergency,
  EmergencyKind,
  Message,
  Need,
  NeedType,
  Proposal,
  Provider,
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
  level: row.solid_level,
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

export function defaultPoint(): Point {
  return DEFAULT_POINT;
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
}): Promise<Need> {
  const id = uid('n');
  const published = roundZone(jitter(input.point, 30));
  run(
    `INSERT INTO needs
       (id, author_id, type, title, description, category, zone,
        lat_public, lng_public, lat_exact, lng_exact, status, is_emergency, created_at)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'abierta', 0, ?)`,
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
      now(),
    ],
  );
  await persist();
  const created = getNeed(id, input.point);
  if (!created) throw new Error('No se pudo guardar la necesidad');
  return created;
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
  run(
    `INSERT INTO messages (id, interaction_id, room_id, sender_id, body, txn_id, status, created_at)
     VALUES (?, ?, ?, 'system', ?, ?, 'enviado', ?)`,
    [
      uid('m'),
      interactionId,
      roomId,
      `Trato acordado por S/ ${(Number(proposal.price_cents) / 100).toFixed(2)}. Coordinen aquí la hora y el lugar. El código de encuentro se muestra solo a quien pidió el servicio.`,
      txnId(),
      createdAt,
    ],
  );

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
    level: row.solid_level,
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

/** Un voto por vecino y por proveedor. Devuelve true si quedó recomendado. */
export async function toggleRecommendation(providerId: string, voterId: string): Promise<boolean> {
  const existing = one<{ id: string }>(
    `SELECT id FROM recommendations WHERE provider_id = ? AND voter_id = ?`,
    [providerId, voterId],
  );
  if (existing) {
    run(`DELETE FROM recommendations WHERE id = ?`, [existing.id]);
    await persist();
    return false;
  }
  run(`INSERT INTO recommendations (id, provider_id, voter_id, created_at) VALUES (?, ?, ?, ?)`, [
    uid('r'),
    providerId,
    voterId,
    now(),
  ]);
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
}): Promise<Emergency> {
  const id = uid('e');
  const published = roundZone(input.point, 3);
  run(
    `INSERT INTO emergency_alerts
       (id, author_id, kind, description, zone, lat_public, lng_public,
        lat_exact, lng_exact, status, institution_called, created_at)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'activa', 0, ?)`,
    [
      id,
      input.authorId,
      input.kind,
      input.description.trim(),
      input.zone,
      published.lat,
      published.lng,
      input.point.lat,
      input.point.lng,
      now(),
    ],
  );
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
  await persist();
}

export async function markInstitutionCalled(id: string): Promise<void> {
  run(`UPDATE emergency_alerts SET institution_called = 1 WHERE id = ?`, [id]);
  await persist();
}

/* ------------------------------------------------------------------ */
/* Perfil                                                              */
/* ------------------------------------------------------------------ */

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
