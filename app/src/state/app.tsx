import { createContext, useContext, useEffect, useMemo, useState, type ReactNode } from 'react';
import { getUser } from '../db/repo';
import { requestPosition, type GpsStatus } from '../lib/geo';
import { openDb } from '../db/sqlite';
import type { Tab, User } from '../types';

export type Screen =
  | { name: 'none' }
  | { name: 'need'; id: string }
  | { name: 'chat'; id: string };

interface AppState {
  ready: boolean;
  me: User | null;
  tab: Tab;
  screen: Screen;
  version: number;
  gps: GpsStatus;
  refreshGps(): Promise<void>;
  setTab(t: Tab): void;
  go(s: Screen): void;
  bump(): void;
  switchUser(id: string): void;
}

const Ctx = createContext<AppState | null>(null);
const CURRENT_USER_KEY = 'redvecinal.currentUser';
const SEED_USER = 'u_lucia';

export function AppProvider({ children }: { children: ReactNode }) {
  const [ready, setReady] = useState(false);
  const [me, setMe] = useState<User | null>(null);
  const [tab, setTabState] = useState<Tab>('inicio');
  const [screen, setScreen] = useState<Screen>({ name: 'none' });
  const [version, setVersion] = useState(0);
  const [gps, setGps] = useState<GpsStatus>('pendiente');

  const refreshGps = async () => {
    setGps('pendiente');
    const status = await requestPosition();
    setGps(status);
    setVersion((v) => v + 1);
  };

  useEffect(() => {
    void refreshGps();
  }, []);

  useEffect(() => {
    let alive = true;
    (async () => {
      const db = await openDb();
      if (!alive) return;
      const stored = localStorage.getItem(CURRENT_USER_KEY);
      const user = getUser(stored ?? '') ?? getUser(SEED_USER);
      if (user) localStorage.setItem(CURRENT_USER_KEY, user.id);
      setMe(user);
      setReady(true);
    })().catch((error) => {
      console.error('[app] no se pudo abrir la base local', error);
      if (alive) setReady(true);
    });
    return () => {
      alive = false;
    };
  }, []);

  const value = useMemo<AppState>(
    () => ({
      ready,
      me,
      tab,
      screen,
      version,
      gps,
      refreshGps,
      setTab: (t) => {
        setTabState(t);
        setScreen({ name: 'none' });
      },
      go: setScreen,
      bump: () => setVersion((v) => v + 1),
      switchUser: (id) => {
        const user = getUser(id);
        if (!user) return;
        localStorage.setItem(CURRENT_USER_KEY, id);
        setMe(user);
        setTabState('inicio');
        setScreen({ name: 'none' });
        setVersion((v) => v + 1);
      },
    }),
    [ready, me, tab, screen, version, gps],
  );

  return <Ctx.Provider value={value}>{children}</Ctx.Provider>;
}

export function useApp(): AppState {
  const ctx = useContext(Ctx);
  if (!ctx) throw new Error('useApp fuera de AppProvider');
  return ctx;
}
