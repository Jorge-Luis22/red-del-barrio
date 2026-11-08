import { useState } from 'react';
import {
  defaultPoint,
  listEmergencyWall,
  listResourcePosts,
  listSolidary,
  listUrgentRequests,
} from '../db/repo';
import { formatDistance, type Point } from '../lib/geo';
import { directionOf, resourceIcon, solidaryIcon, stripProxy } from '../lib/solidarity';
import { ago } from '../lib/time';
import { useApp } from '../state/app';
import { EMERGENCY_LABEL } from '../types';

/**
 * Mapa esquemático del barrio: un radar centrado en ti (norte arriba) con anillos de distancia.
 * No es un mapa de calles: funciona sin internet y no muestra ninguna dirección exacta.
 * Los círculos grandes son zonas de ~1 km (alertas, urgencias, recursos); los puntos, zonas de ~100 m.
 */

type Layer = 'alerta' | 'urgente' | 'recurso' | 'solidario';

interface Mark {
  id: string;
  layer: Layer;
  icon: string;
  title: string;
  sub: string;
  km: number;
  /** Km hacia el este y hacia el norte respecto de quien mira. */
  dx: number;
  dy: number;
  halo: boolean;
  open: () => void;
  openLabel: string;
}

const LAYERS: { id: Layer; icon: string; label: string }[] = [
  { id: 'alerta', icon: '🚨', label: 'Alertas' },
  { id: 'urgente', icon: '🛠️', label: 'Urgencias con costo' },
  { id: 'recurso', icon: '📦', label: 'Recursos' },
  { id: 'solidario', icon: '🤝', label: 'Sin dinero' },
];

const SIZE = 320;
const C = SIZE / 2;
const RADIUS_PX = 138;
/** Una zona publicada con 2 decimales es una casilla de ~1,1 km: su "radio de duda" es ~0,55 km. */
const HALO_KM = 0.55;

function offsetKm(from: Point, to: Point): { dx: number; dy: number } {
  return {
    dy: (to.lat - from.lat) * 110.57,
    dx: (to.lng - from.lng) * 111.32 * Math.cos((from.lat * Math.PI) / 180),
  };
}

