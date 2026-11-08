import { useMemo, useState } from 'react';
import {
  activeEmergency,
  closeEmergency,
  createEmergency,
  listProviders,
  markInstitutionCalled,
} from '../db/repo';
import { formatDistance } from '../lib/geo';
import { timeAgo } from '../lib/format';
import { EMERGENCY_LABEL, type EmergencyKind } from '../types';
import { useStore } from '../state/store';
import { Icon } from '../ui/Icon';

const KINDS: EmergencyKind[] = ['sismo', 'incendio', 'medico', 'persona_mayor', 'violencia'];

const INSTITUTIONS = [
  { name: 'Bomberos', number: '116' },
  { name: 'SAMU / ambulancia', number: '106' },
  { name: 'Policía Nacional', number: '105' },
  { name: 'Línea 100 (violencia)', number: '100' },
];

export function Emergencia() {
  const { session, revision, bump } = useStore();
  const alert = useMemo(() => activeEmergency(session.userId), [session.userId, revision]);
  const providers = useMemo(
    () => listProviders(session.userId, { lat: session.lat, lng: session.lng }).slice(0, 4),
    [revision, session.userId, session.lat, session.lng],
  );

  const [kind, setKind] = useState<EmergencyKind | null>(null);
  const [description, setDescription] = useState('');
  const [busy, setBusy] = useState(false);

  const activate = async () => {
    if (!kind || busy) return;
    setBusy(true);
    try {
      await createEmergency({
        authorId: session.userId,
        kind,
        description,
        zone: session.zone,
        point: { lat: session.lat, lng: session.lng },
      });
      setDescription('');
      setKind(null);
      bump();
    } finally {
      setBusy(false);
    }
  };

  if (alert) {
    return (
      <div className="screen-body">
        <header className="topbar">
          <div>
            <p className="eyebrow">Red activa</p>
            <h1>Emergencia</h1>
          </div>
          <span className="pill pill-alert">
            <Icon name="alert" size={14} /> Activa
          </span>
        </header>

        <article className="card card-alert">
          <p className="alert-kind">{EMERGENCY_LABEL[alert.kind]}</p>
          {alert.description ? <p className="alert-desc">{alert.description}</p> : null}
          <p className="card-meta">
            {alert.zone} · {timeAgo(alert.createdAt)}
          </p>
        </article>

        <div className="section-head">
          <h2>1. Institución primero</h2>
        </div>
        <div className="stack">
          {INSTITUTIONS.map((institution) => (
            <a key={institution.number} className="card call-row" href={`tel:${institution.number}`}>
              <span className="call-icon">
                <Icon name="phone" size={18} />
              </span>
              <span className="grow">
                <strong>{institution.name}</strong>
                <small>Llama tú mismo. La app no llama por ti.</small>
              </span>
              <span className="call-number">{institution.number}</span>
            </a>
          ))}
        </div>

        <button
          type="button"
          className={alert.institutionCalled ? 'btn btn-block btn-ghost' : 'btn btn-block btn-soft'}
          onClick={() => {
            void markInstitutionCalled(alert.id).then(bump);
          }}
        >
          <Icon name={alert.institutionCalled ? 'check' : 'phone'} size={17} />
          {alert.institutionCalled ? 'Institución contactada' : 'Ya llamé a la institución'}
        </button>

        <div className="section-head">
          <h2>2. Tu red vecinal</h2>
          <span className="count">{providers.length}</span>
        </div>
        <div className="stack">
          {providers.map((provider) => (
            <article key={provider.id} className="card wall-row">
              <span className="type-dot type-servicio" aria-hidden="true" />
              <div className="grow">
                <p className="wall-title">{provider.name}</p>
                <p className="card-meta">
                  {provider.category ?? 'Vecino'} · {formatDistance(provider.distanceKm) || 'tu zona'}
                </p>
              </div>
              <span className="level-pill">{provider.level}</span>
            </article>
          ))}
        </div>

        <div className="note note-safe">
          <Icon name="pin" size={16} />
          Tu ubicación exacta no se publica. Solo la recibe quien acepte ayudarte.
        </div>

        <button
          type="button"
          className="btn btn-block btn-danger"
          onClick={() => {
            void closeEmergency(alert.id).then(bump);
          }}
        >
          Marcar como atendida
        </button>
      </div>
    );
  }

  return (
    <div className="screen-body">
      <header className="topbar">
        <div>
          <p className="eyebrow">Preparado, no alarmista</p>
          <h1>Emergencia</h1>
        </div>
        <span className="pill">
          <Icon name="shield" size={14} /> Sin alertas
        </span>
      </header>

      <p className="lead">
        Si hay riesgo para una persona, <strong>llama primero a la institución</strong>. La red
        vecinal ayuda después, no la reemplaza.
      </p>

      <div className="kind-grid" role="group" aria-label="Tipo de emergencia">
        {KINDS.map((item) => (
          <button
            key={item}
            type="button"
            className={kind === item ? 'kind kind-active' : 'kind'}
            onClick={() => setKind(item)}
          >
            <Icon name={item === 'medico' ? 'phone' : 'alert'} size={20} />
            <span>{EMERGENCY_LABEL[item]}</span>
          </button>
        ))}
      </div>

      <label className="field">
        <span className="label">¿Qué está pasando? (opcional)</span>
        <textarea
          className="input textarea"
          rows={3}
          maxLength={220}
          placeholder="Ej. Mi vecina del 3ro no responde y huele a gas."
          value={description}
          onChange={(event) => setDescription(event.target.value)}
        />
      </label>

      <button
        type="button"
        className="sos-btn"
        disabled={!kind || busy}
        onClick={() => void activate()}
      >
        <Icon name="alert" size={30} />
        <span>{busy ? 'Activando…' : 'Activar red de emergencia'}</span>
        <small>{kind ? EMERGENCY_LABEL[kind] : 'Elige el tipo de emergencia'}</small>
      </button>

      <div className="section-head">
        <h2>Números oficiales</h2>
      </div>
      <div className="stack">
        {INSTITUTIONS.map((institution) => (
          <a key={institution.number} className="card call-row" href={`tel:${institution.number}`}>
            <span className="call-icon">
              <Icon name="phone" size={18} />
            </span>
            <span className="grow">
              <strong>{institution.name}</strong>
            </span>
            <span className="call-number">{institution.number}</span>
          </a>
        ))}
      </div>

      <p className="footnote">
        Verifica estos números con una fuente oficial antes de la demo. La app no reemplaza a los
        servicios de emergencia.
      </p>
    </div>
  );
}
