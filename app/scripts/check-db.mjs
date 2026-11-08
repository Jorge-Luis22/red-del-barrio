/**
 * Prueba de humo del esquema SQLite, sin navegador.
 * Uso: node scripts/check-db.mjs
 * Verifica que schema.sql + seed.sql se ejecutan y que las consultas
 * principales devuelven datos. Útil antes de tocar la UI.
 */
import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import initSqlJs from 'sql.js';

const root = resolve(import.meta.dirname, '..');
const schema = readFileSync(resolve(root, 'src/db/schema.sql'), 'utf8');
const seed = readFileSync(resolve(root, 'src/db/seed.sql'), 'utf8');

const SQL = await initSqlJs({
  locateFile: (file) => resolve(root, 'node_modules/sql.js/dist', file),
});

const db = new SQL.Database();
db.exec(schema);
db.exec(seed);

const scalar = (sql, params = []) => {
  const stmt = db.prepare(sql);
  if (params.length) stmt.bind(params);
  stmt.step();
  const value = stmt.getAsObject();
  stmt.free();
  return value;
};

const checks = [
  ['usuarios', 'SELECT COUNT(*) AS n FROM users'],
  ['necesidades abiertas', "SELECT COUNT(*) AS n FROM needs WHERE status = 'abierta'"],
  ['propuestas', 'SELECT COUNT(*) AS n FROM proposals'],
  ['tratos', 'SELECT COUNT(*) AS n FROM interactions'],
  ['mensajes', 'SELECT COUNT(*) AS n FROM messages'],
  ['pendientes de envío', "SELECT COUNT(*) AS n FROM messages WHERE status = 'pendiente'"],
];

let failed = 0;
for (const [label, sql] of checks) {
  const row = scalar(sql);
  const value = Number(row.n);
  console.log(`${value > 0 ? 'OK ' : '-- '} ${label}: ${value}`);
  if (label !== 'pendientes de envío' && value === 0) failed += 1;
}

const needQuery = db.prepare(`
  SELECT n.id, n.title, u.display_name AS author,
         (SELECT COUNT(*) FROM recommendations r WHERE r.provider_id = n.author_id) AS recs
    FROM needs n JOIN users u ON u.id = n.author_id
   WHERE n.status IN ('abierta','en_curso') AND n.is_emergency = 0
   ORDER BY n.created_at DESC
`);
const needs = [];
while (needQuery.step()) needs.push(needQuery.getAsObject());
needQuery.free();
console.log(`OK  consulta de necesidades: ${needs.length} filas`);
console.log(needs.slice(0, 3).map((row) => `    · ${row.title} — ${row.author} (${row.recs})`).join('\n'));

const conversation = scalar(
  `SELECT COUNT(*) AS n FROM interactions i
    JOIN needs n ON n.id = i.need_id
    JOIN users ou ON ou.id = CASE WHEN i.requester_id = ? THEN i.provider_id ELSE i.requester_id END
   WHERE i.requester_id = ? OR i.provider_id = ?`,
  ['u_lucia', 'u_lucia', 'u_lucia'],
);
console.log(`OK  conversaciones de u_lucia: ${Number(conversation.n)}`);

if (failed > 0) {
  console.error(`\n${failed} comprobación(es) fallaron`);
  process.exit(1);
}
console.log('\nEsquema y seed válidos.');
