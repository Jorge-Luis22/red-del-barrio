import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from 'react';
import { getUser, saveProfile, retryPending } from '../db/repo';
import { openDb } from '../db/sqlite';

export interface Session {
  userId: string;
  name: string;
  zone: string;
  lat: number;
  lng: number;
}

const SESSION_KEY = 'redvecinal.session.v1';

const DEFAULT_SESSION: Session = {
  userId: 'u_lucia',
  name: 'Lucía',
  zone: import.meta.env.VITE_DEFAULT_ZONE ?? 'Los Olivos, Lima',
  lat: Number(import.meta.env.VITE_DEFAULT_LAT ?? -11.989),
  lng: Number(import.meta.env.VITE_DEFAULT_LNG ?? -77.071),
};

function readSession(): Session {
  try {
    const raw = localStorage.getItem(SESSION_KEY);
    if (!raw) return DEFAULT_SESSION;
    return { ...DEFAULT_SESSION, ...(JSON.parse(raw) as Partial<Session>) };
  } catch {
    return DEFAULT_SESSION;
  }
}

interface StoreValue {
  ready: boolean;
  error: string | null;
  session: Session;
  online: boolean;
  revision: number;
  bump: () => void;
  updateProfile: (patch: Partial<Pick<Session, 'name' | 'zone'>>) => Promise<void>;
}

const StoreContext = createContext<StoreValue | null>(null);

export function StoreProvider({ children }: { children: ReactNode }) {
  const [ready, setReady] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [session, setSession] = useState<Session>(readSession);
  const [online, setOnline] = useState(
    typeof navigator === 'undefined' ? true : navigator.onLine,
  );
  const [revision, setRevision] = useState(0);

  const bump = useCallback(() => setRevision((value) => value + 1), []);

  useEffect(() => {
    let alive = true;
    (async () => {
      try {
        await openDb();
        const user = getUser(session.userId);
        if (user && alive) {
          setSession((current) => ({
            ...current,
            name: user.name,
            zone: user.zone || current.zone,
            lat: user.lat ?? current.lat,
            lng: user.lng ?? current.lng,
          }));
        }
        if (alive) setReady(true);
      } catch (cause) {
        if (alive) {
          setError(cause instanceof Error ? cause.message : 'No se pudo abrir la base local');
        }
      }
    })();
    return () => {
      alive = false;
    };
    // Solo al montar: la sesión inicial es la de este dispositivo.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  useEffect(() => {
    const goOnline = () => {
      setOnline(true);
      void retryPending().then((delivered) => {
        if (delivered > 0) bump();
      });
    };
    const goOffline = () => setOnline(false);
    window.addEventListener('online', goOnline);
    window.addEventListener('offline', goOffline);
    return () => {
      window.removeEventListener('online', goOnline);
      window.removeEventListener('offline', goOffline);
    };
  }, [bump]);

  const updateProfile = useCallback(
    async (patch: Partial<Pick<Session, 'name' | 'zone'>>) => {
      const next = { ...session, ...patch };
      setSession(next);
      try {
        localStorage.setItem(SESSION_KEY, JSON.stringify(next));
      } catch {
        /* modo privado: la sesión vive solo en memoria */
      }
      await saveProfile(next.userId, patch);
      bump();
    },
    [session, bump],
  );

  const value = useMemo<StoreValue>(
    () => ({ ready, error, session, online, revision, bump, updateProfile }),
    [ready, error, session, online, revision, bump, updateProfile],
  );

  return <StoreContext.Provider value={value}>{children}</StoreContext.Provider>;
}

export function useStore(): StoreValue {
  const value = useContext(StoreContext);
  if (!value) throw new Error('useStore debe usarse dentro de <StoreProvider>');
  return value;
}
