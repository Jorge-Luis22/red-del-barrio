import { useEffect, useRef, useState, type FormEvent } from 'react';
import { getConversation, listMessages, retryPending, sendChatMessage } from '../db/repo';
import { chat } from '../lib/matrix';
import { useApp } from '../state/app';

export default function ChatView({ conversationId }: { conversationId: string }) {
  const { me, version, bump, go } = useApp();
  const [text, setText] = useState('');
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
