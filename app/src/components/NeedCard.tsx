import { useApp } from '../state/app';
import { directionOf, isSolidary } from '../lib/solidarity';
import { NEED_LABEL, type Need } from '../types';

/** Tarjeta de una publicación del muro (Inicio). */
export default function NeedCard({ need }: { need: Need }) {
  const { go } = useApp();
  const dir = directionOf(need.title);
  return (
    <article className="card need-card" onClick={() => go({ name: 'need', id: need.id })}>
      <div className="title-row">
        <h3>{need.title}</h3>
        <span className="badge">{NEED_LABEL[need.type]}</span>
      </div>
      <p>{need.description || need.category}</p>
      <div className="meta">
        {dir && (
          <span className={dir === 'ofrezco' ? 'badge ok' : 'badge warn'}>
            {dir === 'ofrezco' ? '🟢 Ofrece' : '🔵 Necesita'}
          </span>
        )}
        {isSolidary(need.category) && <span className="badge ok">🤝 Sin dinero</span>}
        <span className="badge">{need.category}</span>
        {need.isEmergency && <span className="badge danger">Emergencia</span>}
        <span style={{ fontSize: '0.75rem', color: 'var(--muted)' }}>
          {need.authorName}
          {need.distanceKm !== null && ` · a ${need.distanceKm.toFixed(1)} km`}
          {need.recommendations > 0 && ` · 👍 ${need.recommendations}`}
        </span>
      </div>
    </article>
  );
}
