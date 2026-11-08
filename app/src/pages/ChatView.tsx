import { useEffect, useRef, useState, type FormEvent } from 'react';
import {
  confirmDone,
  getConversation,
  getDealState,
  listMessages,
  rateInteraction,
  retryPending,
  sendChatMessage,
} from '../db/repo';
import { chat } from '../lib/matrix';
import { useApp } from '../state/app';

export default function ChatView({ conversationId }: { conversationId: string }) {
  const { me, version, bump, go } = useApp();
  const [text, setText] = useState('');
  const [stars, setStars] = useState(0);
  const [comment, setComment] = useState('');
  const [busy, setBusy] = useState(false);
  const logRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const el = logRef.current;
    if (el) el.scrollTop = el.scrollHeight;
  }, [version]);

  if (!me) return null;

  const conversation = getConversation(conversationId, me.id);
  if (!conversation) {
    return (
      <div>
        <button type="button" className="back" onClick={() => go({ name: 'none' })}>
          ← Volver
        </button>
        <div className="empty">La conversación ya no existe.</div>
      </div>
    );
  }

  const messages = listMessages(conversationId, me.id);

  async function send(event: FormEvent) {
    event.preventDefault();
    if (!text.trim()) return;
    const body = text;
    setText('');
    await sendChatMessage(conversationId, me!.id, body);
    bump();
  }

  async function retry() {
    await retryPending(conversationId);
    bump();
  }

  const pending = messages.filter((m) => m.status === 'pendiente').length;
  const deal = getDealState(conversationId, me.id);

  async function markDone() {
    setBusy(true);
    try {
      await confirmDone(conversationId, me!.id);
    } finally {
      setBusy(false);
      bump();
    }
  }

  async function sendRating() {
    if (stars < 1) return;
    setBusy(true);
    try {
      await rateInteraction(conversationId, me!.id, stars, comment);
      setStars(0);
      setComment('');
    } finally {
      setBusy(false);
      bump();
    }
  }

  return (
    <div className="chat">
      <header className="chat-head">
        <button type="button" className="back" onClick={() => go({ name: 'none' })} aria-label="Volver">
          ←
        </button>
        <div>
          <h2>{conversation.otherName}</h2>
          <div className="sub">
            {conversation.needTitle} · {chat.label}
          </div>
        </div>
        {pending > 0 && (
          <button
            type="button"
            className="btn small"
            style={{ marginLeft: 'auto', background: 'var(--accent)', color: '#5b4200' }}
            onClick={retry}
          >
            Reintentar ({pending})
          </button>
        )}
      </header>

      {deal && deal.status !== 'cancelado' && (
        <section className="card" aria-live="polite" style={{ margin: '8px 12px' }}>
          {deal.status !== 'completado' && !deal.iConfirmed && (
            <>
              <h3 style={{ marginTop: 0 }}>¿Ya se hizo el trato?</h3>
              <p>Cuando se cumpla, confirma aquí. El trato se completa cuando confirman los dos.</p>
              <button type="button" className="btn block" onClick={markDone} disabled={busy}>
                Sí, ya se hizo
              </button>
            </>
          )}
          {deal.status !== 'completado' && deal.iConfirmed && (
            <p style={{ margin: 0 }}>
              Ya confirmaste. Falta que {deal.otherName} confirme para completar el trato.
            </p>
          )}
          {deal.status === 'completado' && !deal.iRated && (
            <>
              <h3 style={{ marginTop: 0 }}>Trato completado. Califica a {deal.otherName}</h3>
              <div className="meta" role="group" aria-label="Estrellas">
                {[1, 2, 3, 4, 5].map((n) => (
                  <button
                    key={n}
                    type="button"
                    className={n <= stars ? 'btn small' : 'btn small ghost'}
                    aria-pressed={n <= stars}
                    aria-label={`${n} ${n === 1 ? 'estrella' : 'estrellas'}`}
                    onClick={() => setStars(n)}
                  >
                    ★
                  </button>
                ))}
              </div>
              <label htmlFor="rate-comment">Comentario (opcional)</label>
              <input
                id="rate-comment"
                value={comment}
                onChange={(e) => setComment(e.target.value)}
                maxLength={200}
                placeholder="Puntual, buen trato…"
              />
              <p>
                <button type="button" className="btn block" onClick={sendRating} disabled={busy || stars < 1}>
                  Enviar calificación
                </button>
              </p>
            </>
          )}
          {deal.status === 'completado' && deal.iRated && (
            <p style={{ margin: 0 }}>
              Trato completado. Calificaste a {deal.otherName} con {deal.myStars} ★. Gracias.
            </p>
          )}
        </section>
      )}

      <div className="chat-log" ref={logRef}>
        {messages.map((m) => (
          <div
            key={m.id}
            className={m.system ? 'bubble system' : m.mine ? 'bubble mine' : 'bubble other'}
          >
            {m.body}
            {!m.system && (
              <span className={`state ${m.status === 'pendiente' ? 'pending' : ''}`}>
                {m.status === 'pendiente' ? 'Pendiente de envío' : m.status === 'fallido' ? 'Error al enviar' : ''}
              </span>
            )}
          </div>
        ))}
        {messages.length === 0 && <div className="empty">Escribe el primer mensaje para coordinar el trato.</div>}
      </div>

      <form className="chat-input" onSubmit={send}>
        <input
          value={text}
          onChange={(e) => setText(e.target.value)}
          placeholder="Escribe un mensaje…"
          maxLength={1000}
          aria-label="Mensaje"
        />
        <button type="submit" className="btn" disabled={!text.trim()}>
          Enviar
        </button>
      </form>
    </div>
  );
}
