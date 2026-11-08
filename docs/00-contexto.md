# Contexto del proyecto (fuente de verdad)

> Este archivo guarda, tal cual, las secciones 1 a 7 del prompt de trabajo del 7-nov-2026. Es el contexto que se debe pasar de forma explícita a los skills `mobile-design` y `frontend-design`: ellos no conocen el proyecto salvo lo que se les entregue (reto, requisitos —en especial el máximo de 3 clics y la accesibilidad—, usuarios, reglas inviolables y propuesta de valor).
>
> **Usuarios:** vecinos de todas las edades, incluidos adultos mayores y personas con baja alfabetización digital.
> **Archivo del PWA:** en este repositorio es `index.html` (un solo archivo, JavaScript sin librerías).

---

# 1. EL RETO (VIII Hackathon UTP × El Comercio 2026)
Crear en 48 horas un aplicativo que sirva a los ciudadanos para obtener, con costos mínimos y sin necesidad de transporte mayor, productos y servicios avalados por recomendaciones de vecinos. Debe integrar mecanismos de intercambios solidarios y evolucionar en situaciones de emergencia para coordinar soporte a los vecinos.

Módulos de la propuesta presentada:
1. Servicios de Proximidad (Economía Local): directorio de oficios y profesiones del barrio (gasfitería, carpintería, electricidad, paseador de mascotas, clases, cerrajería, etc.) validados con "Visto Bueno Vecinal" (recomendaciones de vecinos de la misma zona). En emergencia: directorio de servicios y grupos de apoyo.
2. Cadena de Favores y Red de Solidaridad (Economía Solidaria): muro comunitario para resolver necesidades sin dinero (préstamo de herramientas, ayuda temporal, donación de materiales, intercambio de habilidades, movilidad solidaria). En emergencia: tablero de ayuda humanitaria con reportes geolocalizados de vecinos en vulnerabilidad y espacio para coordinar y compartir recursos críticos.

Características funcionales que declara la propuesta: obtener información recomendada sobre productos y servicios cerca de la zona de residencia; facilidad para promover servicios y compartir recomendaciones vecinales; facilidad para solicitar y ofrecer ayuda e intercambios solidarios entre vecinos; identificación de servicios y grupos de apoyo disponibles durante emergencias.

Requisitos obligatorios del reto (tienen prioridad sobre todo lo opcional):
1. Coordinación de necesidades y recursos entre vecinos, también en emergencias.
2. Geolocalización de servicios, recursos y necesidades de apoyo, útil y comprensible.
3. Tutorial para usar la aplicación.
4. Enfoque móvil, con un MÁXIMO DE 3 CLICS PARA PUBLICAR. Validar la interpretación exacta; no ocultar pasos.
5. Funcionalidad online y offline, indicando qué requiere sincronización.
6. Uso intuitivo y accesible para cualquier vecino del barrio.

Criterios de evaluación de las bases:
- Usabilidad: intuitivo, sin dificultades en ninguno de sus elementos.
- Confiabilidad: cumple el objetivo; estable.
- Escalabilidad: desarrollado para incorporar a futuro funcionalidades más complejas.
- Propuesta: expone una idea o proyecto considerando riesgos o beneficios a los que puede acceder la institución.
- Código y Programa: realiza completamente la interfaz y la funcionalidad del programa.
- Innovación y Creatividad: responde a la problemática con ideas nuevas y exitosas; algo nuevo y original.

# 2. ANTECEDENTES: GANADORES 2022-2025 (BENCHMARK)
Regla de oro: distingue siempre HECHO documentado / INTERPRETACIÓN del equipo / HIPÓTESIS por validar / REQUISITO del reto actual. No inventes criterios del jurado, resultados de evaluación ni funcionalidades de los ganadores. No copies; aprende de los patrones. Todo el material está aquí: NO busques en internet. Las fuentes se listan solo como referencia bibliográfica.

