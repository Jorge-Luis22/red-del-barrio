import { useState, type FormEvent } from 'react';
import {
  activeEmergency,
  closeEmergency,
  countUrgentForMe,
  createEmergency,
  defaultPoint,
  helpersOf,
  listEmergencyWall,
  markInstitutionCalled,
  offerHelp,
  withdrawHelp,
} from '../db/repo';
import ServiciosUrgencia from '../components/ServiciosUrgencia';
import { formatDistance } from '../lib/geo';
import { ago } from '../lib/time';
import { useApp } from '../state/app';
import { EMERGENCY_LABEL, type EmergencyKind } from '../types';

type Section = 'alertas' | 'servicios';
/** Recuerda la pestaña al volver de ver un pedido; también permite abrirla desde el aviso de Inicio. */
let lastSection: Section = 'alertas';
export function showEmergencySection(section: Section): void {
  lastSection = section;
}

const NUMBERS = [
  { name: 'PNP (Policía)', number: '105' },
  { name: 'Bomberos', number: '116' },
  { name: 'SAMU (ambulancias)', number: '106' },
];

export default function Emergencia() {
  const { me, version, bump } = useApp();
  const [section, setSectionState] = useState<Section>(lastSection);
  const setSection = (next: Section) => {
    lastSection = next;
    setSectionState(next);
  };
  const [showForm, setShowForm] = useState(false);
  const [kind, setKind] = useState<EmergencyKind>('medico');
  const [description, setDescription] = useState('');
  const [zone, setZone] = useState('');

  if (!me) return null;

  const active = activeEmergency(me.id);
  const wall = listEmergencyWall(me.id, defaultPoint());
  const myHelpers = active ? helpersOf(active.id) : [];
  const forMe = countUrgentForMe(me.id);

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

      <div className="seg" role="group" aria-label="Tipo de ayuda">
        <button
          type="button"
          className={section === 'alertas' ? 'seg-btn on' : 'seg-btn'}
          aria-pressed={section === 'alertas'}
          onClick={() => setSection('alertas')}
        >
          <strong>🚨 Alertas vecinales{wall.length > 0 ? ` (${wall.length})` : ''}</strong>
          <span>Ayuda solidaria · sin costo</span>
        </button>
        <button
          type="button"
          className={section === 'servicios' ? 'seg-btn on' : 'seg-btn'}
          aria-pressed={section === 'servicios'}
          onClick={() => setSection('servicios')}
        >
          <strong>🛠️ Servicios de urgencia{forMe > 0 ? ` (${forMe})` : ''}</strong>
          <span>Vecinos que cobran por atender</span>
        </button>
      </div>

      {section === 'servicios' && <ServiciosUrgencia />}

      {section === 'alertas' && (
        <>
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
          {active.kind !== 'violencia' && (
            <div style={{ marginTop: 10 }} aria-live="polite">
              <strong style={{ fontSize: '0.85rem' }}>
                {myHelpers.length === 0
                  ? 'Esperando vecinos que puedan ayudar…'
                  : `${myHelpers.length} ${myHelpers.length === 1 ? 'vecino puede' : 'vecinos pueden'} ayudar`}
              </strong>
              {myHelpers.map((h) => (
                <p key={h.id} style={{ margin: '2px 0' }}>
                  🙋 {h.name} · {h.zone}
                </p>
              ))}
              <p style={{ fontSize: '0.75rem' }}>
                Tus vecinos ven solo la zona aproximada (~1 km). Tu ubicación exacta no sale de tu teléfono: si
                quieres que te encuentren, di una referencia en la descripción.
              </p>
            </div>
          )}
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

      <section aria-label="Alertas de tus vecinos" style={{ marginTop: 18 }}>
        <h2 style={{ fontSize: '1.05rem', margin: '0 0 8px' }}>Alertas de tus vecinos · ayuda solidaria</h2>
        {wall.length === 0 && (
          <div className="empty">
            No hay alertas activas cerca. Si alguien pide ayuda, aparecerá aquí.
          </div>
        )}
        {wall.map((alert) => (
          <article
            key={`${alert.id}-${version}`}
            className="card"
            style={{ borderLeft: '4px solid var(--danger)' }}
          >
            <div style={{ display: 'flex', justifyContent: 'space-between', gap: 8 }}>
              <h3>{EMERGENCY_LABEL[alert.kind]}</h3>
              <span className="badge danger">{ago(alert.createdAt)}</span>
            </div>
            <p style={{ color: 'var(--text)' }}>{alert.description}</p>
            <div className="meta">
              <span className="badge">
                {alert.authorName} · {alert.zone || 'zona aprox.'}
                {alert.distanceKm !== null && ` · ~${formatDistance(alert.distanceKm)}`}
              </span>
              <span className="badge warn">
                {alert.institutionCalled ? '✓ Institución avisada' : 'Institución aún no avisada'}
              </span>
              {alert.helpers.length > 0 && (
                <span className="badge">
                  🙋 {alert.helpers.length} {alert.helpers.length === 1 ? 'vecino ayuda' : 'vecinos ayudan'}
                </span>
              )}
            </div>
            <div className="row" style={{ display: 'flex', gap: 8, marginTop: 10 }}>
              {alert.iOffered ? (
                <>
                  <span className="badge" style={{ alignSelf: 'center' }}>
                    ✓ Avisaste que ayudas
                  </span>
                  <button
                    type="button"
                    className="btn small ghost"
                    onClick={async () => {
                      await withdrawHelp(alert.id, me.id);
                      bump();
                    }}
                  >
                    Ya no puedo
                  </button>
                </>
              ) : (
                <button
                  type="button"
                  className="btn small"
                  onClick={async () => {
                    await offerHelp(alert.id, me.id);
                    bump();
                  }}
                >
                  🙋 Puedo ayudar
                </button>
              )}
            </div>
            <p style={{ fontSize: '0.75rem' }}>
              La institución oficial va primero: si no hay nadie en camino, llama arriba antes de ir. Solo ves la
              zona aproximada.
            </p>
          </article>
        ))}
      </section>
        </>
      )}
    </div>
  );
}
