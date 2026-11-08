import type { NeedType } from '../types';

/**
 * Economía solidaria (sin dinero). Se apoya en la tabla `needs` que ya sincroniza entre teléfonos:
 * no hay columnas nuevas ni migración en el servidor. Lo que distingue cada cosa es:
 *   - Muro "Sin dinero" del día a día: `category` ∈ SOLIDARY_CATEGORIES.
 *   - Recursos críticos de emergencia: `is_emergency = 1` y `category` empieza con RESOURCE_PREFIX.
 *   - "Necesito" / "Ofrezco": el título empieza con DIR_PREFIX (se ve igual en todas las pantallas).
 */

export type Direction = 'necesito' | 'ofrezco';

export const DIR_PREFIX: Record<Direction, string> = {
  necesito: 'Necesito: ',
  ofrezco: 'Ofrezco: ',
};

export const DIR_LABEL: Record<Direction, string> = {
  necesito: 'Necesito',
  ofrezco: 'Ofrezco',
};

export function directionOf(title: string): Direction | null {
  if (title.startsWith(DIR_PREFIX.ofrezco)) return 'ofrezco';
  if (title.startsWith(DIR_PREFIX.necesito)) return 'necesito';
  return null;
}

export const withDirection = (dir: Direction, text: string): string => `${DIR_PREFIX[dir]}${text.trim()}`;

/** Cinco formas de ayudarse sin dinero (módulo "Cadena de favores"). */
export const SOLIDARY_CATEGORIES: { name: string; icon: string; type: NeedType; example: string }[] = [
  { name: 'Préstamo de herramientas', icon: '🔧', type: 'prestamo', example: 'Escalera de 3 metros, taladro, carretilla…' },
  { name: 'Ayuda temporal', icon: '🫶', type: 'ayuda', example: 'Cuidar a un niño un rato, hacer un trámite, cargar algo pesado…' },
  { name: 'Donación de materiales', icon: '🎁', type: 'producto', example: 'Ropa de abrigo, útiles escolares, ladrillos, madera…' },
  { name: 'Intercambio de habilidades', icon: '🔁', type: 'servicio', example: 'Te enseño inglés y tú me ayudas con mi página web…' },
  { name: 'Movilidad solidaria', icon: '🚗', type: 'servicio', example: 'Llevar a alguien a la posta o al mercado…' },
];

export const isSolidary = (category: string): boolean => SOLIDARY_CATEGORIES.some((c) => c.name === category);

export const solidaryIcon = (category: string): string =>
  SOLIDARY_CATEGORIES.find((c) => c.name === category)?.icon ?? '🤝';

/** Recursos críticos para coordinar en una emergencia (módulo "Red de solidaridad"). */
export const CRITICAL_RESOURCES: { name: string; icon: string; type: NeedType; example: string }[] = [
  { name: 'Agua', icon: '💧', type: 'producto', example: '2 bidones de 20 litros, agua hervida…' },
  { name: 'Alimentos', icon: '🍲', type: 'producto', example: 'Arroz, menestras, comida preparada para 6 personas…' },
  { name: 'Abrigo y frazadas', icon: '🧥', type: 'producto', example: 'Frazadas, casacas, colchones…' },
  { name: 'Medicinas y botiquín', icon: '💊', type: 'producto', example: 'Paracetamol, gasas, alcohol, insulina…' },
  { name: 'Linterna y energía', icon: '🔦', type: 'prestamo', example: 'Linternas, pilas, generador, cargador portátil…' },
  { name: 'Transporte', icon: '🚐', type: 'servicio', example: 'Auto o camioneta para trasladar personas o enseres…' },
];

export const RESOURCE_PREFIX = 'Recurso · ';

/** Un recurso ofrecido o pedido sigue visible este tiempo (más que una alerta: el agua y la comida duran). */
export const RESOURCE_WINDOW_HOURS = 48;

export const isResource = (category: string): boolean => category.startsWith(RESOURCE_PREFIX);
export const resourceName = (category: string): string => category.slice(RESOURCE_PREFIX.length);
export const resourceCategory = (name: string): string => `${RESOURCE_PREFIX}${name}`;
export const resourceIcon = (category: string): string =>
  CRITICAL_RESOURCES.find((r) => r.name === resourceName(category))?.icon ?? '📦';

/** Alerta reportada por un vecino en nombre de otra persona (adulto mayor, alguien sin celular). */
export const PROXY_PREFIX = '[Por otra persona] ';
export const isProxyReport = (description: string): boolean => description.startsWith(PROXY_PREFIX);
export const stripProxy = (description: string): string =>
  isProxyReport(description) ? description.slice(PROXY_PREFIX.length) : description;
