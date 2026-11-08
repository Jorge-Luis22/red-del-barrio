# Plan de 48 horas — Red del barrio

**Corte del reto:** domingo 8 de noviembre, 6:30 p. m. (Lima).
**Corte interno de features:** domingo 8, 12:00 p. m. Después de esa hora solo se corrige, no se agrega.
**Estado de partida:** el esqueleto ya existe y compila (`app/`). La demo funciona sin backend; Supabase y Matrix son mejoras, no requisitos para presentar.

---

## 0. La regla que ordena todo

> **La demo nunca se cae.** Si Matrix falla, el chat sigue en local. Si Supabase falla, SQLite sigue respondiendo. Si el APK falla, se presenta la PWA instalada. Nunca se muestra una pantalla en blanco.

Todo lo demás se subordina a eso.

---

## 1. Equipo y responsabilidades

| Rol | Quién | Dueño de | No toca |
|---|---|---|---|
| **Líder / integración** | Jorge | Decisiones, merge final, demo, Supabase | Pantallas de otros sin avisar |
| **Datos y backend** | P1 | Esquema, RLS, sync, Edge Function de Matrix | Estilos |
| **UI y flujos** | P2 | Inicio, Vecinos, Publicar, Perfil | SQL |
| **Chat e infra** | P3 | Synapse, Caddy, transporte Matrix, APK | Reglas de negocio |
| **QA y guion** | P4 | Los 10 casos, accesibilidad, guion, backups | Código de features |

Si el equipo es de 3: P1 absorbe P3, y P4 lo asume el líder.

**Regla de escritura:** cada quien trabaja en archivos distintos. `app/src/db/` es de P1, `app/src/screens/` de P2, `app/src/lib/matrix.ts` e `infra/` de P3. El líder revisa el diff y corre `npm run build` antes de cada merge.

---

## 2. Qué ya está hecho (no volver a hacerlo)

- [x] Proyecto Vite + React + TypeScript que compila (`npm run build`).
- [x] SQLite real en el navegador y en el APK (sql.js + IndexedDB), con `schema.sql` y `seed.sql`.
- [x] 5 pestañas: Inicio, Vecinos, Mensajes, Emergencia, Perfil.
- [x] Publicar necesidad, ofrecer propuesta, aceptar trato, código de encuentro de 4 dígitos.
- [x] Chat con estado **Pendiente de envío**, cola `outbox` idempotente por `txn_id` y reintento al volver la conexión.
- [x] Modo emergencia con institución primero y ubicación exacta fuera de lo público.
- [x] Perfil con estadísticas, accesibilidad (texto grande, alto contraste, tema oscuro) y borrado de datos.
- [x] Prueba de humo del esquema: `node scripts/check-db.mjs`.
- [x] Manifiesto PWA, service worker e íconos.

Lo que **no** está hecho y es el trabajo real de las próximas horas está abajo, con criterio de aceptación.

---

## 3. Backlog por prioridad

### P0 — sin esto no se presenta

#### M1. Identidad y ubicación (2 h) — P1
- [ ] Pantalla de bienvenida de 1 paso: nombre + zona (la sesión ya existe, falta la UI).
- [ ] Botón **“Usar mi ubicación”** con `navigator.geolocation`; si falla, usar la zona por defecto y avisarlo.
- [ ] Guardar lat/lng en `users` y recalcular distancias.
- **Aceptación:** al abrir en un teléfono real, la distancia a las publicaciones cambia respecto de la simulación y el permiso denegado no rompe nada.

#### M2. Necesidades end-to-end (3 h) — P2
- [ ] Detalle de necesidad al tocar la tarjeta (hoy solo se puede ofrecer).
- [ ] “Mis publicaciones” en Perfil con opción de cancelar.
- [ ] Validaciones: título 4–80, descripción ≤280, categoría obligatoria.
- **Aceptación:** publicar → aparece primera en Inicio → sobrevive a cerrar y reabrir la app.

#### M3. Propuestas y trato (3 h) — P1 + P2
- [ ] Pantalla del autor para ver propuestas y aceptar una.
- [ ] Mostrar el código de encuentro **una vez**, con botón “Copiar”, y guardarlo hasheado.
- [ ] Estado del trato: acordado → en curso → completado / cancelado.
- [ ] “Ajuste de precio” con motivo (solo si el proveedor lo propone y el vecino acepta).
- **Aceptación:** aceptar una propuesta abre el chat y muestra el código; el código no aparece en el historial de mensajes.

