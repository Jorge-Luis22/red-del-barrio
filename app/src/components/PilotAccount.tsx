import { useState } from 'react';
import { listBlocked, unblockUser } from '../db/repo';
import { dropDb } from '../db/sqlite';
import { clearAccountLocal, deleteMyAccount } from '../lib/auth';
import { CONTACT_EMAIL } from '../lib/mode';
import { useApp } from '../state/app';
import Legal from './Legal';

/** Perfil (piloto): estado de la cuenta, términos, vecinos bloqueados y eliminar mi cuenta. */
export default function PilotAccount() {
  const { version, bump } = useApp();
  const [legal, setLegal] = useState(false);
  const [confirming, setConfirming] = useState(false);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const blocked = listBlocked();

  async function remove() {
    setBusy(true);
    setError(null);
    try {
      await deleteMyAccount();
    } catch {
      setError('No se pudo eliminar (¿sin conexión?). No se borró nada. Inténtalo de nuevo con señal.');
      setBusy(false);
      return;
    }
    clearAccountLocal();
    await dropDb();
    window.location.reload();
  }

  return (
    <>
      <section className="card">
        <h3>Mi cuenta</h3>
        <p>
          Tu cuenta vive en este teléfono. Si borras los datos del navegador o cambias de teléfono, no se puede
          recuperar: tendrías que entrar de nuevo con el código del barrio.
        </p>
        <div className="meta">
          <button type="button" className="btn small ghost" onClick={() => setLegal(true)}>
            Términos y privacidad
          </button>
        </div>
        {CONTACT_EMAIL && <p style={{ fontSize: '0.78rem' }}>Dudas o reportes: {CONTACT_EMAIL}</p>}
      </section>

      <section className="card" key={`blocked-${version}`}>
        <h3>Vecinos bloqueados</h3>
        {blocked.length === 0 && <p>No has bloqueado a nadie.</p>}
        {blocked.map((b) => (
          <div key={b.id} className="meta" style={{ alignItems: 'center', justifyContent: 'space-between' }}>
            <span>{b.name}</span>
            <button
              type="button"
              className="btn small ghost"
              onClick={async () => {
                await unblockUser(b.id);
                bump();
              }}
            >
              Desbloquear
            </button>
          </div>
        ))}
      </section>

      <section className="card">
        <h3>Eliminar mi cuenta</h3>
        <p>Borra tu cuenta y todo lo que publicaste en el servidor, y limpia este teléfono. No se puede deshacer.</p>
        {!confirming ? (
          <button type="button" className="btn small danger" onClick={() => setConfirming(true)}>
            Eliminar mi cuenta y mis datos
          </button>
        ) : (
          <div role="alertdialog" aria-label="Confirmar eliminación">
            <p>
              <strong>¿Seguro?</strong> Se borra tu perfil, tus publicaciones, tus mensajes y tus calificaciones.
            </p>
            <div className="meta">
              <button type="button" className="btn small danger" disabled={busy} onClick={() => void remove()}>
                {busy ? 'Eliminando…' : 'Sí, eliminar todo'}
              </button>
              <button type="button" className="btn small ghost" disabled={busy} onClick={() => setConfirming(false)}>
                Cancelar
              </button>
            </div>
          </div>
        )}
        {error && (
          <p role="alert" style={{ color: 'var(--danger)', fontSize: '0.82rem' }}>
            {error}
          </p>
        )}
      </section>
      {legal && <Legal onClose={() => setLegal(false)} />}
    </>
  );
}
