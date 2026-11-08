import { formatDistance } from '../lib/geo';
import { timeAgo } from '../lib/format';
import { NEED_LABEL, type Need } from '../types';
import { Icon } from './Icon';
import { Avatar } from './Sheet';

export function NeedCard({
  need,
  mine,
  onOffer,
}: {
  need: Need;
  mine: boolean;
  onOffer: (need: Need) => void;
}) {
  return (
    <article className="card need-card">
      <header className="card-head">
        <Avatar name={need.authorName} color={need.authorColor} size={38} />
        <div className="grow">
          <p className="card-name">
            {need.authorName}
            {mine ? <span className="tag tag-soft">Tú</span> : null}
          </p>
          <p className="card-meta">
            {timeAgo(need.createdAt)} · {need.zone}
          </p>
        </div>
        <span className={`type-pill type-${need.type}`}>{NEED_LABEL[need.type]}</span>
      </header>

      <h3 className="need-title">{need.title}</h3>
      <p className="need-desc">{need.description}</p>

      <footer className="card-foot">
        <span className="meta-line">
          <Icon name="pin" size={15} />
          {formatDistance(need.distanceKm) || 'Zona aproximada'}
        </span>
        <span className="meta-line">
          <Icon name="star" size={15} filled />
          {need.recommendations} {need.recommendations === 1 ? 'vecino' : 'vecinos'}
        </span>
        <span className="chip chip-ghost">{need.category}</span>
      </footer>

      {!mine ? (
        <button type="button" className="btn btn-soft btn-block" onClick={() => onOffer(need)}>
          Ofrecer ayuda
        </button>
      ) : (
        <p className="own-note">
          <Icon name="clock" size={15} /> Esperando propuestas de tus vecinos
        </p>
      )}
    </article>
  );
}
