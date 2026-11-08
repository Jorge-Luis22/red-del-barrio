/**
 * Nivel del vecino en la red: se calcula, no se escribe a mano.
 *
 * Puntos = 2 por cada ayuda completada (las dos partes confirmaron) + 1 por cada recomendación de un vecino.
 * Si tiene al menos 2 calificaciones y el promedio es menor a 3,5 estrellas, no pasa de "Vecino activo":
 * ayudar mucho pero mal no da confianza.
 */

export const POINTS_PER_HELP = 2;
export const POINTS_PER_RECOMMENDATION = 1;
const MIN_RATINGS_FOR_CAP = 2;
const MIN_AVG_FOR_TRUST = 3.5;

export const LEVELS = [
  { name: 'Vecino nuevo', min: 0 },
  { name: 'Vecino activo', min: 2 },
  { name: 'Vecino de confianza', min: 6 },
  { name: 'Vecino referente', min: 14 },
] as const;

export interface LevelInfo {
  name: string;
  points: number;
  /** Nombre del siguiente nivel, o null si ya está en el más alto. */
  next: string | null;
  /** Puntos que faltan para el siguiente nivel (0 si no hay). */
  missing: number;
  /** Verdadero si las calificaciones bajas frenan su ascenso. */
  capped: boolean;
}

export function computeLevel(helps: number, recommendations: number, avgStars: number | null, ratings: number): LevelInfo {
  const points = helps * POINTS_PER_HELP + recommendations * POINTS_PER_RECOMMENDATION;
  const capped = ratings >= MIN_RATINGS_FOR_CAP && avgStars !== null && avgStars < MIN_AVG_FOR_TRUST;
  let index = 0;
  LEVELS.forEach((level, i) => {
    if (points >= level.min) index = i;
  });
  if (capped) index = Math.min(index, 1);
  const next = LEVELS[index + 1] ?? null;
  return {
    name: LEVELS[index].name,
    points,
    next: next ? next.name : null,
    missing: next ? Math.max(0, next.min - points) : 0,
    capped,
  };
}
