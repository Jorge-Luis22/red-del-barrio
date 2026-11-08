import type { ReactNode } from 'react';

export type IconName =
  | 'home'
  | 'swap'
  | 'chat'
  | 'alert'
  | 'user'
  | 'plus'
  | 'search'
  | 'send'
  | 'star'
  | 'clock'
  | 'check'
  | 'phone'
  | 'close'
  | 'pin'
  | 'shield'
  | 'spark'
  | 'back'
  | 'wifiOff'
  | 'store'
  | 'trash'
  | 'chevron';

const PATHS: Record<IconName, ReactNode> = {
  home: <><path d="M3 10.8 12 3.5l9 7.3" /><path d="M5.5 9.5V20h13V9.5" /></>,
  swap: <><path d="M4 8h13" /><path d="m14 5 3 3-3 3" /><path d="M20 16H7" /><path d="m10 13-3 3 3 3" /></>,
  chat: <><path d="M4 5.5h16v11H9l-5 4v-15Z" /><path d="M8 10h8M8 13h5" /></>,
  alert: <><path d="M12 3.5 21 20H3L12 3.5Z" /><path d="M12 9v5" /><path d="M12 17.2v.1" /></>,
  user: <><circle cx="12" cy="8" r="3.6" /><path d="M4.5 20c.7-3.6 3.8-5.5 7.5-5.5s6.8 1.9 7.5 5.5" /></>,
  plus: <><path d="M12 5v14M5 12h14" /></>,
  search: <><circle cx="11" cy="11" r="6.5" /><path d="m16 16 4.5 4.5" /></>,
  send: <><path d="M4 12 20 4l-4.5 16-4-6.5L4 12Z" /><path d="m11.5 13.5 4-4" /></>,
  star: <><path d="m12 3.8 2.6 5.3 5.9.8-4.3 4.1 1 5.8-5.2-2.8-5.2 2.8 1-5.8L3.5 9.9l5.9-.8L12 3.8Z" /></>,
  clock: <><circle cx="12" cy="12" r="8.5" /><path d="M12 7.5V12l3 2" /></>,
  check: <><path d="m5 12.5 4.5 4.5L19 6.5" /></>,
  phone: <><path d="M6 3.5h3l1.5 4-2 1.5a12 12 0 0 0 6.5 6.5l1.5-2 4 1.5v3c0 1.1-.9 2-2 2A16.5 16.5 0 0 1 4 4.5c0-1.1.9-2 2-2Z" /></>,
  close: <><path d="m6 6 12 12M18 6 6 18" /></>,
  pin: <><path d="M12 21s6.5-6 6.5-11a6.5 6.5 0 0 0-13 0C5.5 15 12 21 12 21Z" /><circle cx="12" cy="10" r="2.4" /></>,
  shield: <><path d="M12 3 5 6v5.5c0 4.3 3 7.6 7 9.5 4-1.9 7-5.2 7-9.5V6l-7-3Z" /><path d="m9 12 2 2 4-4" /></>,
  spark: <><path d="M12 3v4M12 17v4M3 12h4M17 12h4M5.6 5.6l2.8 2.8M15.6 15.6l2.8 2.8M18.4 5.6l-2.8 2.8M8.4 15.6l-2.8 2.8" /></>,
  back: <><path d="M15 5 8 12l7 7" /></>,
  wifiOff: <><path d="M3 3l18 18" /><path d="M8.5 15.5a5 5 0 0 1 7 0" /><path d="M5.5 12.5a10 10 0 0 1 3-2" /><path d="M15.5 10.5a10 10 0 0 1 3 2" /><path d="M12 19v.1" /></>,
  store: <><path d="M4 9h16l-1 11H5L4 9Z" /><path d="M8 9V7a4 4 0 0 1 8 0v2" /></>,
  trash: <><path d="M4 7h16" /><path d="M9 7V5h6v2" /><path d="M6 7l1 13h10l1-13" /></>,
  chevron: <><path d="m9 5 7 7-7 7" /></>,
};

export function Icon({
  name,
  size = 24,
  className,
  filled = false,
}: {
  name: IconName;
  size?: number;
  className?: string;
  filled?: boolean;
}) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 24 24"
      fill={filled ? 'currentColor' : 'none'}
      stroke="currentColor"
      strokeWidth={1.9}
      strokeLinecap="round"
      strokeLinejoin="round"
      className={className}
      aria-hidden="true"
      focusable="false"
    >
      {PATHS[name]}
    </svg>
  );
}
