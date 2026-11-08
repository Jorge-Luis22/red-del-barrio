import { countWallAlerts } from '../db/repo';
import { useApp } from '../state/app';
import type { Tab } from '../types';

const TABS: { id: Tab; label: string; icon: string }[] = [
  { id: 'inicio', label: 'Inicio', icon: '🏠' },
  { id: 'vecinos', label: 'Vecinos', icon: '🤝' },
  { id: 'mensajes', label: 'Mensajes', icon: '💬' },
  { id: 'emergencia', label: 'Emergencia', icon: '🚨' },
  { id: 'perfil', label: 'Perfil', icon: '👤' },
];

export default function TabBar() {
  const { me, tab, setTab } = useApp();
  // Alertas activas de otros vecinos: se recalcula en cada cambio (también cuando llega algo del servidor).
  const alerts = me ? countWallAlerts(me.id) : 0;
  return (
    <nav className="tabbar" aria-label="Navegación principal">
      {TABS.map((t) => (
        <button
          key={t.id}
          type="button"
          className={tab === t.id ? 'tab active' : 'tab'}
          onClick={() => setTab(t.id)}
          aria-current={tab === t.id ? 'page' : undefined}
        >
          <span className="tab-icon" aria-hidden="true">
            {t.icon}
            {t.id === 'emergencia' && alerts > 0 ? <span className="tab-dot">{alerts > 9 ? '9+' : alerts}</span> : null}
          </span>
          <span>
            {t.label}
            {t.id === 'emergencia' && alerts > 0 ? <span className="sr-only">, {alerts} alertas activas</span> : null}
          </span>
        </button>
      ))}
    </nav>
  );
}
