/**
 * Cuentas del piloto (Supabase Auth, ingreso anónimo) y llamadas autenticadas al servidor.
 *
 * - Al unirse, el teléfono crea una cuenta anónima automática: sin correo ni contraseña.
 * - La sesión (token + token de renovación) vive en localStorage de ESTE teléfono. Si se borran los datos
 *   del navegador o se cambia de teléfono, la cuenta no se puede recuperar: la app lo avisa en pantalla.
 * - Sin conexión no pasa nada: la sesión se conserva y se renueva cuando vuelve la red. Solo se pierde si
 *   el servidor rechaza expresamente la renovación.
 */
const URL = ((import.meta.env.VITE_SUPABASE_URL as string | undefined) ?? '').replace(/\/+$/, '');
const KEY = (import.meta.env.VITE_SUPABASE_ANON_KEY as string | undefined) ?? '';

const SESSION_KEY = 'redvecinal.pilot.session.v1';
const MEMBER_KEY = 'redvecinal.pilot.member.v1';

export interface Session {
  access_token: string;
  refresh_token: string;
  /** Segundos desde 1970 en que vence el token de acceso. */
  expires_at: number;
  user_id: string;
}

export type AuthFailure = 'offline' | 'rejected' | 'server' | 'no_session' | 'disabled';
export class AuthError extends Error {
  constructor(public kind: AuthFailure, message: string) {
    super(message);
  }
}

function lsGet(key: string): string | null {
  try {
    return localStorage.getItem(key);
  } catch {
    return null;
  }
}
function lsSet(key: string, value: string | null): void {
  try {
    if (value === null) localStorage.removeItem(key);
    else localStorage.setItem(key, value);
  } catch {
    /* sin almacenamiento: la sesión dura solo mientras la app esté abierta */
  }
}

let memory: Session | null = null;

function readSession(): Session | null {
  if (memory) return memory;
  try {
    const parsed = JSON.parse(lsGet(SESSION_KEY) ?? 'null') as Partial<Session> | null;
    if (
      parsed &&
      typeof parsed.access_token === 'string' &&
      typeof parsed.refresh_token === 'string' &&
      typeof parsed.user_id === 'string' &&
      typeof parsed.expires_at === 'number'
    ) {
      memory = parsed as Session;
      return memory;
    }
  } catch {
    /* sesión ilegible: se trata como si no hubiera */
  }
  return null;
}

function writeSession(session: Session | null): void {
  memory = session;
  lsSet(SESSION_KEY, session ? JSON.stringify(session) : null);
}

export const getSessionUserId = (): string | null => readSession()?.user_id ?? null;
export const hasSession = (): boolean => readSession() !== null;

/** El teléfono ya entró al barrio con esta cuenta (el código fue aceptado). */
export const isMemberMarked = (): boolean => {
  const session = readSession();
  return Boolean(session) && lsGet(MEMBER_KEY) === session?.user_id;
};
export const markMember = (userId: string): void => lsSet(MEMBER_KEY, userId);

/** Olvida la cuenta en este teléfono (no borra nada en el servidor). */
export function clearAccountLocal(): void {
  writeSession(null);
  lsSet(MEMBER_KEY, null);
}

const lostListeners = new Set<() => void>();
export function onSessionLost(listener: () => void): () => void {
  lostListeners.add(listener);
  return () => {
    lostListeners.delete(listener);
  };
}

async function timedFetch(url: string, init: RequestInit, ms = 12000): Promise<Response> {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), ms);
  try {
    return await fetch(url, { ...init, signal: controller.signal });
  } catch (error) {
    throw new AuthError('offline', error instanceof Error ? error.message : 'Sin conexión');
  } finally {
    clearTimeout(timer);
  }
}

function toSession(json: unknown): Session {
  const j = json as {
    access_token?: unknown;
    refresh_token?: unknown;
    expires_at?: unknown;
    expires_in?: unknown;
    user?: { id?: unknown };
  };
  if (typeof j?.access_token !== 'string' || typeof j.refresh_token !== 'string' || typeof j.user?.id !== 'string') {
    throw new AuthError('server', 'Respuesta de cuenta inesperada');
  }
  const expiresAt =
    typeof j.expires_at === 'number'
      ? j.expires_at
      : Math.floor(Date.now() / 1000) + (typeof j.expires_in === 'number' ? j.expires_in : 3600);
  return { access_token: j.access_token, refresh_token: j.refresh_token, expires_at: expiresAt, user_id: j.user.id };
}

const authHeaders = { apikey: KEY, 'Content-Type': 'application/json' };

/** Crea una cuenta anónima nueva (la primera vez que alguien abre el piloto). */
export async function signUpAnonymous(): Promise<Session> {
  const res = await timedFetch(`${URL}/auth/v1/signup`, { method: 'POST', headers: authHeaders, body: '{}' });
  if (!res.ok) {
    const text = await res.text().catch(() => '');
    if (res.status === 422 || /anonymous/i.test(text)) {
      throw new AuthError('disabled', 'El servidor todavía no admite cuentas automáticas.');
    }
    throw new AuthError('server', `No se pudo crear la cuenta (${res.status}).`);
  }
  const session = toSession(await res.json());
  writeSession(session);
  return session;
}

