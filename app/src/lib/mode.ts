/**
 * Dos formas de publicar la misma app:
 *  - demo  (por defecto): vecinos de ejemplo, cambiar de vecino, base compartida sin cuentas. Para el jurado.
 *  - piloto (`VITE_APP_MODE=pilot`): vecinos reales. Cuenta automática + código del barrio, sin datos de
 *    ejemplo, chats visibles solo para los dos, reportes y eliminación de cuenta.
 */
export const PILOT = import.meta.env.VITE_APP_MODE === 'pilot';

/** Correo al que escriben los vecinos para dudas, reportes y pedir que se borren sus datos. */
export const CONTACT_EMAIL = (import.meta.env.VITE_CONTACT_EMAIL as string | undefined) ?? '';
