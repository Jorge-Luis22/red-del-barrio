import type { NeedType } from '../types';
import { withDirection } from './solidarity';

/**
 * Publicar en 3 toques: Necesito/Ofrezco → qué (botón grande) → Publicar.
 * Todo lo demás (qué pasó, para cuándo, detalle) es opcional y también son botones.
 * No hay columnas nuevas: el oficio va en `category` (igual que los oficios del Directorio, para que
 * los pedidos urgentes coincidan con quienes atienden ese oficio) y el resto se arma en título y descripción.
 */

export interface Tile {
  key: string;
  icon: string;
  /** Lo que lee el vecino en el botón y en el título. */
  label: string;
  /** Oficio o rubro que se guarda (coincide con TRADES cuando es un oficio). */
  category: string;
  type: NeedType;
  /** Botones rápidos de "¿Qué pasó?" (opcionales). */
  quick: string[];
  /** Se puede ofrecer como servicio en el Directorio. */
  trade: boolean;
}

/** Los 11 pedidos más comunes del barrio: se ven todos de una vez, sin desplazarse mucho. */
export const TILES: Tile[] = [
  { key: 'gasfiteria', icon: '🔧', label: 'Gasfitería', category: 'Gasfitería', type: 'servicio', trade: true,
    quick: ['Fuga de agua', 'Caño tapado', 'Instalar grifo o ducha', 'Cambiar tubería'] },
  { key: 'electricidad', icon: '⚡', label: 'Electricidad', category: 'Electricidad', type: 'servicio', trade: true,
    quick: ['Sin luz en casa', 'Cambiar enchufe o interruptor', 'Instalar lámpara', 'Revisar el tablero'] },
  { key: 'cerrajeria', icon: '🔑', label: 'Cerrajería', category: 'Cerrajería', type: 'servicio', trade: true,
    quick: ['Me quedé afuera', 'Cambiar chapa', 'Copiar llaves', 'Puerta trabada'] },
  { key: 'carpinteria', icon: '🔨', label: 'Carpintería', category: 'Carpintería', type: 'servicio', trade: true,
    quick: ['Arreglar puerta', 'Reparar mueble', 'Mueble a medida', 'Ventana o closet'] },
  { key: 'limpieza', icon: '🧹', label: 'Limpieza y jardín', category: 'Limpieza y jardinería', type: 'servicio', trade: true,
    quick: ['Limpieza de casa', 'Lavar tanque de agua', 'Podar el jardín', 'Limpiar terraza'] },
  { key: 'cuidado', icon: '👶', label: 'Cuidado de personas', category: 'Cuidado de niños y adultos mayores', type: 'servicio', trade: true,
    quick: ['Cuidar niños un rato', 'Acompañar a un adulto mayor', 'Recoger del colegio'] },
  { key: 'comida', icon: '🍲', label: 'Comida', category: 'Cocina y repostería', type: 'producto', trade: true,
    quick: ['Almuerzos del día', 'Torta o postres', 'Menú para un evento'] },
  { key: 'transporte', icon: '🚗', label: 'Transporte', category: 'Transporte', type: 'servicio', trade: true,
    quick: ['Llevar a la posta', 'Mudanza pequeña', 'Ir al mercado', 'Flete'] },
  { key: 'costura', icon: '🧵', label: 'Costura y arreglos', category: 'Costura y arreglos', type: 'servicio', trade: true,
    quick: ['Arreglar ropa', 'Bastas', 'Uniforme escolar', 'Cortinas'] },
  { key: 'clases', icon: '📚', label: 'Clases', category: 'Clases y refuerzo escolar', type: 'servicio', trade: true,
    quick: ['Matemática', 'Inglés', 'Primaria', 'Ayuda con tareas'] },
  { key: 'herramientas', icon: '🧰', label: 'Herramientas', category: 'Herramientas', type: 'prestamo', trade: false,
    quick: ['Escalera', 'Taladro', 'Carretilla', 'Cables de batería'] },
];

