import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// base: './' para que el build funcione dentro del WebView de Capacitor (file://).
export default defineConfig({
  base: './',
  plugins: [react()],
  server: { host: true, port: 5173 },
  build: { target: 'es2020', outDir: 'dist' },
});
