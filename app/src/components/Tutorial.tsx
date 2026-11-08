import { useEffect, useRef, useState } from 'react';
import { markTutorialSeen, TUTORIAL_EVENT, tutorialSeen } from '../lib/prefs';

interface Step {
  icon: string;
  title: string;
  body: string;
  points: string[];
}

const STEPS: Step[] = [
  {
    icon: '🏘️',
    title: 'Tu barrio, a la mano',
    body: 'Red del barrio junta a quienes necesitan algo con vecinos que saben o pueden ayudar, cerca de ti.',
    points: [
      'En Inicio ves lo que pide y ofrece tu barrio, de lo más cercano a lo más lejano.',
      'Toca "+ Pedir / Ofrecer" para publicar. Tú pones lo que necesitas o lo que sabes hacer.',
      'En Vecinos encuentras a quien hace cada oficio y qué tan recomendado está.',
    ],
  },
  {
    icon: '🤝',
    title: 'Ayuda con y sin dinero',
    body: 'No todo se paga. Puedes pedir o dar ayuda sin dinero, y también contratar un servicio.',
    points: [
      'En "Sin dinero": prestar herramientas, donar, intercambiar habilidades, acompañar.',
      'Los servicios con costo los pacta cada vecino en el chat; la app no maneja pagos.',
      'Cada ayuda completada sube tu nivel y la confianza de tu barrio.',
    ],
  },
  {
    icon: '🚨',
    title: 'Emergencias y avisos',
    body: 'En Emergencia, lo oficial va primero: PNP 105, Bomberos 116 y SAMU 106.',
    points: [
      'Alertas vecinales: pide ayuda y tus vecinos de la zona la ven al instante.',
      'Aviso de seguridad: avisa de un robo o una zona peligrosa; otros vecinos lo confirman.',
      'Recursos críticos y Mapa del barrio: agua, comida, abrigo y qué pasa cerca.',
    ],
  },
  {
    icon: '🔒',
    title: 'Tu privacidad y la confianza',
    body: 'Tus vecinos ven una zona aproximada, nunca tu dirección exacta.',
    points: [
      'La dirección exacta se la das solo a quien elijas, por el chat.',
      'Al encontrarse usan un código de un solo uso y después se califican entre los dos.',
      'En Perfil puedes poner texto grande o alto contraste, y volver a ver esta guía.',
    ],
  },
];

/** Guía de 4 pasos: se abre sola la primera vez y desde Perfil → "Ver tutorial". */
export default function Tutorial() {
  const [open, setOpen] = useState(false);
  const [step, setStep] = useState(0);
  const primary = useRef<HTMLButtonElement>(null);

  useEffect(() => {
    if (!tutorialSeen()) setOpen(true);
    const show = () => {
      setStep(0);
      setOpen(true);
    };
    window.addEventListener(TUTORIAL_EVENT, show);
    return () => window.removeEventListener(TUTORIAL_EVENT, show);
  }, []);

  useEffect(() => {
    if (open) primary.current?.focus();
  }, [open, step]);

  useEffect(() => {
    if (!open) return;
    const onKey = (event: KeyboardEvent) => {
      if (event.key === 'Escape') close();
    };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  });

  function close() {
    markTutorialSeen();
    setOpen(false);
  }

  if (!open) return null;
  const last = step === STEPS.length - 1;
  const s = STEPS[step];

  return (
    <div className="tutorial-backdrop">
      <div className="tutorial" role="dialog" aria-modal="true" aria-labelledby="tutorial-title">
        <div className="tutorial-top">
          <span className="tutorial-count" aria-live="polite">
            Paso {step + 1} de {STEPS.length}
          </span>
          <button type="button" className="tutorial-skip" onClick={close}>
            Omitir
          </button>
        </div>
        <div className="tutorial-icon" aria-hidden="true">
          {s.icon}
        </div>
        <h2 id="tutorial-title">{s.title}</h2>
        <p className="tutorial-body">{s.body}</p>
        <ul>
          {s.points.map((point) => (
            <li key={point}>{point}</li>
          ))}
        </ul>
        <div className="tutorial-dots" aria-hidden="true">
          {STEPS.map((_, i) => (
            <span key={i} className={i === step ? 'dot on' : 'dot'} />
          ))}
        </div>
        <div className="tutorial-actions">
          <button type="button" className="btn ghost" onClick={() => setStep((v) => v - 1)} disabled={step === 0}>
            Atrás
          </button>
          <button
            ref={primary}
            type="button"
            className="btn"
            onClick={() => (last ? close() : setStep((v) => v + 1))}
          >
            {last ? 'Empezar' : 'Siguiente'}
          </button>
        </div>
      </div>
    </div>
  );
}
