/**
 * Capa de chat. Dos implementaciones con la misma interfaz:
 *  - LocalTransport: sin servidor. Sirve para la demo y para desarrollar sin red.
 *  - MatrixTransport: Synapse real por Client-Server API (sin SDK, ~100 líneas).
 *
 * Al configurar VITE_MATRIX_HOMESERVER + VITE_MATRIX_TOKEN se usa Matrix.
 * Un room por trato: el `room_id` queda guardado en `interactions`.
 */

import { syncConfigured } from './sync';

const HOMESERVER = (import.meta.env.VITE_MATRIX_HOMESERVER ?? '').replace(/\/+$/, '');
const TOKEN = import.meta.env.VITE_MATRIX_TOKEN ?? '';

export const matrixConfigured = Boolean(HOMESERVER && TOKEN);

export interface RoomInput {
  interactionId: string;
  name: string;
  invite?: string;
}

export interface ChatTransport {
  kind: 'matrix' | 'local';
  label: string;
  ensureRoom(input: RoomInput): Promise<string>;
  send(roomId: string, body: string, txnId: string): Promise<void>;
}

function matrixUser(userId: string): string | undefined {
  if (!HOMESERVER) return undefined;
  try {
    const host = new URL(HOMESERVER).hostname;
    return `@${userId.replace(/[^a-z0-9._=-]/gi, '_')}:${host}`;
  } catch {
    return undefined;
  }
}

async function api<T>(path: string, init?: RequestInit): Promise<T> {
  const response = await fetch(`${HOMESERVER}${path}`, {
    ...init,
    headers: {
      Authorization: `Bearer ${TOKEN}`,
      'Content-Type': 'application/json',
      ...(init?.headers ?? {}),
    },
  });
  if (!response.ok) {
    const detail = await response.text().catch(() => '');
    throw new Error(`Matrix ${response.status}: ${detail.slice(0, 120)}`);
  }
  return (await response.json()) as T;
}

class MatrixTransport implements ChatTransport {
  kind = 'matrix' as const;
  label = 'Matrix conectado';

  async ensureRoom(input: RoomInput): Promise<string> {
    const invite = input.invite ?? matrixUser(input.interactionId);
    const body: Record<string, unknown> = {
      name: input.name,
      preset: 'private_chat',
      is_direct: true,
      visibility: 'private',
      // E2EE fuera en la demo: ver docs/DECISIONES.md
    };
    if (invite) body.invite = [invite];
    const room = await api<{ room_id: string }>('/_matrix/client/v3/createRoom', {
      method: 'POST',
      body: JSON.stringify(body),
    });
    return room.room_id;
  }

  async send(roomId: string, body: string, txnId: string): Promise<void> {
    await api(
      `/_matrix/client/v3/rooms/${encodeURIComponent(roomId)}/send/m.room.message/${encodeURIComponent(txnId)}`,
      { method: 'PUT', body: JSON.stringify({ msgtype: 'm.text', body }) },
    );
  }
}

class LocalTransport implements ChatTransport {
  kind = 'local' as const;
  label = syncConfigured ? 'Chat en vivo' : 'Chat local (demo)';

  async ensureRoom(input: RoomInput): Promise<string> {
    return `!local:${input.interactionId}`;
  }

  async send(_roomId: string, _body: string, _txnId: string): Promise<void> {
    // Simula latencia de red y falla sin conexión para ver el estado "Pendiente".
    await new Promise((resolve) => setTimeout(resolve, 450));
    if (typeof navigator !== 'undefined' && navigator.onLine === false) {
      throw new Error('Sin conexión');
    }
  }
}

export const chat: ChatTransport = matrixConfigured ? new MatrixTransport() : new LocalTransport();

export function matrixInvite(userId: string): string | undefined {
  return matrixUser(userId);
}
