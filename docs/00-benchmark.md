# Benchmark: ganadores del hackathon UTP × El Comercio 2022-2025

**Convención de etiquetas** (regla de oro del contexto): **HECHO** = documentado en el material del equipo · **INTERPRETACIÓN** = lectura del equipo, no oficial · **HIPÓTESIS** = por validar · **REQUISITO** = exigido por el reto 2026.
No se inventan criterios del jurado ni funcionalidades de los ganadores. Las fuentes son solo referencia bibliográfica; no se consultó internet.

> Sobre "nuestro MVP actual": se describe lo que **el código de `index.html` realmente hace** (verificado en la Fase 1; ver `01-analisis.md`), no solo lo que dice el informe autodeclarado. Casi toda la interacción entre personas del MVP es **simulada** (no hay servidor), y eso se tiene en cuenta en cada comparación.

---

## 2025 — "Loop: Tu Voto Manda"

| Campo | Contenido |
|---|---|
| Equipo / sede | Nicolás Alayo, Isaac Takamura, Víctor Sevillano, Juan Carlos Chávez · UTP Chimbote (**HECHO**) |
| Reto de la edición | **NO DOCUMENTADO** |
| Reto implícito | **INTERPRETACIÓN:** el problema que atacaron sugiere un reto sobre ciudadanía/democracia/acceso a información cívica. No se afirma como el reto oficial. |
| Problema (**HECHO**) | Acceso desigual a información confiable y comprensible sobre las elecciones generales de Perú 2026. |
| Qué construyeron (**HECHO**, función por función) | (1) Plataforma de información electoral. (2) Perfiles adaptados: electores analíticos y prácticos. (3) Información oficial organizada. (4) Asistente de IA en WhatsApp. (5) Lectura asistida. (6) Compatibilidad con distintas lenguas. (7) Gamificación. |
| Por qué probablemente destacó (**INTERPRETACIÓN**) | Se diferenció por **canal** (WhatsApp, donde ya está la gente), **personalización** y **accesibilidad**, no solo por "usar IA". |
| Qué nos enseña | Una solución sobresale cuando elimina una barrera concreta del usuario (**HECHO** como lección documentada). Para nosotros: la barrera es *escribir y navegar* una app nueva; hay que bajarla (frases rápidas, chips, poca escritura). |
| Qué NO repetir | Poner "IA" o un chatbot como argumento central sin barrera eliminada. Tampoco gamificación con puntos públicos: contradice nuestra regla inviolable 4. |
| Nuestro MVP — lo que hacemos igual (no diferencia) | Accesibilidad declarada (alto contraste, texto grande, frases rápidas), varios idiomas (es/en/qu parcial). Lo hace casi toda app que se dice "inclusiva". |
| Nuestro MVP — lo que hacemos distinto | No usamos WhatsApp ni IA; el canal es una PWA/app instalable. Nuestra barrera atacada es la **desconfianza entre vecinos** (reputación sin puntos públicos), no la falta de información. |

## 2024 — App de seguridad ciudadana (**antecedente más cercano**)

