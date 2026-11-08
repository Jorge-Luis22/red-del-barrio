export interface Point {
  lat: number;
  lng: number;
}

const EARTH_KM = 6371;

const toRad = (deg: number) => (deg * Math.PI) / 180;

/** Distancia en línea recta entre dos coordenadas (Haversine). */
export function distanceKm(a: Point, b: Point): number {
  const dLat = toRad(b.lat - a.lat);
  const dLng = toRad(b.lng - a.lng);
  const h =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(a.lat)) * Math.cos(toRad(b.lat)) * Math.sin(dLng / 2) ** 2;
  return 2 * EARTH_KM * Math.asin(Math.min(1, Math.sqrt(h)));
}

/**
 * Redondea una coordenada para publicarla. 3 decimales ≈ 110 m,
 * suficiente para decir "zona aproximada" sin revelar la casa.
 */
export function roundZone(point: Point, decimals = 3): Point {
  const factor = 10 ** decimals;
  return {
    lat: Math.round(point.lat * factor) / factor,
    lng: Math.round(point.lng * factor) / factor,
  };
}

export function formatDistance(km: number | null | undefined): string {
  if (km === null || km === undefined || Number.isNaN(km)) return '';
  if (km < 1) return `${Math.max(50, Math.round((km * 1000) / 50) * 50)} m`;
  return `${km.toFixed(1)} km`;
}

/** Lima: la precisión del GPS en interiores es mala; 3 decimales es lo honesto. */
export function jitter(point: Point, meters = 40): Point {
  const dLat = (Math.random() - 0.5) * (meters / 111_320);
  const dLng = (Math.random() - 0.5) * (meters / (111_320 * Math.cos(toRad(point.lat))));
  return { lat: point.lat + dLat, lng: point.lng + dLng };
}

/* ---------- GPS real ---------- */

export type GpsStatus = 'pendiente' | 'ok' | 'denegado' | 'no_disponible';

let currentPoint: Point | null = null;

/** Última posición real conocida (null si el GPS no respondió). */
export function getCurrentPoint(): Point | null {
  return currentPoint;
}

export function setCurrentPoint(point: Point | null): void {
  currentPoint = point;
}

/** Pide la posición al navegador. Resuelve con el estado final, nunca lanza. */
export function requestPosition(): Promise<GpsStatus> {
  return new Promise((resolve) => {
    if (typeof navigator === 'undefined' || !('geolocation' in navigator)) {
      resolve('no_disponible');
      return;
    }
    navigator.geolocation.getCurrentPosition(
      (pos) => {
        currentPoint = { lat: pos.coords.latitude, lng: pos.coords.longitude };
        resolve('ok');
      },
      (err) => resolve(err.code === 1 ? 'denegado' : 'no_disponible'),
      { enableHighAccuracy: true, timeout: 15000, maximumAge: 60000 },
    );
  });
}