#### M4. Chat real con Matrix (4 h) — P3
- [ ] Levantar Synapse + Caddy en el VPS (`infra/`).
- [ ] `VITE_MATRIX_HOMESERVER` + token en `.env.local`.
- [ ] Un room por trato (`createRoom` con `preset: private_chat`).
- [ ] Enviar con `PUT /rooms/{id}/send/m.room.message/{txnId}` y reintentar con el mismo `txnId`.
- [ ] Recibir con `/sync` (long-polling) y volcar a `messages`.
- [ ] Prueba de interoperabilidad: escribir desde **Element** y verlo en la app.
- **Aceptación:** dos teléfonos + Element en un tercero; los tres ven los mismos mensajes; apagar el wifi deja “Pendiente” y al volver se envía una sola vez.

#### M5. Emergencia (2 h) — P2
- [ ] Alerta con tipo y descripción; institución primero.
- [ ] Lista de vecinos que pueden ayudar ahora, ordenada por distancia.
- [ ] “Marcar como atendida” y cierre.
- [ ] Texto de privacidad visible: la ubicación exacta no es pública.
- **Aceptación:** activar una alerta en un teléfono y verla en otro (cuando Supabase esté); sin Supabase, funciona en el teléfono de la demo.

#### M6. Build y publicación (2 h) — P3 + P4
- [ ] `npm run build` + deploy web (Netlify Drop o Vercel).
- [ ] `npx cap add android && npm run android` → APK firmado en modo debug.
- [ ] Subir APK + build web + guion a OneDrive (enlace público).
- [ ] Probar la instalación en 2 teléfonos Android distintos.
- **Aceptación:** el jurado puede entrar por URL y por APK; ambos abren sin internet después de la primera carga.

#### M7. QA de los 10 casos (2 h) — P4
- [ ] Ejecutar la lista de la sección 6 y anotar resultado.
- [ ] Corregir solo fallos P0.
- **Aceptación:** 10/10 en verde o con plan B explícito.

### P1 — suma puntos, se corta si hay riesgo

#### M8. Reputación y Visto Bueno (2 h) — P1
- [ ] Calificación de dos vías al completar el trato.
- [ ] Visto Bueno Vecinal con umbral (≥2 recomendaciones) y etiqueta “sin verificar”.
- [ ] Anti-abuso: un voto por vecino, máximo 2 ayudas con la misma persona.

#### M9. Offline y sincronización con Supabase (4 h) — P1
- [ ] Aplicar `supabase/migrations/0001_init.sql`.
- [ ] Login anónimo o magic link.
- [ ] Subida de la cola `outbox` y bajada por `updated_at`.
- [ ] Regla de conflicto: gana el servidor; los mensajes van siempre por Matrix.
- **Aceptación:** modo avión → publicar 2 necesidades y enviar 1 mensaje → volver la señal → todo llega una sola vez.

#### M10. Accesibilidad e idiomas (2 h) — P2
- [ ] Revisar contraste y foco visible en las 5 pantallas.
- [ ] Inglés y quechua en las cadenas principales (reusar las del simulador).
- [ ] Frases rápidas con pictogramas en Emergencia.
- **Aceptación:** navegable solo con teclado; texto al 200% sin romper; quechua revisado por un hablante o declarado como pendiente.

### P2 — solo si todo lo anterior está cerrado
- [ ] Notificaciones push (FCM).
- [ ] Fotos en publicaciones (con borrado de EXIF).
- [ ] Mapa con OpenStreetMap.
- [ ] E2EE en Matrix.

---

## 4. Cronograma (hora de Lima)

| Hora | Qué | Quién |
|---|---|---|
| **Sáb 23:30–00:30** | Revisar el esqueleto, `npm run dev`, crear proyecto Supabase, repartir archivos | Todos |
| **00:30–02:00** | M1 + M2 (identidad y publicar) | P1, P2 |
| **02:00–02:20** | Pausa corta | — |
| **02:20–05:00** | M3 + M4 (trato, código, Synapse) | P1, P2, P3 |
| **05:00–08:00** | **Dormir 3 horas.** No es opcional: el domingo se decide con cabeza | Todos |
| **08:00–08:30** | Standup: qué falla, qué se corta | Todos |
| **08:30–10:30** | M4 cerrado (Element ↔ app) + M5 emergencia | P3, P2 |
| **10:30–12:00** | M8 reputación + M10 accesibilidad | P1, P2 |
| **12:00** | **CORTE DE FEATURES** | Líder |
| **12:00–14:00** | M7 QA de los 10 casos + arreglos P0 | P4 + todos |
| **14:00–15:30** | M6 build APK + deploy web + OneDrive | P3, P4 |
| **15:30–16:30** | Ensayo cronometrado del guion (2 vueltas) | Todos |
| **16:30–17:30** | Congelar, backup, cargar teléfonos, modo avión probado | P4 |
| **17:30–18:30** | Margen. No tocar código nuevo | Líder |

