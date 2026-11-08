import { useMemo, useState } from 'react';
import { createNeed, createProposal, listNeeds } from '../db/repo';
import { formatDistance } from '../lib/geo';
import { money } from '../lib/format';
import { NEED_LABEL, type Need, type NeedType } from '../types';
import { useStore } from '../state/store';
import { Icon } from '../ui/Icon';
import { NeedCard } from '../ui/NeedCard';
import { Sheet } from '../ui/Sheet';

const TYPES: NeedType[] = ['servicio', 'producto', 'prestamo', 'ayuda'];

const CATEGORIES = [
  'Gasfitería',
  'Electricidad',
  'Carpintería',
  'Cerrajería',
  'Cuidado',
  'Limpieza',
  'Comida',
  'Herramientas',
  'Otros',
];

export function Inicio({ onEmergency }: { onEmergency: () => void }) {
  const { session, online, revision, bump } = useStore();
  const [query, setQuery] = useState('');
  const [filter, setFilter] = useState<NeedType | 'todos'>('todos');
  const [publishing, setPublishing] = useState(false);
  const [offerFor, setOfferFor] = useState<Need | null>(null);

  const point = { lat: session.lat, lng: session.lng };
  const needs = useMemo(
    () => listNeeds(point, { q: query, type: filter }),
    // revision fuerza a releer después de cada escritura
    [revision, query, filter, session.lat, session.lng],
  );

  return (
    <div className="screen-body">
      <header className="topbar">
        <div>
          <p className="eyebrow">{session.zone}</p>
          <h1>Hola, {session.name.split(' ')[0]}</h1>
        </div>
        <button
          type="button"
          className="icon-btn"
          aria-label="Activar modo emergencia"
          onClick={onEmergency}
        >
          <Icon name="alert" size={22} />
        </button>
      </header>

      {!online ? (
        <div className="banner banner-warn">
          <Icon name="wifiOff" size={18} />
          <div>
            <strong>Sin conexión</strong>
            <p>Puedes seguir publicando. Tus mensajes se envían al volver la señal.</p>
          </div>
        </div>
      ) : null}

      <button type="button" className="emergency-strip" onClick={onEmergency}>
        <span className="strip-icon">
          <Icon name="shield" size={20} />
        </span>
        <span className="grow">
          <strong>¿Emergencia en el barrio?</strong>
          <small>Activa la red vecinal. La institución oficial va primero.</small>
        </span>
        <Icon name="chevron" size={18} />
      </button>

      <div className="search">
        <Icon name="search" size={18} />
        <input
          type="search"
          placeholder="Buscar gasfitero, comida, préstamo…"
          value={query}
          onChange={(event) => setQuery(event.target.value)}
          aria-label="Buscar en tu zona"
        />
      </div>

      <div className="chips" role="group" aria-label="Filtrar por tipo">
        <button
          type="button"
          className={filter === 'todos' ? 'chip chip-active' : 'chip'}
          onClick={() => setFilter('todos')}
        >
          Todo
        </button>
        {TYPES.map((type) => (
          <button
            key={type}
            type="button"
            className={filter === type ? 'chip chip-active' : 'chip'}
            onClick={() => setFilter(type)}
          >
            {NEED_LABEL[type]}
          </button>
        ))}
      </div>

      <div className="section-head">
        <h2>Cerca de ti</h2>
        <span className="count">{needs.length}</span>
      </div>

      {needs.length === 0 ? (
        <div className="empty">
          <Icon name="search" size={28} />
          <p>No hay publicaciones con ese filtro.</p>
          <button type="button" className="btn btn-ghost" onClick={() => setPublishing(true)}>
            Publicar la primera
          </button>
        </div>
      ) : (
        <div className="stack">
          {needs.map((need) => (
            <NeedCard
              key={need.id}
              need={need}
              mine={need.authorId === session.userId}
              onOffer={setOfferFor}
            />
          ))}
        </div>
      )}

      <button type="button" className="fab" onClick={() => setPublishing(true)}>
        <Icon name="plus" size={22} />
        Pedir ayuda
      </button>

      {publishing ? (
        <PublishSheet
          onClose={() => setPublishing(false)}
          onDone={() => {
            setPublishing(false);
            bump();
          }}
        />
      ) : null}

      {offerFor ? (
        <OfferSheet
          need={offerFor}
          onClose={() => setOfferFor(null)}
          onDone={() => {
            setOfferFor(null);
            bump();
          }}
        />
      ) : null}
    </div>
  );
}

