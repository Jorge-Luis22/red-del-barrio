import type { Tab } from '../types';
import { Icon, type IconName } from './Icon';

const TABS: Array<{ id: Tab; label: string; icon: IconName }> = [
  { id: 'inicio', label: 'Inicio', icon: 'home' },
  { id: 'vecinos', label: 'Vecinos', icon: 'swap' },
  { id: 'mensajes', label: 'Mensajes', icon: 'chat' },
  { id: 'emergencia', label: 'Emergencia', icon: 'alert' },
  { id: 'perfil', label: 'Perfil', icon: 'user' },
];

export function TabBar({
  tab,
  onChange,
  pending,
}: {
  tab: Tab;
  onChange: (tab: Tab) => void;
  pending: number;
}) {
  return (
    <nav className="tabbar" aria-label="Secciones de la app">
      {TABS.map((item) => (
        <button
          key={item.id}
          type="button"
          className={item.id === 'emergencia' ? 'tab tab-emergency' : 'tab'}
          aria-current={tab === item.id ? 'page' : undefined}
          onClick={() => onChange(item.id)}
        >
          <span className="tab-icon">
            <Icon name={item.icon} size={23} />
            {item.id === 'mensajes' && pending > 0 ? (
              <span className="tab-dot" aria-label={`${pending} pendientes`}>
                {pending > 9 ? '9+' : pending}
              </span>
            ) : null}
          </span>
          <span>{item.label}</span>
        </button>
      ))}
    </nav>
  );
}
