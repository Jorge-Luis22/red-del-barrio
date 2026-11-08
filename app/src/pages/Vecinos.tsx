import { defaultPoint, listProviders, toggleRecommendation } from '../db/repo';
import { useApp } from '../state/app';

export default function Vecinos() {
  const { me, version, bump } = useApp();
  if (!me) return null;

  const providers = listProviders(me.id, defaultPoint());

  async function toggle(providerId: string) {
    await toggleRecommendation(providerId, me!.id);
    bump();
  }

  return (
    <div>
      <header className="page-head">
        <div>
          <h1>Vecinos de confianza</h1>
          <p className="sub">Recomendados por la propia comunidad</p>
        </div>
      </header>

      {providers.length === 0 && <div className="empty">Aún no hay vecinos registrados.</div>}

      {providers.map((p) => (
        <article key={`${p.id}-${version}`} className="card">
          <div className="title-row" style={{ display: 'flex', justifyContent: 'space-between', gap: 8 }}>
            <h3>
              <span style={{ color: p.color }}>●</span> {p.name}
            </h3>
            <span className="badge">{p.level}</span>
          </div>
          <p>
            {[p.category, p.latest].filter(Boolean).join(' · ') || 'Todavía no publica servicios'}
          </p>
          <div className="meta">
            <span className="badge warn">👍 {p.recommendations} vecinos</span>
            {p.distanceKm !== null && <span className="badge">a {p.distanceKm.toFixed(1)} km</span>}
          </div>
          <p style={{ marginTop: 8 }}>
            <button
              type="button"
              className={p.recommendedByMe ? 'btn small ghost' : 'btn small'}
              onClick={() => toggle(p.id)}
            >
              {p.recommendedByMe ? '✓ Recomendado (quitar)' : 'Recomendar'}
            </button>
          </p>
        </article>
      ))}
    </div>
  );
}