/** Oficios menos frecuentes: salen en "Otra cosa". */
export const MORE_TILES: Tile[] = [
  { key: 'enfermeria', icon: '💉', label: 'Enfermería', category: 'Enfermería', type: 'servicio', trade: true,
    quick: ['Inyectable', 'Curaciones', 'Control de presión'] },
  { key: 'aguagas', icon: '💧', label: 'Agua y gas', category: 'Agua y gas', type: 'producto', trade: true,
    quick: ['Balón de gas', 'Bidón de agua', 'Cisterna'] },
  { key: 'mascotas', icon: '🐕', label: 'Mascotas', category: 'Paseo de mascotas', type: 'servicio', trade: true,
    quick: ['Pasear perro', 'Cuidarlo unos días'] },
  { key: 'electro', icon: '📺', label: 'Electrodomésticos', category: 'Reparación de electrodomésticos', type: 'servicio', trade: true,
    quick: ['Refrigeradora', 'Lavadora', 'Cocina', 'Televisor'] },
];

const normalize = (value: string) => value.normalize('NFD').replace(/[̀-ͯ]/g, '').trim().toLowerCase();

/** Botón de un oficio o rubro; si no existe (oficio escrito a mano en el Directorio) se arma uno genérico. */
export function tileFor(category: string): Tile {
  const found = [...TILES, ...MORE_TILES].find((t) => normalize(t.category) === normalize(category));
  if (found) return found;
  return { key: 'custom', icon: '🛠️', label: category, category, type: 'servicio', quick: [], trade: true };
}

/** Tipo que se puede elegir en "Otra cosa". */
export const OTHER_TYPES: { type: NeedType; label: string }[] = [
  { type: 'servicio', label: 'Un servicio' },
  { type: 'producto', label: 'Un producto' },
  { type: 'prestamo', label: 'Un préstamo' },
  { type: 'ayuda', label: 'Una ayuda' },
];

/** ¿Para cuándo? (opcional). */
export const WHEN: { key: string; label: string }[] = [
  { key: 'hoy', label: 'Hoy' },
  { key: 'manana', label: 'Mañana' },
  { key: 'semana', label: 'Esta semana' },
  { key: 'sinapuro', label: 'Sin apuro' },
];

/** ¿Cuándo atiendes? (opcional, al ofrecer un servicio). */
export const SCHEDULES = ['Mañanas', 'Tardes', 'Todo el día', 'Fines de semana'];

export const MAX_DETAIL = 200;

/** Recorta un texto escrito a una frase corta para el título, sin cortar palabras a la mitad. */
export function shortPhrase(text: string, max = 45): string {
  const clean = text.trim().replace(/\s+/g, ' ');
  if (clean.length <= max) return clean;
  const cut = clean.slice(0, max);
  const lastSpace = cut.lastIndexOf(' ');
  return `${(lastSpace > 20 ? cut.slice(0, lastSpace) : cut).trim()}…`;
}

/**
 * Título del pedido: "Necesito: Gasfitería · Fuga de agua".
 * Si el vecino tocó un botón rápido se usa ese; si prefirió escribir con sus palabras, se usa lo escrito.
 */
export function needTitle(tile: Tile, what: string | null, written = ''): string {
  const extra = what ?? (written.trim() ? shortPhrase(written) : null);
  const base = extra ? `${tile.label} · ${extra}` : tile.label;
  return withDirection('necesito', base).slice(0, 80);
}

/** Descripción del pedido: lo que eligió en los botones más el detalle escrito (si lo hay). */
export function needDescription(whenKey: string | null, detail: string): string {
  const when = WHEN.find((w) => w.key === whenKey);
  return [when ? `Para: ${when.label}.` : '', detail.trim().slice(0, MAX_DETAIL)].filter(Boolean).join(' ');
}
