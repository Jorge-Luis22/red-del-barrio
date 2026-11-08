import { listConversations, retryPending } from '../db/repo';
import { useApp } from '../state/app';

const time = (iso: string | null) =>
  iso
    ? new Date(iso).toLocaleTimeString('es-PE', { hour: '2-digit', minute: '2-digit' })
    : '';

export default function Mensajes() {
  const { me, version, bump, go } = useApp();
  if (!me) return null;

  const conversations = listConversations(me.id);
  const pending = conversations.reduce((sum, c) => sum + c.pending, 0);

  async function retryAll() {
    await retryPending();
    bump();
  }

  return (
    <div>
      <header className="page-head">
        <div>
          <h1>Mensajes</h1>
          <p className="sub">Un chat por cada trato acordado</p>
        </div>
        {pending > 0 && (
          <div className="actions">
            <button type="button" className="btn small warn-btn" onClick={retryAll}>
              Reintentar ({pending})
            </button>
          </div>
        )}
      </header>

      {conversations.length === 0 && (
        <div className="empty">Cuando aceptes una propuesta, el chat aparece aquí.</div>
      )}

      {conversations.map((c) => (
        <article
          key={`${c.id}-${version}`}
          className="card need-card"
          onClick={() => go({ name: 'chat', id: c.id })}
        >
          <div className="title-row" style={{ display: 'flex', justifyContent: 'space-between', gap: 8 }}>
            <h3>
              <span style={{ color: c.otherColor }}>●</span> {c.otherName}
            </h3>
            <span style={{ fontSize: '0.72rem', color: 'var(--muted)' }}>{time(c.lastAt)}</span>
          </div>
          <p>{c.lastBody ?? c.needTitle}</p>
          <div className="meta">
            <span className="badge">{c.needTitle}</span>
            <span className="badge warn">{c.status}</span>
            {c.pending > 0 && <span className="badge danger">{c.pending} pendiente</span>}
          </div>
        </article>
      ))}
    </div>
  );
}
