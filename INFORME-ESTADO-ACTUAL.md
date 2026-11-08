# Informe del estado actual — "Red del barrio"
VIII Hackathon UTP–El Comercio 2026 · Equipo de Jorge (Daniel, Adams, André, José) · Versión del 7-nov-2026, 7:20 p. m. (Lima)

> Para GPT: este informe describe lo que la app hace hoy. Adjunto también `red-del-barrio.html` (un solo archivo, sin librerías). Al final están las preguntas concretas que quiero que respondas.

## 1. La idea
**"Red de capacidades y confianza vecinal".** El vecino dice qué necesita, su barrio propone cómo resolverlo, cada interacción confirmada construye reputación, y esa misma red se activa en una emergencia. Es una PWA instalable (un solo `index.html`, JavaScript sin librerías, funciona sin internet).

## 2. Qué pide el reto (lámina "Características funcionales") y qué hace la app

| # | Requisito del reto | Estado | Cómo se cumple |
|---|---|---|---|
| 1 | Información recomendada de productos y servicios cerca de la zona de residencia | Cumple | "Explorar cerca" en Inicio: pestañas Servicios y Productos, filtro por rubro, orden por "más recomendados" o "más cerca". La distancia sale del GPS real. Cada tarjeta dice "Recomendado por X vecinos de tu zona". |
| 2 | Promover servicios y compartir recomendaciones vecinales | Cumple (agregado hoy) | Promover: "Cuéntanos qué haces" (oficio y disponibilidad, sin precio) y publicar ventas de productos. Recomendar: botón "Recomendar" en cada tarjeta (un voto por persona, se puede quitar) y "Recomendar a un vecino" para alguien que no está en la lista (queda "sin verificar"). Además, el Visto Bueno sube después de una interacción confirmada. |
| 3 | Solicitar y ofrecer ayuda e intercambios solidarios entre vecinos | Cumple | Pedir ayuda con 4 tipos de solicitud (servicio, producto, préstamo, ayuda). Muro de pedidos y ofertas. Préstamos con código de encuentro de 4 dígitos. Donativos en puntos de acopio. Calificación de dos vías. |
| 4 | Servicios y grupos de apoyo disponibles en emergencias | Cumple (agregado hoy) | Modo emergencia: institución oficial primero; "Oficios y vecinos que pueden ayudar ahora" (gasfitero, electricista, cerrajero, carpintero, enfermera con botiquín, vecino con camioneta, bodega), con distancia y qué puede hacer cada uno; grupos de apoyo; puntos de acopio; mapa; brigadistas voluntarios. |

Otros requisitos del reto: geolocalización (real), tutorial (existe), máximo 3 clics (las acciones principales están en 2–3), online/offline (real), accesibilidad (alto contraste, texto grande, alertas visuales y vibración, frases rápidas con pictogramas), idiomas (español, inglés y quechua).

## 3. Cómo funciona el flujo principal
1. **Pedir.** El vecino escribe o elige qué necesita. En "Explorar cerca" puede pedir un servicio en 2 toques.
2. **Proponer.** El proveedor **no publica precio de antemano**. Cuenta qué hace y cuándo está disponible. Cuando aparece un pedido, ve el pedido y **propone su precio** (la app no deja enviar sin precio).
3. **Aceptar y encontrarse.** El vecino acepta una propuesta, se genera un código de 4 dígitos para verificar el encuentro, y hay un chat.
4. **Ajuste de precio.** Si el servicio cambia en el lugar, el proveedor propone un nuevo precio con motivo y foto. El precio solo cambia si el vecino acepta. No hay contraofertas (se simplificó).
5. **Cerrar.** Calificación en los dos sentidos. Eso alimenta la reputación y el Visto Bueno.

## 4. Reputación y nivel solidario
- **Reputación de servicio** (estrellas) y **reputación entre vecinos**, por separado.
- **"Tu ayuda al barrio"**: resumen de evidencia (ayudas confirmadas, personas distintas, préstamos completados, tiempo aportado, calificación promedio). **No hay puntos, puestos, prioridad ni ventaja comercial.** Cada persona ve solo su propio resumen.
- Anti-abuso: una ayuda cuenta solo si ambos confirman, y máximo 2 con la misma persona.

