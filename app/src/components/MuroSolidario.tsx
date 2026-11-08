import { useState, type FormEvent } from 'react';
import { createNeed, defaultPoint, listSolidary } from '../db/repo';
import { DIR_LABEL, SOLIDARY_CATEGORIES, withDirection, type Direction } from '../lib/solidarity';
import { useApp } from '../state/app';
import NeedCard from './NeedCard';

/**
 * Cadena de favores (día a día): resolver necesidades sin dinero. Se presta, se ayuda, se dona,
 * se intercambian habilidades y se comparte movilidad. Nadie pone precio: quien responde se ofrece
 * y el autor elige; después vienen el chat, el código de encuentro y la calificación.
 */
export default function MuroSolidario() {
  const { me, version, bump } = useApp();
  const [category, setCategory] = useState('todas');
  const [direction, setDirection] = useState<Direction | 'todas'>('todas');
  const [showForm, setShowForm] = useState(false);

  const [formDir, setFormDir] = useState<Direction>('necesito');
  const [formCat, setFormCat] = useState(SOLIDARY_CATEGORIES[0].name);
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');

  if (!me) return null;
  const viewer = defaultPoint();
  const all = listSolidary(viewer);
  const needs = listSolidary(viewer, { category, direction });
  const chosen = SOLIDARY_CATEGORIES.find((c) => c.name === formCat) ?? SOLIDARY_CATEGORIES[0];

  async function publish(event: FormEvent) {
    event.preventDefault();
    if (!title.trim()) return;
    await createNeed({
      authorId: me!.id,
      type: chosen.type,
      title: withDirection(formDir, title),
      category: chosen.name,
      description,
      zone: me!.zone || (import.meta.env.VITE_DEFAULT_ZONE ?? 'Los Olivos, Lima'),
      point: defaultPoint(),
    });
    setTitle('');
    setDescription('');
    setShowForm(false);
    setCategory('todas');
    setDirection('todas');
    bump();
  }

  return (
    <div>
      <section className="card">
        <h3>Cadena de favores · sin dinero</h3>
        <p>
          Aquí <strong>nadie paga</strong>: se presta, se ayuda, se dona o se intercambia. Quien ayuda gana confianza
          y sube de nivel en la red. Después de acordar siguen el chat, el código de encuentro y la calificación.
        </p>
      </section>

      {!showForm ? (
        <button type="button" className="btn block" onClick={() => setShowForm(true)}>
          🤝 Pedir u ofrecer sin dinero
        </button>
      ) : (
        <form className="panel" onSubmit={publish}>
          <h3 style={{ marginTop: 0 }}>Pedir u ofrecer sin dinero</h3>
          <div className="seg" role="group" aria-label="¿Pides u ofreces?" style={{ margin: '0 0 4px' }}>
            {(['necesito', 'ofrezco'] as Direction[]).map((d) => (
              <button
                key={d}
                type="button"
                className={formDir === d ? 'seg-btn on' : 'seg-btn'}
                aria-pressed={formDir === d}
                onClick={() => setFormDir(d)}
              >
                <strong>{d === 'necesito' ? '🔵 Necesito' : '🟢 Ofrezco'}</strong>
                <span>{d === 'necesito' ? 'Pido ayuda a mis vecinos' : 'Doy, presto o enseño'}</span>
              </button>
            ))}
          </div>
          <label htmlFor="s-cat">Qué tipo de favor</label>
          <select id="s-cat" value={formCat} onChange={(e) => setFormCat(e.target.value)}>
            {SOLIDARY_CATEGORIES.map((c) => (
              <option key={c.name} value={c.name}>
                {c.icon} {c.name}
              </option>
            ))}
          </select>
          <label htmlFor="s-title">Título</label>
          <input
            id="s-title"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            placeholder={chosen.example}
            maxLength={70}
          />
          <label htmlFor="s-desc">Detalles</label>
          <textarea
            id="s-desc"
            rows={3}
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            placeholder="Cuándo, dónde, por cuánto tiempo, qué esperas a cambio (si algo)…"
            maxLength={400}
          />
          <div className="meta">
            <span className="badge">Ubicación aproximada: se redondea al publicar</span>
          </div>
          <div className="row" style={{ display: 'flex', gap: 8, marginTop: 12 }}>
            <button type="button" className="btn ghost" onClick={() => setShowForm(false)}>
              Cancelar
            </button>
            <button type="submit" className="btn" disabled={!title.trim()}>
              Publicar
            </button>
          </div>
        </form>
      )}

      <div className="chips" role="group" aria-label="Tipo de favor" style={{ marginTop: 12 }}>
        <button
          type="button"
          className={category === 'todas' ? 'chip on' : 'chip'}
          aria-pressed={category === 'todas'}
          onClick={() => setCategory('todas')}
        >
          Todas ({all.length})
        </button>
        {SOLIDARY_CATEGORIES.map((c) => {
          const n = all.filter((need) => need.category === c.name).length;
          return (
            <button
              key={c.name}
              type="button"
              className={category === c.name ? 'chip on' : 'chip'}
              aria-pressed={category === c.name}
              onClick={() => setCategory(c.name)}
            >
              {c.icon} {c.name} ({n})
            </button>
          );
        })}
      </div>
      <div className="chips" role="group" aria-label="Pide u ofrece">
        {(['todas', 'necesito', 'ofrezco'] as const).map((d) => (
          <button
            key={d}
            type="button"
            className={direction === d ? 'chip on' : 'chip'}
            aria-pressed={direction === d}
            onClick={() => setDirection(d)}
          >
            {d === 'todas' ? 'Pido y ofrezco' : d === 'necesito' ? `🔵 ${DIR_LABEL[d]}` : `🟢 ${DIR_LABEL[d]}`}
          </button>
        ))}
      </div>

      {needs.length === 0 && (
        <div className="empty">Todavía no hay favores así. Sé el primero en pedir u ofrecer.</div>
      )}
      <div aria-label="Favores entre vecinos">
        {needs.map((need) => (
          <NeedCard key={`${need.id}-${version}`} need={need} />
        ))}
      </div>
    </div>
  );
}