| Campo | Contenido |
|---|---|
| Equipo / sede | Gabriel Andrade, Luis Bautista, Omar Mariños, Antonio Montejo · UTP Chimbote (**HECHO**) |
| Reto de la edición | **NO DOCUMENTADO** |
| Reto implícito | **INTERPRETACIÓN:** seguridad y convivencia ciudadana mediante tecnología (el título de la nota dice "combaten la inseguridad ciudadana con tecnología"). No es el texto oficial del reto. |
| Problema (**HECHO**) | Inseguridad ciudadana y coordinación insuficiente en situaciones de riesgo. |
| Qué construyeron (**HECHO**, función por función) | (1) Notificaciones de emergencia. (2) Botón de pánico. (3) Chat vecinal. (4) Bot online/offline. (5) Reportes geográficos. (6) Funciones experimentales de prevención con IA. |
| Elementos de diseño (**HECHO**) | Coordinación comunitaria; comunicación rápida en emergencias; información contextual por ubicación; consideración de escenarios sin conexión. |
| Por qué probablemente destacó (**INTERPRETACIÓN**) | Integró varias herramientas alrededor de **una necesidad concreta y emocionalmente clara** (pedir apoyo y sentirse seguro), con un recorrido que un jurado entiende en segundos: *me asusto → aprieto → mis vecinos se enteran*. El "online/offline" mostró que pensaron en el contexto real (mala señal). |
| Qué nos enseña | La coordinación comunitaria debe **producir resultados concretos**; alertas, mapa u offline por sí solos no diferencian (**HECHO** como lección documentada). |
| Qué NO repetir | (a) Presentar "chat vecinal + mapa + offline + alertas" como si fuera nuestra innovación: eso **ya ganó en 2024** y nuestro MVP lo tiene casi idéntico. (b) Quedarnos en "avisar" sin cerrar el ciclo (¿llegó la ayuda? ¿se resolvió?). (c) Un botón de pánico/alerta que parezca sustituir a los servicios oficiales (riesgo R10). |
| Nuestro MVP — lo que hacemos igual (**NO nos diferencia**) | Chat con el vecino (en el MVP es **simulado**: respuestas de guion con `setTimeout`); reportes/necesidades geolocalizados (en el MVP, un esquema SVG, no un mapa real); funcionamiento sin conexión (real solo en lo local: abre sin red y guarda; la "sincronización" es simulada); modo emergencia con avisos por tipo de situación; notificación visual/vibración (`flash()` + `navigator.vibrate`). |
| Nuestro MVP — lo que hacemos distinto (**candidato a diferenciador, aún sin demostrar con personas reales**) | (1) Ciclo **completo hasta la resolución**: necesidad → propuestas con precio → aceptar con código de encuentro → ajuste de precio solo con acuerdo → cierre con calificación en dos sentidos. (2) Economía cotidiana + solidaria + emergencia sobre la **misma red** (la red de uso diario es la que responde en la emergencia). (3) Confianza medible **sin puntos ni rankings públicos** ("Tu ayuda al barrio" como evidencia privada). (4) Descubrimiento cercano de oficios con "Visto Bueno Vecinal". Todo esto es **HIPÓTESIS** de valor hasta probarlo con vecinos reales. |

## 2023 — "Sismo Seguro"

| Campo | Contenido |
|---|---|
| Equipo / sede | Integrantes **no documentados** · UTP Chimbote (**HECHO**) |
| Reto de la edición | **NO DOCUMENTADO** |
| Reto implícito | **INTERPRETACIÓN:** gestión de riesgo de desastres / preparación ante emergencias. |
| Problema (**HECHO**) | Falta de preparación familiar ante sismos de gran magnitud. |
| Qué construyeron (**HECHO**) | Una app de prevención y reducción de riesgos por sismos. (El material no detalla función por función; **no se inventan funciones**.) |
| Por qué probablemente destacó (**INTERPRETACIÓN**) | Problema local, vivido y concreto (Perú es sísmico); foco en **prevenir**, no solo en reaccionar; alcance acotado. |
| Qué nos enseña | La prevención complementa la respuesta inmediata **sin una plataforma excesivamente compleja** (**HECHO** como lección documentada). Nuestro "Un barrio preparado" (capacidades que aportas antes de una emergencia) sigue esa línea. |
| Qué NO repetir | Convertir la emergencia en el centro de toda la app: el reto 2026 pide economía local + solidaria *y además* evolución en emergencia. |
| Nuestro MVP — igual | Existe un caso "sismo" como tipo de emergencia y una pestaña de preparación (capacidades, brigadista voluntario, recursos). Es un contenido que otros equipos también pueden tener. |
| Nuestro MVP — distinto | La preparación no es un manual de seguridad sino **un registro de capacidades vecinales** (primeros auxilios, movilidad, herramientas) que se activa en la emergencia. Hoy es un interruptor local (`S.caps`), sin datos compartidos. |