export default function MapaBarrio({ onShowAlerts }: { onShowAlerts: () => void }) {
  const { me, version, go } = useApp();
  const [on, setOn] = useState<Record<Layer, boolean>>({ alerta: true, urgente: true, recurso: true, solidario: true });
  const [selected, setSelected] = useState<string | null>(null);

  if (!me) return null;
  const viewer = defaultPoint();
  const marks: Mark[] = [];

  const push = (m: Omit<Mark, 'dx' | 'dy' | 'km'>, point: Point | null) => {
    if (!point) return;
    const { dx, dy } = offsetKm(viewer, point);
    marks.push({ ...m, dx, dy, km: Math.hypot(dx, dy) });
  };

  for (const a of listEmergencyWall(me.id, viewer)) {
    push(
      {
        id: `a-${a.id}`,
        layer: 'alerta',
        icon: '🚨',
        title: EMERGENCY_LABEL[a.kind],
        sub: `${stripProxy(a.description)} · ${a.authorName} · ${ago(a.createdAt)}`,
        halo: true,
        open: onShowAlerts,
        openLabel: 'Ver alertas',
      },
      a.latPublic !== null && a.lngPublic !== null ? { lat: a.latPublic, lng: a.lngPublic } : null,
    );
  }
  for (const r of listUrgentRequests(me.id, viewer)) {
    push(
      {
        id: `u-${r.need.id}`,
        layer: 'urgente',
        icon: '🛠️',
        title: r.need.title,
        sub: `${r.need.description} · ${r.need.authorName} · con costo`,
        halo: true,
        open: () => go({ name: 'need', id: r.need.id }),
        openLabel: 'Ver y proponer',
      },
      r.need.latPublic !== null && r.need.lngPublic !== null ? { lat: r.need.latPublic, lng: r.need.lngPublic } : null,
    );
  }
  for (const p of listResourcePosts(me.id, viewer)) {
    push(
      {
        id: `r-${p.need.id}`,
        layer: 'recurso',
        icon: resourceIcon(p.need.category),
        title: p.need.title,
        sub: `${p.need.description} · ${p.mine ? 'Tú' : p.need.authorName}`,
        halo: true,
        open: () => go({ name: 'need', id: p.need.id }),
        openLabel: p.mine ? 'Ver respuestas' : p.direction === 'ofrezco' ? 'Lo necesito' : 'Puedo ayudar',
      },
      p.need.latPublic !== null && p.need.lngPublic !== null ? { lat: p.need.latPublic, lng: p.need.lngPublic } : null,
    );
  }
  for (const n of listSolidary(viewer)) {
    const dir = directionOf(n.title);
    push(
      {
        id: `s-${n.id}`,
        layer: 'solidario',
        icon: solidaryIcon(n.category),
        title: n.title,
        sub: `${n.category} · ${n.authorName}${dir ? (dir === 'ofrezco' ? ' · ofrece' : ' · necesita') : ''}`,
        halo: false,
        open: () => go({ name: 'need', id: n.id }),
        openLabel: 'Ver',
      },
      n.latPublic !== null && n.lngPublic !== null ? { lat: n.latPublic, lng: n.lngPublic } : null,
    );
  }

  const visible = marks.filter((m) => on[m.layer]).sort((a, b) => a.km - b.km);
  const counts = (layer: Layer) => marks.filter((m) => m.layer === layer).length;

  // Escala: que quepa lo más lejano, entre 2 y 6 km.
  const farthest = visible.reduce((max, m) => Math.max(max, m.km + (m.halo ? HALO_KM : 0)), 0);
  const range = Math.min(6, Math.max(2, Math.ceil(farthest)));
  const scale = RADIUS_PX / range;
  const ringStep = range <= 4 ? 1 : 2;
  const rings: number[] = [];
  for (let k = ringStep; k <= range; k += ringStep) rings.push(k);

  // Posición en pantalla; los que caen en el mismo punto se abren en abanico para poder tocarlos.
  const placed = visible.map((m) => {
    const px = Math.max(-RADIUS_PX, Math.min(RADIUS_PX, m.dx * scale));
    const py = Math.max(-RADIUS_PX, Math.min(RADIUS_PX, m.dy * scale));
    return { m, x: C + px, y: C - py };
  });
  const groups = new Map<string, number[]>();
  placed.forEach((p, i) => {
    const key = `${Math.round(p.x / 6)}:${Math.round(p.y / 6)}`;
    groups.set(key, [...(groups.get(key) ?? []), i]);
  });
  for (const idx of groups.values()) {
    if (idx.length < 2) continue;
    idx.forEach((i, k) => {
      const angle = (k / idx.length) * Math.PI * 2 - Math.PI / 2;
      placed[i].x += Math.cos(angle) * 13;
      placed[i].y += Math.sin(angle) * 13;
    });
  }

  return (
    <div>
      <section className="card">
        <h3>Mapa del barrio</h3>
        <p>
          Tú estás en el centro; arriba es el norte. Cada marca es una zona aproximada, nunca una dirección exacta.
          Toca una marca o elige de la lista.
        </p>
      </section>

      <div className="chips" role="group" aria-label="Qué mostrar en el mapa">
        {LAYERS.map((l) => (
          <button
            key={l.id}
            type="button"
            className={on[l.id] ? 'chip on' : 'chip'}
            aria-pressed={on[l.id]}
            onClick={() => setOn((prev) => ({ ...prev, [l.id]: !prev[l.id] }))}
          >
            {l.icon} {l.label} ({counts(l.id)})
          </button>
        ))}
      </div>

      <div className="map-wrap">
        <svg
          viewBox={`0 0 ${SIZE} ${SIZE}`}
          role="group"
          aria-label={`Mapa esquemático del barrio con ${visible.length} marcas alrededor de ti`}
        >
          <circle cx={C} cy={C} r={RADIUS_PX} className="map-bg" />
          {rings.map((k) => (
            <g key={k}>
              <circle cx={C} cy={C} r={k * scale} className="map-ring" />
              <text x={C + 3} y={C - k * scale + 11} className="map-ring-label">
                {k} km
              </text>
            </g>
          ))}
          <line x1={C} y1={C - RADIUS_PX} x2={C} y2={C + RADIUS_PX} className="map-axis" />
          <line x1={C - RADIUS_PX} y1={C} x2={C + RADIUS_PX} y2={C} className="map-axis" />
          <text x={C} y={12} textAnchor="middle" className="map-n">
            N
          </text>

          {/* Primero las zonas (círculos grandes), después las marcas: así ninguna zona tapa un punto. */}
          {placed
            .filter(({ m }) => m.halo)
            .map(({ m, x, y }) => (
              <circle key={`h-${m.id}`} cx={x} cy={y} r={HALO_KM * scale} className={`map-halo layer-${m.layer}`} />
            ))}
          {placed.map(({ m, x, y }) => (
            <g
              key={`${m.id}-${version}`}
              className={`map-mark layer-${m.layer}${selected === m.id ? ' sel' : ''}`}
              role="button"
              tabIndex={0}
              aria-label={`${m.title}, a ${formatDistance(m.km)}`}
              onClick={() => setSelected(m.id)}
              onKeyDown={(e) => {
                if (e.key === 'Enter' || e.key === ' ') {
                  e.preventDefault();
                  setSelected(m.id);
                }
              }}
            >
              <circle cx={x} cy={y} r={11} className="map-dot" />
              <text x={x} y={y + 4.5} textAnchor="middle" className="map-icon">
                {m.icon}
              </text>
            </g>
          ))}

          <circle cx={C} cy={C} r={8} className="map-me" />
          <text x={C} y={C - 13} textAnchor="middle" className="map-me-label">
            Tú
          </text>
        </svg>
      </div>

      <p style={{ fontSize: '0.75rem', color: 'var(--muted)' }}>
        Esquema sin calles: funciona sin internet. Círculo grande = zona de ~1 km; punto = zona de ~100 m. Anillos
        cada {ringStep} km.
      </p>

      <section aria-label="Lista de lo que hay en el mapa">
        <h2 style={{ fontSize: '1.05rem', margin: '4px 0 8px' }}>Cerca de ti ({visible.length})</h2>
        {visible.length === 0 && <div className="empty">No hay nada que mostrar con estos filtros.</div>}
        {visible.map((m) => (
          <article
            key={`${m.id}-${version}`}
            className="card"
            style={selected === m.id ? { outline: '2px solid var(--teal)' } : undefined}
          >
            <div style={{ display: 'flex', justifyContent: 'space-between', gap: 8 }}>
              <h3>
                {m.icon} {m.title}
              </h3>
              <span className="badge" style={{ whiteSpace: 'nowrap', alignSelf: 'flex-start' }}>
                ~{formatDistance(m.km)}
              </span>
            </div>
            <p>{m.sub}</p>
            <p>
              <button type="button" className="btn small" onClick={m.open}>
                {m.openLabel}
              </button>
            </p>
          </article>
        ))}
      </section>
    </div>
  );
}
