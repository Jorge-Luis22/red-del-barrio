import type { Database, SqlJsStatic, SqlValue } from 'sql.js';
import { del, get, set } from 'idb-keyval';
import schemaSql from './schema.sql?raw';
import seedSql from './seed.sql?raw';

const DB_KEY = 'redvecinal.sqlite.v1';

type InitSqlJs = (config?: { locateFile?: (file: string) => string }) => Promise<SqlJsStatic>;

declare global {
  interface Window {
    initSqlJs?: InitSqlJs;
  }
}

let engine: SqlJsStatic | null = null;
let db: Database | null = null;

function injectScript(src: string): Promise<void> {
  return new Promise((resolve, reject) => {
    const script = document.createElement('script');
    script.src = src;
    script.async = true;
    script.onload = () => resolve();
    script.onerror = () => reject(new Error(`No se pudo cargar el motor SQLite (${src})`));
    document.head.appendChild(script);
  });
}

let opening: Promise<Database> | null = null;

/** Abre (o crea) la base local. Idempotente: se llama una vez al arrancar. */
export function openDb(): Promise<Database> {
  if (db) return Promise.resolve(db);
  if (!opening) {
    opening = openInternal().catch((error) => {
      opening = null;
      throw error;
    });
  }
  return opening;
}

async function openInternal(): Promise<Database> {
  const base = import.meta.env.BASE_URL;
  if (!window.initSqlJs) {
    await injectScript(`${base}vendor/sql-wasm.js`);
  }
  if (!window.initSqlJs) {
    throw new Error('sql.js no está disponible. Ejecuta `npm install` para copiar el motor.');
  }

  engine = await window.initSqlJs({
    locateFile: (file) => `${base}vendor/${file}`,
  });

  const saved = await get<Uint8Array>(DB_KEY);
  db = saved && saved.byteLength > 0 ? new engine.Database(saved) : new engine.Database();
  db.exec(schemaSql);

  const result = db.exec('SELECT COUNT(*) FROM users');
  const empty = !result.length || Number(result[0].values[0]?.[0] ?? 0) === 0;
  if (empty) {
    db.exec(seedSql);
  }

  await persist();
  return db;
}

/** Vuelca la base a IndexedDB. Llamar después de cada escritura. */
export async function persist(): Promise<void> {
  if (!db) return;
  await set(DB_KEY, db.export());
}

function handle(): Database {
  if (!db) throw new Error('La base de datos no está abierta');
  return db;
}

export function all<T>(sqlText: string, params: SqlValue[] = []): T[] {
  const stmt = handle().prepare(sqlText);
  try {
    if (params.length) stmt.bind(params);
    const rows: T[] = [];
    while (stmt.step()) {
      rows.push(stmt.getAsObject() as unknown as T);
    }
    return rows;
  } finally {
    stmt.free();
  }
}

export function one<T>(sqlText: string, params: SqlValue[] = []): T | null {
  return all<T>(sqlText, params)[0] ?? null;
}

export function run(sqlText: string, params: SqlValue[] = []): void {
  handle().run(sqlText, params);
}

export function count(sqlText: string, params: SqlValue[] = []): number {
  const row = one<{ n: number }>(sqlText, params);
  return Number(row?.n ?? 0);
}

/** Tamaño aproximado de la base, para mostrarlo en Perfil. */
export function sizeBytes(): number {
  if (!db) return 0;
  try {
    const pageCount = Number(db.exec('PRAGMA page_count')[0]?.values[0]?.[0] ?? 0);
    const pageSize = Number(db.exec('PRAGMA page_size')[0]?.values[0]?.[0] ?? 0);
    return pageCount * pageSize;
  } catch {
    return 0;
  }
}

/** Borra todo (Perfil → Borrar mis datos). */
export async function wipeDb(): Promise<void> {
  if (db) {
    db.close();
    db = null;
  }
  engine = null;
  await del(DB_KEY);
  await openDb();
}
