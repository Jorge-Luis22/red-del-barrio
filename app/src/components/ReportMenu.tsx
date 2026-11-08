import { useState } from 'react';
import { blockUser } from '../db/repo';
import { reportToServer } from '../lib/auth';
import { PILOT } from '../lib/mode';
import { useApp } from '../state/app';

const REASONS = ['Spam o publicidad', 'Estafa o engaño', 'Acoso o amenazas', 'Contenido inapropiado', 'Información falsa', 'Otro'];
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

/**
 * "Reportar o bloquear" a un vecino (solo en el piloto). El reporte llega a quien organiza el piloto;
 * bloquear oculta a ese vecino en este teléfono al instante.
 */
export default function ReportMenu({
  userId,
  userName,
  entity,
  entityId,
  label = 'Reportar o bloquear',
}: {
  userId: string;
  userName: string;
  entity: string;
  entityId: string;
  label?: string;
}) {
  const { me, bump, go } = useApp();
  const [open, setOpen] = useState(false);
  const [reason, setReason] = useState(REASONS[0]);
  const [alsoBlock, setAlsoBlock] = useState(true);
  const [busy, setBusy] = useState(false);
  const [msg, setMsg] = useState<string | null>(null);

  if (!PILOT || !me || userId === me.id || !UUID.test(userId)) return null;

  async function send() {
    setBusy(true);
    setMsg(null);
    try {
      await reportToServer(entity, entityId, userId, reason);
      if (alsoBlock) await blockUser(userId);
      setMsg('Gracias. Tu reporte llegó a quien organiza el piloto.');
      if (alsoBlock) {
        bump();
        go({ name: 'none' });
      }
    } catch {
      setMsg('No se pudo enviar el reporte (¿sin conexión?). Inténtalo de nuevo con señal.');
    } finally {
      setBusy(false);
    }
  }

  async function blockOnly() {
    await blockUser(userId);
    bump();
    go({ name: 'none' });
  }

  return (
    <div className="report-menu">
      <button type="button" className="link" onClick={() => setOpen((v) => !v)} aria-expanded={open}>
        ⚑ {label}
      </button>
      {open && (
        <div className="panel" role="group" aria-label={`Reportar a ${userName}`}>
          <p style={{ margin: '0 0 6px' }}>
            <strong>{userName}</strong>
          </p>
          <label htmlFor={`rp-${entityId}`}>Motivo</label>
          <select id={`rp-${entityId}`} value={reason} onChange={(e) => setReason(e.target.value)}>
            {REASONS.map((r) => (
              <option key={r}>{r}</option>
            ))}
          </select>
          <label style={{ display: 'flex', gap: 8, alignItems: 'center', margin: '8px 0' }}>
            <input
              type="checkbox"
              style={{ width: 'auto', margin: 0 }}
              checked={alsoBlock}
              onChange={(e) => setAlsoBlock(e.target.checked)}
            />
            También bloquearlo (no verás más sus cosas)
          </label>
          <div className="meta">
            <button type="button" className="btn small danger" disabled={busy} onClick={() => void send()}>
              {busy ? 'Enviando…' : 'Enviar reporte'}
            </button>
            <button type="button" className="btn small ghost" disabled={busy} onClick={() => void blockOnly()}>
              Solo bloquear
            </button>
          </div>
          {msg && <p style={{ fontSize: '0.8rem' }}>{msg}</p>}
        </div>
      )}
    </div>
  );
}
