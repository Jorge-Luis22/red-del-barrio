import { useState, type FormEvent } from 'react';
import {
  activeEmergency,
  closeEmergency,
  createEmergency,
  defaultPoint,
  markInstitutionCalled,
} from '../db/repo';
import { useApp } from '../state/app';
import { EMERGENCY_LABEL, type EmergencyKind } from '../types';

const NUMBERS = [
  { name: 'PNP (Policía)', number: '105' },
  { name: 'Bomberos', number: '116' },
  { name: 'SAMU (ambulancias)', number: '106' },
];

export default function Emergencia() {
  const { me, version, bump } = useApp();
  const [showForm, setShowForm] = useState(false);
  const [kind, setKind] = useState<EmergencyKind>('medico');
  const [description, setDescription] = useState('');
  const [zone, setZone] = useState('');

  if (!me) return null;

  const active = activeEmergency(me.id);

  async function create(event: FormEvent) {
    event.preventDefault();
    if (!description.trim()) return;
    await createEmergency({
      authorId: me!.id,
      kind,
      description,
      zone: zone.trim() || me!.zone,
      point: defaultPoint(),
    });
    setDescription('');
    setZone('');
    setShowForm(false);
    bump();
  }

  return (
    <div>
      <header className="page-head">
        <div>
          <h1>Emergencia</h1>
          <p className="sub">La institución oficial siempre va primero</p>
        </div>
      </header>

      <section className="card">
        <h3>Llamar primero</h3>
        <div className="meta">
          {NUMBERS.map((n) => (
            <a key={n.number} href={`tel:${n.number}`} className="badge" style={{ textDecoration: 'none' }}>
              {n.name}: {n.number}
            </a>
          ))}
        </div>
      </section>

      {active && (
        <section className="card" key={`${active.id}-${version}`} style={{ borderLeft: '4px solid var(--danger)' }}>
          <div className="title-row" style={{ display: 'flex', justifyContent: 'space-between', gap: 8 }}>
            <h3>Tu alerta activa</h3>
            <span className="badge danger">{EMERGENCY_LABEL[active.kind]}</span>
          </div>
          <p>{active.description}</p>
          <div className="meta">
            {active.kind === 'violencia' && (
              <span className="badge danger">Privado: no aparece en el muro público</span>
            )}
            <span className="badge warn">
              {active.institutionCalled ? '✓ Institución avisada' : 'Institución aún no avisada'}
            </span>
          </div>
          <div className="row" style={{ display: 'flex', gap: 8, marginTop: 10 }}>
            {!active.institutionCalled && (
              <button
                type="button"
                className="btn small"
                onClick={async () => {
                  await markInstitutionCalled(active.id);
                  bump();
                }}
              >
                Marcar institución avisada
              </button>
            )}
            <button
              type="button"
              className="btn small ghost"
              onClick={async () => {
                await closeEmergency(active.id);
                bump();
              }}
            >
              Cerrar alerta (atendida)
            </button>
          </div>
        </section>
      )}

      {!active && !showForm && (
        <button type="button" className="btn block danger" onClick={() => setShowForm(true)}>
          🚨 Activar alerta vecinal
        </button>
      )}

      {!active && showForm && (
        <form className="panel" onSubmit={create}>
          <h3 style={{ marginTop: 0 }}>Nueva alerta</h3>
          <label htmlFor="kind">Tipo</label>
          <select id="kind" value={kind} onChange={(e) => setKind(e.target.value as EmergencyKind)}>
            {Object.entries(EMERGENCY_LABEL).map(([value, label]) => (
              <option key={value} value={value}>
                {label}
              </option>
            ))}
          </select>
          <label htmlFor="desc">Descripción</label>
          <textarea
            id="desc"
            rows={3}
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            placeholder="Qué pasa, dónde, qué se necesita…"
            maxLength={300}
          />
          <label htmlFor="zone">Zona</label>
          <input id="zone" value={zone} onChange={(e) => setZone(e.target.value)} placeholder={me.zone} maxLength={60} />
          {kind === 'violencia' && (
            <p className="badge danger" style={{ marginTop: 8 }}>
              Caso sensible: se comparte solo con personas de confianza, no en el muro.
            </p>
          )}
          <div className="row" style={{ display: 'flex', gap: 8, marginTop: 12 }}>
            <button type="button" className="btn ghost" onClick={() => setShowForm(false)}>
              Cancelar
            </button>
            <button type="submit" className="btn danger" disabled={!description.trim()}>
              Activar alerta
            </button>
          </div>
        </form>
      )}
    </div>
  );
}
