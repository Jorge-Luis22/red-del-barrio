import { copyFileSync, existsSync, mkdirSync } from 'node:fs';
import { resolve } from 'node:path';

// Copia el motor SQLite (sql.js) a public/vendor para cargarlo fuera del bundler.
// Así el mismo archivo funciona en Vite, en el navegador y dentro del WebView de Capacitor.
const root = resolve(import.meta.dirname, '..');
const from = resolve(root, 'node_modules', 'sql.js', 'dist');
const to = resolve(root, 'public', 'vendor');

try {
  if (!existsSync(from)) {
    console.warn('[copy-sqljs] sql.js todavía no está instalado; se omite.');
    process.exit(0);
  }
  mkdirSync(to, { recursive: true });
  for (const file of ['sql-wasm.js', 'sql-wasm.wasm']) {
    copyFileSync(resolve(from, file), resolve(to, file));
  }
  console.log('[copy-sqljs] sql-wasm.js + sql-wasm.wasm copiados a public/vendor');
} catch (error) {
  console.warn('[copy-sqljs] no se pudo copiar:', error instanceof Error ? error.message : error);
}