## 2022 — Participación y seguimiento ciudadano

| Campo | Contenido |
|---|---|
| Equipo / sede | Pryscila Flores, Luis Melgarejo, Gerardo Quispe, Rodrigo Berrios · sede **no documentada** (**HECHO**: el material no la indica) |
| Reto de la edición | **NO DOCUMENTADO** |
| Reto implícito | **INTERPRETACIÓN:** participación ciudadana y transparencia municipal. |
| Problema (**HECHO**) | Dificultad para conocer, reportar y supervisar acciones municipales. |
| Qué construyeron (**HECHO**) | App móvil con: (1) información de obras públicas, (2) reportes geolocalizados, (3) notificaciones, (4) seguimiento ciudadano. |
| Por qué probablemente destacó (**INTERPRETACIÓN**) | Conectó al ciudadano con su municipalidad y **cerró el ciclo con seguimiento** (no solo reportar). |
| Qué nos enseña | **La ubicación debe servir para decidir y actuar, no solo para mostrar marcadores** (lección documentada). Exige que el mapa y la distancia de nuestra app influyan en una decisión (¿a quién elijo? ¿a dónde voy?). |
| Qué NO repetir | Un mapa decorativo. **Aviso honesto:** el "mapa" actual del MVP (`mapSVG`) es un esquema con posiciones fijas que *ni siquiera usa el GPS*; hoy es decorativo. |
| Nuestro MVP — igual | Reportes con ubicación aproximada y seguimiento por estados (Aceptada → Hecho). |
| Nuestro MVP — distinto | Seguimiento hasta **resolución con calificación de ambas partes**; la distancia sí influye en el orden ("Más cerca") y en la decisión de aceptar una propuesta. |

---

## Tabla comparativa 2022-2026

Leyenda: ● sí / ◐ parcial o simulado / ○ no documentado / — no aplica. Las columnas de ganadores reflejan **solo lo documentado**; "○" significa "el material no lo dice", no "no lo tenía".

| Año | Problema | Canal / tecnología | Accesibilidad | Geolocalización | Offline | Coordinación comunitaria | Seguimiento hasta resolución | Lección |
|---|---|---|---|---|---|---|---|---|
| 2022 | Conocer, reportar y supervisar acciones municipales | App móvil + notificaciones | ○ | ● reportes geolocalizados | ○ | ◐ ciudadano ↔ municipalidad | ● seguimiento ciudadano | La ubicación sirve para decidir y actuar |
| 2023 | Falta de preparación familiar ante sismos | App de prevención | ○ | ○ | ○ | ○ | — (prevención) | Prevenir complementa responder, sin complejidad excesiva |
| 2024 | Inseguridad y coordinación en riesgo | App: pánico, chat vecinal, bot online/offline, IA experimental | ○ | ● reportes geográficos y contexto por ubicación | ● bot online/offline | ● chat vecinal, notificaciones | ○ | La coordinación debe dar resultados concretos; alertas/mapa/offline solos no diferencian |
| 2025 | Información electoral confiable y comprensible | Plataforma + asistente de IA en WhatsApp | ● lectura asistida, lenguas, perfiles | ○ | ○ | — | — | Eliminar una barrera relevante del usuario |
| **2026 (nuestro MVP, estado real)** | Conseguir productos/servicios de confianza cerca, intercambiar ayuda y coordinar en emergencias | PWA instalable (Flutter planificado) | ◐ declarada (contraste, texto grande, vibración, frases rápidas, es/en/qu parcial); sin probar con personas | ◐ GPS real, pero vecinos y "mapa" sintéticos | ◐ abre sin red y guarda; sincronización simulada | ◐ **simulada** (sin servidor; respuestas de guion) | ● ciclo completo hasta calificación de dos vías (en simulación) | A demostrar: *ciclo completo + confianza sin puntos públicos* |

