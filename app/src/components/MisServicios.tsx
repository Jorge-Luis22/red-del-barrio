import { useState, type FormEvent } from 'react';
import { listMyServices, removeService, saveService, updateService } from '../db/repo';
import { useApp } from '../state/app';
import { TRADES } from '../types';

const CHECK = { width: 'auto', margin: 0 } as const;

/** Perfil → lo que el vecino sabe hacer. Con "Atiendo urgencias" aparece en Emergencia → Servicios de urgencia. */
export default function MisServicios() {
  const { me, version, bump } = useApp();
  const [adding, setAdding] = useState(false);
  const [trade, setTrade] = useState<string>(TRADES[0]);
  const [description, setDescription] = useState('');
  const [schedule, setSchedule] = useState('');
  const [urgent, setUrgent] = useState(true);
  const [availableNow, setAvailableNow] = useState(false);

  if (!me) return null;
  const services = listMyServices(me.id);

  async function add(event: FormEvent) {
    event.preventDefault();
    await saveService({ providerId: me!.id, trade, description, urgent, availableNow, schedule });
    setDescription('');
    setSchedule('');
    setAdding(false);
    bump();
  }

  return (
    <section className="card">
      <h3>Mis servicios</h3>
      <p>
        Lo que sabes hacer. Si marcas <strong>Atiendo urgencias</strong>, apareces en Emergencia → Servicios de
        urgencia y te avisamos cuando un vecino pida tu oficio. No publicas precio: lo propones cuando te piden.
      </p>

      {services.length === 0 && <p style={{ color: 'var(--muted)' }}>Todavía no ofreces ningún servicio.</p>}

      {services.map((s) => (
        <div key={`${s.id}-${version}`} style={{ borderTop: '1px solid var(--line, #e3e8e8)', padding: '8px 0' }}>
          <strong>{s.trade}</strong>
          {s.description && <span> · {s.description}</span>}
          {s.schedule && <span style={{ color: 'var(--muted)' }}> · {s.schedule}</span>}
          <div className="meta" style={{ marginTop: 6 }}>
            <label style={{ display: 'inline-flex', gap: 6, alignItems: 'center' }}>
              <input
                type="checkbox"
                style={CHECK}
                checked={s.urgent}
                onChange={(e) => {
                  // La escritura local es inmediata; guardar en disco sigue en segundo plano.
                  void updateService(s.id, { urgent: e.target.checked });
                  bump();
                }}
              />
              Atiendo urgencias
            </label>
            <label style={{ display: 'inline-flex', gap: 6, alignItems: 'center' }}>
              <input
                type="checkbox"
                style={CHECK}
                checked={s.availableNow}
                onChange={(e) => {
                  void updateService(s.id, { availableNow: e.target.checked });
                  bump();
                }}
              />
              Disponible ahora
            </label>
            <button
              type="button"
              className="btn small ghost"
              onClick={() => {
                void removeService(s.id);
                bump();
              }}
            >
              Quitar
            </button>
          </div>
        </div>
      ))}

      {!adding ? (
        <button type="button" className="btn small" style={{ marginTop: 8 }} onClick={() => setAdding(true)}>
          + Agregar un servicio
        </button>
      ) : (
        <form onSubmit={add} style={{ marginTop: 8 }}>
          <label htmlFor="s-trade">Oficio</label>
          <select id="s-trade" value={trade} onChange={(e) => setTrade(e.target.value)}>
            {TRADES.map((t) => (
              <option key={t} value={t}>
                {t}
              </option>
            ))}
          </select>
          <label htmlFor="s-desc">Qué haces</label>
          <input
            id="s-desc"
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            placeholder="Ej.: Fugas, cañerías y termas"
            maxLength={120}
          />
          <label htmlFor="s-sched">Horario</label>
          <input
            id="s-sched"
            value={schedule}
            onChange={(e) => setSchedule(e.target.value)}
            placeholder="Ej.: 24 horas · hasta las 10 p. m."
            maxLength={40}
          />
          <label style={{ display: 'flex', gap: 6, alignItems: 'center', marginTop: 8 }}>
            <input type="checkbox" style={CHECK} checked={urgent} onChange={(e) => setUrgent(e.target.checked)} />
            Atiendo urgencias
          </label>
          <label style={{ display: 'flex', gap: 6, alignItems: 'center' }}>
            <input type="checkbox" style={CHECK} checked={availableNow} onChange={(e) => setAvailableNow(e.target.checked)} />
            Disponible ahora
          </label>
          <div className="row" style={{ display: 'flex', gap: 8, marginTop: 10 }}>
            <button type="button" className="btn ghost" onClick={() => setAdding(false)}>
              Cancelar
            </button>
            <button type="submit" className="btn">
              Guardar servicio
            </button>
          </div>
        </form>
      )}
    </section>
  );
}