2025, "Loop: Tu Voto Manda" (Nicolás Alayo, Isaac Takamura, Víctor Sevillano, Juan Carlos Chávez; UTP Chimbote). Reto de esa edición: NO DOCUMENTADO. Problema: acceso desigual a información confiable y comprensible sobre las elecciones generales de Perú 2026. Solución: plataforma de información electoral con perfiles adaptados (electores analíticos y prácticos), información oficial organizada y asistente de IA en WhatsApp. Elementos: WhatsApp para reducir barreras, lectura asistida, compatibilidad con distintas lenguas, gamificación. Interpretación: se diferenció por canal, personalización y accesibilidad, no solo por usar IA. Lección: una solución sobresale cuando elimina una barrera relevante para el usuario. Fuente: elcomercio.pe, nota "Tu Voto Manda: la solución de inteligencia artificial que ganó la hackathon de UTP y El Comercio".

2024, app de seguridad ciudadana (Gabriel Andrade, Luis Bautista, Omar Mariños, Antonio Montejo; UTP Chimbote). Reto: NO DOCUMENTADO. Problema: inseguridad ciudadana y coordinación insuficiente en situaciones de riesgo. Solución: notificaciones de emergencia, botón de pánico, chat vecinal, bot online/offline, reportes geográficos y funciones experimentales de prevención con IA. Elementos: coordinación comunitaria, comunicación rápida en emergencias, información contextual por ubicación, consideración de escenarios sin conexión. Interpretación: integró varias herramientas alrededor de una necesidad concreta (pedir apoyo y mejorar la seguridad). Lección: la coordinación comunitaria debe producir resultados concretos; alertas, mapa u offline por sí solos no diferencian. Fuente: elcomercio.pe, nota "Ganadores del hackathon UTP-El Comercio combaten la inseguridad ciudadana con tecnología". ES EL ANTECEDENTE MÁS CERCANO A NUESTRA PROPUESTA (chat vecinal, geolocalización, offline, emergencias): analízalo con el máximo detalle.

2023, "Sismo Seguro" (UTP Chimbote; integrantes no documentados). Reto: NO DOCUMENTADO. Problema: falta de preparación familiar ante sismos de gran magnitud. Solución: app de prevención y reducción de riesgos por sismos. Lección: la prevención puede complementar la respuesta inmediata sin una plataforma excesivamente compleja. Fuente: publicación de UTP en LinkedIn sobre la Hackathon 2023.

2022, participación y seguimiento ciudadano (Pryscila Flores, Luis Melgarejo, Gerardo Quispe, Rodrigo Berrios). Reto: NO DOCUMENTADO. Problema: dificultad para conocer, reportar y supervisar acciones municipales. Solución: app móvil con información de obras públicas, reportes geolocalizados, notificaciones y seguimiento ciudadano. Lección: la ubicación debe servir para decidir y actuar, no solo para mostrar marcadores. Fuente: elcomercio.pe, nota "Jóvenes peruanos desarrollan una app para promover la participación entre ciudadanos y municipalidades".

Patrones (observaciones del equipo, NO criterios oficiales): A) problemas sociales concretos; B) accesibilidad y menor fricción; C) tecnología con función clara, no para impresionar; D) prototipos demostrables con recorridos completos, no apps llenas de funciones parciales.

Qué producir en docs/00-benchmark.md: para CADA edición, equipo y sede; reto (si es "no documentado", escríbelo y agrega APARTE una inferencia etiquetada INTERPRETACIÓN del reto implícito); problema; qué construyeron función por función (solo lo documentado); por qué probablemente destacó (INTERPRETACIÓN); qué nos enseña y qué NO repetir; y cómo se compara nuestro MVP actual (qué ya hacemos igual y por tanto NO nos diferencia, qué hacemos distinto). Cierra con: tabla comparativa 2022-2026 (año, problema, canal/tecnología, accesibilidad, geolocalización, offline, coordinación comunitaria, seguimiento hasta resolución, lección); patrones A-D; y un mapa de diferenciación de lo que ya apareció (geolocalización, chat vecinal, offline, IA, lista de necesidades) y por tanto NO puede ser nuestro único argumento de innovación.

# 3. ESTADO ACTUAL DEL MVP: "Red del barrio" (informe del equipo del 7-nov-2026, 7:20 p. m.)
Equipo: Jorge, Daniel, Adams, André, José. Nombre de la propuesta estratégica: "Comunidad que Responde". Nombre de la app: "Red del barrio".
IMPORTANTE: este informe es AUTODECLARADO por el equipo. El código es la verdad. En la Fase 1 verifica cada afirmación contra el código y repórtame toda discrepancia (lo declarado que no existe, o lo que existe y no se declaró).

