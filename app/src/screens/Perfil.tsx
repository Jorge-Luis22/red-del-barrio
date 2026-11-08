import { useEffect, useMemo, useState } from 'react';
import { dbBytes, getStats, resetAll } from '../db/repo';
import { bytes, timeAgo } from '../lib/format';
import { chat } from '../lib/matrix';
import { useStore } from '../state/store';
import { Icon } from '../ui/Icon';
import { Avatar } from '../ui/Sheet';

function readFlag(key: string): boolean {
  try {
    return localStorage.getItem(key) === '1';
  } catch {
    return false;
  }
}

function writeFlag(key: string, value: boolean): void {
  try {
    localStorage.setItem(key, value ? '1' : '0');
  } catch {
    /* sin almacenamiento */
  }
}

export function Perfil() {
  const { session, revision, bump, updateProfile } = useStore();
  const [name, setName] = useState(session.name);
  const [zone, setZone] = useState(session.zone);
  const [saved, setSaved] = useState(false);
  const [big, setBig] = useState(() => readFlag('rv.big'));
  const [contrast, setContrast] = useState(() => readFlag('rv.hc'));
  const [dark, setDark] = useState(() => readFlag('rv.dark'));
  const [wipeStep, setWipeStep] = useState(0);
  const [wiping, setWiping] = useState(false);

  const stats = useMemo(() => getStats(session.userId), [session.userId, revision]);
  const size = useMemo(() => dbBytes(), [revision]);

  useEffect(() => {
    document.documentElement.dataset.big = big ? '1' : '0';
    writeFlag('rv.big', big);
  }, [big]);

  useEffect(() => {
    document.documentElement.dataset.hc = contrast ? '1' : '0';
    writeFlag('rv.hc', contrast);
  }, [contrast]);

  useEffect(() => {
    document.documentElement.dataset.theme = dark ? 'dark' : 'light';
    writeFlag('rv.dark', dark);
  }, [dark]);

  const save = async () => {
    await updateProfile({ name, zone });
    setSaved(true);
    window.setTimeout(() => setSaved(false), 1800);
  };

  const wipe = async () => {
    if (wipeStep === 0) {
      setWipeStep(1);
      return;
    }
    if (wipeStep === 1) {
      setWipeStep(2);
      return;
    }
    setWiping(true);
    try {
      await resetAll();
      setWipeStep(0);
      bump();
    } finally {
      setWiping(false);
    }
  };

  return (
    <div className="screen-body">
      <header className="topbar">
        <div>
          <p className="eyebrow">Tu cuenta local</p>
          <h1>Perfil</h1>
        </div>
        <Avatar name={session.name} color="#0a6b66" size={42} />
      </header>

      <section className="card profile-card">
        <div className="row">
          <Avatar name={session.name} color="#0a6b66" size={54} />
          <div className="grow">
            <p className="card-name">{session.name}</p>
            <p className="card-meta">
              {session.zone} · {stats.helps} ayudas confirmadas
            </p>
          </div>
          <span className="level-pill">{stats.helps >= 3 ? 'Colaborador' : 'Vecino'}</span>
        </div>
      </section>

      <div className="stat-grid">
        <div className="stat">
          <strong>{stats.helps}</strong>
          <span>Ayudas</span>
        </div>
        <div className="stat">
          <strong>{stats.people}</strong>
          <span>Personas</span>
        </div>
        <div className="stat">
          <strong>{stats.avgStars ? stats.avgStars.toFixed(1) : '—'}</strong>
          <span>Estrellas</span>
        </div>
        <div className="stat">
          <strong>{stats.recommendations}</strong>
          <span>Vistos buenos</span>
        </div>
      </div>

      <p className="footnote">
        Tu ayuda al barrio es privada: no hay puntos, puestos ni prioridad comercial.
      </p>

      <div className="section-head">
        <h2>Datos de contacto</h2>
      </div>
      <div className="card form-card">
        <label className="field">
          <span className="label">Nombre</span>
          <input className="input" value={name} onChange={(event) => setName(event.target.value)} />
        </label>
        <label className="field">
          <span className="label">Zona</span>
          <input className="input" value={zone} onChange={(event) => setZone(event.target.value)} />
        </label>
        <button type="button" className="btn btn-primary btn-block" onClick={() => void save()}>
          {saved ? 'Guardado' : 'Guardar cambios'}
        </button>
      </div>

      <div className="section-head">
        <h2>Accesibilidad</h2>
      </div>
      <div className="card form-card">
        <Toggle
          label="Texto más grande"
          hint="Ideal para pantallas pequeñas y vista cansada."
          checked={big}
          onChange={setBig}
        />
        <Toggle
          label="Alto contraste"
          hint="Fondo blanco, texto negro, bordes marcados."
          checked={contrast}
          onChange={setContrast}
        />
        <Toggle label="Tema oscuro" hint="Se guarda en este teléfono." checked={dark} onChange={setDark} />
      </div>

      <div className="section-head">
        <h2>Almacenamiento y chat</h2>
      </div>
      <div className="card form-card">
        <div className="row row-between">
          <span className="meta-line">
            <Icon name="store" size={16} /> Base local SQLite
          </span>
          <strong>{bytes(size)}</strong>
        </div>
        <div className="row row-between">
          <span className="meta-line">
            <Icon name="chat" size={16} /> Chat
          </span>
          <span className={chat.kind === 'matrix' ? 'pill pill-ok' : 'pill'}>{chat.label}</span>
        </div>
        <div className="row row-between">
          <span className="meta-line">
            <Icon name="clock" size={16} /> Pendientes de envío
          </span>
          <strong>{stats.pending}</strong>
        </div>
        <p className="footnote">
          Los datos viven en este dispositivo. Al conectar Supabase, esta base pasa a ser el espejo
          offline.
        </p>
      </div>

      <button
        type="button"
        className={wipeStep > 0 ? 'btn btn-block btn-danger' : 'btn btn-block btn-ghost'}
        disabled={wiping}
        onClick={() => void wipe()}
      >
        <Icon name="trash" size={17} />
        {wipeStep === 0
          ? 'Borrar mis datos'
          : wipeStep === 1
            ? '¿Seguro? Toca otra vez'
            : 'Confirma: se borra todo'}
      </button>
      {wipeStep > 0 ? (
        <button type="button" className="btn btn-block btn-ghost" onClick={() => setWipeStep(0)}>
          Cancelar
        </button>
      ) : null}

      <p className="footnote center">
        Red del barrio · v0.1.0 · demo local con SQLite
      </p>
    </div>
  );
}

function Toggle({
  label,
  hint,
  checked,
  onChange,
}: {
  label: string;
  hint: string;
  checked: boolean;
  onChange: (value: boolean) => void;
}) {
  return (
    <label className="toggle">
      <span className="grow">
        <strong>{label}</strong>
        <small>{hint}</small>
      </span>
      <input
        type="checkbox"
        checked={checked}
        onChange={(event) => onChange(event.target.checked)}
        aria-label={label}
      />
      <span className="switch" aria-hidden="true" />
    </label>
  );
}