**Si van atrasados, se recorta en este orden:** M9 → M8 → M10 → M4 (Matrix real) → M5 (emergencia queda con lo que ya tiene). **Nunca se recorta:** M2, M3, M6, M7.

---

## 5. Cómo se trabaja cada tarea

1. Abrir un issue o tarjeta con el ID (`M3-aceptar`).
2. Rama `feat/m3-aceptar` desde `main`.
3. Implementar + `npm run build` + `node scripts/check-db.mjs` si tocó SQL.
4. PR pequeño; el líder revisa y hace merge.
5. Actualizar la tarjeta y avisar en el grupo.

**Definición de terminado:** compila, funciona en el navegador a 390 px de ancho, funciona en el APK si aplica, no deja `console.error`, y está probado en modo avión si toca red.

---

## 6. Los 10 casos que hay que poder mostrar

| # | Caso | Criterio |
|---|---|---|
| 1 | Publicar necesidad | 3 toques desde Inicio, aparece primera |
| 2 | Ver cerca | Distancia coherente con el GPS |
| 3 | Ofrecer propuesta | Precio obligatorio, no se envía vacío |
| 4 | Aceptar y chatear | Room creado + código de 4 dígitos |
| 5 | Chat sin señal | “Pendiente de envío” y luego “Enviado” una sola vez |
| 6 | Interoperabilidad | Mensaje desde Element aparece en la app |
| 7 | Emergencia | Institución primero, ubicación exacta privada |
| 8 | Visto Bueno | Un voto por vecino, umbral visible |
| 9 | Accesibilidad | Texto grande + alto contraste sin romper |
| 10 | Persistencia | Cerrar y reabrir conserva todo |

---

## 7. Guion de demo (7 minutos)

| Min | Qué se dice / hace |
|---|---|
| 0:00 | Problema: pedir un gasfitero hoy cuesta llamadas, transporte y desconfianza. |
| 0:40 | Inicio: “Lucía necesita un gasfitero”. Publicar en 3 toques. |
| 1:40 | Cambiar de teléfono: Miguel ve el pedido, ofrece S/ 60, Lucía acepta. |
| 2:40 | Se abre el chat y el código de 4 dígitos. Aclarar que el código no viaja por el chat. |
| 3:20 | **Element en un tercer equipo** escribe; el mensaje aparece en la app. |
| 4:10 | Modo avión: enviar mensaje → “Pendiente”; volver la señal → “Enviado” una vez. |
| 4:50 | Emergencia: institución primero, red vecinal después, ubicación exacta privada. |
| 5:40 | Perfil: Visto Bueno y ayuda al barrio sin puntos públicos. |
| 6:20 | Cierre honesto: qué es real, qué falta (pagos, RENIEC, push) y costo (USD 5/mes). |

**No tocar en vivo:** borrar datos, cambiar idioma a quechua sin revisar, activar una alerta real con el GPS del jurado, ni prometer pagos.

---

## 8. Riesgos y planes B

| Riesgo | Señal | Plan B |
|---|---|---|
| Synapse no levanta | TLS o puerto ocupado | Chat local (ya implementado) + decir “Matrix en local para la demo” |
| Matrix cae en vivo | `/sync` sin respuesta | La UI sigue; los mensajes quedan pendientes y se explican |
| Supabase sin cuota | 429 | Todo local; la app ya funciona así |
| APK no compila | Gradle/SDK | PWA instalada desde el navegador + enlace web |
| Sin internet en el venue | — | Hotspot propio + build local + APK ya instalado |
| Se rompe la base por un dato viejo | pantalla vacía | Perfil → Borrar mis datos (ya existe) |
| El jurado pide código | — | Repo público + `app/README.md` con arquitectura |

---

## 9. Comandos del día

```powershell
# app
cd app
npm install
npm run dev            # http://localhost:5173
npm run build          # verifica TypeScript + build
node scripts/check-db.mjs

# APK
npx cap add android    # una sola vez
npm run android        # build + abre Android Studio

# web
# subir app/dist a Netlify Drop o Vercel
```

**Antes de cada demo:** `npm run build`, abrir la URL publicada, instalar/actualizar en los teléfonos, y probar modo avión una vez.
