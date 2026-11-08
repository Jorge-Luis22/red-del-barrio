import { useState, type FormEvent } from 'react';
import {
  acceptProposal,
  createProposal,
  defaultPoint,
  getNeed,
  listProposals,
  type AcceptedDeal,
} from '../db/repo';
import { useApp } from '../state/app';
import { NEED_LABEL } from '../types';

const soles = (cents: number) => `S/ ${(cents / 100).toFixed(2)}`;

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

  async function propose(event: FormEvent) {
    event.preventDefault();
    const value = Number(price);
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
        {need.isEmergency && (
          <p style={{ fontSize: '0.8rem' }}>
            <span className="badge danger">Urgente · con costo</span> Quien atiende propone el precio y quien pidió
            decide si lo acepta. En esta versión el pago se acuerda entre ustedes.
          </p>
        )}
        <div className="meta">
          <span className="badge">{need.category}</span>
          <span className="badge warn">{need.status === 'abierta' ? 'Abierta' : 'En curso'}</span>
          <span style={{ fontSize: '0.75rem', color: 'var(--muted)' }}>
            {need.authorName} · {need.zone}
            {need.distanceKm !== null && ` · a ${need.distanceKm.toFixed(1)} km`}
          </span>
        </div>
      </header>

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
        <h2 style={{ fontSize: '1rem' }}>Propuestas ({proposals.length})</h2>
        {proposals.length === 0 && (
          <div className="empty">Todavía no hay propuestas. Sé el primero en ofrecerte.</div>
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
                  Aceptar propuesta
                </button>
              </p>
            )}
          </article>
        ))}
      </section>

      {!isAuthor && !showPropose && (
        <button type="button" className="btn block" onClick={() => setShowPropose(true)}>
          {need.isEmergency ? 'Ofrecer mi servicio' : 'Ofrecer mi ayuda'}
        </button>
      )}

      {!isAuthor && showPropose && (
        <form className="panel" onSubmit={propose}>
          <h3 style={{ marginTop: 0 }}>Mi propuesta</h3>
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
          <label htmlFor="msg">Mensaje</label>
          <textarea
            id="msg"
            rows={3}
            value={message}
            onChange={(e) => setMessage(e.target.value)}
            placeholder="Qué ofreces, materiales, condiciones…"
            maxLength={300}
          />
          <label htmlFor="eta">Cuándo puedes</label>
          <input id="eta" value={eta} onChange={(e) => setEta(e.target.value)} placeholder="Hoy 4:00 p. m." maxLength={40} />
          <div className="row" style={{ marginTop: 12 }}>
            <button type="button" className="btn ghost" onClick={() => setShowPropose(false)}>
              Cancelar
            </button>
            <button type="submit" className="btn" disabled={price === ''}>
              Enviar propuesta
            </button>
          </div>
        </form>
      )}
    </div>
  );
}
