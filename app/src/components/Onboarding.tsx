import { useState, type FormEvent } from 'react';
import { createPilotUser } from '../db/repo';
import { JoinFailed, joinNeighborhood, type JoinError } from '../lib/auth';
import { CONTACT_EMAIL } from '../lib/mode';
import type { User } from '../types';
import Legal from './Legal';

const ERRORS: Record<JoinError | 'offline' | 'disabled' | 'server', string> = {
  bad_code: 'Ese código no es correcto. Revísalo con quien te lo dio.',
  too_many_attempts: 'Demasiados intentos con código incorrecto. Espera una hora e inténtalo de nuevo.',
  banned: 'Esta cuenta fue suspendida del piloto.',
  not_configured: 'El barrio todavía no está abierto. Avisa a quien organiza el piloto.',
  bad_name: 'Escribe tu nombre (hasta 60 letras).',
  no_auth: 'No se pudo crear tu cuenta. Inténtalo otra vez.',
  offline: 'Sin conexión. Conéctate a internet para entrar por primera vez.',
  disabled: 'El servidor todavía no está listo para cuentas nuevas. Avisa a quien organiza el piloto.',
  server: 'Algo falló al entrar. Inténtalo en un minuto.',
};

/** Pantalla de entrada del piloto: código del barrio + nombre + zona. */
export default function Onboarding({ notice, onDone }: { notice: string | null; onDone: (user: User) => void }) {
  const [code, setCode] = useState('');
  const [name, setName] = useState('');
  const [zone, setZone] = useState((import.meta.env.VITE_DEFAULT_ZONE as string | undefined) ?? '');
  const [adult, setAdult] = useState(false);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [legal, setLegal] = useState(false);

  const ready = code.trim().length >= 6 && name.trim().length >= 1 && adult && !busy;

  async function submit(event: FormEvent) {
    event.preventDefault();
    if (!ready) return;
    setBusy(true);
    setError(null);
    try {
      const id = await joinNeighborhood(code, name.trim(), zone.trim());
      const user = await createPilotUser({ id, name, zone });
      onDone(user);
    } catch (e) {
      setError(ERRORS[e instanceof JoinFailed ? e.code : 'server']);
      setBusy(false);
    }
  }

  return (
    <div className="onboard">
      <header>
        <div className="onboard-logo" aria-hidden="true">
          🏘️
        </div>
        <h1>Red del barrio</h1>
        <p className="sub">Vecinos que se ayudan, con confianza.</p>
      </header>

      {notice === 'session_lost' && (
        <p className="onboard-note warn" role="alert">
          Tu cuenta en este teléfono ya no está disponible, así que se borraron los datos locales. Puedes entrar de nuevo
          con el código del barrio.
        </p>
      )}

      <form className="panel" onSubmit={submit}>
        <label htmlFor="ob-code">Código del barrio</label>
        <input
          id="ob-code"
          value={code}
          onChange={(e) => setCode(e.target.value)}
          placeholder="Te lo da quien organiza el piloto"
          autoComplete="off"
          autoCapitalize="characters"
          spellCheck={false}
        />
        <label htmlFor="ob-name">Tu nombre</label>
        <input
          id="ob-name"
          value={name}
          onChange={(e) => setName(e.target.value)}
          placeholder="Como te conocerán tus vecinos"
          maxLength={60}
          autoComplete="given-name"
        />
        <label htmlFor="ob-zone">Tu zona o barrio</label>
        <input
          id="ob-zone"
          value={zone}
          onChange={(e) => setZone(e.target.value)}
          placeholder="Los Olivos, Lima"
          maxLength={60}
        />

        <label className="onboard-check">
          <input type="checkbox" checked={adult} onChange={(e) => setAdult(e.target.checked)} />
          <span>
            Tengo 18 años o más y acepto los{' '}
            <button type="button" className="link" onClick={() => setLegal(true)}>
              términos y la privacidad
            </button>
            .
          </span>
        </label>

        {error && (
          <p className="onboard-note danger" role="alert">
            {error}
          </p>
        )}

        <p>
          <button type="submit" className="btn block" disabled={!ready}>
            {busy ? 'Entrando…' : 'Entrar al barrio'}
          </button>
        </p>
      </form>

      <ul className="onboard-points">
        <li>🔒 Tus vecinos ven tu nombre y una zona aproximada, nunca tu dirección.</li>
        <li>💬 Los chats los ven solo las dos personas del trato.</li>
        <li>🚨 En una emergencia llama primero: PNP 105 · Bomberos 116 · SAMU 106.</li>
        <li>📱 Tu cuenta vive en este teléfono: si borras los datos del navegador, la pierdes.</li>
      </ul>
      {CONTACT_EMAIL && <p className="onboard-foot">Dudas: {CONTACT_EMAIL}</p>}
      {legal && <Legal onClose={() => setLegal(false)} />}
    </div>
  );
}
