import { useState, type FormEvent } from 'react';
import { createNeed, defaultPoint, listEmergencyWall, listNeeds, listSolidary, listUrgentRequests } from '../db/repo';
import MuroSolidario from '../components/MuroSolidario';
import NeedCard from '../components/NeedCard';
import { showEmergencySection } from './Emergencia';
import { useApp } from '../state/app';
import { EMERGENCY_LABEL, NEED_LABEL, type NeedType } from '../types';

type Mode = 'todo' | 'sin_dinero';
/** Recuerda la vista al volver de ver una publicación. */
let lastMode: Mode = 'todo';

/** Borrador que deja otra pantalla (Vecinos → "Pedir este servicio") para abrir el formulario ya llenado. */
interface Draft {
  type: NeedType;
  title: string;
  category: string;
  description: string;
}
let pendingDraft: Draft | null = null;
export function startNeedDraft(draft: Draft): void {
  pendingDraft = draft;
  lastMode = 'todo';
}

export default function Inicio() {
  const { me, version, bump, setTab } = useApp();
  const [q, setQ] = useState('');
  const [type, setType] = useState<NeedType | 'todos'>('todos');
  const [draft] = useState<Draft | null>(() => {
    const taken = pendingDraft;
    pendingDraft = null;
    return taken;
  });
  const [showForm, setShowForm] = useState(draft !== null);
  const [mode, setModeState] = useState<Mode>(lastMode);
  const setMode = (next: Mode) => {
    lastMode = next;
    setModeState(next);
  };

  const [formType, setFormType] = useState<NeedType>(draft?.type ?? 'servicio');
  const [title, setTitle] = useState(draft?.title ?? '');
  const [category, setCategory] = useState(draft?.category ?? '');
  const [description, setDescription] = useState(draft?.description ?? '');
  const [zone, setZone] = useState('');

  if (!me) return null;

  const needs = listNeeds(defaultPoint(), { q, type });
  const solidaryCount = listSolidary(defaultPoint()).length;
  const alerts = listEmergencyWall(me.id, defaultPoint());
  const urgentForMe = listUrgentRequests(me.id, defaultPoint()).filter((r) => r.matchesMe);

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
        {mode === 'todo' && (
          <div className="actions">
            <button type="button" className="btn" onClick={() => setShowForm((v) => !v)}>
              {showForm ? 'Cerrar' : '+ Pedir / Ofrecer'}
            </button>
          </div>
        )}
      </header>

      {alerts.length > 0 ? (
        <button
          type="button"
          className="alert-banner"
          onClick={() => {
            showEmergencySection('alertas');
            setTab('emergencia');
          }}
          role="alert"
        >
          <span>
            {alerts[0].kind === 'seguridad' ? '⚠️' : '🚨'} <strong>{EMERGENCY_LABEL[alerts[0].kind]}</strong> cerca · {alerts[0].zone || 'tu barrio'}
            {alerts.length > 1 && ` (+${alerts.length - 1} más)`}
          </span>
          <span aria-hidden="true">Ver ›</span>
        </button>
      ) : (
        urgentForMe.length > 0 && (
          <button
            type="button"
            className="alert-banner"
            onClick={() => {
              showEmergencySection('servicios');
              setTab('emergencia');
            }}
            role="alert"
          >
            <span>
              🛠️ <strong>Pedido urgente de {urgentForMe[0].need.category}</strong> cerca de ti
              {urgentForMe.length > 1 && ` (+${urgentForMe.length - 1} más)`}
            </span>
            <span aria-hidden="true">Ver ›</span>
          </button>
        )
      )}

      <div className="seg" role="group" aria-label="Vista del muro" style={{ marginTop: 0 }}>
        <button
          type="button"
          className={mode === 'todo' ? 'seg-btn on' : 'seg-btn'}
          aria-pressed={mode === 'todo'}
          onClick={() => setMode('todo')}
        >
          <strong>🏘️ Todo el barrio</strong>
          <span>Pedidos y ofertas</span>
        </button>
        <button
          type="button"
          className={mode === 'sin_dinero' ? 'seg-btn on' : 'seg-btn'}
          aria-pressed={mode === 'sin_dinero'}
          onClick={() => setMode('sin_dinero')}
        >
          <strong>🤝 Sin dinero{solidaryCount > 0 ? ` (${solidaryCount})` : ''}</strong>
          <span>Prestar, donar, intercambiar</span>
        </button>
      </div>

      {mode === 'sin_dinero' && <MuroSolidario />}

      {mode === 'todo' && showForm && (
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

      {mode === 'todo' && (
        <>
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
        <NeedCard key={`${need.id}-${version}`} need={need} />
      ))}
        </>
      )}
    </div>
  );
}