## Patrones (observaciones del equipo, **NO criterios oficiales**)

- **A) Problemas sociales concretos.** Los cuatro partieron de un dolor reconocible. *Nuestro riesgo:* tenemos tres problemas (economía local, solidaria, emergencia); hay que presentar **uno** como historia (ej.: "necesito un gasfitero de confianza hoy") y que los otros salgan de ahí.
- **B) Accesibilidad y menor fricción.** 2025 lo hizo explícito (WhatsApp, lectura asistida). *Nuestro riesgo:* la regla de 3 clics y la accesibilidad son **requisitos del reto**, así que se evaluarán sí o sí; el MVP las declara pero hay discrepancias (ver `01-analisis.md` §d y §f).
- **C) Tecnología con función clara.** *Nuestro riesgo:* Matrix, PostGIS y Realtime son infraestructura; ante el jurado deben aparecer como "por eso funciona sin que te des cuenta", no como lista de siglas.
- **D) Prototipos demostrables con recorridos completos, no apps llenas de funciones parciales.** *Nuestro riesgo mayor:* el MVP tiene ~30 funciones parciales/simuladas. La estrategia ganadora es **recortar la demo a un recorrido** (ver `02-demo.md`).

## Mapa de diferenciación: lo que ya apareció y NO puede ser nuestro único argumento

| Elemento | ¿Apareció antes? (HECHO documentado) | ¿Lo tiene nuestro MVP? | Veredicto |
|---|---|---|---|
| Geolocalización / reportes en mapa | Sí: 2022 (reportes geolocalizados), 2024 (reportes geográficos, contexto por ubicación) | Sí (parcial, esquemático) | **No diferencia.** Solo cuenta si cambia una decisión (elegir proveedor por cercanía real). |
| Chat vecinal | Sí: 2024 | Sí (simulado) | **No diferencia.** |
| Funcionamiento sin conexión | Sí: 2024 (bot online/offline) | Sí (parcial) | **No diferencia por sí solo.** Sí puede sumar si es *honesto y visible* (Pendiente/Enviada/Error). |
| IA / asistente | Sí: 2024 (experimental), 2025 (WhatsApp) | No | No es necesario; **no añadirla** solo por moda. |
| Lista de necesidades / alertas / notificaciones | Sí: 2022, 2024 | Sí (muro de pedidos, avisos) | **No diferencia.** |
| Accesibilidad / varias lenguas | Sí: 2025 | Sí (parcial) | Mínimo esperado; diferencia solo si se **demuestra con una persona real**. |
| Ciclo completo con precio acordado, código de encuentro y calificación de dos vías | No documentado en ganadores previos | Sí (en simulación) | **Candidato a diferenciador** (HIPÓTESIS). |
| Confianza vecinal medible sin puntos públicos (Visto Bueno + "Tu ayuda al barrio") | No documentado | Sí (parcial: el Visto Bueno hoy no sube tras interacciones; ver análisis) | **Candidato**, pero necesita regla anti-inflado creíble (R25). |
| Una sola red para economía cotidiana, solidaria y emergencia | No documentado | Sí | **Candidato** (es el núcleo de la propuesta "Comunidad que Responde"). |

**Conclusión (INTERPRETACIÓN):** la innovación debe presentarse como *"el ciclo de confianza que convierte una necesidad cercana en una respuesta organizada y cerrada, y que ya está en uso cuando llega la emergencia"*. Geolocalización, chat, offline y alertas son el **piso** (ya ganaron en 2024), no el techo.

*Fuentes (solo referencia bibliográfica):* elcomercio.pe — "Tu Voto Manda…" (2025); elcomercio.pe — "Ganadores del hackathon UTP-El Comercio combaten la inseguridad ciudadana con tecnología" (2024); publicación de UTP en LinkedIn sobre la Hackathon 2023; elcomercio.pe — "Jóvenes peruanos desarrollan una app para promover la participación entre ciudadanos y municipalidades" (2022).
