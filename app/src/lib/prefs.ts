/**
 * Preferencias que viven solo en este teléfono (localStorage): accesibilidad y si ya se vio el tutorial.
 * Todo está protegido con try/catch: en modo privado o con el almacenamiento bloqueado la app sigue igual.
 */

const A11Y_KEY = 'redvecinal.a11y.v1';
const TUTORIAL_KEY = 'redvecinal.tutorial.v1';
export const TUTORIAL_EVENT = 'redvecinal:tutorial';

function read(key: string): string | null {
  try {
    return localStorage.getItem(key);
  } catch {
    return null;
  }
}

function write(key: string, value: string): void {
  try {
    localStorage.setItem(key, value);
  } catch {
    /* sin almacenamiento: la preferencia dura solo esta sesión */
  }
}

export interface A11y {
  /** Texto más grande (125 %). */
  large: boolean;
  /** Alto contraste: blanco y negro con bordes marcados. */
  contrast: boolean;
}

export function loadA11y(): A11y {
  try {
    const parsed = JSON.parse(read(A11Y_KEY) ?? '{}') as Partial<A11y>;
    return { large: parsed.large === true, contrast: parsed.contrast === true };
  } catch {
    return { large: false, contrast: false };
  }
}

/** Aplica las preferencias a la raíz del documento (los estilos leen `data-large` y `data-contrast`). */
export function applyA11y(prefs: A11y = loadA11y()): void {
  const root = document.documentElement;
  root.dataset.large = prefs.large ? '1' : '0';
  root.dataset.contrast = prefs.contrast ? '1' : '0';
}

export function setA11y(patch: Partial<A11y>): A11y {
  const next = { ...loadA11y(), ...patch };
  write(A11Y_KEY, JSON.stringify(next));
  applyA11y(next);
  return next;
}

export const tutorialSeen = (): boolean => read(TUTORIAL_KEY) === '1';
export const markTutorialSeen = (): void => write(TUTORIAL_KEY, '1');

/** Perfil → "Ver tutorial": avisa al componente del tutorial que se abra. */
export function openTutorial(): void {
  window.dispatchEvent(new Event(TUTORIAL_EVENT));
}
