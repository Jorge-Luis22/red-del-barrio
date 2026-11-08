import { useState, type FormEvent } from 'react';
import {
  createNeed,
  defaultPoint,
  listMyUrgentRequests,
  listUrgentRequests,
  listUrgentServices,
  listUrgentTrades,
} from '../db/repo';
import { formatDistance } from '../lib/geo';
import { ago } from '../lib/time';
import { useApp } from '../state/app';
import { TRADES } from '../types';

/**
 * Servicios de urgencia (con costo): vecinos que atienden emergencias y cobran por su trabajo.
 * Nadie publica precio de antemano: el vecino pide, quien atiende propone un precio y el vecino decide.
 * La ayuda solidaria (sin costo) vive en la otra pestaña: "Alertas vecinales".
 */
export default function ServiciosUrgencia() {
  const { me, version, bump, go } = useApp();
  const [filter, setFilter] = useState('todos');
  const [showForm, setShowForm] = useState(false);
  const [trade, setTrade] = useState<string>(TRADES[0]);
  const [description, setDescription] = useState('');
  const [sent, setSent] = useState<string | null>(null);

  if (!me) return null;
  const viewer = defaultPoint();
  const services = listUrgentServices(me.id, viewer, filter === 'todos' ? undefined : filter);
  const trades = listUrgentTrades(me.id);
  const mine = listMyUrgentRequests(me.id, viewer);
  const others = listUrgentRequests(me.id, viewer);

  function ask(forTrade: string) {
    setTrade(forTrade);
    setSent(null);
    setShowForm(true);
  }

  async function submit(event: FormEvent) {
    event.preventDefault();
    if (!description.trim()) return;
    await createNeed({
      authorId: me!.id,
      type: 'servicio',
      title: `Urgente: ${trade}`,
      description,
      category: trade,
      zone: me!.zone,
      point: defaultPoint(),
      isEmergency: true,
    });
    setDescription('');
    setShowForm(false);
    setSent(trade);
    bump();
  }

  return (
    <div>
      <section className="card">
        <h3>Servicios de urgencia · con costo</h3>
        <p>
          Vecinos de tu zona que atienden urgencias y cobran por su trabajo. <strong>Nadie publica precio de
          antemano</strong>: tú pides, quien atiende propone un precio y tú decides si lo aceptas. En esta versión el
          pago se acuerda entre ustedes.
        </p>
        <p style={{ fontSize: '0.8rem' }}>
          Si hay peligro de vida, llama primero a la institución (arriba). La ayuda gratuita de vecinos está en
          "Alertas vecinales".
        </p>
      </section>

      {sent && (
        <div className="card" role="status" style={{ borderLeft: '4px solid var(--accent)' }}>
          <strong>Pedido enviado.</strong> Los vecinos que atienden <strong>{sent}</strong> verán tu pedido y te
          propondrán un precio. Lo verás aquí abajo, en "Mis pedidos urgentes".
        </div>
      )}

      {!showForm ? (
        <button type="button" className="btn block" onClick={() => ask(trade)}>
          🛠️ Pedir un servicio urgente
        </button>
      ) : (
        <form className="panel" onSubmit={submit}>
          <h3 style={{ marginTop: 0 }}>Pedido urgente</h3>
          <label htmlFor="u-trade">Qué necesitas</label>
          <select id="u-trade" value={trade} onChange={(e) => setTrade(e.target.value)}>
            {TRADES.map((t) => (
              <option key={t} value={t}>
                {t}
              </option>
            ))}
          </select>
          <label htmlFor="u-desc">Qué pasa</label>
          <textarea
            id="u-desc"
            rows={3}
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            placeholder="Ej.: Se rompió un tubo y sale mucha agua en la cocina."
            maxLength={300}
          />
          <p style={{ fontSize: '0.75rem' }}>
            Tus vecinos ven solo tu zona aproximada (~1 km). La dirección exacta se la das a quien aceptes, por el
            chat.
          </p>
          <div className="row" style={{ display: 'flex', gap: 8, marginTop: 8 }}>
            <button type="button" className="btn ghost" onClick={() => setShowForm(false)}>
              Cancelar
            </button>
            <button type="submit" className="btn danger" disabled={!description.trim()}>
              Enviar pedido urgente
            </button>
          </div>
        </form>
      )}

      {mine.length > 0 && (
        <section aria-label="Mis pedidos urgentes" style={{ marginTop: 16 }}>
          <h2 style={{ fontSize: '1.05rem', margin: '0 0 8px' }}>Mis pedidos urgentes</h2>
          {mine.map(({ need, proposals }) => (
            <article key={`${need.id}-${version}`} className="card" style={{ borderLeft: '4px solid var(--danger)' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', gap: 8 }}>
                <h3>{need.title}</h3>
                <span className="badge danger">{ago(need.createdAt)}</span>
              </div>
              <p>{need.description}</p>
              <div className="meta">
                <span className="badge warn">
                  {need.status === 'en_curso'
                    ? 'En curso · sigue en Mensajes'
                    : proposals === 0
                      ? 'Esperando propuestas…'
                      : `${proposals} ${proposals === 1 ? 'propuesta' : 'propuestas'}`}
                </span>
              </div>
              <p>
                <button type="button" className="btn small" onClick={() => go({ name: 'need', id: need.id })}>
                  {need.status === 'en_curso' ? 'Ver pedido' : 'Ver propuestas'}
                </button>
              </p>
            </article>
          ))}
        </section>
      )}

      {others.length > 0 && (
        <section aria-label="Pedidos urgentes de vecinos" style={{ marginTop: 16 }}>
          <h2 style={{ fontSize: '1.05rem', margin: '0 0 8px' }}>Pedidos urgentes de vecinos</h2>
          {others.map(({ need, matchesMe, proposals }) => (
            <article key={`${need.id}-${version}`} className="card" style={{ borderLeft: '4px solid var(--danger)' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', gap: 8 }}>
                <h3>{need.title}</h3>
                <span className="badge danger">{ago(need.createdAt)}</span>
              </div>
              <p>{need.description}</p>
              <div className="meta">
                {matchesMe && <span className="badge warn">Para ti: es tu oficio</span>}
                <span className="badge">
                  {need.authorName} · {need.zone || 'zona aprox.'}
                  {need.distanceKm !== null && ` · ~${formatDistance(need.distanceKm)}`}
                </span>
                {proposals > 0 && (
                  <span className="badge">
                    {proposals} {proposals === 1 ? 'propuesta' : 'propuestas'}
                  </span>
                )}
              </div>
              <p>
                <button type="button" className="btn small" onClick={() => go({ name: 'need', id: need.id })}>
                  Ver y proponer
                </button>
              </p>
            </article>
          ))}
        </section>
      )}

      <section aria-label="Quién atiende urgencias" style={{ marginTop: 16 }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: 8, marginBottom: 8 }}>
          <h2 style={{ fontSize: '1.05rem', margin: 0 }}>Quién atiende urgencias</h2>
          <select
            aria-label="Filtrar por oficio"
            value={filter}
            onChange={(e) => setFilter(e.target.value)}
            style={{ maxWidth: 160 }}
          >
            <option value="todos">Todos</option>
            {trades.map((t) => (
              <option key={t} value={t}>
                {t}
              </option>
            ))}
          </select>
        </div>
        {services.length === 0 && (
          <div className="empty">
            Todavía nadie atiende urgencias de este oficio. Puedes ofrecer el tuyo en Perfil → Mis servicios.
          </div>
        )}
        {services.map((s) => (
          <article key={`${s.id}-${version}`} className="card">
            <div style={{ display: 'flex', justifyContent: 'space-between', gap: 8 }}>
              <h3>{s.trade}</h3>
              <span className={s.availableNow ? 'badge ok' : 'badge'}>
                {s.availableNow ? '🟢 Disponible ahora' : '🕐 No disponible ahora'}
              </span>
            </div>
            <p>
              <strong>
                <span style={{ color: s.providerColor }}>●</span> {s.providerName}
              </strong>
              {s.description && ` · ${s.description}`}
            </p>
            <div className="meta">
              <span className="badge warn">👍 {s.recommendations} vecinos</span>
              {s.schedule && <span className="badge">🕐 {s.schedule}</span>}
              {s.distanceKm !== null && <span className="badge">a {formatDistance(s.distanceKm)}</span>}
              <span className="badge">Con costo · lo propone al pedirlo</span>
            </div>
            <p>
              <button type="button" className="btn small" onClick={() => ask(s.trade)}>
                Pedir {s.trade.toLowerCase()}
              </button>
            </p>
          </article>
        ))}
      </section>
    </div>
  );
}
