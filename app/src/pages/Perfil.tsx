import { useState, type FormEvent } from 'react';
import { dbBytes, getStats, listUsers, resetAll, saveProfile } from '../db/repo';
import { chat } from '../lib/matrix';
import { useApp } from '../state/app';

const mb = (bytes: number) => `${(bytes / (1024 * 1024)).toFixed(1)} MB`;

export default function Perfil() {
  const { me, version, bump, switchUser } = useApp();
  const [name, setName] = useState('');
  const [zone, setZone] = useState('');
  const [saved, setSaved] = useState(false);

  if (!me) return null;

  const stats = getStats(me.id);
  const users = listUsers();
  const currentName = name !== '' || saved ? name : me.name;
  const currentZone = zone !== '' || saved ? zone : me.zone;

  async function save(event: FormEvent) {
    event.preventDefault();
    await saveProfile(me!.id, { name: currentName, zone: currentZone });
    setSaved(false);
    bump();
  }

  async function wipe() {
    if (!window.confirm('¿Borrar TODOS los datos locales? Se restaura la demo.')) return;
    if (!window.confirm('Confirmación final: no se puede deshacer.')) return;
    await resetAll();
    switchUser('u_lucia');
    setName('');
    setZone('');
    setSaved(false);
  }

  return (
    <div>
      <header className="page-head">
        <div>
          <h1>
            <span style={{ color: me.color }}>●</span> {me.name}
          </h1>
          <p className="sub">
            {me.level} · {me.zone}
          </p>
        </div>
      </header>

      <section className="card">
        <h3>Mis números</h3>
        <div className="meta">
          <span className="badge">🫶 {stats.helps} ayudas completadas</span>
          <span className="badge">👥 {stats.people} vecinos</span>
          <span className="badge">⭐ {stats.avgStars !== null ? stats.avgStars.toFixed(1) : '—'}</span>
          <span className="badge">👍 {stats.recommendations} recomendaciones</span>
          {stats.pending > 0 && <span className="badge danger">{stats.pending} pendientes</span>}
        </div>
        <p>
          Chat: {chat.label} · Base local: {mb(dbBytes())}
        </p>
      </section>

      <form className="panel" onSubmit={save}>
        <h3 style={{ marginTop: 0 }}>Mi perfil</h3>
        <label htmlFor="name">Nombre</label>
        <input id="name" value={currentName} onChange={(e) => { setName(e.target.value); setSaved(true); }} maxLength={60} />
        <label htmlFor="zone">Zona</label>
        <input id="zone" value={currentZone} onChange={(e) => { setZone(e.target.value); setSaved(true); }} maxLength={60} />
        <p>
          <button type="submit" className="btn block" disabled={!saved}>
            Guardar cambios
          </button>
        </p>
      </form>

      <section className="card">
        <h3>Cambiar de vecino (demo y pruebas)</h3>
        <p>
          Simula a otra persona en este mismo teléfono. Al conectar el servidor, esto se reemplaza
          por cuentas reales.
        </p>
        <div className="meta">
          {users.map((u) => (
            <button
              key={`${u.id}-${version}`}
              type="button"
              className={u.id === me.id ? 'btn small' : 'btn small ghost'}
              onClick={() => switchUser(u.id)}
            >
              {u.name}
            </button>
          ))}
        </div>
      </section>

      <button type="button" className="btn ghost block" onClick={wipe}>
        Borrar mis datos
      </button>
    </div>
  );
}