function PublishSheet({ onClose, onDone }: { onClose: () => void; onDone: () => void }) {
  const { session } = useStore();
  const [type, setType] = useState<NeedType>('servicio');
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [category, setCategory] = useState(CATEGORIES[0]);
  const [busy, setBusy] = useState(false);

  const submit = async () => {
    if (title.trim().length < 4 || busy) return;
    setBusy(true);
    try {
      await createNeed({
        authorId: session.userId,
        type,
        title,
        description,
        category,
        zone: session.zone,
        point: { lat: session.lat, lng: session.lng },
      });
      onDone();
    } finally {
      setBusy(false);
    }
  };

  return (
    <Sheet
      title="Pedir ayuda"
      subtitle="Tu dirección exacta no se publica: solo la zona aproximada."
      onClose={onClose}
    >
      <div className="field">
        <span className="label">¿Qué necesitas?</span>
        <div className="chips">
          {TYPES.map((item) => (
            <button
              key={item}
              type="button"
              className={type === item ? 'chip chip-active' : 'chip'}
              onClick={() => setType(item)}
            >
              {NEED_LABEL[item]}
            </button>
          ))}
        </div>
      </div>

      <label className="field">
        <span className="label">Título</span>
        <input
          className="input"
          value={title}
          maxLength={80}
          placeholder="Ej. Necesito un gasfitero hoy"
          onChange={(event) => setTitle(event.target.value)}
        />
      </label>

      <label className="field">
        <span className="label">Detalle (opcional)</span>
        <textarea
          className="input textarea"
          value={description}
          maxLength={280}
          rows={3}
          placeholder="Cuenta lo justo para que un vecino pueda ayudarte."
          onChange={(event) => setDescription(event.target.value)}
        />
      </label>

      <label className="field">
        <span className="label">Rubro</span>
        <select className="input" value={category} onChange={(event) => setCategory(event.target.value)}>
          {CATEGORIES.map((item) => (
            <option key={item} value={item}>
              {item}
            </option>
          ))}
        </select>
      </label>

      <div className="note">
        <Icon name="pin" size={16} />
        Se publicará como <strong>{session.zone}</strong> con un radio aproximado de 110 m.
      </div>

      <button
        type="button"
        className="btn btn-primary btn-block"
        disabled={title.trim().length < 4 || busy}
        onClick={submit}
      >
        {busy ? 'Publicando…' : 'Publicar necesidad'}
      </button>
    </Sheet>
  );
}

function OfferSheet({
  need,
  onClose,
  onDone,
}: {
  need: Need;
  onClose: () => void;
  onDone: () => void;
}) {
  const { session } = useStore();
  const [price, setPrice] = useState('');
  const [message, setMessage] = useState('');
  const [eta, setEta] = useState('');
  const [busy, setBusy] = useState(false);
  const [done, setDone] = useState(false);

  const cents = Math.round(Number(price.replace(',', '.')) * 100);
  const valid = Number.isFinite(cents) && cents >= 0 && message.trim().length > 3;

  const submit = async () => {
    if (!valid || busy) return;
    setBusy(true);
    try {
      await createProposal({
        needId: need.id,
        providerId: session.userId,
        priceCents: cents,
        message,
        eta,
      });
      setDone(true);
    } finally {
      setBusy(false);
    }
  };

  if (done) {
    return (
      <Sheet title="Propuesta enviada" onClose={onDone}>
        <div className="success">
          <span className="success-icon">
            <Icon name="check" size={26} />
          </span>
          <p>
            {need.authorName} verá tu propuesta de <strong>{money(cents)}</strong>. Si la acepta, se
            abre un chat y un código de encuentro de 4 dígitos.
          </p>
        </div>
        <button type="button" className="btn btn-primary btn-block" onClick={onDone}>
          Entendido
        </button>
      </Sheet>
    );
  }

  return (
    <Sheet title={`Ayudar a ${need.authorName.split(' ')[0]}`} subtitle={need.title} onClose={onClose}>
      <label className="field">
        <span className="label">Tu precio (S/)</span>
        <input
          className="input"
          inputMode="decimal"
          placeholder="0 = gratis"
          value={price}
          onChange={(event) => setPrice(event.target.value)}
        />
      </label>

      <label className="field">
        <span className="label">¿Qué incluye?</span>
        <textarea
          className="input textarea"
          rows={3}
          maxLength={220}
          placeholder="Ej. Llevo tubo y sellador. Puedo a las 4 p. m."
          value={message}
          onChange={(event) => setMessage(event.target.value)}
        />
      </label>

      <label className="field">
        <span className="label">Disponibilidad</span>
        <input
          className="input"
          placeholder="Ej. Hoy 4:00 p. m."
          value={eta}
          onChange={(event) => setEta(event.target.value)}
        />
      </label>

      <p className="note">
        <Icon name="pin" size={16} />
        Distancia aproximada: {formatDistance(need.distanceKm) || 'zona cercana'}.
      </p>

      <button type="button" className="btn btn-primary btn-block" disabled={!valid || busy} onClick={submit}>
        {busy ? 'Enviando…' : 'Enviar propuesta'}
      </button>
    </Sheet>
  );
}