## La idea
"Red de capacidades y confianza vecinal": el vecino dice qué necesita, su barrio propone cómo resolverlo, cada interacción confirmada construye reputación, y esa misma red se activa en una emergencia. Es una PWA instalable: un solo archivo HTML, JavaScript sin librerías, funciona sin internet.

## Qué hace hoy frente a las características del reto
1. Información recomendada cerca de la zona de residencia: "Explorar cerca" en Inicio, pestañas Servicios y Productos, filtro por rubro, orden por "más recomendados" o "más cerca"; la distancia sale del GPS real; cada tarjeta dice "Recomendado por X vecinos de tu zona".
2. Promover servicios y compartir recomendaciones: "Cuéntanos qué haces" (oficio y disponibilidad, sin precio) y publicar ventas de productos; botón "Recomendar" en cada tarjeta (un voto por persona, se puede quitar); "Recomendar a un vecino" que no está en la lista (queda "sin verificar"); el Visto Bueno sube tras una interacción confirmada.
3. Solicitar y ofrecer ayuda e intercambios solidarios: 4 tipos de solicitud (servicio, producto, préstamo, ayuda); muro de pedidos y ofertas; préstamos con código de encuentro de 4 dígitos; donativos en puntos de acopio; calificación de dos vías.
4. Emergencias: modo emergencia con la institución oficial primero; "Oficios y vecinos que pueden ayudar ahora" (gasfitero, electricista, cerrajero, carpintero, enfermera con botiquín, vecino con camioneta, bodega) con distancia y qué puede hacer cada uno; grupos de apoyo; puntos de acopio; mapa; brigadistas voluntarios.
Otros: geolocalización real, tutorial, máximo 3 clics (acciones principales en 2-3), online/offline, accesibilidad (alto contraste, texto grande, alertas visuales y vibración, frases rápidas con pictogramas), idiomas español, inglés y quechua.

## Flujo principal (el REAL; úsalo, no uno genérico)
1. Pedir: el vecino escribe o elige qué necesita; en "Explorar cerca" pide un servicio en 2 toques.
2. Proponer: el proveedor NO publica precio de antemano; cuenta qué hace y cuándo está disponible. Cuando aparece un pedido, propone SU precio (la app no deja enviar sin precio).
3. Aceptar y encontrarse: el vecino acepta una propuesta, se genera un código de 4 dígitos para verificar el encuentro, y hay un chat.
4. Ajuste de precio: si el servicio cambia en el lugar, el proveedor propone un nuevo precio con motivo y foto; solo cambia si el vecino acepta. Sin contraofertas.
5. Cerrar: calificación en los dos sentidos; alimenta la reputación y el Visto Bueno.

## Reputación y nivel solidario
Reputación de servicio (estrellas) y reputación entre vecinos, por separado. "Tu ayuda al barrio": resumen de evidencia (ayudas confirmadas, personas distintas, préstamos completados, tiempo aportado, calificación promedio). NO hay puntos, puestos, prioridad ni ventaja comercial; cada persona ve solo su propio resumen. Anti-abuso: una ayuda cuenta solo si ambos confirman, y máximo 2 con la misma persona.

## Emergencias
Tipos: sismo, incendio, médico, persona mayor en riesgo y violencia (esta es privada, no sale en el muro). Primero la institución oficial, después la red vecinal. La ubicación exacta NO se muestra en público: se ve una zona aproximada (~1 km); la exacta la recibe solo quien aceptó ayudar. Brigadista vecinal voluntario (sin verificar). Cualquier vecino puede proponer un punto de acopio, mostrado como "Propuesto por un vecino (sin verificar)".

## Lo que funciona de verdad (según el informe)
Datos guardados en el teléfono (localStorage); GPS real y distancia calculada desde la ubicación real; abre sin conexión y deja las solicitudes en una cola de pendientes hasta que vuelve la señal; fotos reducidas y guardadas (si el almacenamiento se llena, quita las más antiguas, avisa y no pierde datos; el perfil muestra el uso de espacio y permite quitar fotos); panel de error con botón para volver a Inicio si falla una pantalla; los datos viejos guardados se actualizan solos al abrir una versión nueva (migración de esquema); pruebas automáticas con navegador (flujos principales, estado viejo, persistencia, emergencia, y clics aleatorios en 5 semillas sin errores). Esos escenarios de prueba son la ESPECIFICACIÓN DE PARIDAD para la migración: reprodúcelos como pruebas en Flutter.

