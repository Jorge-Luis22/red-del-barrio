import { useCallback, useEffect, useState } from 'react';
import { defaultPoint, listEmergencyWall, listNeeds, listSolidary, listUrgentRequests } from '../db/repo';
import MuroSolidario from '../components/MuroSolidario';
import NeedCard from '../components/NeedCard';
import PublishSheet, { type PublishRequest } from '../components/PublishSheet';
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
  // Desde el Directorio ("Pedir este servicio") la hoja se abre ya en el último paso.
  const [sheet, setSheet] = useState<PublishRequest | null>(
    draft ? { dir: 'necesito', category: draft.category, detail: draft.description } : null,
  );
  const [done, setDone] = useState('');
  const [mode, setModeState] = useState<Mode>(lastMode);
  const setMode = (next: Mode) => {
    lastMode = next;
    setModeState(next);
  };
  const closeSheet = useCallback(() => setSheet(null), []);

  // El aviso "Listo" desaparece solo.
  useEffect(() => {
    if (!done) return;
    const timer = window.setTimeout(() => setDone(''), 7000);
    return () => window.clearTimeout(timer);
  }, [done]);

  if (!me) return null;

  const needs = listNeeds(defaultPoint(), { q, type });
  const solidaryCount = listSolidary(defaultPoint()).length;
  const alerts = listEmergencyWall(me.id, defaultPoint());
  const urgentForMe = listUrgentRequests(me.id, defaultPoint()).filter((r) => r.matchesMe);

  return (
    <div>
      <header className="page-head">
        <div>
          <h1>Red del barrio</h1>
          <p className="sub">
            {me.name} · {me.zone}
          </p>
        </div>
      </header>

      {mode === 'todo' && (
        <div className="pub-bar" role="group" aria-label="Publicar">
          <button type="button" className="pub-btn need" data-pub="necesito" onClick={() => setSheet({ dir: 'necesito' })}>
            <span className="ico" aria-hidden="true">
              🙋
            </span>
            <strong>Necesito</strong>
            <span className="sub">Pido ayuda a un vecino</span>
          </button>
          <button type="button" className="pub-btn offer" data-pub="ofrezco" onClick={() => setSheet({ dir: 'ofrezco' })}>
            <span className="ico" aria-hidden="true">
              🤝
            </span>
            <strong>Ofrezco</strong>
            <span className="sub">Mi servicio al barrio</span>
          </button>
        </div>
      )}

      {done && (
        <p className="toast-ok" role="status">
          ✅ {done}
        </p>
      )}

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

      {mode === 'todo' && (
        <>
      <input
        value={q}
        onChange={(e) => setQ(e.target.value)}
        placeholder="Buscar en el barrio…"
        aria-label="Buscar"
        style={{ marginBottom: 8 }}
      />
      <div className="chips" role="group" aria-label="Filtrar por tipo">
        <button
          type="button"
          className={type === 'todos' ? 'chip on' : 'chip'}
          aria-pressed={type === 'todos'}
          onClick={() => setType('todos')}
        >
          Todo
        </button>
        {Object.entries(NEED_LABEL).map(([value, label]) => (
          <button
            key={value}
            type="button"
            className={type === value ? 'chip on' : 'chip'}
            aria-pressed={type === value}
            onClick={() => setType(type === value ? 'todos' : (value as NeedType))}
          >
            {label}
          </button>
        ))}
      </div>

      {needs.length === 0 && <div className="empty">No hay publicaciones que coincidan.</div>}

      {needs.map((need) => (
        <NeedCard key={`${need.id}-${version}`} need={need} />
      ))}
        </>
      )}

      {sheet && (
        <PublishSheet
          request={sheet}
          onClose={closeSheet}
          onDone={(message) => {
            setSheet(null);
            setDone(message);
            bump();
          }}
        />
      )}
    </div>
  );
}
