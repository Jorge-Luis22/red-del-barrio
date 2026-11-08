import { createContext, useContext, useEffect, useMemo, useRef, useState, type ReactNode } from 'react';
import { emergencySignal, getUser } from '../db/repo';
import { requestPosition, type GpsStatus } from '../lib/geo';
import { syncConfigured, syncNow } from '../lib/sync';
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

  // Sincronización: al abrir, cada 4 s, al volver la red y poco después de cada cambio local.
  useEffect(() => {
    if (!ready || !syncConfigured) return;
    let alive = true;
    const tick = () =>
      void syncNow().then((changed) => {
        if (alive && changed) setVersion((v) => v + 1);
      });
    tick();
    const timer = window.setInterval(tick, 4000);
    window.addEventListener('online', tick);
    document.addEventListener('visibilitychange', tick);
    return () => {
      alive = false;
      window.clearInterval(timer);
      window.removeEventListener('online', tick);
      document.removeEventListener('visibilitychange', tick);
    };
  }, [ready]);

  useEffect(() => {
    if (!ready || !syncConfigured) return;
    const timer = window.setTimeout(() => void syncNow(), 400);
    return () => window.clearTimeout(timer);
  }, [ready, version]);

  // Aviso por vibración cuando llega una alerta nueva de un vecino o alguien ofrece ayudar en la mía.
  const lastSignal = useRef<{ user: string; n: number } | null>(null);
  useEffect(() => {
    if (!ready || !me) return;
    const n = emergencySignal(me.id);
    const prev = lastSignal.current;
    lastSignal.current = { user: me.id, n };
    if (prev && prev.user === me.id && n > prev.n && typeof navigator.vibrate === 'function') {
      navigator.vibrate([200, 100, 200]);
    }
  }, [ready, me, version]);

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
