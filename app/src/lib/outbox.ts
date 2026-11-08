import { all, persist, run } from '../db/sqlite';
import { uid } from './ids';

export interface OutboxItem {
  id: string;
  entity: string;
  entity_id: string;
  op: string;
  payload: string;
  txn_id: string;
  attempts: number;
  status: 'pendiente' | 'enviado' | 'fallido';
  last_error: string | null;
  created_at: string;
}

export function enqueue(item: {
  entity: string;
  entityId: string;
  op: string;
  txnId: string;
  payload?: unknown;
}): void {
  run(
    `INSERT OR IGNORE INTO outbox
       (id, entity, entity_id, op, payload, txn_id, attempts, status, last_error, created_at)
     VALUES (?, ?, ?, ?, ?, ?, 0, 'pendiente', NULL, ?)`,
    [
      uid('ob'),
      item.entity,
      item.entityId,
      item.op,
      JSON.stringify(item.payload ?? {}),
      item.txnId,
      new Date().toISOString(),
    ],
  );
}

export function pendingOutbox(): number {
  return Number(all<{ n: number }>(`SELECT COUNT(*) AS n FROM outbox WHERE status = 'pendiente'`)[0]?.n ?? 0);
}

export function listOutbox(status: OutboxItem['status'] = 'pendiente'): OutboxItem[] {
  return all<OutboxItem>(`SELECT * FROM outbox WHERE status = ? ORDER BY created_at LIMIT 25`, [status]);
}

export function markOutbox(id: string, status: OutboxItem['status'], error?: string): void {
  run(`UPDATE outbox SET status = ?, attempts = attempts + 1, last_error = ? WHERE id = ?`, [
    status,
    error ?? null,
    id,
  ]);
}

/**
 * Reintenta la cola. `send` debe ser idempotente (usa el txn_id del item):
 * si el servidor ya recibió el mensaje, no se duplica.
 */
export async function flushOutbox(send: (item: OutboxItem) => Promise<void>): Promise<number> {
  const items = listOutbox('pendiente');
  if (!items.length) return 0;
  let delivered = 0;
  for (const item of items) {
    try {
      await send(item);
      markOutbox(item.id, 'enviado');
      delivered += 1;
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      const failed = item.attempts + 1 >= 5;
      markOutbox(item.id, failed ? 'fallido' : 'pendiente', message);
    }
  }
  await persist();
  return delivered;
}
