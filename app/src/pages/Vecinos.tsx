import { useState } from 'react';
import { defaultPoint, listDirectory, toggleRecommendation } from '../db/repo';
import ReportMenu from '../components/ReportMenu';
import { useApp } from '../state/app';
import { startNeedDraft } from './Inicio';

const norm = (value: string) => value.normalize('NFD').replace(/[̀-ͯ]/g, '').toLowerCase();

/** Directorio de vecinos: quién hace qué, qué tan recomendado está y a qué distancia vive. Con buscador y filtro por oficio. */
export default function Vecinos() {
  const { me, version, bump, setTab } = useApp();
  const [q, setQ] = useState('');
  const [trade, setTrade] = useState('todos');
  const [nowOnly, setNowOnly] = useState(false);
  if (!me) return null;

  const everyone = listDirectory(me.id, defaultPoint());

  // Oficios que existen hoy en el barrio, con cuántos vecinos los ofrecen.
  const tradeCount = new Map<string, number>();
  for (const entry of everyone) {
    for (const t of new Set(entry.offers.map((o) => o.trade))) tradeCount.set(t, (tradeCount.get(t) ?? 0) + 1);
  }
  const trades = [...tradeCount.entries()].sort((a, b) => b[1] - a[1] || a[0].localeCompare(b[0], 'es'));

  const needle = norm(q.trim());
  const providers = everyone.filter((p) => {
    if (trade !== 'todos' && !p.offers.some((o) => o.trade === trade)) return false;
    if (nowOnly && !p.offers.some((o) => o.availableNow && (trade === 'todos' || o.trade === trade))) return false;
    if (!needle) return true;
    const haystack = norm(
      [p.name, p.zone, p.category ?? '', p.latest ?? '', ...p.offers.flatMap((o) => [o.trade, o.description])].join(' '),
    );
    return haystack.includes(needle);
  });

  async function toggle(providerId: string) {
    await toggleRecommendation(providerId, me!.id);
    bump();
  }

  function ask(tradeName: string) {
    startNeedDraft({
      type: 'servicio',
      title: `Busco ${tradeName.toLowerCase()}`,
      category: tradeName,
      description: '',
    });
    setTab('inicio');
  }

  return (
    <div>
      <header className="page-head">
        <div>
          <h1>Directorio de vecinos</h1>
          <p className="sub">Quién hace qué en tu barrio, recomendado por la propia comunidad</p>
        </div>
      </header>

      <input
        type="search"
        value={q}
        onChange={(e) => setQ(e.target.value)}
        placeholder="Buscar por nombre, oficio o zona…"
        aria-label="Buscar en el directorio"
        style={{ marginBottom: 8 }}
      />

      <div className="chips" role="group" aria-label="Filtrar por oficio">
        <button
          type="button"
          className={trade === 'todos' ? 'chip on' : 'chip'}
          aria-pressed={trade === 'todos'}
          onClick={() => setTrade('todos')}
        >
          Todos ({everyone.length})
        </button>
        {trades.map(([name, n]) => (
          <button
            key={name}
            type="button"
            className={trade === name ? 'chip on' : 'chip'}
            aria-pressed={trade === name}
            onClick={() => setTrade(trade === name ? 'todos' : name)}
          >
            {name} ({n})
          </button>
        ))}
        <button
          type="button"
          className={nowOnly ? 'chip on' : 'chip'}
          aria-pressed={nowOnly}
          onClick={() => setNowOnly((v) => !v)}
        >
          🟢 Disponible ahora
        </button>
      </div>

      {everyone.length === 0 && <div className="empty">Aún no hay vecinos registrados.</div>}
      {everyone.length > 0 && providers.length === 0 && (
        <div className="empty">Ningún vecino coincide. Prueba con otra palabra o quita un filtro.</div>
      )}

      {providers.map((p) => {
        const shown = p.offers.filter(
          (o) => (trade === 'todos' || o.trade === trade) && (!nowOnly || o.availableNow),
        );
        return (
          <article key={`${p.id}-${version}`} className="card">
            <div className="title-row" style={{ display: 'flex', justifyContent: 'space-between', gap: 8 }}>
              <h3>
                <span style={{ color: p.color }}>●</span> {p.name}
              </h3>
              <span className="badge">{p.level}</span>
            </div>
            {shown.length === 0 && (
              <p>{[p.category, p.latest].filter(Boolean).join(' · ') || 'Todavía no publica servicios'}</p>
            )}
            {shown.map((o) => (
              <div key={o.id} className="dir-trade">
                <strong>{o.trade}</strong>
                {o.description && <span> · {o.description}</span>}
                {o.schedule && <span style={{ color: 'var(--muted)' }}> · {o.schedule}</span>}
                <div className="meta" style={{ marginTop: 4 }}>
                  {o.availableNow && <span className="badge ok">🟢 Disponible ahora</span>}
                  {o.urgent && <span className="badge warn">🛠️ Atiende urgencias</span>}
                  <button type="button" className="btn small ghost" onClick={() => ask(o.trade)}>
                    Pedir este servicio
                  </button>
                </div>
              </div>
            ))}
            <div className="meta">
              <span className="badge warn">👍 {p.recommendations} vecinos</span>
              <span className="badge">{p.zone || 'zona aprox.'}</span>
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
            <ReportMenu userId={p.id} userName={p.name} entity="user" entityId={p.id} />
          </article>
        );
      })}
    </div>
  );
}