## Lo que es simulado o está incompleto (debe decirse así al jurado y nunca presentarse como real)
- No hay servidor ni cuentas: los datos viven solo en ese teléfono y no se comparten entre personas.
- Vecinos, proveedores, precios, propuestas y respuestas son de ejemplo.
- Las recomendaciones propias (botón Recomendar) solo se guardan en el teléfono; en una versión real contarían solo vecinos verificados de la zona.
- Los números de emergencia NO están verificados contra fuentes oficiales.
- El quechua NO fue revisado por un hablante nativo; inglés y quechua cubren las pantallas principales, no toda la app.
- Verificación de identidad (RENIEC), pagos y seguimiento en vivo están como "Próximamente".
- Sin contraofertas; sin escala de sanciones (solo se mide cumplimiento, reportes y quien no se presenta).
- No se probó en un teléfono real ni con HTTPS publicado; las pruebas fueron en navegador de escritorio con tamaño de celular.
- Queda código sin uso de una guía de demo anterior (no afecta el funcionamiento).

## REGLAS INVIOLABLES (restricciones duras para TODAS las ramas)
1. Máximo 3 clics en las acciones principales.
2. Funciona sin internet.
3. La ubicación exacta nunca es pública.
4. Los puntos y puestos de reputación no son públicos.
5. En emergencia, siempre va primero la institución oficial.
6. Texto en español claro y sencillo.

# 4. PROPUESTA, ALCANCE Y DIFERENCIACIÓN
Propuesta de valor: transformar necesidades cercanas en respuestas comunitarias organizadas. No es una red social, ni un directorio comercial, ni un mapa de incidentes, ni una app de alertas. Proceso completo: Necesidad → Publicación → Descubrimiento → Oferta de ayuda → Coordinación → Resolución.
Hipótesis (por validar, NO presentar como resultado demostrado): una plataforma geolocalizada con solicitudes estructuradas, respuestas claras y seguimiento reduce la dificultad de coordinación entre vecinos.
Diferenciación (hipótesis a demostrar con un caso práctico): la COMBINACIÓN de publicación extremadamente rápida + descubrimiento cercano + coordinación entre vecinos + funcionamiento degradado sin conexión + seguimiento hasta la resolución + confianza vecinal medible sin puntos públicos.
Fuera de alcance (posible Fase 2 del producto, NO implementar): formalización de trabajadores o negocios, SUNAT, RUC, facturación electrónica, contabilidad, IA financiera, verificación RENIEC, pagos reales.
Decisiones por defecto (puedo cambiarlas):
- El directorio de oficios con Visto Bueno ya existe en el MVP, así que se migra completo en mobile-ux; en mobile-mejoras se le agrega la regla anti-inflado.
- Matrix/Element entra en mobile-mejoras junto con el backend; la demo NO debe depender de que el jurado abra Element: la coordinación y el estado de la solicitud se ven dentro de la app.
Escenarios de demostración: principal (pedir → proponer con precio → aceptar con código → ajuste de precio opcional → cerrar con calificación) y offline (sin conexión la app lo indica → la solicitud queda en la cola de pendientes → al volver la conexión se sincroniza o muestra error recuperable). Nunca simular que una operación llegó al servidor si sigue pendiente.

# 5. STACK TECNOLÓGICO
Decididos (no los cuestiones): Flutter + Supabase + Matrix (Synapse/Element). Los paquetes son MI RECOMENDACIÓN: puedes proponer un cambio justificado en la Fase 1 y anotarlo en docs/decisiones.md. Prioriza Android (APK); iOS solo si hay Mac. Como el PWA NO tiene servidor, el stack se introduce en DOS etapas:

Etapa 1, rama mobile-ux (SIN servidor, equivalente al PWA):

