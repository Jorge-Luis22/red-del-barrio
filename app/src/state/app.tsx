import { createContext, useContext, useEffect, useMemo, useRef, useState, type ReactNode } from 'react';
import { flushSync } from 'react-dom';
import { createPilotUser, emergencySignal, getUser, updateMyApproxPosition } from '../db/repo';
import { fetchMyMember, getSessionUserId, isMemberMarked, onSessionLost } from '../lib/auth';
import { getCurrentPoint, requestPosition, type GpsStatus } from '../lib/geo';
import { PILOT } from '../lib/mode';
import { onSyncChanged, syncConfigured, syncNow } from '../lib/sync';
import { openDb, wipeDb } from '../db/sqlite';
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
  /** Piloto: todavía no entró al barrio (falta el código) y, si aplica, por qué se le vuelve a pedir. */
  needsOnboarding: boolean;
  notice: string | null;
  completeOnboarding(user: User): void;
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
  const [needsOnboarding, setNeedsOnboarding] = useState(false);
  const [notice, setNotice] = useState<string | null>(null);

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
      if (PILOT) {
        // Piloto: la cuenta es la de este teléfono; si falta el perfil local se reconstruye desde el servidor.
        const id = getSessionUserId();
        let user = id && isMemberMarked() ? getUser(id) : null;
        if (id && isMemberMarked() && !user) {
          try {
            const member = await fetchMyMember();
            if (member) user = await createPilotUser({ id, name: member.display_name, zone: member.zone });
          } catch {
            /* sin red: se vuelve a pedir el código */
          }
        }
        if (!alive) return;
        setMe(user);
        setNeedsOnboarding(!user);
        setReady(true);
        return;
      }
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

  // Piloto: si el servidor rechaza la sesión de este teléfono, la cuenta ya no existe aquí.
  useEffect(() => {
    if (!PILOT) return;
    return onSessionLost(() => {
      void (async () => {
        // Primero se quitan las pantallas que leen la base (render síncrono) y recién después se borra.
        flushSync(() => {
          setMe(null);
          setNotice('session_lost');
          setNeedsOnboarding(true);
          setTabState('inicio');
          setScreen({ name: 'none' });
        });
        await wipeDb();
      })();
    });
  }, []);

  // Piloto: publico mi posición redondeada a ~1 km cuando el GPS responde.
  useEffect(() => {
    if (!PILOT || !ready || !me || gps !== 'ok') return;
    const point = getCurrentPoint();
    if (point) void updateMyApproxPosition(me.id, point).then((changed) => changed && setVersion((v) => v + 1));
  }, [ready, me?.id, gps]);

  // Sincronización: al abrir, cada 4 s, al volver la red y poco después de cada cambio local.
  useEffect(() => {
    if (!ready || !syncConfigured || (PILOT && !me)) return;
    let alive = true;
    // Cualquier sincronización que traiga cambios (también las repetidas) refresca la pantalla.
    const unsubscribe = onSyncChanged(() => {
      if (alive) setVersion((v) => v + 1);
    });
    const tick = () => void syncNow();
    tick();
    const timer = window.setInterval(tick, 4000);
    window.addEventListener('online', tick);
    document.addEventListener('visibilitychange', tick);
    return () => {
      alive = false;
      unsubscribe();
      window.clearInterval(timer);
      window.removeEventListener('online', tick);
      document.removeEventListener('visibilitychange', tick);
    };
  }, [ready, me?.id]);

  useEffect(() => {
    if (!ready || !syncConfigured || (PILOT && !me)) return;
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
      needsOnboarding,
      notice,
      completeOnboarding: (user) => {
        setMe(user);
        setNeedsOnboarding(false);
        setNotice(null);
        setTabState('inicio');
        setScreen({ name: 'none' });
        setVersion((v) => v + 1);
      },
    }),
    [ready, me, tab, screen, version, gps, needsOnboarding, notice],
  );

  return <Ctx.Provider value={value}>{children}</Ctx.Provider>;
}

export function useApp(): AppState {
  const ctx = useContext(Ctx);
  if (!ctx) throw new Error('useApp fuera de AppProvider');
  return ctx;
}
