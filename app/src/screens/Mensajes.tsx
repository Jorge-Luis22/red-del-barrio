import { useEffect, useMemo } from 'react';
import { listConversations, retryPending } from '../db/repo';
import { clockTime, timeAgo } from '../lib/format';
import { chat } from '../lib/matrix';
import { useStore } from '../state/store';
import { Icon } from '../ui/Icon';
import { Avatar } from '../ui/Sheet';

export function Mensajes({ onOpen }: { onOpen: (id: string) => void }) {
  const { session, revision, bump } = useStore();

  const conversations = useMemo(
    () => listConversations(session.userId),
    [revision, session.userId],
  );

  useEffect(() => {
    let alive = true;
    void retryPending().then((delivered) => {
      if (alive && delivered > 0) bump();
    });
    return () => {
      alive = false;
    };
  }, [bump]);

  return (
    <div className="screen-body">
      <header className="topbar">
        <div>
          <p className="eyebrow">Tratos acordados</p>
          <h1>Mensajes</h1>
        </div>
        <span className={chat.kind === 'matrix' ? 'pill pill-ok' : 'pill'}>
          <Icon name={chat.kind === 'matrix' ? 'shield' : 'chat'} size={14} />
          {chat.label}
        </span>
      </header>

      {conversations.length === 0 ? (
        <div className="empty">
          <Icon name="chat" size={30} />
          <p>Todavía no tienes tratos.</p>
          <small>Cuando acepten una propuesta se abre aquí un chat con un código de encuentro.</small>
        </div>
      ) : (
        <div className="stack">
          {conversations.map((conversation) => (
            <button
              key={conversation.id}
              type="button"
              className="card conversation"
              onClick={() => onOpen(conversation.id)}
            >
              <Avatar name={conversation.otherName} color={conversation.otherColor} size={46} />
              <div className="grow">
                <div className="row row-between">
                  <p className="card-name">{conversation.otherName}</p>
                  <span className="card-meta">
                    {conversation.lastAt ? clockTime(conversation.lastAt) : timeAgo(conversation.createdAt)}
                  </span>
                </div>
                <p className="conv-need">{conversation.needTitle}</p>
                <p className="conv-last">{conversation.lastBody ?? 'Trato acordado. Coordinen aquí.'}</p>
              </div>
              {conversation.pending > 0 ? (
                <span className="pending-badge" title="Mensajes pendientes de envío">
                  <Icon name="clock" size={13} />
                  {conversation.pending}
                </span>
              ) : null}
            </button>
          ))}
        </div>
      )}
    </div>
  );
}