| Capa | Tecnología | Por qué |
|---|---|---|
| Framework | Flutter + Dart | Un solo código, rendimiento, UI propia |
| Estado e inyección | Riverpod | Testeable; sirve de inyección de dependencias |
| Navegación | go_router | Rutas declarativas |
| UI | Material 3 | Accesibilidad y componentes |
| Persistencia local | Drift (SQLite) con migraciones | Reemplaza localStorage; las migraciones reemplazan la actualización automática de datos viejos |
| Cola de pendientes | Tabla local de operaciones + UUID de cliente | Equivale a la cola del PWA; queda lista para sincronizar en la etapa 2 |
| Conectividad | connectivity_plus | Estado online/offline |
| Ubicación | geolocator + permission_handler | GPS real, distancia, manejo de permisos |
| Mapa | flutter_map + OpenStreetMap | Sin API keys de pago; caché de tiles para offline |
| Fotos | image_picker + flutter_image_compress | Reducir, re-codificar sin EXIF y gestionar el espacio |
| i18n | intl / flutter_localizations | Español, inglés y quechua (marca el quechua como NO revisado) |
| Accesibilidad | Semantics, escala de texto, modo alto contraste, vibración (haptics) | Paridad con alertas visuales y vibración del PWA |
| Errores | Manejador global de errores con pantalla de recuperación | Paridad con el panel de error del PWA |
| Frases rápidas | Pictogramas propios | Paridad con el PWA |

Etapa 2, rama mobile-mejoras (se agrega servidor):

| Pieza | Uso | Nota |
|---|---|---|
| Supabase Auth | Cuentas reales | Método simple para adultos mayores (teléfono o correo) |
| Postgres + PostGIS | Datos compartidos entre personas; consultas por cercanía | Índice GIST; migraciones versionadas |
| RLS | En TODAS las tablas | La ubicación exacta solo se expone a quien aceptó ayudar (regla inviolable 3, forzada por RLS y no solo por la UI); probar con dos usuarios |
| Realtime | Nuevas solicitudes y cambios de estado | No disponible offline |
| Storage | Fotos sin EXIF, con políticas | |
| Edge Functions (Deno) | Provisionar cuentas Matrix vía Synapse Admin API | El token de admin vive SOLO aquí |
| Matrix (SDK matrix de Dart) + Synapse + Element | Chat del trato: una room por trato al aceptar una propuesta | Detrás del puerto DealChatGateway; plan B: chat en una tabla de Supabase |
| Sincronización | La cola de pendientes del PWA se vacía hacia Supabase con idempotencia por UUID | |
| Seed | Script SQL con los datos de ejemplo del PWA, marcados como datos de demostración | |

Diagrama de sistemas objetivo (etapa 2): Flutter --REST/Realtime--> Supabase (Postgres: solicitudes, propuestas, interacciones, calificaciones; Storage). Al aceptar una propuesta: Flutter --Matrix Client-Server--> Synapse (una room por trato) --> Element. La Admin API provisiona cuentas solo desde una Edge Function.

# 6. ARQUITECTURA DE LA APP (obligatoria): HEXAGONAL PRAGMÁTICA, ESCALABLE Y TESTEABLE
- Puertos y adaptadores por feature: lib/app (router, tema, inyección), lib/core (Result/errores, utilidades, config) y lib/features/<feature>/{domain, infrastructure, presentation}. Features previstas (deriva las definitivas del mapa del PWA): needs (solicitudes y muro), proposals (propuestas, precio, ajuste de precio, código de encuentro), explore (explorar cerca, servicios y productos), directory (oficios, promover y recomendar), reputation (reputación y "Tu ayuda al barrio"), loans (préstamos), emergency, location, sync, deals_chat, settings (accesibilidad e idiomas).
- domain: entidades, value objects, puertos y casos de uso. NO importa Flutter, Drift, Supabase, matrix ni geolocator.
- infrastructure: adaptadores que implementan los puertos. presentation: pantallas y providers de Riverpod; depende solo de domain.
- Regla de dependencias: presentation → domain ← infrastructure. Nunca al revés.
- Puertos mínimos: NeedRepository, ProposalRepository, DirectoryRepository, ReputationRepository, DealChatGateway, LocationProvider, ConnectivityMonitor, ImageSanitizer, OutboxQueue, Clock. Añade otros solo si hay una frontera externa real.
- CLAVE DEL PLAN DE DOS ETAPAS: en mobile-ux los repositorios tienen adaptadores LOCALES (Drift). En mobile-mejoras se AGREGAN adaptadores remotos (Supabase) sin tocar dominio ni presentación: eso es lo que demuestra "Escalabilidad" ante el jurado.
- Casos de uso solo donde hay lógica de negocio: publicar solicitud, proponer precio, aceptar propuesta y generar código, validar código de encuentro, proponer ajuste de precio, cerrar y calificar, calcular reputación y Visto Bueno (con la regla de máximo 2 ayudas con la misma persona y confirmación de ambos), sincronizar la cola.
- Offline-first en el repositorio: la UI solo conoce Pendiente / Enviada / Error.
- Errores con Result (o Either); ninguna excepción de infraestructura se filtra a la UI.
- Pruebas: unitarias de casos de uso con adaptadores falsos; un test de arquitectura que falle si domain/ importa paquetes de infraestructura; pruebas de paridad que reproduzcan los escenarios del PWA (flujos principales, estado viejo, persistencia, emergencia); prueba de la cola de pendientes (duplicados y reintentos); una prueba de clics aleatorios equivalente a la del PWA.
- Pragmatismo: prohibida la ceremonia innecesaria (capas vacías, mappers para todo, abstracciones sin segundo uso). Cada abstracción se justifica en docs/decisiones.md.

