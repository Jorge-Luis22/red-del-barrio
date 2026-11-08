import { useState, type FormEvent } from 'react';
import { createNeed, defaultPoint, listNeeds } from '../db/repo';
import { useApp } from '../state/app';
import { NEED_LABEL, type NeedType } from '../types';

export default function Inicio() {
  const { me, version, bump, go } = useApp();
  const [q, setQ] = useState('');
  const [type, setType] = useState<NeedType | 'todos'>('todos');
  const [showForm, setShowForm] = useState(false);

  const [formType, setFormType] = useState<NeedType>('servicio');
  const [title, setTitle] = useState('');
  const [category, setCategory] = useState('');
  const [description, setDescription] = useState('');
  const [zone, setZone] = useState('');

  if (!me) return null;

  const needs = listNeeds(defaultPoint(), { q, type });

  async function publish(event: FormEvent) {
    event.preventDefault();
    if (!title.trim()) return;
    await createNeed({
      authorId: me!.id,
      type: formType,
      title,
      category: category.trim() || 'Otros',
      description,
      zone: zone.trim() || me!.zone || (import.meta.env.VITE_DEFAULT_ZONE ?? 'Los Olivos, Lima'),
      point: defaultPoint(),
    });
    setTitle('');
    setCategory('');
    setDescription('');
    setZone('');
    setShowForm(false);
    bump();
  }

  return (
    <div>
      <header className="page-head">
        <div>
          <h1>Red del barrio</h1>
          <p className="sub">
            {me.name} · {me.zone}
          </p>
        </div>
        <div className="actions">
          <button type="button" className="btn" onClick={() => setShowForm((v) => !v)}>
            {showForm ? 'Cerrar' : '+ Pedir / Ofrecer'}
          </button>
        </div>
      </header>

      {showForm && (
        <form className="panel" onSubmit={publish}>
          <label htmlFor="type">Tipo</label>
          <select id="type" value={formType} onChange={(e) => setFormType(e.target.value as NeedType)}>
            {Object.entries(NEED_LABEL).map(([value, label]) => (
              <option key={value} value={value}>
                {label}
              </option>
            ))}
          </select>
          <label htmlFor="title">Título</label>
          <input
            id="title"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            placeholder="¿Qué necesitas u ofreces?"
            maxLength={80}
          />
          <label htmlFor="category">Categoría</label>
          <input
            id="category"
            value={category}
            onChange={(e) => setCategory(e.target.value)}
            placeholder="Gasfitería, Comida, Cuidado…"
            maxLength={40}
          />
          <label htmlFor="description">Descripción</label>
          <textarea
            id="description"
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            rows={3}
            placeholder="Detalles, horario, qué ofreces a cambio…"
            maxLength={400}
          />
          <label htmlFor="zone">Zona</label>
          <input
            id="zone"
            value={zone}
            onChange={(e) => setZone(e.target.value)}
            placeholder={me.zone || 'Los Olivos, Lima'}
            maxLength={60}
          />
          <div className="meta">
            <span className="badge">Ubicación aproximada: se redondea al publicar</span>
          </div>
          <p>
            <button type="submit" className="btn block" disabled={!title.trim()}>
              Publicar
            </button>
          </p>
        </form>
      )}

      <div className="row-filters" style={{ display: 'flex', gap: 8, marginBottom: 12 }}>
        <input
          value={q}
          onChange={(e) => setQ(e.target.value)}
          placeholder="Buscar en el barrio…"
          aria-label="Buscar"
          style={{ flex: 2 }}
        />
        <select
          value={type}
          onChange={(e) => setType(e.target.value as NeedType | 'todos')}
          aria-label="Filtrar por tipo"
          style={{ flex: 1 }}
        >
          <option value="todos">Todos</option>
          {Object.entries(NEED_LABEL).map(([value, label]) => (
            <option key={value} value={value}>
              {label}
            </option>
          ))}
        </select>
      </div>

      {needs.length === 0 && <div className="empty">No hay publicaciones que coincidan.</div>}

      {needs.map((need) => (
        <article
          key={`${need.id}-${version}`}
          className="card need-card"
          onClick={() => go({ name: 'need', id: need.id })}
        >
          <div className="title-row">
            <h3>{need.title}</h3>
            <span className="badge">{NEED_LABEL[need.type]}</span>
          </div>
          <p>{need.description || need.category}</p>
          <div className="meta">
            <span className="badge">{need.category}</span>
            {need.isEmergency && <span className="badge danger">Emergencia</span>}
            <span style={{ fontSize: '0.75rem', color: 'var(--muted)' }}>
              {need.authorName}
              {need.distanceKm !== null && ` · a ${need.distanceKm.toFixed(1)} km`}
              {need.recommendations > 0 && ` · 👍 ${need.recommendations}`}
            </span>
          </div>
        </article>
      ))}
    </div>
  );
}