let refreshing: Promise<Session> | null = null;

async function refresh(session: Session): Promise<Session> {
  if (!refreshing) {
    refreshing = (async () => {
      const res = await timedFetch(`${URL}/auth/v1/token?grant_type=refresh_token`, {
        method: 'POST',
        headers: authHeaders,
        body: JSON.stringify({ refresh_token: session.refresh_token }),
      });
      if (res.status === 400 || res.status === 401 || res.status === 403) {
        writeSession(null);
        lostListeners.forEach((listener) => listener());
        throw new AuthError('rejected', 'La sesión de este teléfono ya no es válida.');
      }
      if (!res.ok) throw new AuthError('server', `No se pudo renovar la sesión (${res.status}).`);
      const next = toSession(await res.json());
      writeSession(next);
      return next;
    })().finally(() => {
      refreshing = null;
    });
  }
  return refreshing;
}

/** Token de acceso vigente (lo renueva si vence en menos de un minuto). */
export async function getAccessToken(forceRefresh = false): Promise<string> {
  let session = readSession();
  if (!session) throw new AuthError('no_session', 'Falta iniciar sesión.');
  if (forceRefresh || session.expires_at - Math.floor(Date.now() / 1000) < 60) {
    session = await refresh(session);
  }
  return session.access_token;
}

/** Pide al servidor con la sesión de este teléfono. Si el token venció, lo renueva y reintenta una vez. */
export async function authedRest(path: string, init: RequestInit = {}): Promise<Response> {
  const attempt = async (force: boolean) => {
    const token = await getAccessToken(force);
    return timedFetch(`${URL}/rest/v1/${path}`, {
      ...init,
      headers: { apikey: KEY, 'Content-Type': 'application/json', ...(init.headers ?? {}), Authorization: `Bearer ${token}` },
    });
  };
  let res = await attempt(false);
  if (res.status === 401) res = await attempt(true);
  if (!res.ok) {
    const text = await res.text().catch(() => '');
    let message = text.slice(0, 160);
    try {
      const parsed = JSON.parse(text) as { message?: string };
      if (parsed.message) message = parsed.message;
    } catch {
      /* texto plano */
    }
    throw new Error(`Servidor ${res.status}: ${message}`);
  }
  return res;
}

/** Llama a una función del servidor (todas las escrituras del piloto pasan por aquí). */
export async function rpc<T>(fn: string, args: Record<string, unknown>): Promise<T> {
  const res = await authedRest(`rpc/${fn}`, { method: 'POST', body: JSON.stringify(args) });
  if (res.status === 204) return null as T;
  const text = await res.text();
  return (text ? JSON.parse(text) : null) as T;
}

/* ---------- Unirse al barrio ---------- */

export type JoinError = 'bad_code' | 'too_many_attempts' | 'banned' | 'not_configured' | 'bad_name' | 'no_auth';

export class JoinFailed extends Error {
  constructor(public code: JoinError | 'offline' | 'disabled' | 'server') {
    super(code);
  }
}

/** Crea la cuenta (si hace falta) y entra al barrio con el código. Devuelve el id de la cuenta. */
export async function joinNeighborhood(code: string, name: string, zone: string): Promise<string> {
  try {
    const session = readSession() ?? (await signUpAnonymous());
    const result = await rpc<{ ok: boolean; error?: JoinError }>('pilot_join', {
      p_code: code,
      p_name: name,
      p_zone: zone,
    });
    if (!result?.ok) throw new JoinFailed(result?.error ?? 'server');
    markMember(session.user_id);
    return session.user_id;
  } catch (error) {
    if (error instanceof JoinFailed) throw error;
    if (error instanceof AuthError) {
      if (error.kind === 'offline') throw new JoinFailed('offline');
      if (error.kind === 'disabled') throw new JoinFailed('disabled');
      throw new JoinFailed('server');
    }
    if (error instanceof Error && /failed to fetch|network|abort/i.test(error.message)) throw new JoinFailed('offline');
    throw new JoinFailed('server');
  }
}

/** Datos de mi cuenta en el servidor (para reconstruir el perfil si la base local se perdió). */
export async function fetchMyMember(): Promise<{ display_name: string; zone: string } | null> {
  const res = await authedRest('pilot_members?select=display_name,zone,banned');
  const rows = (await res.json()) as { display_name: string; zone: string; banned: boolean }[];
  return rows[0] && !rows[0].banned ? rows[0] : null;
}

/** Elimina mi cuenta y todo lo que publiqué en el servidor. Después hay que borrar también lo local. */
export async function deleteMyAccount(): Promise<void> {
  await rpc<null>('pilot_delete_me', {});
}

export async function reportToServer(entity: string, id: string, target: string, reason: string): Promise<void> {
  await rpc<null>('pilot_report', { p_entity: entity, p_id: id, p_target: target, p_reason: reason });
}
