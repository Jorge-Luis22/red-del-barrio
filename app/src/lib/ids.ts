export function uid(prefix = ''): string {
  const raw =
    typeof crypto !== 'undefined' && 'randomUUID' in crypto
      ? crypto.randomUUID()
      : `${Date.now().toString(36)}-${Math.random().toString(36).slice(2, 10)}`;
  return prefix ? `${prefix}_${raw}` : raw;
}

export function txnId(): string {
  return `txn_${Date.now().toString(36)}_${Math.random().toString(36).slice(2, 8)}`;
}

/** Código de encuentro de 4 dígitos. Solo lo ve quien pidió el servicio. */
export function meetCode(): string {
  return String(Math.floor(1000 + Math.random() * 9000));
}

/**
 * Nunca guardamos el código en claro ni lo escribimos en el chat:
 * se guarda el hash y se compara en el servidor.
 */
export async function hashMeetCode(code: string, salt: string): Promise<string> {
  const payload = `${salt}:${code}`;
  if (typeof crypto !== 'undefined' && crypto.subtle) {
    const buffer = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(payload));
    return Array.from(new Uint8Array(buffer))
      .map((byte) => byte.toString(16).padStart(2, '0'))
      .join('');
  }
  // Fallback para contextos sin WebCrypto (file:// en navegadores viejos).
  let hash = 2166136261;
  for (let i = 0; i < payload.length; i += 1) {
    hash ^= payload.charCodeAt(i);
    hash = Math.imul(hash, 16777619);
  }
  return `fnv1a-${(hash >>> 0).toString(16)}`;
}
