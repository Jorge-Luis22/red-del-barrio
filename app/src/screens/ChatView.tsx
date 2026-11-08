import { useEffect, useMemo, useRef, useState } from 'react';
import { getConversation, listMessages, retryPending, sendChatMessage } from '../db/repo';
import { clockTime, money } from '../lib/format';
import { chat } from '../lib/matrix';
import { useStore } from '../state/store';
import { Icon } from '../ui/Icon';
import { Avatar } from '../ui/Sheet';

export function ChatView({
  conversationId,
  onClose,
}: {
  conversationId: string;
  onClose: () => void;
}) {
  const { session, revision, bump } = useStore();
  const [text, setText] = useState('');
  const [sending, setSending] = useState(false);
  const listRef = useRef<HTMLDivElement>(null);

  const conversation = useMemo(
    () => getConversation(conversationId, session.userId),
    [conversationId, session.userId, revision],
  );
  const messages = useMemo(
    () => listMessages(conversationId, session.userId),
    [conversationId, session.userId, revision],
  );

  const meetCode = useMemo(() => {
    try {
      return sessionStorage.getItem(`meetcode:${conversationId}`);
    } catch {
      return null;
    }
  }, [conversationId, revision]);

  useEffect(() => {
    const node = listRef.current;
    if (node) node.scrollTop = node.scrollHeight;
  }, [messages.length]);

  useEffect(() => {
    let alive = true;
    void retryPending(conversationId).then((delivered) => {
      if (alive && delivered > 0) bump();
    });
    return () => {
      alive = false;
    };
    // solo al abrir este chat
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [conversationId]);

  const send = async () => {
    if (!text.trim() || sending) return;
    setSending(true);
    const body = text;
    setText('');
    try {
      await sendChatMessage(conversationId, session.userId, body);
      bump();
    } finally {
      setSending(false);
    }
  };

  if (!conversation) {
    return (
      <div className="chat-screen">
        <header className="chat-head">
          <button type="button" className="icon-btn" onClick={onClose} aria-label="Volver">
            <Icon name="back" size={22} />
          </button>
          <h2>Chat no encontrado</h2>
        </header>
      </div>
    );
  }

  return (
    <div className="chat-screen" role="dialog" aria-modal="true" aria-label={`Chat con ${conversation.otherName}`}>
      <header className="chat-head">
        <button type="button" className="icon-btn" onClick={onClose} aria-label="Volver">
          <Icon name="back" size={22} />
        </button>
        <Avatar name={conversation.otherName} color={conversation.otherColor} size={38} />
        <div className="grow">
          <h2>{conversation.otherName}</h2>
          <p className="chat-sub">
            {conversation.needTitle} · {money(conversation.priceCents)}
          </p>
        </div>
        <span className={chat.kind === 'matrix' ? 'pill pill-ok' : 'pill'}>{chat.kind === 'matrix' ? 'Matrix' : 'Local'}</span>
      </header>

      <div className="chat-meta">
        <span className="room-id" title="Room de Matrix asociado a este trato">
          {conversation.roomId ?? 'sin room'}
        </span>
        {meetCode ? (
          <span className="meet-code">
            <Icon name="shield" size={14} /> Código de encuentro: <strong>{meetCode}</strong>
          </span>
        ) : (
          <span className="meet-code muted">El código lo ve quien pidió el servicio</span>
        )}
      </div>

      <div className="chat-list" ref={listRef}>
        {messages.map((message) =>
          message.system ? (
            <p key={message.id} className="system-msg">
              {message.body}
            </p>
          ) : (
            <div key={message.id} className={message.mine ? 'bubble-row mine' : 'bubble-row'}>
              <div className={message.mine ? 'bubble bubble-mine' : 'bubble'}>
                <p>{message.body}</p>
                <span className="bubble-meta">
                  {clockTime(message.createdAt)}
                  {message.mine && message.status === 'pendiente' ? (
                    <em className="bubble-pending">
                      <Icon name="clock" size={12} /> Pendiente de envío
                    </em>
                  ) : null}
                </span>
              </div>
            </div>
          ),
        )}
      </div>

      <form
        className="composer"
        onSubmit={(event) => {
          event.preventDefault();
          void send();
        }}
      >
        <input
          className="input"
          value={text}
          placeholder="Escribe al vecino…"
          onChange={(event) => setText(event.target.value)}
          aria-label="Mensaje"
        />
        <button type="submit" className="send-btn" disabled={!text.trim() || sending} aria-label="Enviar">
          <Icon name="send" size={20} />
        </button>
      </form>
    </div>
  );
}
