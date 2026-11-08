# Red del barrio — app instalable (PWA)

Prototipo de "Red de capacidades y confianza vecinal" (VIII Hackathon UTP–El Comercio 2026).

## Qué contiene esta carpeta

| Archivo | Para qué sirve |
|---|---|
| `index.html` | Toda la app (un solo archivo) |
| `manifest.webmanifest` | Nombre, colores e íconos para instalarla |
| `sw.js` | Guarda la app para que abra sin internet |
| `icon-192.png`, `icon-512.png`, `icon-maskable-512.png` | Íconos |
| `GUION-DEMO.md` | Guion de 4 actos para presentar al jurado (no se sube al hosting) |

Hay que subir **todos** los archivos a la misma carpeta del hosting.

## Qué hace de verdad (y qué no)

Hace de verdad:
- Guarda tus datos en el teléfono (se mantienen al cerrar y reabrir).
- Usa el GPS real del teléfono. En público solo se ve una zona aproximada (~1 km); las coordenadas exactas se muestran solo cuando la persona que aceptó ayudar las recibe.
- Funciona sin internet: abre sin conexión y deja las solicitudes pendientes hasta que vuelve la señal.
- Se instala como app y se ve a pantalla completa en celular.
- Las fotos se reducen y se guardan en el teléfono. Si el almacenamiento se llena, la app quita las fotos más antiguas, avisa y no pierde tus datos; en Perfil se ve cuánto espacio se usa y se pueden quitar fotos.
- **Explorar cerca** (en Inicio): directorio de oficios y productos del barrio con "Visto Bueno Vecinal" (recomendado por X vecinos de tu zona) y distancia calculada desde tu GPS real.
- **Recomendar a un vecino**: un voto por persona por proveedor, y recomendar a alguien que aún no está en la lista (queda "sin verificar").
- **Oficios y vecinos que pueden ayudar ahora** (en Emergencia): gasfitero, electricista, cerrajero, carpintero, enfermera con botiquín, vecino con camioneta y bodega; la institución oficial siempre va primero.
- Idiomas: español completo; inglés y quechua en las pantallas principales (el quechua debe revisarlo un hablante nativo).

Sigue siendo simulado:
- No hay servidor ni cuentas: los datos viven solo en ese teléfono y no se comparten entre personas.
- Los vecinos, propuestas y respuestas son de ejemplo.
- Los números de emergencia deben verificarse antes de presentarlos como definitivos.
- Idiomas parciales; el quechua necesita revisión de un hablante nativo.

## Publicarla gratis (necesita HTTPS)

El service worker, el GPS y la instalación **solo funcionan con HTTPS** (o en `localhost`). Estas opciones lo dan automáticamente.

### Opción A — Netlify Drop (la más rápida, sin cuenta de Git)
1. Entra a https://app.netlify.com/drop
2. Arrastra la **carpeta** (descomprimida) a la página.
3. Te da una dirección tipo `https://nombre-aleatorio.netlify.app`. Listo.

### Opción B — GitHub Pages
1. Crea un repositorio público y sube los archivos a la raíz.
2. En *Settings → Pages*, elige la rama `main` y la carpeta `/ (root)`.
3. En un par de minutos queda en `https://tu-usuario.github.io/tu-repo/`.

## Instalarla en el celular

- **Android (Chrome):** abre la dirección → botón "Instalar app" dentro de *Perfil* (o menú ⋮ → *Instalar app*).
- **iPhone (Safari):** abre la dirección → botón Compartir → *Añadir a pantalla de inicio*. (Debe ser Safari.)

Tras instalar, la primera vez abre la app **con internet** una vez; después ya abre sin conexión.

## Uso

- En computadora la app se ve centrada como una columna de celular.
- En *Perfil → Borrar mis datos* se reinicia todo (pide confirmación dos veces).

## Para quien desarrolla

- Al publicar una versión nueva, **cambia `VERSION` en `sw.js`** (por ejemplo `redvecinal-v8-2`); si no, los teléfonos seguirán con la versión guardada.
- Los datos se guardan en `localStorage` con la clave `redvecinal.v8`.
- Probar en local: `python3 -m http.server 8000` dentro de esta carpeta y abrir `http://localhost:8000`.
- Privacidad: la app no envía datos a ningún servidor. Las tipografías vienen de Google Fonts y quedan en caché.
