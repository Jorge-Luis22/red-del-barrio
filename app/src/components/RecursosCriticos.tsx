import { useState, type FormEvent } from 'react';
import { closeNeed, createNeed, defaultPoint, listResourcePosts } from '../db/repo';
import { formatDistance } from '../lib/geo';
import {
  CRITICAL_RESOURCES,
  DIR_LABEL,
  resourceCategory,
  resourceIcon,
  withDirection,
  type Direction,
} from '../lib/solidarity';
import { ago } from '../lib/time';
import { useApp } from '../state/app';

/**
 * Red de solidaridad en emergencia: coordinar y compartir recursos críticos (agua, alimentos, abrigo,
 * medicinas, energía, transporte). Sin dinero. Quien necesita publica "Necesito"; quien tiene publica
 * "Ofrezco"; la app avisa cuando una necesidad y un ofrecimiento coinciden y deja coordinar por chat.
 */
export default function RecursosCriticos() {
  const { me, version, bump, go } = useApp();
  const [resourceFilter, setResourceFilter] = useState('todos');
  const [dirFilter, setDirFilter] = useState<Direction | 'todas'>('todas');
  const [showForm, setShowForm] = useState(false);
  const [dir, setDir] = useState<Direction>('necesito');
  const [resource, setResource] = useState<string>(CRITICAL_RESOURCES[0].name);
  const [detail, setDetail] = useState('');
  const [sent, setSent] = useState<string | null>(null);

  if (!me) return null;
  const viewer = defaultPoint();
  const everything = listResourcePosts(me.id, viewer);
  const posts = listResourcePosts(me.id, viewer, { resource: resourceFilter, direction: dirFilter });
  const chosen = CRITICAL_RESOURCES.find((r) => r.name === resource) ?? CRITICAL_RESOURCES[0];
  const needCount = everything.filter((p) => p.direction === 'necesito').length;
  const offerCount = everything.length - needCount;

  async function publish(event: FormEvent) {
    event.preventDefault();
    if (!detail.trim()) return;
    await createNeed({
      authorId: me!.id,
      type: chosen.type,
      title: withDirection(dir, chosen.name),
      category: resourceCategory(chosen.name),
      description: detail,
      zone: me!.zone,
      point: defaultPoint(),
      isEmergency: true,
    });
    setDetail('');
    setShowForm(false);
    setSent(`${DIR_LABEL[dir]}: ${chosen.name}`);
    bump();
  }

  return (
    <div>
      <section className="card">
        <h3>Recursos críticos · economía solidaria</h3>
        <p>
          Coordina con tus vecinos lo que más falta en una emergencia: agua, alimentos, abrigo, medicinas, linternas y
          transporte. <strong>Sin dinero</strong>: unos publican lo que necesitan, otros lo que pueden dar, y la app
          avisa cuando coinciden.
        </p>
        <div className="meta">
          <span className="badge warn">🔵 {needCount} {needCount === 1 ? 'necesidad' : 'necesidades'}</span>
          <span className="badge ok">🟢 {offerCount} {offerCount === 1 ? 'ofrecimiento' : 'ofrecimientos'}</span>
          <span className="badge">Zona aproximada ~1 km</span>
        </div>
      </section>

      {sent && (
        <div className="card" role="status" style={{ borderLeft: '4px solid var(--accent)' }}>
          <strong>Publicado:</strong> {sent}. Tus vecinos lo verán aquí; cuando alguien responda, lo verás en tu
          publicación.
        </div>
      )}

      {!showForm ? (
        <button type="button" className="btn block" onClick={() => setShowForm(true)}>
          📦 Publicar un recurso (necesito / ofrezco)
        </button>
      ) : (
        <form className="panel" onSubmit={publish}>
          <h3 style={{ marginTop: 0 }}>Publicar un recurso</h3>
          <div className="seg" role="group" aria-label="¿Necesitas u ofreces?" style={{ margin: '0 0 4px' }}>
            {(['necesito', 'ofrezco'] as Direction[]).map((d) => (
              <button
                key={d}
                type="button"
                className={dir === d ? 'seg-btn on' : 'seg-btn'}
                aria-pressed={dir === d}
                onClick={() => setDir(d)}
              >
                <strong>{d === 'necesito' ? '🔵 Necesito' : '🟢 Ofrezco'}</strong>
                <span>{d === 'necesito' ? 'Me falta este recurso' : 'Tengo y puedo compartir'}</span>
              </button>
            ))}
          </div>
          <label htmlFor="r-res">Recurso</label>
          <select id="r-res" value={resource} onChange={(e) => setResource(e.target.value)}>
            {CRITICAL_RESOURCES.map((r) => (
              <option key={r.name} value={r.name}>
                {r.icon} {r.name}
              </option>
            ))}
          </select>
          <label htmlFor="r-detail">Cantidad y detalle</label>
          <textarea
            id="r-detail"
            rows={3}
            value={detail}
            onChange={(e) => setDetail(e.target.value)}
            placeholder={chosen.example}
            maxLength={300}
          />
          <p style={{ fontSize: '0.75rem' }}>
            Tus vecinos ven solo tu zona aproximada (~1 km). La dirección exacta se la das a quien elijas, por el chat.
          </p>
          <div className="row" style={{ display: 'flex', gap: 8, marginTop: 8 }}>
            <button type="button" className="btn ghost" onClick={() => setShowForm(false)}>
              Cancelar
            </button>
            <button type="submit" className="btn danger" disabled={!detail.trim()}>
              Publicar
            </button>
          </div>
        </form>
      )}

      <div style={{ display: 'flex', gap: 8, margin: '12px 0 8px' }}>
        <select
          aria-label="Filtrar por recurso"
          value={resourceFilter}
          onChange={(e) => setResourceFilter(e.target.value)}
          style={{ flex: 2 }}
        >
          <option value="todos">Todos los recursos</option>
          {CRITICAL_RESOURCES.map((r) => (
            <option key={r.name} value={r.name}>
              {r.icon} {r.name}
            </option>
          ))}
        </select>
        <select
          aria-label="Filtrar por necesito u ofrezco"
          value={dirFilter}
          onChange={(e) => setDirFilter(e.target.value as Direction | 'todas')}
          style={{ flex: 1 }}
        >
          <option value="todas">Todo</option>
          <option value="necesito">Necesitan</option>
          <option value="ofrezco">Ofrecen</option>
        </select>
      </div>

      <section aria-label="Recursos de tus vecinos">
        {posts.length === 0 && (
          <div className="empty">Todavía no hay publicaciones de este tipo. Publica lo que necesitas o puedes dar.</div>
        )}
        {posts.map(({ need, direction, resource: name, proposals, mine, matches }) => (
          <article
            key={`${need.id}-${version}`}
            className="card"
            style={{ borderLeft: `4px solid ${direction === 'necesito' ? 'var(--danger)' : 'var(--teal)'}` }}
          >
            <div style={{ display: 'flex', justifyContent: 'space-between', gap: 8 }}>
              <h3>
                {resourceIcon(need.category)} {need.title}
              </h3>
              <span className="badge">{ago(need.createdAt)}</span>
            </div>
            <p style={{ color: 'var(--text)' }}>{need.description}</p>
            <div className="meta">
              <span className={direction === 'ofrezco' ? 'badge ok' : 'badge warn'}>
                {direction === 'ofrezco' ? '🟢 Ofrece' : '🔵 Necesita'}
              </span>
              <span className="badge">
                {mine ? 'Tú' : need.authorName} · {need.zone || 'zona aprox.'}
                {!mine && need.distanceKm !== null && ` · ~${formatDistance(need.distanceKm)}`}
              </span>
              {need.status === 'en_curso' && <span className="badge ok">En curso · sigue en Mensajes</span>}
              {proposals > 0 && (
                <span className="badge">
                  {proposals} {direction === 'ofrezco' ? (proposals === 1 ? 'interesado' : 'interesados') : proposals === 1 ? 'respuesta' : 'respuestas'}
                </span>
              )}
              {matches > 0 && (
                <span className="badge warn">
                  💡 {matches} {direction === 'necesito' ? (matches === 1 ? 'vecino ofrece' : 'vecinos ofrecen') : matches === 1 ? 'vecino necesita' : 'vecinos necesitan'}{' '}
                  {name.toLowerCase()}
                </span>
              )}
            </div>
            <div className="row" style={{ display: 'flex', gap: 8, marginTop: 10 }}>
              {mine ? (
                <>
                  <button type="button" className="btn small" onClick={() => go({ name: 'need', id: need.id })}>
                    Ver respuestas
                  </button>
                  <button
                    type="button"
                    className="btn small ghost"
                    onClick={async () => {
                      await closeNeed(need.id);
                      bump();
                    }}
                  >
                    ✓ Ya está cubierto
                  </button>
                </>
              ) : (
                <button type="button" className="btn small" onClick={() => go({ name: 'need', id: need.id })}>
                  {direction === 'ofrezco' ? '🙋 Lo necesito' : '🙋 Puedo ayudar'}
                </button>
              )}
            </div>
          </article>
        ))}
      </section>
    </div>
  );
}
