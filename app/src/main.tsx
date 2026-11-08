import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import App from './App';
import './index.css';
import { applyA11y } from './lib/prefs';

// Texto grande / alto contraste: se aplica antes de pintar para que no parpadee.
applyA11y();

const root = document.getElementById('root');
if (!root) throw new Error('Falta <div id="root"> en index.html');

createRoot(root).render(
  <StrictMode>
    <App />
  </StrictMode>,
);

// PWA: solo en producción y sobre https/localhost.
if ('serviceWorker' in navigator && import.meta.env.PROD) {
  window.addEventListener('load', () => {
    navigator.serviceWorker
      .register(`${import.meta.env.BASE_URL}sw.js`)
      .catch((error) => console.warn('[pwa] service worker no registrado', error));
  });
}
