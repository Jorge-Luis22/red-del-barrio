import type { Database, SqlJsStatic, SqlValue } from 'sql.js';
import { del, get, set } from 'idb-keyval';
import schemaSql from './schema.sql?raw';
import seedSql from './seed.sql?raw';
import seedOffersSql from './seed-offers.sql?raw';
import seedSolidarioSql from './seed-solidario.sql?raw';
import { PILOT } from '../lib/mode';

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

/** Sentencia CREATE TABLE de `schema.sql` para una tabla, con otro nombre (fuente única de la definición). */
function ddlFor(table: string, as: string): string {
  const found = schemaSql.match(new RegExp(`CREATE TABLE IF NOT EXISTS ${table} \\([\\s\\S]*?\\n\\);`));
  if (!found) throw new Error(`No se encontró la definición de ${table} en schema.sql`);
  return found[0].replace(`IF NOT EXISTS ${table}`, as);
}

const tableSql = (database: Database, table: string): string =>
  String(
    database.exec(`SELECT sql FROM sqlite_master WHERE type = 'table' AND name = '${table}'`)[0]?.values[0]?.[0] ?? '',
  );

/**
 * Migraciones de bases que ya existían en el teléfono. `CREATE TABLE IF NOT EXISTS` no cambia los CHECK de
 * una tabla vieja, así que, si falta algún valor nuevo, se reconstruye la tabla (receta oficial de SQLite:
 * crear la nueva, copiar, borrar la vieja, renombrar). Conserva todos los datos.
 *  - emergency_alerts.kind admite 'seguridad' (aviso de seguridad).
 *  - emergency_responses.status admite 'disputa' ("no es real o ya pasó").
 */
function migrate(database: Database): void {
  const alertsOld = !tableSql(database, 'emergency_alerts').includes("'seguridad'");
  const responsesOld = !tableSql(database, 'emergency_responses').includes("'disputa'");
  if (!alertsOld && !responsesOld) return;

  database.exec('PRAGMA foreign_keys = OFF'); // no puede cambiarse dentro de una transacción
  try {
    database.exec('BEGIN');
    if (alertsOld) {
      database.exec(
        `${ddlFor('emergency_alerts', 'emergency_alerts_new')}
         INSERT INTO emergency_alerts_new
           (id, author_id, kind, description, zone, lat_public, lng_public, lat_exact, lng_exact, status, institution_called, created_at)
         SELECT id, author_id, kind, description, zone, lat_public, lng_public, lat_exact, lng_exact, status, institution_called, created_at
           FROM emergency_alerts;
         DROP TABLE emergency_alerts;
         ALTER TABLE emergency_alerts_new RENAME TO emergency_alerts;`,
      );
    }
    if (responsesOld) {
      database.exec(
        `${ddlFor('emergency_responses', 'emergency_responses_new')}
         INSERT INTO emergency_responses_new (id, alert_id, helper_id, status, created_at, updated_at)
         SELECT id, alert_id, helper_id, status, created_at, updated_at FROM emergency_responses;
         DROP TABLE emergency_responses;
         ALTER TABLE emergency_responses_new RENAME TO emergency_responses;
         CREATE INDEX IF NOT EXISTS idx_emergency_resp_alert ON emergency_responses (alert_id, status);`,
      );
    }
    database.exec('COMMIT');
  } catch (error) {
    try {
      database.exec('ROLLBACK');
    } catch {
      /* ya no había transacción */
    }
    console.error('[db] migración fallida; se sigue con la base anterior', error);
  } finally {
    database.exec('PRAGMA foreign_keys = ON');
  }
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
  migrate(db);

  // Piloto con vecinos reales: nada de usuarios ni publicaciones de ejemplo.
  if (!PILOT) {
    const result = db.exec('SELECT COUNT(*) FROM users');
    const empty = !result.length || Number(result[0].values[0]?.[0] ?? 0) === 0;
    if (empty) {
      db.exec(seedSql);
    }
    db.exec(seedOffersSql);
    db.exec(seedSolidarioSql);
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

/** Cierra y borra la base sin volver a abrirla (se usa justo antes de recargar la página). */
export async function dropDb(): Promise<void> {
  if (db) {
    db.close();
    db = null;
  }
  engine = null;
  opening = null;
  await del(DB_KEY);
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