## 5. Emergencias
- Tipos: sismo, incendio, médico, persona mayor en riesgo y violencia (esta es privada, no sale en el muro).
- **Primero la institución oficial**, después la red vecinal.
- **La ubicación exacta no se muestra en público.** Se ve una zona aproximada (~1 km). La exacta la recibe solo quien aceptó ayudar.
- Brigadista vecinal voluntario (sin verificar). Cualquier vecino puede proponer un punto de acopio, que se muestra como "Propuesto por un vecino (sin verificar)".

## 6. Lo que funciona de verdad
- Datos guardados en el teléfono (`localStorage`).
- GPS real; distancia calculada desde la ubicación real.
- Sin internet: abre sin conexión y deja las solicitudes en una cola de pendientes hasta que vuelve la señal.
- Fotos reducidas y guardadas; si el almacenamiento se llena, quita las más antiguas, avisa y no pierde los datos. Perfil muestra el uso de espacio y permite quitar fotos.
- Si falla una pantalla, aparece un panel de error con botón para volver a Inicio, y no queda en blanco.
- Datos viejos guardados se actualizan solos al abrir la versión nueva (esto causó un error hoy y ya está corregido).
- Pruebas automáticas con navegador: flujos principales, estado guardado viejo, persistencia, emergencia, y una prueba aleatoria de clics en 5 semillas sin errores.

## 7. Lo que es simulado o está incompleto (decirlo así al jurado)
- **No hay servidor ni cuentas.** Los datos viven solo en ese teléfono y no se comparten entre personas.
- Los vecinos, proveedores, precios, propuestas y respuestas son de ejemplo.
- Las recomendaciones propias (botón Recomendar) solo se guardan en tu teléfono. En la versión real contarían solo vecinos verificados de la zona.
- **Los números de emergencia no están verificados** contra fuentes oficiales.
- **El quechua no fue revisado por un hablante nativo.** Inglés y quechua cubren las pantallas principales, no toda la app.
- Verificación de identidad (RENIEC), pagos y seguimiento en vivo están como "Próximamente".
- Sin contraofertas; sin escala de sanciones (solo se mide cumplimiento, reportes y quien no se presenta).
- No se probó en un teléfono real ni con HTTPS publicado; las pruebas fueron en navegador de escritorio con tamaño de celular.
- Queda código sin uso de la guía de demo anterior (no afecta el funcionamiento).

## 8. Reglas que no se pueden romper
Máximo 3 clics en las acciones principales · funciona sin internet · la ubicación exacta nunca es pública · los puntos y puestos de reputación no son públicos · en emergencia siempre va primero la institución oficial · texto en español claro y sencillo.

## 9. Lo que quiero que analices
1. **Contra el reto:** ¿qué requisito o criterio del jurado queda flojo? Dime lo peor primero.
2. **Riesgos de confianza:** ¿se puede inflar el Visto Bueno con el botón Recomendar? ¿Qué regla simple (sin servidor) lo haría creíble en una demo?
3. **Emergencia:** ¿hay algo que pueda confundir o poner en riesgo a una persona real? ¿Qué debo advertir antes de mostrarla?
4. **Privacidad:** ¿algún texto o pantalla sugiere más de lo que la app hace con la ubicación o los datos?
5. **Accesibilidad (WCAG 2.2 AA):** los 5 problemas más importantes, con el arreglo en un fragmento pequeño.
6. **Demo de 3 minutos:** ¿qué mostraría yo primero, y qué debería evitar tocar porque es simulado?
7. **Preguntas difíciles del jurado** (escalabilidad, modelo de sostenibilidad, cómo arrancar sin masa crítica de vecinos) y una respuesta honesta de 2 frases para cada una.

Formato que prefiero: lista corta ordenada por impacto y esfuerzo, y los cambios como parches pequeños (la función o línea que cambia), sin reescribir el archivo.