# 7. REGISTRO DE RIESGOS (punto de partida: extiéndelo con lo que encuentres en el código)
Guárdalo en docs/03-riesgos.md con: ID, descripción, probabilidad, impacto, señal temprana, mitigación y plan B. Al final de la Fase 1 agrega los riesgos nuevos y reordena por severidad (probabilidad × impacto).

| ID | Riesgo | Prob. | Impacto | Señal temprana | Mitigación | Plan B |
|---|---|---|---|---|---|---|
| R1 | Alcance excesivo: el PWA ya tiene muchas funciones y migrarlas todas a mano consume el tiempo | Alta | Alto | Funciones "casi listas" a mitad del tiempo | Migrar por prioridad de la demo; congelar alcance a la mitad | Migrar solo lo que recorren los dos escenarios de demo |
| R2 | Offline aparente | Alta | Alto | La app abre sin datos en modo avión | Drift + cola con UUID, estados Pendiente/Enviada visibles | Offline limitado y honesto |
| R3 | Duplicados y conflictos al sincronizar (etapa 2) | Media | Medio | Filas repetidas tras reintentar | Idempotencia por UUID, upsert, last-write-wins documentado | Mostrar el duplicado y permitir fusionarlo |
| R4 | Matrix complejo: provisioning, SDK, E2EE, caída de Synapse | Media | Alto | Falla la creación de la room o el login | Edge Function robusta con reintentos | Chat en tabla de Supabase tras el mismo puerto |
| R5 | La demo depende de Element o de la red del lugar | Media | Alto | Ensayo con mala conexión | Coordinación visible en la app; ensayo con datos móviles; video de respaldo | Demo grabada |
| R6 | RLS mal configurado o fuga de secretos | Media | Muy alto | Un usuario ve datos de otro; secreto en el repo | RLS en todo, prueba con dos usuarios, escanear el repo antes de cada push | Rotar claves |
| R7 | Exposición de la ubicación exacta (viola la regla inviolable 3) | Media | Muy alto | Se ve la ubicación exacta en mapa, lista, logs o respuestas de API | Zona aproximada (~1 km) para terceros, exacta solo a quien aceptó, forzado por RLS; revisar logs | Ocultar el mapa y mostrar solo distancia |
| R8 | Fotos con EXIF | Media | Alto | Metadatos en una foto subida | Re-codificar antes de guardar o subir; verificar con una foto real | Deshabilitar fotos |
| R9 | Abuso, estafas y riesgo físico al encontrarse | Media | Alto | Reportes o publicaciones sospechosas | Reportar, código de encuentro, reputación, consejos de lugar público | Moderación manual en la demo |
| R10 | Emergencia: el usuario cree que la app sustituye a los servicios oficiales, o llama a un número incorrecto | Media | Muy alto | Uso de la app en una emergencia vital | Institución oficial primero (regla inviolable 5); verificar los números vigentes de Perú con fuentes oficiales y mostrarlos como "por verificar" hasta entonces; texto que no prometa respuesta | Retirar el número o texto dudoso |
| R11 | Geolocalización: permiso denegado, GPS impreciso, mapa sin conexión | Alta | Medio | Mapa vacío o ubicación errónea | Selección manual de zona, lista siempre disponible, caché de tiles | Búsqueda por barrio o rubro sin mapa |
| R12 | Límites del plan gratuito de Supabase y pausa por inactividad (etapa 2) | Media | Medio | Lentitud o proyecto pausado | Índices, paginación; despertar el proyecto antes de la demo | Reducir Realtime |
| R13 | Entorno y build: emulador, firma Android, sin Mac para iOS | Media | Alto | Errores de compilación recurrentes | APK debug para la demo | Dispositivo Android real |
| R14 | Sincronización en segundo plano bloqueada por ahorro de batería | Media | Medio | La cola no se vacía con la app cerrada | Sincronizar al abrir la app y al detectar red | Botón "Sincronizar ahora" |
| R15 | Accesibilidad insuficiente (WCAG 2.2 AA) | Media | Alto | Falla la prueba con una persona real | Objetivos de 48dp, contraste AA, texto escalable, Semantics; probar con al menos 2 personas ajenas al equipo | Modo de letra grande |
| R16 | Parece una red social o app de alertas más | Media | Alto | La demo se parece al antecedente 2024 | Centrar la demo en el ciclo completo hasta calificar | Reforzar el caso práctico del barrio |
| R17 | Hipótesis o datos simulados presentados como hechos | Media | Alto | Frases como "reduce la coordinación en un X%" o vecinos de ejemplo presentados como reales | Etiquetar hipótesis; marcar los datos de ejemplo como demostración | Reescribir con lenguaje de hipótesis |
| R18 | Datos personales: consentimiento y cumplimiento normativo (verifica la ley peruana de protección de datos personales vigente) | Media | Alto | No hay aviso ni consentimiento | Consentimiento explícito, mínimo de datos, política breve | Anonimizar los datos de la demo |
| R19 | Arranque en frío: sin vecinos, la app se ve vacía | Alta | Alto | Feed vacío en el ensayo | Seed marcado como demostración; estados vacíos con guía | Mostrar el escenario con datos de ejemplo declarados |
| R20 | Regresión: se pierde algo que el PWA sí hacía | Media | Alto | Funciones del mapa (a) que ya no están | Pruebas de paridad contra los escenarios del PWA | Mantener main como respaldo |
| R21 | Conflictos de ramas y desorden por el poco tiempo | Media | Medio | Merges difíciles | Commits pequeños, sin merges sin aprobación, docs/progreso.md al día | Volver al último commit estable |
| R22 | Sobreingeniería de dependencias | Media | Medio | Paquetes que nadie usa | Justificar cada dependencia | Retirarla |
| R23 | Sobreingeniería arquitectónica | Media | Medio | Más tiempo en carpetas y puertos que en pantallas | Hexagonal pragmática | Colapsar una capa en ese módulo |
| R24 | El dominio se contamina con tipos de infraestructura | Media | Medio | Imports prohibidos en domain/ | Test de arquitectura | Refactor puntual |
| R25 | Inflado del Visto Bueno con el botón Recomendar | Alta | Alto | Muchos votos desde un mismo origen o recién creados | Regla anti-inflado (ver Fase 1, sección j); solo vecinos verificados de la zona en la etapa 2 | Mostrar el Visto Bueno solo tras interacción confirmada |
| R26 | Traducciones: quechua sin revisión nativa y cobertura parcial de inglés y quechua | Alta | Medio | Textos erróneos o inconsistentes | Marcar quechua como "no revisado" en la app y en la demo; fallback a español | Retirar el quechua de la demo |
| R27 | Nunca probado en teléfono real ni con HTTPS publicado | Alta | Alto | Fallos de permisos, GPS o rendimiento en el aparato | Probar en un Android real desde la primera versión instalable | Demo en el dispositivo ya probado |
| R28 | Migración de datos locales (equivalente a la actualización automática del PWA) | Media | Medio | Error al abrir tras actualizar la app | Migraciones de Drift con pruebas desde esquemas viejos | Reiniciar el almacenamiento local con aviso |
| R29 | Almacenamiento lleno por fotos | Media | Medio | Fallos al guardar | Compresión, política de limpieza, aviso (paridad con el PWA) | Limitar las fotos por solicitud |
