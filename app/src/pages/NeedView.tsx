import { useState, type FormEvent } from 'react';
import {
  acceptProposal,
  closeNeed,
  createProposal,
  defaultPoint,
  getNeed,
  listProposals,
  type AcceptedDeal,
} from '../db/repo';
import ReportMenu from '../components/ReportMenu';
import { useApp } from '../state/app';
import { directionOf, isResource, isSolidary, resourceIcon } from '../lib/solidarity';
import { NEED_LABEL } from '../types';

const soles = (cents: number) => (cents === 0 ? 'Sin costo' : `S/ ${(cents / 100).toFixed(2)}`);

export default function NeedView({ needId }: { needId: string }) {
  const { me, version, bump, go } = useApp();
  const [showPropose, setShowPropose] = useState(false);
  const [deal, setDeal] = useState<AcceptedDeal | null>(null);
  const [price, setPrice] = useState('');
  const [message, setMessage] = useState('');
  const [eta, setEta] = useState('');

  if (!me) return null;

  const need = getNeed(needId, defaultPoint());
  if (!need) {
    return (
      <div>
        <button type="button" className="back" onClick={() => go({ name: 'none' })}>
          ← Volver
        </button>
        <div className="empty">La publicación ya no existe.</div>
      </div>
    );
  }

  const proposals = listProposals(needId);
  const isAuthor = me.id === need.authorId;
  const resource = isResource(need.category);
  // Recursos críticos y favores "sin dinero": no hay precio, quien responde se ofrece y el autor elige.
  const free = resource || isSolidary(need.category);
  const dir = directionOf(need.title);
  const offering = free && dir === 'ofrezco';
  const statusLabel: Record<string, string> = {
    abierta: 'Abierta',
    en_curso: 'En curso',
    cerrada: resource ? 'Cubierto' : 'Resuelto',
    cancelada: 'Cancelada',
  };

  async function propose(event: FormEvent) {
    event.preventDefault();
    const value = free ? 0 : Number(price);
    if (Number.isNaN(value) || value < 0) return;
    await createProposal({
      needId,
      providerId: me!.id,
      priceCents: Math.round(value * 100),
      message,
      eta,
    });
    setPrice('');
    setMessage('');
    setEta('');
    setShowPropose(false);
    bump();
  }

  async function accept(proposalId: string) {
    const result = await acceptProposal(proposalId);
    setDeal(result);
    bump();
  }

  return (
    <div>
      <button type="button" className="back" onClick={() => go({ name: 'none' })}>
        ← Volver
      </button>

      <header className="card" style={{ marginTop: 8 }}>
        <div className="title-row" style={{ display: 'flex', justifyContent: 'space-between', gap: 8 }}>
          <h3>{need.title}</h3>
          <span className="badge">{NEED_LABEL[need.type]}</span>
        </div>
        <p>{need.description}</p>
        {need.isEmergency && !resource && (
          <p style={{ fontSize: '0.8rem' }}>
            <span className="badge danger">Urgente · con costo</span> Quien atiende propone el precio y quien pidió
            decide si lo acepta. En esta versión el pago se acuerda entre ustedes.
          </p>
        )}
        {resource && (
          <p style={{ fontSize: '0.8rem' }}>
            <span className="badge ok">{resourceIcon(need.category)} Recurso crítico · sin costo</span> Ayuda solidaria
            entre vecinos. Se coordina por el chat; la dirección exacta solo se da a quien elijas.
          </p>
        )}
        {!resource && free && (
          <p style={{ fontSize: '0.8rem' }}>
            <span className="badge ok">🤝 Sin dinero</span> Favor entre vecinos: nadie paga. El autor elige a quién
            aceptar y después siguen el chat y la calificación.
          </p>
        )}
        <div className="meta">
          {dir && (
            <span className={dir === 'ofrezco' ? 'badge ok' : 'badge warn'}>
              {dir === 'ofrezco' ? '🟢 Ofrece' : '🔵 Necesita'}
            </span>
          )}
          <span className="badge">{need.category}</span>
          <span className="badge warn">{statusLabel[need.status] ?? need.status}</span>
          <span style={{ fontSize: '0.75rem', color: 'var(--muted)' }}>
            {need.authorName} · {need.zone}
            {need.distanceKm !== null && ` · a ${need.distanceKm.toFixed(1)} km`}
          </span>
        </div>
      </header>

      {!isAuthor && <ReportMenu userId={need.authorId} userName={need.authorName} entity="need" entityId={need.id} />}

      {isAuthor && free && need.status !== 'cerrada' && need.status !== 'cancelada' && (
        <p>
          <button
            type="button"
            className="btn small ghost"
            onClick={async () => {
              await closeNeed(need.id);
              bump();
            }}
          >
            ✓ {resource ? 'Ya está cubierto' : 'Ya está resuelto'}
          </button>
        </p>
      )}

      {deal && (
        <section className="card code-card" key={deal.interactionId}>
          <h3>Trato acordado</h3>
          <p>
            Muestra este código solo cuando te encuentres con{' '}
            {proposals.find((p) => p.status === 'aceptada')?.providerName ?? 'tu vecino'}:
          </p>
          <div className="code">{deal.code}</div>
          <button type="button" className="btn block" onClick={() => go({ name: 'chat', id: deal.interactionId })}>
            Abrir el chat del trato
          </button>
        </section>
      )}

      <section>
        <h2 style={{ fontSize: '1rem' }}>
          {offering ? 'Interesados' : 'Propuestas'} ({proposals.length})
        </h2>
        {proposals.length === 0 && (
          <div className="empty">
            {offering
              ? 'Todavía nadie lo pidió. Sé el primero en decir que lo necesitas.'
              : 'Todavía no hay propuestas. Sé el primero en ofrecerte.'}
          </div>
        )}
        {proposals.map((p) => (
          <article key={`${p.id}-${version}`} className="card">
            <div className="title-row" style={{ display: 'flex', justifyContent: 'space-between', gap: 8 }}>
              <h3>{p.providerName}</h3>
              <strong>{soles(p.priceCents)}</strong>
            </div>
            <p>{p.message}</p>
            <div className="meta">
              {p.eta && <span className="badge">🕐 {p.eta}</span>}
              <span className="badge warn">
                {p.status === 'enviada' ? 'Enviada' : p.status === 'aceptada' ? 'Aceptada' : 'Respondida'}
              </span>
            </div>
            {isAuthor && p.status === 'enviada' && !deal && (
              <p>
                <button type="button" className="btn small" onClick={() => accept(p.id)}>
                  {offering ? 'Elegir a esta persona' : 'Aceptar propuesta'}
                </button>
              </p>
            )}
          </article>
        ))}
      </section>

      {!isAuthor && !showPropose && need.status === 'abierta' && (
        <button type="button" className="btn block" onClick={() => setShowPropose(true)}>
          {free ? (offering ? '🙋 Lo necesito' : '🙋 Puedo ayudar') : need.isEmergency ? 'Ofrecer mi servicio' : 'Ofrecer mi ayuda'}
        </button>
      )}

      {!isAuthor && showPropose && (
        <form className="panel" onSubmit={propose}>
          <h3 style={{ marginTop: 0 }}>{offering ? 'Lo necesito' : free ? 'Puedo ayudar' : 'Mi propuesta'}</h3>
          {free ? (
            <p className="badge ok" style={{ marginBottom: 4 }}>
              Sin dinero: aquí no se propone precio
            </p>
          ) : (
            <>
              <label htmlFor="price">Precio en soles (0 = intercambio solidario)</label>
              <input
                id="price"
                type="number"
                min="0"
                step="0.5"
                inputMode="decimal"
                value={price}
                onChange={(e) => setPrice(e.target.value)}
                placeholder="15.00"
              />
            </>
          )}
          <label htmlFor="msg">Mensaje</label>
          <textarea
            id="msg"
            rows={3}
            value={message}
            onChange={(e) => setMessage(e.target.value)}
            placeholder={offering ? 'Para qué lo necesitas, cuántas personas…' : 'Qué ofreces, materiales, condiciones…'}
            maxLength={300}
          />
          <label htmlFor="eta">Cuándo puedes</label>
          <input id="eta" value={eta} onChange={(e) => setEta(e.target.value)} placeholder="Hoy 4:00 p. m." maxLength={40} />
          <div className="row" style={{ marginTop: 12 }}>
            <button type="button" className="btn ghost" onClick={() => setShowPropose(false)}>
              Cancelar
            </button>
            <button type="submit" className="btn" disabled={!free && price === ''}>
              {free ? 'Enviar' : 'Enviar propuesta'}
            </button>
          </div>
        </form>
      )}
    </div>
  );
}
