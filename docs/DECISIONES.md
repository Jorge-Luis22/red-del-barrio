# Decisiones técnicas

Registro corto de por qué se hizo así. Cambiar algo aquí = cambiar código y doc.

1. **SQLite local primero, servidor después.** La app funciona completa sin red:
   `sql.js` (WASM) persiste en IndexedDB (web) y Capacitor embebe los mismos assets
   (Android). El servidor se sincroniza por la cola `outbox` con `txn_id` idempotente:
   reintentar nunca duplica.
2. **Supabase como fuente de verdad del servidor** (Postgres + RLS + Realtime + Storage).
   Alternativa acordada: PocketBase si el equipo decide SQLite también en el servidor
   (un binario, sin RLS; reglas en hooks). El cambio queda aislado en la capa de datos,
   la UI no se toca.
3. **Chat = Matrix/Synapse con wrapper REST propio (~100 líneas)**, no SDK: menos
   dependencias, misma API Client-Server que Element, y `txnId` da idempotencia gratis.
   Con `VITE_MATRIX_HOMESERVER` vacío el chat corre en modo local para desarrollar.
4. **Un room por trato** (`private_chat`, `is_direct`), creado al aceptar la propuesta.
   El `room_id` se guarda en `interactions`.
5. **E2EE desactivado en la demo.** Los rooms no llevan `m.room.encryption`: permite
   moderación, pruebas y el golpe de efecto con Element. Se declara como limitación.
6. **El código de encuentro (4 dígitos) nunca va en el chat.** Se guarda hasheado
   (`meet_code_hash`) y solo quien pide lo ve, una sola vez.
7. **Ubicación:** la publicación muestra zona redondeada (~100 m, `roundZone`);
   la coordenada exacta se comparte solo tras aceptar y expira.
8. **Cuenta Matrix de la app por dispositivo** (token en env). Login real por usuario = P1.
9. **Sin router:** navegación por estado (5 pestañas + 2 pantallas). Añadir
   `react-router` solo si se necesitan URLs compartibles.
10. **GPS en dev usa `VITE_DEFAULT_LAT/LNG`.** El GPS real del teléfono es P1
    (hook `useGeolocation` con `navigator.geolocation`), porque el simulador ya
    demostró el flujo y el servidor tiene más riesgo.
11. **Sin pagos, sin push (FCM), sin verificación de identidad.** Se declaran como
    límites del prototipo; el discurso del hackathon no depende de ellos.
