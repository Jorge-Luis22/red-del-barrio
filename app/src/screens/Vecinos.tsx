import { useMemo, useState } from 'react';
import { listNeeds, listProviders, toggleRecommendation } from '../db/repo';
import { formatDistance } from '../lib/geo';
import { timeAgo } from '../lib/format';
import { NEED_LABEL } from '../types';
import { useStore } from '../state/store';
import { Icon } from '../ui/Icon';
import { Avatar } from '../ui/Sheet';

export function Vecinos() {
  const { session, revision, bump } = useStore();
  const [segment, setSegment] = useState<'proveedores' | 'muro'>('proveedores');
  const [busy, setBusy] = useState<string | null>(null);

  const point = { lat: session.lat, lng: session.lng };
  const providers = useMemo(
    () => listProviders(session.userId, point),
    [revision, session.userId, session.lat, session.lng],
  );
  const wall = useMemo(
    () => listNeeds(point, {}),
    [revision, session.lat, session.lng],
  );

  const recommend = async (providerId: string) => {
    setBusy(providerId);
    try {
      await toggleRecommendation(providerId, session.userId);
      bump();
    } finally {
      setBusy(null);
    }
  };

  return (
    <div className="screen-body">
      <header className="topbar">
        <div>
          <p className="eyebrow">Confianza vecinal</p>
          <h1>Tu barrio</h1>
        </div>
        <span className="level-pill">
          <Icon name="shield" size={15} /> {session.zone.split(',')[0]}
        </span>
      </header>

      <div className="segmented" role="group" aria-label="Ver proveedores o el muro">
        <button
          type="button"
          className={segment === 'proveedores' ? 'seg seg-active' : 'seg'}
          onClick={() => setSegment('proveedores')}
        >
          Proveedores
        </button>
        <button
          type="button"
          className={segment === 'muro' ? 'seg seg-active' : 'seg'}
          onClick={() => setSegment('muro')}
        >
          Muro del barrio
        </button>
      </div>

      {segment === 'proveedores' ? (
        <>
          <p className="lead">
            El <strong>Visto Bueno Vecinal</strong> se construye con interacciones confirmadas y
            recomendaciones de vecinos de la zona.
          </p>
          <div className="stack">
            {providers.map((provider) => (
              <article key={provider.id} className="card provider-card">
                <div className="row">
                  <Avatar name={provider.name} color={provider.color} size={46} />
                  <div className="grow">
                    <p className="card-name">{provider.name}</p>
                    <p className="card-meta">
                      {provider.category ?? 'Vecino'} · {formatDistance(provider.distanceKm) || 'tu zona'}
                    </p>
                  </div>
                  <span className="level-pill">{provider.level}</span>
                </div>

                {provider.latest ? <p className="provider-latest">“{provider.latest}”</p> : null}

                <div className="row row-between">
                  <span className={`visto ${provider.recommendations >= 2 ? 'visto-ok' : ''}`}>
                    <Icon name="shield" size={15} />
                    {provider.recommendations >= 2 ? 'Visto Bueno Vecinal' : 'Sin verificar'} ·{' '}
                    {provider.recommendations}
                  </span>
                  <button
                    type="button"
                    className={provider.recommendedByMe ? 'btn btn-sm btn-primary' : 'btn btn-sm btn-ghost'}
                    disabled={busy === provider.id}
                    onClick={() => void recommend(provider.id)}
                  >
                    {provider.recommendedByMe ? 'Recomendado' : 'Recomendar'}
                  </button>
                </div>
              </article>
            ))}
          </div>
          <p className="footnote">
            Un voto por vecino y por proveedor. Recomendar a alguien que aún no está en la lista lo
            deja como “sin verificar”.
          </p>
        </>
      ) : (
        <>
          <p className="lead">Pedidos y ofertas activos. Toca “Ofrecer ayuda” en Inicio para responder.</p>
          <div className="stack">
            {wall.map((need) => (
              <article key={need.id} className="card wall-row">
                <span className={`type-dot type-${need.type}`} aria-hidden="true" />
                <div className="grow">
                  <p className="wall-title">{need.title}</p>
                  <p className="card-meta">
                    {NEED_LABEL[need.type]} · {need.authorName} · {timeAgo(need.createdAt)} ·{' '}
                    {formatDistance(need.distanceKm) || 'zona'}
                  </p>
                </div>
                <span className="chip chip-ghost">{need.category}</span>
              </article>
            ))}
          </div>
        </>
      )}
    </div>
  );
}
