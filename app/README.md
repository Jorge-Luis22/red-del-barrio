# app — Red del barrio

Aplicación real del proyecto: **PWA instalable + APK Android**, con **SQLite local** y chat **Matrix** (o local si no hay servidor).

## Arrancar

```powershell
cd app
npm install
npm run dev
```

Abre `http://localhost:5173`. La primera vez crea la base SQLite, carga datos de demo y persiste en IndexedDB.

> `npm install` copia el motor SQLite a `public/vendor/`. Si borras esa carpeta, vuelve a ejecutar `npm install` o `node scripts/copy-sqljs.mjs`.

## Comandos

| Comando | Qué hace |
|---|---|
| `npm run dev` | servidor de desarrollo |
| `npm run build` | TypeScript + build de producción en `dist/` |
| `npm run preview` | sirve `dist/` para probar el build |
| `node scripts/check-db.mjs` | prueba el esquema y el seed sin navegador |
| `npx cap add android` | genera el proyecto Android (una vez) |
| `npm run android` | build + sync + abre Android Studio |
| `npm run cap:sync` | build + copia `dist/` al proyecto Android |

## Variables de entorno

Copia `.env.example` a `.env.local`. **Sin variables, la app funciona completa en local.**

```env
VITE_MATRIX_HOMESERVER=https://matrix.tudominio.pe
VITE_MATRIX_TOKEN=...
```

Con esas dos variables, `lib/matrix.ts` usa Synapse; sin ellas, usa el transporte local (la demo sigue).

## Estructura

```
src/
├─ db/
│  ├─ schema.sql     esquema SQLite
│  ├─ seed.sql       datos de demo
│  ├─ sqlite.ts      motor + persistencia
│  └─ repo.ts        única puerta a los datos
├─ lib/
│  ├─ geo.ts         distancias y redondeo de zona
│  ├─ ids.ts         uuid, txnId, hash del código
│  ├─ matrix.ts      transporte Matrix / local
│  ├─ outbox.ts      cola idempotente
│  └─ format.ts      dinero, fechas, tamaños
├─ state/store.tsx   sesión, conexión, revisión
├─ screens/          Inicio, Vecinos, Mensajes, Emergencia, Perfil
├─ ui/               Icon, TabBar, Sheet, NeedCard
├─ types.ts
├─ App.tsx
└─ styles.css
```

## Flujo principal

1. **Inicio** → “Pedir ayuda” → publicar (título, tipo, rubro).
2. Otro vecino ve la tarjeta → “Ofrecer ayuda” → precio + mensaje.
3. El autor acepta → se crea el trato, el room de Matrix y el código de 4 dígitos.
4. **Mensajes** → chat con estado “Pendiente de envío” si no hay red.
5. **Emergencia** → institución primero, red vecinal después.
6. **Perfil** → accesibilidad, almacenamiento y borrado de datos.

## APK Android

Requisitos: Android Studio con SDK 34+ y Java 17.

```powershell
npx cap add android
npm run android
```

En Android Studio: *Build → Build Bundle(s)/APK(s) → Build APK(s)*. El APK queda en `android/app/build/outputs/apk/debug/`.

`capacitor.config.ts` ya usa `https` como esquema y `dist` como `webDir`.

## Problemas comunes

| Síntoma | Causa | Arreglo |
|---|---|---|
| “No se pudo cargar el motor SQLite” | falta `public/vendor` | `node scripts/copy-sqljs.mjs` |
| Cambios que no aparecen en el teléfono | service worker con caché vieja | subir `CACHE` en `public/sw.js` y recargar dos veces |
| “Pendiente de envío” para siempre | sin red o Matrix caído | revisar conexión; el reintento es automático |
| Datos raros de una versión anterior | base vieja en IndexedDB | Perfil → Borrar mis datos |
| `cap` no encuentra Android | falta `npx cap add android` | ejecutarlo una vez |

## Pruebas antes de cada demo

```powershell
npm run build
node scripts/check-db.mjs
```

Y en el teléfono: publicar, aceptar, modo avión, volver la señal, emergencia, borrar datos.
