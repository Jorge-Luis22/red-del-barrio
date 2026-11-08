import { useEffect, useRef, useState } from 'react';
import { createNeed, defaultPoint, saveService } from '../db/repo';
import {
  MAX_DETAIL,
  MORE_TILES,
  OTHER_TYPES,
  SCHEDULES,
  TILES,
  WHEN,
  needDescription,
  needTitle,
  tileFor,
  type Tile,
} from '../lib/publish';
import type { Direction } from '../lib/solidarity';
import { useApp } from '../state/app';
import type { NeedType } from '../types';

/** Lo que Inicio le pide a la hoja: qué botón grande tocó el vecino (y, desde el Directorio, el oficio ya elegido). */
export interface PublishRequest {
  dir: Direction;
  category?: string;
  detail?: string;
}

type Step = 'cat' | 'otro' | 'confirm';

/**
 * Hoja para publicar sin escribir: Necesito/Ofrezco (botón de Inicio) → qué (botón grande) → Publicar.
 * "Necesito" publica un pedido en el muro; "Ofrezco" te anota en el Directorio de vecinos (y, si marcas
 * "Atiendo urgencias", en Emergencia). Todo lo demás es opcional y también son botones.
 */
export default function PublishSheet({
  request,
  onClose,
  onDone,
}: {
  request: PublishRequest;
  onClose: () => void;
  onDone: (message: string) => void;
}) {
  const { me, bump } = useApp();
  const offer = request.dir === 'ofrezco';

  const [step, setStep] = useState<Step>(request.category ? 'confirm' : 'cat');
  const [tile, setTile] = useState<Tile | null>(request.category ? tileFor(request.category) : null);
  const [other, setOther] = useState('');
  const [otherType, setOtherType] = useState<NeedType>('servicio');
  const [what, setWhat] = useState<string | null>(null);
  const [when, setWhen] = useState<string | null>(null);
  const [detail, setDetail] = useState(request.detail ?? '');
  const [availableNow, setAvailableNow] = useState(false);
  const [urgent, setUrgent] = useState(true);
  const [schedule, setSchedule] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');

  const heading = useRef<HTMLHeadingElement>(null);
  const closeRef = useRef(onClose);
  closeRef.current = onClose;

  // Cerrar con Escape; devolver el foco al botón que abrió la hoja.
  useEffect(() => {
    const opener = document.activeElement;
    const onKey = (event: KeyboardEvent) => {
      if (event.key === 'Escape') closeRef.current();
    };
    document.addEventListener('keydown', onKey);
    return () => {
      document.removeEventListener('keydown', onKey);
      if (opener instanceof HTMLElement) opener.focus();
    };
  }, []);

  // Al cambiar de paso, el lector de pantalla lee el título nuevo.
  useEffect(() => {
    heading.current?.focus();
  }, [step]);

  if (!me) return null;

  const zone = me.zone || (import.meta.env.VITE_DEFAULT_ZONE ?? 'Los Olivos, Lima');
  const tiles = offer ? TILES.filter((t) => t.trade) : TILES;
  const moreTiles = offer ? MORE_TILES.filter((t) => t.trade) : MORE_TILES;

  function pick(next: Tile) {
    setTile(next);
    setWhat(null);
    setStep('confirm');
  }

  function back() {
    if (step === 'confirm') {
      const fromOther = tile?.key === 'custom' || MORE_TILES.some((t) => t.key === tile?.key);
      setStep(fromOther ? 'otro' : 'cat');
    }
    else if (step === 'otro') setStep('cat');
  }

  function useOther() {
    const text = other.trim();
    if (text.length < 3) return;
    // Al ofrecer, lo escrito es el oficio; al pedir, queda en el título y el rubro es "Otros".
    pick({
      key: 'custom',
      icon: '✏️',
      label: text,
      category: offer ? text : 'Otros',
      type: otherType,
      quick: [],
      trade: true,
    });
  }

  async function publish() {
    if (!tile || busy) return;
    setBusy(true);
    setError('');
    try {
      if (offer) {
        await saveService({
          providerId: me!.id,
          trade: tile.category,
          description: detail.trim().slice(0, MAX_DETAIL),
          urgent,
          availableNow,
          schedule: schedule ?? '',
        });
        bump();
        onDone(`Listo: ya apareces en el Directorio de vecinos como ${tile.label.toLowerCase()}.`);
      } else {
        await createNeed({
          authorId: me!.id,
          type: tile.type,
          title: needTitle(tile, what, detail),
          category: tile.category,
          description: needDescription(when, detail),
          zone,
          point: defaultPoint(),
        });
        bump();
        onDone('Listo: tu pedido ya está publicado en el muro del barrio.');
      }
    } catch {
      setError('No se pudo publicar. Inténtalo otra vez.');
      setBusy(false);
    }
  }

  const stepNumber = step === 'confirm' ? 2 : 1;
  const verb = offer ? 'Ofrezco' : 'Necesito';

  return (
    <div className="sheet-wrap">
      <div className="sheet-scrim" onClick={onClose} aria-hidden="true" />
      <div className="sheet" role="dialog" aria-modal="true" aria-labelledby="sheet-title" data-step={step}>
        <div className="sheet-head">
          {step !== 'cat' && !(step === 'confirm' && request.category) ? (
            <button type="button" className="sheet-link" onClick={back}>
              ‹ Atrás
            </button>
          ) : (
            <span className="sheet-step">Paso {stepNumber} de 2</span>
          )}
          <button type="button" className="sheet-close" onClick={onClose} aria-label="Cerrar">
            ✕
          </button>
        </div>

        {step === 'cat' && (
          <>
            <h2 id="sheet-title" tabIndex={-1} ref={heading}>
              {offer ? '¿Qué sabes hacer?' : '¿Qué necesitas?'}
            </h2>
            <p className="sheet-hint">Toca una opción.</p>
            <div className="tiles">
              {tiles.map((t) => (
                <button key={t.key} type="button" className="tile" data-tile={t.key} onClick={() => pick(t)}>
                  <span className="ico" aria-hidden="true">
                    {t.icon}
                  </span>
                  {t.label}
                </button>
              ))}
              <button type="button" className="tile" data-tile="otro" onClick={() => setStep('otro')}>
                <span className="ico" aria-hidden="true">
                  ✏️
                </span>
                Otra cosa (escribir)
              </button>
            </div>
            {offer && (
              <p className="sheet-hint" style={{ marginTop: 10 }}>
                ¿Quieres prestar, regalar o ayudar sin dinero? Usa la pestaña “🤝 Sin dinero”.
              </p>
            )}
          </>
        )}

        {step === 'otro' && (
          <>
            <h2 id="sheet-title" tabIndex={-1} ref={heading}>
              {offer ? '¿Qué sabes hacer?' : '¿Qué necesitas?'}
            </h2>
            <p className="sheet-hint">Elige uno de estos o escribe en pocas palabras.</p>
            <div className="chips">
              {moreTiles.map((t) => (
                <button key={t.key} type="button" className="chip big" onClick={() => pick(t)}>
                  {t.icon} {t.label}
                </button>
              ))}
            </div>
            <label htmlFor="pub-other">Escríbelo aquí</label>
            <input
              id="pub-other"
              value={other}
              onChange={(e) => setOther(e.target.value)}
              placeholder={offer ? 'Ej. Pintura de paredes' : 'Ej. Pintar una pared'}
              maxLength={50}
              autoComplete="off"
              enterKeyHint="next"
              onKeyDown={(e) => {
                if (e.key === 'Enter') {
                  e.preventDefault();
                  useOther();
                }
              }}
            />
            {!offer && (
              <div className="chips" role="group" aria-label="¿Qué es?" style={{ marginTop: 10 }}>
                {OTHER_TYPES.map((o) => (
                  <button
                    key={o.type}
                    type="button"
                    className={otherType === o.type ? 'chip big on' : 'chip big'}
                    aria-pressed={otherType === o.type}
                    onClick={() => setOtherType(o.type)}
                  >
                    {o.label}
                  </button>
                ))}
              </div>
            )}
            <button type="button" className="btn block sheet-go" disabled={other.trim().length < 3} onClick={useOther}>
              Seguir
            </button>
          </>
        )}

        {step === 'confirm' && tile && (
          <>
            <h2 id="sheet-title" tabIndex={-1} ref={heading}>
              {verb}: {tile.icon} {tile.label}
            </h2>

            {!offer && tile.quick.length > 0 && (
              <>
                <p className="sheet-q">¿Qué pasó? <span>(opcional)</span></p>
                <div className="chips" role="group" aria-label="¿Qué pasó?">
                  {tile.quick.map((q) => (
                    <button
                      key={q}
                      type="button"
                      className={what === q ? 'chip big on' : 'chip big'}
                      aria-pressed={what === q}
                      onClick={() => setWhat(what === q ? null : q)}
                    >
                      {q}
                    </button>
                  ))}
                </div>
              </>
            )}

            {!offer && (
              <>
                <p className="sheet-q">¿Para cuándo? <span>(opcional)</span></p>
                <div className="chips" role="group" aria-label="¿Para cuándo?">
                  {WHEN.map((w) => (
                    <button
                      key={w.key}
                      type="button"
                      className={when === w.key ? 'chip big on' : 'chip big'}
                      aria-pressed={when === w.key}
                      onClick={() => setWhen(when === w.key ? null : w.key)}
                    >
                      {w.label}
                    </button>
                  ))}
                </div>
              </>
            )}

            {offer && (
              <>
                <p className="sheet-q">¿Cuándo atiendes? <span>(opcional)</span></p>
                <div className="chips" role="group" aria-label="¿Cuándo atiendes?">
                  <button
                    type="button"
                    className={availableNow ? 'chip big on' : 'chip big'}
                    aria-pressed={availableNow}
                    onClick={() => setAvailableNow((v) => !v)}
                  >
                    🟢 Disponible ahora
                  </button>
                  {SCHEDULES.map((s) => (
                    <button
                      key={s}
                      type="button"
                      className={schedule === s ? 'chip big on' : 'chip big'}
                      aria-pressed={schedule === s}
                      onClick={() => setSchedule(schedule === s ? null : s)}
                    >
                      {s}
                    </button>
                  ))}
                </div>
                <div className="chips" role="group" aria-label="Urgencias">
                  <button
                    type="button"
                    className={urgent ? 'chip big on' : 'chip big'}
                    aria-pressed={urgent}
                    onClick={() => setUrgent((v) => !v)}
                  >
                    🛠️ Atiendo urgencias
                  </button>
                </div>
              </>
            )}

            <label htmlFor="pub-detail" className="sheet-q" style={{ display: 'block' }}>
              {offer ? 'Cuéntalo con tus palabras' : '¿Otra cosa? Cuéntalo con tus palabras'} <span>(opcional)</span>
            </label>
            <textarea
              id="pub-detail"
              rows={3}
              value={detail}
              onChange={(e) => setDetail(e.target.value)}
              maxLength={MAX_DETAIL}
              placeholder={
                offer
                  ? 'Ej. Hago instalaciones y reparaciones, con 10 años de experiencia'
                  : 'Ej. Se me quemó el tablero y no tengo luz en la cocina'
              }
            />

            <p className="sheet-where">
              📍 {zone}. Se muestra solo una zona aproximada, nunca tu ubicación exacta.
            </p>
            {error && (
              <p className="onboard-note danger" role="alert">
                {error}
              </p>
            )}
            <button type="button" className="btn block sheet-go" data-publish="1" disabled={busy} onClick={() => void publish()}>
              {busy ? 'Publicando…' : offer ? 'Publicar mi servicio' : 'Publicar'}
            </button>
          </>
        )}
      </div>
    </div>
  );
}
