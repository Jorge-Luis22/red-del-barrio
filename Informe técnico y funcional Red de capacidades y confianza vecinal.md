# Informe técnico y funcional: Red de capacidades y confianza vecinal 

Nov 7, 2026 · @Jorge

Este informe reúne todo lo acordado por el equipo de producto para la Hackathon UTP–El Comercio 2026, para que el equipo de desarrollo lo cargue en su IA y construya el prototipo sin partir de cero.

## 1. Cómo usar este documento

Este es el brief completo del producto: léelo entero antes de escribir código y trata cada sección como requisito, salvo lo marcado como pendiente o ruta futura.

**Instrucciones para la IA del equipo de desarrollo**

1. Lee primero las secciones 3 a 12 (qué hace el producto y por qué) y después la 14 (qué construir y en qué orden).
2. Distingue tres etiquetas que se repiten en todo el documento: **Decidido** (acordado por el equipo), **En el simulador** (ya existe como maqueta interactiva con datos ficticios) y **Pendiente** (acordado pero aún no construido).
3. No inventes reglas. Si algo no está escrito aquí, está en la sección 15 como decisión abierta: pregunta al equipo en lugar de decidir.
4. Los vecinos, precios, ubicaciones y nombres de este documento son **ficticios**. Todo dato simulado en la demo debe decirse como simulado.
5. Prioriza que lo mostrado funcione y sea estable por encima de sumar funciones: el jurado evalúa lo que ve funcionando.

**Glosario**

| Término | Significado |
| --- | --- |
| Necesidad | Lo que un vecino pide: un servicio, un producto, un préstamo o una ayuda |
| Propuesta | Respuesta de un vecino o negocio a una necesidad, con precio o modalidad, distancia y disponibilidad |
| Ofertante | Quien responde o publica algo que ofrece |
| Demandante o cliente | Quien pide |
| Código de encuentro | Código de 4 dígitos que muestra el demandante y el ofertante ingresa al llegar |
| Reputación de servicio | Estrellas y comentarios por trabajos y ventas, para comparar propuestas |
| Nivel solidario | Nombre del nivel por ayudas sin dinero (Vecino nuevo, activo, colaborador, solidario) |
| Cumplimiento | Porcentaje que baja con cancelaciones tardías; reemplaza al dinero como consecuencia |
| Punto de acopio | Lugar del barrio donde se reúnen donaciones en una emergencia |
| Visto Bueno Vecinal | Recomendación de vecinos de la misma zona (término del reto) |

## 2. Contexto: evento, reto y criterios

La Hackathon UTP–El Comercio 2026 es virtual y da 48 horas, del viernes 6 al domingo 8 de noviembre, para crear una app barrial; lo que el jurado vea funcionando decide.

**Fechas y formato**

| Hito | Dato |
| --- | --- |
| Inicio del desarrollo | Viernes 6, 7:00 p. m. (el equipo contó desde las 6:30 p. m.) |
| Cierre asumido | Domingo 8, 6:30 p. m., hora de Lima (sin confirmar con la organización) |
| Propuestas | 10, 11 o 12 de noviembre, 7:00 p. m. según sorteo; 15 min de exposición y 5 de preguntas del jurado |
| Finalistas | Se anuncian el 13; presentan el 17 de noviembre, 6:00 a 8:30 p. m.: 5 min de presentación y 15 de demo de toda la aplicación |
| Entrega | Desarrollo y presentación cargados en la carpeta de OneDrive del equipo; no se puede modificar después |
| Premios | 1.º USD 2,000 y difusión en El Comercio; 2.º USD 800 |

**El reto (texto de la organización)**

Crear una aplicación para que los ciudadanos obtengan, con costos mínimos y sin transporte mayor, productos y servicios avalados por recomendaciones de vecinos. Debe integrar intercambios solidarios y evolucionar en emergencias para coordinar soporte.

Características funcionales que pide:

1. Información recomendada sobre productos y servicios cercanos a la zona de residencia.
2. Facilidad para promover servicios y compartir recomendaciones vecinales.
3. Facilidad para solicitar y ofrecer ayuda e intercambios solidarios.
4. Identificar servicios y grupos de apoyo disponibles en emergencias.
5. Coordinar necesidades de ayuda y recursos entre vecinos en emergencias.
6. Geolocalizar servicios, recursos y necesidades de apoyo.
7. Tutorial de uso.
8. Enfoque móvil, con **máximo tres clics para publicar**.
9. Funcionamiento online y offline.
10. Uso intuitivo y accesible para cualquier vecino.

Módulos del reto:

- **Módulo 1, servicios de proximidad (economía local):** directorio de oficios y profesiones del barrio validados con el «Visto Bueno Vecinal»; en emergencias, directorio de servicios y grupos de apoyo.
- **Módulo 2, cadena de favores y red de solidaridad (economía solidaria):** muro colaborativo para resolver necesidades sin dinero (préstamo de herramientas, ayuda temporal, donación de materiales, intercambio de habilidades, movilidad solidaria); en emergencias, tablero de ayuda con reportes geolocalizados y coordinación de recursos críticos.

**Criterios del jurado (la organización no publicó pesos)**

- Funcionalidad: usabilidad, confiabilidad, escalabilidad, propuesta (riesgos y beneficios para «la institución», sin aclarar cuál), código y programa (interfaz y funcionalidad completas), innovación y creatividad.
- Presentación: comunicación y rol del equipo, manejo del tiempo, recursos audiovisuales, organización, capacidad de respuesta a preguntas.

Lectura propia, a validar: cuatro criterios premian que lo mostrado funcione, esté completo y sea estable.

## 3. Producto: la idea y su propuesta de valor

La **Red de capacidades y confianza vecinal** organiza necesidades y su resolución: el vecino dice qué necesita, su barrio propone cómo resolverlo, cada interacción confirmada construye reputación y esa misma red se activa en una emergencia.

**Estado: Decidido.**

- **Insight:** lo cotidiano construye la red que se usa en emergencias. Quien ya se conoce, se ha ayudado y se tiene confianza responde mejor cuando algo grave pasa.
- **Diferencial en una frase:** Facebook organiza publicaciones, WhatsApp conversaciones y los marketplaces anuncios; esta app organiza necesidades y su resolución.
- **Tesis de reputación:** ser buen gasfitero no es lo mismo que ser buen vecino prestador, así que cada contexto tiene su propia nota (reputación contextual) y solo cuentan interacciones confirmadas.
- **Frase de cierre del pitch:** aún sin elegir entre «la comunidad propone cómo resolver tu necesidad» y «el barrio que aprende y se prepara».

**Usuario objetivo**

Vecinos alrededor de los 30 años, con la experiencia pensada para simplicidad e intuición; el producto no debe depender de la edad ni de ser propietario de la vivienda.

**Problema que ataca (hipótesis, sin datos propios todavía)**

- No saber en quién confiar al contratar un servicio cercano.
- No tener dónde ofrecer lo que uno sabe hacer o puede prestar.
- No saber quién puede ayudar cerca cuando ocurre una emergencia.

**Problema detectado en el diseño: el cliente no es experto**

Un cliente puede describir un problema que resulta ser otro, y un proveedor puede aceptar un precio bajo por algo que termina siendo más grande. La respuesta del producto: precio estimado, detalles con foto y video antes de cotizar, ajuste de precio solo por acuerdo de ambas partes con motivo registrado, e historial visible de ajustes por proveedor (sección 7).

**Qué no es el producto**

- No reemplaza al 105, Bomberos, SAMU ni Defensa Civil: en una urgencia grave, primero se llama a los servicios oficiales.
- No procesa pagos en esta versión.
- No promete comunicación sin red entre celulares.

## 4. Roles, navegación y pantallas

La app es móvil, con cinco pestañas fijas abajo y un selector de rol; una misma persona puede pedir y ofrecer.

**Roles (Estado: En el simulador)**

| Rol | Qué hace | Cómo se elige |
| --- | --- | --- |
| Busco ayuda (demanda) | Pide servicios, productos, préstamos o favores | Pantalla inicial o Perfil |
| Ofrezco un servicio (oferta) | Publica su oficio, recibe solicitudes, cotiza | Pantalla inicial o Perfil |
| Las dos cosas (ambos) | Pide y ofrece; cambia con un selector arriba de Inicio | Pantalla inicial o Perfil |

Al abrir la app por primera vez aparece la hoja «¿Cómo quieres usar la app?». También hay un tutorial de 3 pasos (cómo publicar, cómo propone tu barrio, cómo se activa la red en emergencias).

**Barra de pestañas**

| Pestaña | Contenido |
| --- | --- |
| Inicio | Pregunta «¿Qué necesitas?», atajos rápidos, «Mis necesidades», recomendados del barrio con Visto Bueno. En modo oferta: «Ofrece tu servicio», mis productos, solicitudes cercanas |
| Vecinos | Muro entre vecinos (modalidades sin dinero), pedir algo a un vecino, vender un producto, pedidos de vecinos con botón Ofrecer |
| Mensajes | Lista de chats con las personas con quienes se cierra un trato |
| Emergencia | Preparación (capacidades, grupos de apoyo, recursos) y modo emergencia activo |
| Perfil | Nivel, reputación contextual, cumplimiento, comentarios recibidos, rol, privacidad, próximamente |

**Indicadores globales**

- Botón Online/Offline arriba a la derecha (en la demo simula la conexión; en la app real debe reflejar la conexión verdadera).
- Franja de aviso cuando no hay internet.
- En modo emergencia, el acento de color pasa a rojo y aparece un banner con la opción de salir.

**Pantallas y hojas (Estado: En el simulador, salvo lo marcado)**

1. Publicar necesidad (hoja): tipo, descripción, sugerencias, plazo, detalles opcionales, contador de clics.
2. Detalle de necesidad: estados de búsqueda, propuestas ordenables, perfil del proveedor, aceptación, código, cronómetro, ajuste de precio, cancelación, calificación.
3. Perfil de proveedor (hoja): reputación por contexto, comentarios, interacciones, capacidades.
4. Chat (pantalla completa con avisos de seguridad y respuestas rápidas).
5. Ofrecer servicio (hoja), Solicitud y cotización (hoja), Proponer otro precio (hoja), Cancelar (hoja).
6. Vender un producto (hoja) y tarjetas de propuestas con aceptar, rechazar y contraofertar.
7. Emergencia: preparación y modo activo con mapa esquemático, necesidades, recursos y grupos.
8. **Pendiente:** verificación de perfil, nivel solidario y balance, constancia, muro de emergencia completo, filtro por tipo de situación, recursos y donativos, filtro del muro por modalidad.

## 5. Motor central: de la necesidad a la reputación

Todo parte de la necesidad y sigue siete pasos; los mismos estados sirven para servicios, productos, préstamos y ayudas.

**Flujo (Estado: En el simulador)**

1. **Necesidad:** el vecino elige tipo, describe lo que necesita y el plazo. Publicar suma **tres clics como máximo** (tipo, descripción, publicar); los atajos y sugerencias reducen clics. Cualquier campo adicional (detalles, fotos, video) es opcional y no cuenta como clic.
2. **Propuestas:** vecinos y negocios cercanos responden con precio o modalidad, distancia, reputación y disponibilidad. Cada propuesta indica si llega a tiempo para el plazo elegido.
3. **Comparación:** se ordena por reputación, cercanía o precio, y se abre el perfil del proveedor.
4. **Elección:** el demandante acepta una propuesta; se abre el chat y se genera el código de encuentro.
5. **Interacción:** se validan el código y, si aplica, se ajusta el precio por acuerdo. Corre el cronómetro.
6. **Resolución:** se confirma el servicio, la entrega, el préstamo o la ayuda.
7. **Reputación:** ambas partes se califican; el resultado se muestra cuando las dos terminaron.

**Tipos de necesidad y sus pasos de resolución**

| Tipo | Contexto de reputación | Pasos | Ejemplo |
| --- | --- | --- | --- |
| Servicio | Servicios | Aceptada, Servicio hecho | Necesito un gasfitero para arreglar una fuga |
| Producto | Servicios | Aceptada, Entregado | Necesito 2 bidones de agua |
| Préstamo | Entre vecinos | Aceptada, Entregado, Devuelto | Necesito un taladro por una hora |
| Ayuda | Entre vecinos | Aceptada, Ayuda recibida | Necesito ayuda para mover un mueble |

**Plazo:** Ahora mismo, Hoy, Mañana o Esta semana. Sirve para marcar cada propuesta como a tiempo o después del plazo.

**Estados de una necesidad**

| Estado | Significado | Siguiente |
| --- | --- | --- |
| pendiente | Creada sin internet; vive solo en el teléfono | sincronizando al volver la red |
| sincronizando | Enviándose | abierta |
| abierta | Recibiendo propuestas | aceptada |
| aceptada | Hay proveedor elegido; falta validar el código y terminar | esperando calificación, cancelada |
| esperando calificación | El demandante calificó; falta la otra parte | resuelta |
| resuelta | Ambos calificaron; se actualizan reputaciones | fin |
| cancelada | Se canceló con o sin causa; se registra el motivo | fin |

**Reglas del motor**

- Solo las interacciones confirmadas con código cuentan para reputación.
- No se puede confirmar sin internet; el botón de confirmación avisa que se restaure la conexión.
- Una necesidad aceptada no admite confirmar el trabajo mientras haya una propuesta de precio sin respuesta.
- Un mismo motor sirve para el sentido contrario (vender un producto, sección 10).

## 6. Detalles del problema, distancia y privacidad

Quien pide puede describir mejor el problema para que el ofertante cotice con información y no a ciegas; todo eso es opcional y no suma clics. **Estado: En el simulador.**

**Añadir detalles (opcional)**

- Botón «+ Añadir detalles (opcional, no cuenta como clic)» dentro de la hoja de publicar.
- **Preguntas guiadas por tipo** (se responden con un toque):

| Tipo | Preguntas |
| --- | --- |
| Servicio | ¿Dónde está el problema? (Cocina, Baño, Techo o pared, Otro); ¿Desde cuándo pasa? (Hoy, Hace unos días, Hace semanas); ¿Hay riesgo ahora? (Sí, hay fuga o chispas / No, puede esperar) |
| Producto | ¿Cuántos necesitas? (1, 2, 3 o más); ¿Entrega o recojo? |
| Préstamo | ¿Por cuánto tiempo? (1 hora, Hoy, Varios días); ¿Ofreces algo a cambio? (Nada, Trueque, Propina) |
| Ayuda | ¿Cuánto tiempo toma? (30 min, 1 a 2 h, Medio día); ¿Es urgente? |

- Descripción larga en texto libre.
- **Foto** (subida de archivo) y **video** (límite: en la demo, 20 MB; en la app real, máximo 30 s). Para la demo hay un botón «Usar ejemplo».
- Al publicar, los detalles quedan en la necesidad y se muestran en una tarjeta «Detalles que enviaste».

**Reglas de privacidad de los detalles (Estado: Decidido)**

- Solo los ven quienes proponen, nunca el barrio en general.
- Se eliminan los metadatos de ubicación de las fotos antes de guardarlas.
- Sin internet, las fotos y videos se suben al volver la conexión.

**Lo que ve el ofertante antes de cotizar (Estado: En el simulador)**

- Texto de la solicitud, plazo, detalles completos (respuestas guiadas, texto, foto, video).
- **Distancia aproximada** del cliente. La dirección exacta se muestra solo después de que el cliente lo acepta.
- **Calificación del cliente:** estrellas como cliente, número de servicios y porcentaje de cumplimiento.
- Botón **Pedir más detalles:** el cliente responde con nueva información o foto (en la demo, la respuesta es simulada).
- Opción de **visita de diagnóstico** (en la demo, S/ 10, se descuenta si lo contratan).

**Reglas**

- La dirección exacta nunca viaja por el chat ni por la lista de propuestas.
- Los comentarios y fotos del problema no se muestran en perfiles públicos.

## 7. Precio estimado, ajustes y sanciones

El precio de un servicio es estimado y solo cambia si cliente y ofertante lo acuerdan; esto protege a ambos de un problema que resulta distinto al descrito. **Estado: En el simulador (sanciones solo mostradas).**

**Precio estimado**

- Cada propuesta de servicio muestra «Precio estimado».
- Al cliente se le avisa: si el problema resulta distinto, el proveedor puede proponer otro precio, pero solo cambia si el cliente acepta.
- Al ofertante se le avisa: es un precio estimado; si el problema es otro, puede proponer un ajuste con motivo, que solo cambia si el cliente acepta.
- Visita de diagnóstico opcional (S/ 10 en la demo, se descuenta si lo contratan).

**Cuándo y cómo se propone un ajuste**

1. Solo después de validar el código y antes de marcar el servicio como hecho.
2. El ofertante propone un nuevo precio, elige un **motivo de una lista fija** y puede adjuntar una foto.
3. Motivos fijos: el problema es distinto al descrito; hacen falta más materiales; es más trabajo de lo previsto; otro motivo (se explica en el chat).
4. El cliente decide: **aceptar**, **contraofertar** (punto medio) o **rechazar**.
5. Cada ajuste queda registrado: precio anterior, nuevo, motivo, resultado.
6. Mientras haya una propuesta de precio sin respuesta, no se puede marcar el servicio como hecho.
7. Si no hay acuerdo, se mantiene el precio original y cualquiera de las partes puede cancelar **sin penalización**.
8. El precio final aparece en el resultado de la interacción.

**Regla de demo:** si el nuevo precio es hasta 35 % mayor que el estimado, el cliente simulado lo acepta; si es mayor, contraoferta al punto medio.

**Historial de ajustes por proveedor (Estado: En el simulador)**

- Cada tarjeta de propuesta muestra: «Ajustó el precio en N de M trabajos · Estado: \<nivel>».
- En el simulador, José Ramós aparece con muchos ajustes y estado «Menos visibilidad» para mostrar la consecuencia; es un dato ficticio.
- El cliente puede **reportar un ajuste injustificado**.

**Sanciones graduales (Estado: Decidido; en el simulador solo se muestran)**

| Nivel | Estado de la cuenta | Qué implica |
| --- | --- | --- |
| 0 | En regla | Sin consecuencia |
| 1 | Aviso | Mensaje de advertencia |
| 2 | Menos visibilidad | Aparece más abajo al comparar |
| 3 | Suspensión temporal | No puede cotizar por un tiempo |
| 4 | Baja | Cuenta cerrada, **siempre con derecho a apelar** |

- Se mira el **patrón con distintos clientes**, no un caso aislado.
- La misma lógica aplica al cliente que rechaza ajustes sin motivo de forma repetida: el ofertante puede reportar el rechazo y se registra.
- Sin pagos en la app, la consecuencia es de reputación y visibilidad, no económica.

**Pregunta abierta para validar con un mentor:** qué umbral de reportes activa cada nivel y quién revisa las apelaciones.

## 8. Código de encuentro, cronómetro y cancelaciones

El código confirma que dos personas se encontraron de verdad, y de ahí salen el cronómetro y la reputación. **Estado: En el simulador.**

**Código de encuentro**

- Al aceptar una propuesta se genera un código de 4 dígitos que ve solo el demandante.
- El ofertante lo pide en persona e ingresa para validar. Si es incorrecto, muestra error y puede reintentar.
- Hasta validarlo no se puede marcar el trabajo como hecho, ni cuenta para reputación.
- En la demo, el código se muestra a ambos lados y hay un botón que simula que el proveedor lo ingresa.

**Cronómetro**

- Arranca al validar el código y se detiene al marcar el trabajo como hecho.
- Muestra «En curso» con el tiempo transcurrido; es **informativo, no es un cobro**.
- Al terminar muestra: «Trabajo realizado en X tiempo. Califica el nivel de servicio y deja tus comentarios» (con la palabra Entrega o Préstamo según el tipo).
- Quién marca «hecho»: en el simulador, el ofertante marca y el cliente confirma. Es una decisión abierta (sección 15).
- En la demo hay un botón «avanzar 45 min» para mostrar un tiempo realista.

**Cancelaciones (Estado: Decidido; simulado con tiempos cortos)**

No hay pagos, así que la consecuencia es sobre el **cumplimiento** (porcentaje que sube o baja).

| Situación | Consecuencia | Tiempo en la demo |
| --- | --- | --- |
| Cancelar dentro de la ventana de gracia | Sin costo | 30 s tras aceptar (real: unos minutos) |
| Cancelar después, sin que el trabajo haya empezado | Baja el cumplimiento 5 puntos | Después de 30 s |
| Cancelar con el trabajo ya iniciado (código validado) | Baja el cumplimiento 10 puntos y el otro lado recibe aviso | Tras validar el código |
| Cancelar con causa | Sin penalización | Cualquier momento |
| «No llegó» tras la espera | Cancelas sin penalización; el otro recibe una consecuencia | 15 s (real: unos 15 min) |
| No hubo acuerdo de precio | Cancelar no penaliza | Tras rechazar un ajuste |

- Motivos al cancelar: con causa (la otra persona no responde; el problema es distinto al descrito; no llegamos a acuerdo en el precio) y sin causa (cambié de opinión).
- Se muestra qué consecuencia tendrá antes de confirmar.
- **Prohibido pedir o aceptar cancelar fuera de la app.** El chat detecta palabras como cancelar, WhatsApp, Yape o Plin y muestra un aviso a ambos lados; se pide reportarlo.
- Referencia de diseño: las reglas de cancelación de apps de transporte (fuentes de EE. UU.; las reglas aplicables en Perú no están verificadas).

## 9. Calificaciones de dos vías y reputación contextual

Ambas partes se califican y el resultado se muestra cuando las dos terminaron, para que nadie califique por represalia. **Estado: En el simulador.**

**Dos escalas separadas (Estado: Decidido)**

|  | Reputación de servicio | Nivel solidario |
| --- | --- | --- |
| Mide | Cómo cumples un trabajo o una venta | Cuánto ayudas sin cobrar |
| Fuente | Servicios y ventas | Préstamos, favores, trueques, donaciones y ayuda en emergencias |
| Se muestra como | Estrellas y comentarios | Solo nombre del nivel (desde «activo») |
| Estado | En el simulador | Pendiente (sección 12) |

No se mezclan: ser mal gasfitero no quita lo solidario y ayudar mucho no sube la nota como gasfitero. Lo único que cruza es la insignia «Vecino solidario» como sello en el perfil de servicios.

**Reputación contextual en el simulador**

- Cada proveedor guarda dos notas: **en servicios** y **entre vecinos**, con promedio y número de interacciones.
- La nota general que se muestra al comparar es el promedio ponderado de ambas.
- Al terminar, se muestra el cambio: reputación antes y después, e interacciones verificadas.

**Calificación del cliente al ofertante**

- Estrellas de 1 a 5 y etiquetas rápidas (Puntual, Buen trato, Buen precio, Trabajo limpio).
- Comentario opcional; las etiquetas se suman al texto.
- Aparece en el perfil público del proveedor, junto a los comentarios de vecinos.

**Calificación del ofertante al cliente**

- Estrellas y etiquetas propias (Puntual, Claro con el problema, Buen trato, Cumplió lo acordado) y comentario opcional.
- El cliente tiene su **propia reputación como cliente**: estrellas, número de servicios y porcentaje de cumplimiento. El ofertante la ve antes de cotizar.
- Se revela a ambos solo cuando los dos calificaron; mientras tanto se muestra «esperando que X también te califique».

**Reglas**

- Solo cuentan interacciones validadas con código.
- La calificación del cliente no cambia la nota de servicio del proveedor; son dos cuentas distintas.
- Las notas visibles son públicas; el cumplimiento, el estado de la cuenta y los puntos solidarios exactos son **privados**.

## 10. Venta de productos y muro entre vecinos

Vender un producto es el mismo motor al revés, y el muro entre vecinos cubre el Módulo 2 del reto (sin dinero). La venta está En el simulador; el muro está solo a medias.

**Venta de productos (Estado: En el simulador)**

1. El vendedor sube una foto, describe el producto y fija un **precio de lista** (estándar).
2. Los vecinos ven ese precio y deciden si lo compran o proponen uno **más bajo**.
3. El vendedor ve cada propuesta y puede **aceptar**, **rechazar** o **contraofertar** (punto medio entre su lista y la propuesta).
4. Máximo **2 rondas** de contraoferta; si no hay acuerdo, se cierra.
5. Al aceptar una propuesta (o al ser aceptada la contraoferta), se crea la entrega con el mismo motor: código de encuentro, chat, cronómetro, «entrega hecha», calificación de dos vías.
6. Las demás propuestas se cierran con el estado «el producto se vendió».
7. En la demo, llegan tres compradores simulados: uno al precio de lista, uno al 80 % y uno al 60 % que contraoferta de vuelta.

La pantalla de compra del lado del comprador (comprar o proponer un precio) aún no existe; solo se simula la llegada de propuestas.

**Muro entre vecinos, Módulo 2 (Estado: parcial)**

Siete modalidades sin dinero: préstamo, trueque, alquiler, donación, favor, intercambio de habilidades y movilidad solidaria.

| Elemento | Estado |
| --- | --- |
| Pedir algo a un vecino (tipos Préstamo y Ayuda) con propuestas, código, chat y calificación | En el simulador |
| Lista de pedidos de vecinos con botón Ofrecer (3 de ejemplo, fijos) | En el simulador |
| Las siete modalidades como etiquetas informativas | En el simulador (solo etiquetas) |
| Elegir la modalidad al publicar | **Pendiente** |
| Filtro del muro por modalidad | **Pendiente** |
| Publicar una **oferta** («presto mi taladro», «regalo materiales»), no solo pedidos | **Pendiente** |
| Flujo propio para donación, intercambio de habilidades y movilidad solidaria | **Pendiente** |
| Mezclar los pedidos del usuario con los de otros vecinos en el mismo muro | **Pendiente** |

Prioridad: sin esto, el muro se ve como maqueta, y el reto pide un muro colaborativo.

## 11. Emergencias

En emergencia, la red cotidiana cambia de reglas: se avisa al barrio, se muestra el contacto oficial correcto y se coordinan ayuda y recursos sin exponer a nadie. **Principio: la app no reemplaza al 105, Bomberos, SAMU ni Defensa Civil.**

**Modo emergencia actual (Estado: En el simulador)**

- Activación con un botón «Simular una emergencia»; el color pasa a rojo.
- Tres acciones: **Estoy bien**, **Necesito ayuda** (con tipo: Agua, Primeros auxilios, Movilidad, Otro) y **Puedo ayudar** (con las capacidades declaradas).
- Necesidades cercanas con distancia aproximada y botón «Puedo ayudar»; mapa esquemático con anillos de distancia; recursos del barrio; grupos de apoyo cercanos.
- Capacidades declaradas de antemano: Primeros auxilios, Movilidad, Herramientas, Ayudar a adultos mayores.

**Filtro por tipo de situación (Estado: Pendiente, decidido en el diseño)**

Al reportar, se elige una categoría. El sistema muestra primero el contacto oficial y después las acciones permitidas. Los números son los que el equipo conoce; **verifíquenlos antes de ponerlos en pantalla**.

| Situación | Atiende primero | Qué puede hacer la red vecinal | Visibilidad |
| --- | --- | --- | --- |
| Incendio | Bomberos (116) | Avisar a vecinos cercanos, evacuar, albergue temporal | Alerta de zona, sin dirección |
| Sismo, huayco o inundación | Defensa Civil/INDECI (115) y bomberos | Agua, botiquín, albergue, ayuda a adultos mayores, movilidad | Necesidades por zona aproximada |
| Emergencia médica | SAMU (106) | Primeros auxilios básicos, movilidad a la posta | Pedido «persona necesita primeros auxilios» |
| Robo o asalto | Policía (105) y serenazgo | Aviso de precaución; **nunca confrontar** | Alerta general de zona, sin datos de víctima ni sospechoso |
| Violencia familiar, acoso o violencia sexual | Línea 100 y policía | Acompañamiento y apoyo discreto | **Nada público**; solo canal privado de confianza |
| Persona desaparecida | Policía | Difundir un aviso verificado | Datos mínimos y con autorización |
| Fallecimiento de un vecino | Servicios oficiales y la familia | Apoyo después: acompañar, comida, trámites, cuidado de niños | Solo si la familia lo autoriza |
| Crisis emocional o riesgo de autolesión | Línea de salud mental (113, por verificar) y familia | Acompañar sin dejar sola a la persona | **Nada público** |
| Adulto mayor o persona sola en riesgo | Familia, serenazgo o posta | Visitas, compañía, compras, movilidad | Necesidad sin nombre, zona aproximada |
| Falta de agua, luz o alimentos | Municipalidad o empresa de servicios | Compartir agua, víveres, cargadores | Recursos y necesidades por zona |
| Riesgo para niños | Policía y Línea 100 | Apoyo discreto a la familia | **Nada público** |

Para el prototipo, el equipo sugiere incluir **Incendio, Médico, Sismo o desastre, Robo y Persona sola o mayor**, más «Violencia o acoso» como caso privado; el resto va a ruta futura. Es una decisión abierta (sección 15).

**Contacto oficial junto con el aviso a vecinos (Estado: Decidido, pendiente)**

- Primero se muestra el contacto institucional: botón grande «Llamar a Bomberos (116)» o equivalente; después «Avisar a mis vecinos».
- Quien **recibe** el aviso también ve la institución: por ejemplo, ante un incendio, «Si puedes, llama al 116 y no entres al lugar», para no asumir que otro ya llamó.
- También se muestran contactos locales: serenazgo, posta, junta vecinal (en el prototipo son de ejemplo).
- La app **no llama ni reporta por la persona**. Conectarse automáticamente con una institución exigiría un convenio (ruta futura).
- En un celular, el número puede abrir el marcador; en la demo web se muestra como texto grande con botón de copiar.

**Ubicación al activar una emergencia (Estado: Decidido, pendiente)**

1. Al activar, la app pide permiso de ubicación y explica para qué y quién la verá.
2. **Aproximada** (zona de unos cientos de metros): la ven los vecinos cercanos en el mapa.
3. **Exacta:** solo quien **aceptó ayudar** o las instituciones, y solo mientras la ayuda esté en curso; se borra al cerrar el caso. Decisión abierta: si un contacto de confianza elegido por la persona también puede verla.
4. Categorías sensibles (violencia o acoso, autolesión, niños en riesgo, muerte): **sin ubicación pública**; solo a personas de confianza o a instituciones.
5. La ubicación expira sola a las pocas horas o cuando alguien marca «resuelto».
6. Sin internet: el GPS del teléfono funciona, pero enviar la ubicación requiere conexión; el aviso se guarda y se envía al volver la red. No se promete comunicación sin red.
7. Opción de botón único «Necesito ayuda» que comparte la ubicación sin pedir más datos, para quien no puede escribir.
8. **Riesgos:** rastreo o acoso, reportes falsos, privacidad de datos (Ley 29733, sin verificar). Mitigación: la exacta solo la ve quien aceptó, expira, reportes falsos con consecuencias graduales y apelación.

**Muro de emergencia (Estado: Decidido, pendiente)**

Cada publicación tiene:

- **Título:** por ejemplo, «Incendio en vivienda cerca del parque X».
- **Tipo de situación** con ícono.
- **El porqué:** descripción corta escrita por quien reporta.
- **Qué se necesita:** lista concreta (colchones, abrigo, agua, albergue temporal, ayuda para limpiar).
- **Zona aproximada**, no dirección.
- **Estado:** nuevo, recibiendo ayuda, cubierto.
- **Institución** correspondiente.
- **Confirmaciones:** «N vecinos confirman», para reducir reportes falsos.

Qué es público y qué no:

- Públicos: título, tipo, porqué, necesidades y zona aproximada.
- **Nombre de la familia:** solo si ellos lo autorizan con un interruptor «mostrar mi nombre».
- **Dirección exacta:** nunca en el muro; solo para quien aceptó ayudar o las instituciones.
- Casos sensibles: no aparecen en el muro público.
- Principio: lo público es mínimo y la persona puede **subir** su nivel de detalle, nunca al revés.

Cómo llega la ayuda sin dirección pública:

1. Un vecino toca «Puedo ayudar».
2. La persona afectada ve quien ofrece (nombre, nivel solidario, distancia) y acepta a quien quiera.
3. Al aceptar se abre el chat y, solo para esa persona, se muestra la dirección exacta mientras dure la ayuda.
4. Se confirma con código de encuentro; al cerrar el caso, la dirección deja de verse.
5. Si la persona no puede chatear, puede activar de antemano «compartir ubicación exacta con quien acepte ayudar».
6. Si lo necesario son cosas (agua, abrigo, comida), se puede dejar en un **punto de acopio** cercano.

Decisión abierta: si publica solo la persona afectada o también un vecino testigo; en ese caso se pide confirmación de la familia antes de mostrar su nombre.

**Recursos y donativos (Estado: Decidido, pendiente)**

- Dos botones: **Ofrezco** y **Necesito**.
- Categorías: agua, alimentos, abrigo y ropa, botiquín básico, herramientas, linternas y cargadores, espacio seguro o albergue, movilidad, cuidado de niños o adultos mayores.
- Cada recurso: qué es, cantidad, zona aproximada, estado (disponible, reservado, entregado) y hasta cuándo está disponible.
- Cruce automático entre pedidos y ofertas cercanas, con confirmación por código.
- **Puntos de acopio:** lugares del barrio donde se reúne lo donado (local comunal, parroquia, colegio, tienda); aparecen en el mapa. Decisión abierta: si los pueden crear los vecinos o solo organizaciones verificadas.
- Resumen por zona para que una junta o grupo de apoyo vea dónde falta.
- Reglas: **sin dinero** (no hay colectas ni transferencias); medicinas solo de botiquín básico, nunca con receta ni vencidas; aviso de estado y vencimiento en alimentos; límite por pedido y por persona para evitar acaparamiento; pedido con zona aproximada; reportes falsos con consecuencias graduales y apelación.
- La ayuda en emergencia otorga **más puntos solidarios** que una ayuda normal (sección 12).

## 12. Nivel solidario, incentivos y confianza

Para promover la ayuda entre todos los vecinos se incentiva con reconocimiento, reciprocidad y funciones, nunca con dinero: ponerle precio a un favor puede reducir las ganas de ayudar (hipótesis respaldada por estudios conocidos de economía del comportamiento). **Estado: Decidido, Pendiente de construir.** En el simulador solo existe un nivel simple en Perfil (Nuevo, Activo, Colaborador por número de necesidades resueltas).

**Nombres de nivel (no estrellas)**

| Nivel | Se logra con (propuesta, umbrales por ajustar) | Visible en público |
| --- | --- | --- |
| Vecino nuevo | Sin ayudas todavía | No |
| Vecino activo | Primeras ayudas confirmadas (por ejemplo, 3) | Sí |
| Vecino colaborador | Ayuda constante a varias personas (por ejemplo, 10) | Sí |
| Vecino solidario | Nivel máximo (por ejemplo, 25 ayudas, al menos 8 personas distintas y promedio de 4,5 o más) | Sí, también como sello en el perfil de servicios |

Los umbrales son propuesta del equipo de producto, **no datos validados**: dedíquenlos como parámetros fáciles de cambiar.

**Puntos y ranking (privados)**

- Los puntos exactos y el puesto en el ranking los ve **solo la propia persona**. Públicamente solo se ve el nombre del nivel. Quien no ayuda no tiene insignia y no se muestra que está abajo.
- Cada persona ve su avance en privado: por ejemplo, «te faltan 12 puntos para Vecino solidario».
- Los puntos **nunca bajan**; no hay castigo por no ayudar.
- Solo cuentan ayudas **confirmadas con código y calificadas con 4 o 5 estrellas** por quien las recibió.
- Propuesta de valores:

| Tipo de ayuda | Puntos |
| --- | --- |
| Ayuda corta (préstamo, favor de 5 minutos) | 1 |
| Ayuda que toma tiempo (mover un mueble, acompañar) | 3 |
| Ayuda en una emergencia | 5 |
| Bonus por ayudar a una persona nueva o distinta | Adicional |
| Bonus por racha (por ejemplo, 3 semanas seguidas) | Adicional |

- **Anti-trampa:** rendimientos decrecientes con la misma persona (la segunda ayuda vale la mitad y de la tercera en adelante, cero); tope diario de puntos (por ejemplo, 5); la misma pareja no suma indefinidamente; sin código y calificación no hay puntos.
- Si la ayuda no fue calificada con 4 o 5, se dice solo «gracias por ayudar», sin exponer a nadie.

**Beneficios dentro de la app (sin dinero)**

| Beneficio | Nivel | Nota |
| --- | --- | --- |
| Perfil con capacidades visibles y estado «disponible ahora» | Activo |  |
| Prioridad al pedir ayuda en pedidos **no urgentes** | Colaborador | Nunca aplica a emergencias, para no dejar sin ayuda a los nuevos |
| Publicar ofertas destacadas en el muro y balance mensual | Colaborador |  |
| Sello en el perfil de servicios y más visibilidad de tus productos y servicios | Solidario | Ver reglas abajo |
| Confirmar reportes de emergencia con más peso | Solidario | Se pierde si se abusa |
| Crear puntos de acopio | Solidario | Decisión abierta: si también pueden los vecinos sin nivel |
| Rol de brigadista vecinal y convocatoria prioritaria a brigadas y simulacros | Solidario |  |
| Constancia exportable de ayuda vecinal | Solidario | Ver abajo |

**Regla de oro:** nunca se bloquea nada básico ni de seguridad. Pedir ayuda, el botón de emergencia y los contactos oficiales son para todos, siempre.

**Visibilidad de productos y servicios según el nivel**

- El nivel solidario es **un factor más**, no el único, en el orden de las propuestas. Siguen pesando la relevancia, distancia, precio, disponibilidad y calificación de servicio.
- El beneficio tiene **tope**: un producto caro, lejano o mal calificado no queda primero por esto.
- Se muestra una **etiqueta clara** («Vecino solidario») para que el comprador entienda por qué aparece antes.
- El comprador sigue pudiendo ordenar por reputación, cercanía o precio.
- **El peso del factor es un parámetro ajustable**, sin valor fijo; se probará con usuarios reales más adelante.
- Quien recién llega tiene exposición neutra, no baja.
- Decisión abierta: si los negocios formales (bodegas, minimarkets) acumulan nivel solidario o tienen otro camino, por ejemplo apoyar puntos de acopio.

**Balance al cerrar una ayuda (Estado: Pendiente)**

Para quien ayudó, solo en privado: a quién ayudó y cuánto tardó (cronómetro), puntos ganados con la razón, avance al siguiente nivel, balance de ayudas dadas y recibidas y personas distintas ayudadas, el agradecimiento de quien recibió y una frase de impacto. Para quien recibió: qué se le resolvió y en cuánto tiempo, con un recordatorio amable de que también puede ayudar, sin presión. El balance es de ayudas, tiempo y puntos, no de dinero.

**Constancia de ayuda vecinal (Estado: Decidido, Pendiente)**

- Historial verificable y exportable de las ayudas confirmadas. Sirve para CV, becas, voluntariado o reconocimiento de una junta o municipalidad.
- La emite **la propia app**, con código o QR de verificación y la lista de ayudas confirmadas, con el texto «Constancia de ayuda vecinal verificada por la plataforma; no es un documento oficial».
- Las juntas, la municipalidad y otros aliados quedan como **co-firmantes opcionales** en la ruta futura; no son requisito.
- Decisión abierta: si lleva el nombre completo de quien ayudó o un código anónimo que la persona puede mostrar a su criterio.
- Inspiración: el equipo PAYNI, con B-VOZ, propone certificar participación comunitaria de jóvenes con insignias y certificados; nosotros no lo copiamos entero (sin foco en jóvenes, sin depender de una empresa, sin puntaje con aprendizaje automático).

**Verificación de perfil (Estado: Pendiente, no definida)**

El equipo quiere un perfil verificado. El DNI solo no es autenticación; la validación oficial (RENIEC por convenio o PIDE, con consentimiento y la Ley 29733) va en la ruta futura. Para el prototipo, una pantalla de verificación **simulada y etiquetada** sirve para mostrar la idea.

**Juntas vecinales y aliados (ruta futura)**

- Entran como **aliadas, no como filtro de acceso**: algunas juntas solo reconocen propietarios y excluirían a inquilinos, jóvenes y adultos mayores que alquilan.
- Posibles aportes: difusión, puntos de acopio, reconocimiento público, co-firma de constancias, prioridad en brigadas.
- Próximo paso real: un piloto en un solo barrio para validar umbrales, peso de visibilidad y cómo reciben el sistema. Todavía no hay conversación con ninguna junta.
- Ideas no validadas: reconocer públicamente, carta de respaldo, prioridad en talleres o campañas, uso del local comunal, descuentos pactados con comercios.

## 13. Offline, geolocalización, datos y arquitectura sugerida

El simulador no tiene servidor ni base de datos; este bloque define qué debe ser real en la versión que se construya y qué sigue simulado. Es una **propuesta**, no una decisión del equipo: el equipo de desarrollo decide la tecnología según lo que sabe hacer.

**Opciones de producción discutidas**

| Opción | Qué implica | Riesgo |
| --- | --- | --- |
| A. Presentar el simulador tal cual | Cero trabajo técnico nuevo; más tiempo para el pitch | Puede verse como solo maqueta |
| B. App web instalable (PWA) alojada | Datos guardados en el teléfono, offline real y ubicación del navegador | Medio: pocas horas; los datos siguen locales |
| C. Backend real | Cuentas y base de datos compartida, vecinos viendo lo mismo | Alto para 48 horas; igual hay que simular datos por el arranque en frío |

Recomendación del equipo de producto (hipótesis): la opción **B**, porque hace reales dos requisitos del reto (offline y geolocalización). La C va como ruta futura.

**Offline (Estado: simulado; real en B)**

- Lo que debe poder hacerse sin internet: abrir la app, ver lo último guardado, crear una solicitud o aviso y guardarlo como **pendiente**.
- Al volver la conexión, lo pendiente se **sincroniza solo** y empiezan a llegar propuestas.
- Sin internet no se puede confirmar entregas ni calificar (se avisa que se restaure la conexión).
- Los chats escritos sin red quedan como «Pendiente de envío».
- Mapa y datos del barrio disponibles desde lo guardado en el teléfono.
- **No se promete comunicación directa entre celulares sin red.**

**Geolocalización**

- Distancias y mapas son simulados en el simulador; en la versión real se usa la ubicación del navegador o del dispositivo, con permiso explícito y sobre HTTPS.
- Siempre **aproximada** en público; exacta solo para quien aceptó ayudar o las instituciones (sección 11).
- La vista previa dentro de algunas herramientas no permite el GPS real; probar en un navegador de celular.

**Entidades de datos sugeridas**

| Entidad | Campos principales |
| --- | --- |
| Usuario | id, nombre, rol (demanda, oferta, ambos), zona aproximada, capacidades, verificado (sí o no), cumplimiento, estado de cuenta |
| Necesidad | id, autor, tipo, texto, plazo, detalles (respuestas guiadas, texto, foto, video), estado, propuesta elegida, código, precio, tiempos |
| Propuesta | id, necesidad, proponente, precio o modalidad, distancia aproximada, disponibilidad, diagnóstico (sí o no) |
| Ajuste de precio | id, necesidad, de, a, motivo, foto, resultado, fecha |
| Interacción | id, partes, tipo, código validado, inicio, fin, calificaciones de ambos lados |
| Calificación | autor, destinatario, contexto (servicio o vecinos), estrellas, etiquetas, comentario, revelada (sí o no) |
| Producto en venta | id, vendedor, foto, descripción, precio de lista, estado |
| Oferta de compra | producto, comprador, precio, ronda (máximo 2), estado |
| Publicación de emergencia | tipo de situación, título, porqué, necesidades, zona aproximada, estado, confirmaciones, privacidad |
| Recurso | tipo, cantidad, zona, estado, disponibilidad, punto de acopio |
| Puntos de ayuda | usuario, ayuda, puntos, motivo (privados) |

**Privacidad y seguridad (aplican a todo)**

- Nunca mostrar dirección exacta ni nombre de víctimas en público.
- Quitar metadatos de ubicación de fotos antes de almacenarlas.
- Cumplimiento, estado de cuenta, puntos y ranking son privados.
- Los reportes tienen consecuencias graduales y siempre apelación.
- No guardar claves ni datos personales reales en el repositorio ni en los prompts.

**Accesibilidad y UX**

- Público de unos 30 años: pantallas simples, botones grandes (mínimo 44 px), texto claro, sin jerga.
- Etiquetas accesibles en botones y estados; no depender solo del color.
- Publicar en tres clics como máximo; lo opcional nunca suma clics.

## 14. Estado del prototipo y plan de construcción

Existe un simulador interactivo de un solo archivo HTML (versión 6) que sirve como **especificación ejecutable**; el equipo debe abrirlo, recorrerlo y reproducir su comportamiento en la versión real, y luego sumar lo pendiente.

**Casos de demo del simulador (siete, con guía paso a paso)**

1. Servicio: de la necesidad a la reputación de dos vías.
2. Entre vecinos: préstamo con entrega y devolución.
3. Emergencia: modo emergencia con estado, ayuda y mapa.
4. Sin internet: cola y sincronización.
5. Ofrezco un servicio: ver el problema, cotizar, ajustar precio y calificar al cliente.
6. Cancelaciones: ventana de gracia, cancelación tardía, con causa, «no llegó» y aviso fuera de la app.
7. Vender un producto: contraoferta y entrega.

**Qué funciona hoy en el simulador**

- Necesidad, propuestas, elección, código, chat, resolución y calificación de dos vías.
- Detalles con foto y video, preguntas guiadas, distancia aproximada y calificación del cliente.
- Precio estimado, ajuste por acuerdo mutuo con motivo, historial por proveedor, estados de sanción mostrados.
- Cronómetro y mensaje de trabajo realizado en X tiempo.
- Cancelaciones con ventana de gracia, cumplimiento y aviso en el chat.
- Venta de productos con contraoferta (2 rondas).
- Modo emergencia simple, cola sin internet, tutorial y roles.

**Lo que es simulado y debe decirse**

- Vecinos, precios, propuestas, ubicaciones, distancias, fotos de ejemplo y mapa.
- Verificación de identidad; las sanciones se muestran pero no se aplican de verdad.
- Las respuestas del otro lado (cliente, proveedor, comprador) son automáticas.

**Pendiente de construir (acordado, no existe aún)**

1. Verificación de perfil.
2. Nivel solidario con nombres, puntos privados y ranking privado.
3. Visibilidad extra de productos y servicios según el nivel, con parámetro ajustable.
4. Desbloqueos por nivel (confirmar reportes, crear acopios, rol de brigadista).
5. Balance al cerrar una ayuda y constancia emitida por la app.
6. Muro entre vecinos completo: elegir modalidad, filtrar, publicar ofertas.
7. Emergencias ampliadas: filtro por tipo de situación, contacto oficial, ubicación exacta controlada, muro de emergencia, recursos y donativos con puntos de acopio.
8. Compra del lado del comprador en la venta de productos.

**Prioridad de construcción sugerida (propuesta, ajustable)**

| Orden | Qué | Por qué |
| --- | --- | --- |
| 1 | Muro entre vecinos completo | Es un requisito explícito del reto y hoy se ve incompleto |
| 2 | Emergencias: filtro por tipo, contacto oficial, muro y ubicación | Es el segundo módulo del reto y la parte más diferencial |
| 3 | Offline y geolocalización reales (opción B) | Dos requisitos del reto; hacen real el prototipo |
| 4 | Nivel solidario, puntos y balance | Es el diferencial de incentivos; puede ir simplificado |
| 5 | Constancia, verificación de perfil y desbloqueos | Valor de pitch; pueden ser pantallas simuladas y etiquetadas |

**Plan sugerido de las 48 horas finales** (hoy es sábado 7 de noviembre y el límite asumido es el domingo 8 a las 6:30 p. m.)

- Sobre todo: **corte de funciones nuevas hacia el domingo 12:00 p. m.**
- Subida completa a la carpeta de OneDrive con 2 horas de margen (hacia las 4:30 p. m.).
- Entre ambos: guion, ensayo cronometrado de los 15 minutos y de los 5 de preguntas.
- La demo se prueba en otro dispositivo antes de entregar.

**Regla de oro de construcción:** un escalón bajo que funciona vale más que uno alto roto. Si algo no llega, se baja a pantalla simulada y etiquetada, no se elimina.

## 15. Riesgos, decisiones abiertas y datos no verificados

**Riesgos principales**

| Riesgo | Por qué importa | Mitigación propuesta |
| --- | --- | --- |
| Arranque en frío | Una red vecinal vacía no sirve; el jurado puede preguntar cómo se consiguen los primeros usuarios | Piloto en un solo barrio, alianzas futuras con juntas y datos de demostración claramente etiquetados |
| Privacidad y seguridad | Se manejan ubicaciones, fotos y casos sensibles | Ubicación aproximada en público, metadatos fuera de las fotos, casos sensibles privados, cumplir la Ley 29733 en la ruta real |
| Reportes falsos o abuso | Emergencias y reputación pueden usarse para dañar | Confirmaciones de vecinos con nivel, sanciones graduales y apelación |
| Prometer de más | Hay cosas simuladas | Decir en voz alta qué es simulado y qué es real; mostrar el roadmap |
| Alcance excesivo en 48 horas | Mucho acordado y poco tiempo | Prioridad de la sección 14 y regla del escalón bajo que funciona |
| Incentivos que distorsionan | Puntos pueden empujar a ayudas falsas | Código obligatorio, calificación 4 o 5, personas distintas, tope diario |

**Decisiones abiertas (necesitan respuesta del equipo)**

1. ¿Quién más ve la ubicación exacta además de quien acepta ayudar (por ejemplo, un contacto de confianza)?
2. ¿Quién puede crear puntos de acopio: solo nivel solidario o cualquier vecino?
3. ¿Qué categorías de emergencia entran al prototipo? Propuesta: Incendio, Médico, Sismo o desastre, Robo, Persona sola o mayor y Violencia o acoso (privado).
4. ¿Los negocios formales acumulan nivel solidario?
5. ¿La constancia lleva el nombre completo o un código?
6. ¿La prioridad al pedir ayuda entra en la primera tanda?
7. ¿Quién marca «hecho» en una ayuda: quien ayuda, quien recibe o ambos?
8. ¿Quién puede publicar en el muro de emergencia: la persona afectada o también un testigo?
9. ¿Para ser brigadista basta declarar capacidades o se exige al menos una ayuda confirmada?
10. ¿Qué tecnología y hosting domina el equipo de desarrollo (opción B)?
11. ¿Cuál es la frase de cierre del pitch?
12. ¿Qué significa «institución» en el criterio de Propuesta del reto?

**Datos no verificados (no afirmarlos como hechos en el pitch)**

- Hora límite de entrega: se asume el domingo 8 a las 6:30 p. m. (hora de Lima) sin confirmación.
- Si se enviaron las bases firmadas (plazo indicado: 5 de noviembre, 11:59 p. m.).
- Números de emergencia citados (105, 116, 106, 100, 115, 113): verificar uno por uno antes de mostrarlos.
- Detalles de la Ley 29733.
- Cifras citadas de B-VOZ (4,03 % y 96 %) y su origen.
- Reglas de Uber en Perú citadas como comparación.
- La lista de competidores y su alcance real.
- Los pesos de los criterios de evaluación (no han sido publicados).
- Los umbrales de nivel y los valores de puntos (son propuestas).
- La efectividad del incentivo de visibilidad (hipótesis a probar con usuarios reales).

## 16. Hoja de ruta y prompt de arranque para la IA del equipo

**Hoja de ruta (no construir ahora; mostrar como visión)**

| Etapa | Qué incluye |
| --- | --- |
| Tras el hackatón | Piloto en un solo barrio; validar umbrales de nivel, peso de visibilidad y reglas de cancelación con usuarios reales |
| Corto plazo | Cuentas y base de datos compartida (opción C), moderación básica, notificaciones |
| Mediano plazo | Seguimiento en vivo y tiempo estimado de llegada (solo el mismo día), verificación oficial de identidad con consentimiento, pagos |
| Largo plazo | Convenios con juntas vecinales, municipalidad y aliados; co-firma de constancias; moderación completa; comunicación con poca o ninguna red |

**Prompt de arranque (copiar y pegar en la IA del equipo de desarrollo, junto con este informe y el archivo del simulador)**

> Eres el asistente técnico de un equipo que compite en la VIII Hackathon UTP–El Comercio 2026 (virtual, 48 horas). Vamos a construir el prototipo de «Red de capacidades y confianza vecinal», una app de barrio con dos módulos del reto: servicios de proximidad con Visto Bueno Vecinal y muro de favores y solidaridad, con geolocalización, tutorial, máximo tres clics para publicar, funcionamiento online y offline, y accesibilidad.
>
> Te adjunto: (1) el informe técnico y funcional completo y (2) un simulador interactivo en un solo archivo HTML que es la especificación ejecutable del comportamiento.
>
> Reglas de trabajo: responde en español, directo y breve. Antes de programar, resume en 10 líneas lo que entendiste y lista tus dudas. Respeta lo marcado como Decidido; lo marcado como Propuesta o Decisión abierta me lo preguntas. No inventes datos ni cifras: si algo no está verificado, márcalo como supuesto. Construye por etapas pequeñas que funcionen de punta a punta; si algo no llega, déjalo como pantalla simulada y etiquetada, nunca roto. Mantén todos los parámetros ajustables (umbrales, tiempos, pesos) en un solo archivo de configuración.
>
> Primera tarea: dime qué tecnología recomiendas (propuesta: PWA con datos locales, geolocalización del navegador y modo offline con cola de sincronización) según lo que domina el equipo, y propón el plan de las horas restantes con la prioridad de la sección 14. No escribas código hasta que yo confirme el plan.

## 17. Idiomas y accesibilidad para personas sordas o con dificultad del habla

**Estado: Decidido como principio de diseño, Pendiente de construir.** Nada de esto existe aún en el simulador.

**17.1 Idiomas (principio: la app se adapta al idioma de cada persona)**

- Idiomas objetivo: español (base), inglés, quechua, francés, portugués, chino y japonés.
- Regla de arquitectura: **ningún texto escrito directamente en las pantallas**. Todo texto sale de un archivo de traducciones por claves, con un archivo por idioma. Agregar un idioma no debe tocar el diseño.
- Selector de idioma en el primer arranque y luego en Perfil. Si no elige, se usa el idioma del dispositivo y, si no existe, español.
- Formatos por idioma: fechas, horas y moneda (S/ para precios en Perú). Revisar que el diseño aguante textos más largos (francés, portugués) y escrituras sin espacios (chino, japonés).
- Los mensajes que escriben los vecinos no se traducen en el prototipo. A futuro, un botón «traducir» opcional.
- Los números de emergencia dependen del país, no del idioma.
- **Prioridad realista para las 48 horas (propuesta):** español e inglés funcionando de punta a punta; los demás idiomas con la estructura lista y las traducciones de las pantallas principales. Lo que no alcance se marca como «próximamente» en el selector, nunca roto.
- Calidad: el quechua debe revisarlo un hablante nativo; chino y japonés conviene que los revise alguien que los domine. Una traducción automática sin revisar es un riesgo en una app de confianza.
- Decisión abierta: qué variante de quechua (por ejemplo, sureo o ayacuchano-cusqueño) se usa primero.

**17.2 Personas sordas o con dificultad del habla (principio: nada depende del audio ni de hablar)**

- El chat de texto es la vía principal. Frases rápidas y pictogramas («ya llegué», «¿puedes repetir?», «necesito ayuda»).
- Campo opcional en el perfil, «Cómo prefiero comunicarme» (solo texto, lengua de señas, apoyo escrito), visible para quien va a ayudar o a prestar un servicio.
- Todos los avisos con vibración y alerta visual; nunca solo sonido. Ninguna función obliga a llamar por voz.
- Videos (tutorial, detalles de una necesidad) con subtítulos. Los detalles ya admiten video, que sirve para mostrar el problema con señas.
- Emergencia sin hablar: elegir tipo, un toque y texto opcional. El código de encuentro de 4 dígitos ya es visual.
- «Lengua de Señas Peruana» como capacidad ofertable en el muro de intercambio de habilidades; ayudar con ella suma al nivel solidario.
- Ruta futura: intérprete en video, contacto de emergencia por texto con las instituciones.
- Complementa lo ya definido en la sección 13 (botones grandes, etiquetas accesibles, no depender solo del color); sumar alto contraste y texto ampliable.

**No verificado**

- Si la PNP, el SAMU o los bomberos tienen línea de texto o WhatsApp de emergencia: confirmar antes de prometerlo en el pitch.
- Cómo la normativa peruana reconoce la lengua de señas y el quechua: no citarla hasta revisarla.

## 18. Catálogo completo de funciones de la app

Este catálogo lista **todas** las funciones que debe tener la app, con su regla de negocio y su estado. Es la referencia para construir y para verificar que no falte nada. Si una sección anterior (12 o 14) dice «pendiente» y esta tabla dice «En simulador», **vale esta sección**: el simulador v7 ya incluye el nivel solidario, el muro entre vecinos, las emergencias ampliadas, los idiomas y la accesibilidad.

**Estados**

| Estado | Significado |
| --- | --- |
| En simulador | Ya funciona en el simulador v7 (con datos y respuestas simuladas). Hay que reproducir el comportamiento en la versión real. |
| Parcial | Existe una parte en el simulador; la tabla dice qué falta. |
| Pendiente | Decidido por el equipo pero aún sin construir. |
| Visión | Hoja de ruta; no se construye en el prototipo. |

**Identificadores:** F-1x cuenta y perfil, F-2x motor de pedidos, F-3x precio y cancelaciones, F-4x oferta y venta, F-5x muro y chat, F-6x reputación y nivel solidario, F-7x emergencias, F-8x plataforma. Los umbrales, puntos y tiempos son **parámetros ajustables** (sección 13), no valores definitivos.

### 18.1 Cuenta, perfil, verificación, roles, idioma y accesibilidad

| ID | Función | Qué hace y reglas | Estado |
| --- | --- | --- | --- |
| F-11 | Tutorial inicial | 3 pasos: cuenta qué necesitas, tu barrio propone, la red se activa en emergencias. Se reabre desde Perfil. | En simulador |
| F-12 | Roles de uso | Busco ayuda, Ofrezco un servicio o Las dos cosas. Con «Las dos cosas» hay un interruptor arriba para alternar. Se cambia cuando se quiera en Perfil. | En simulador |
| F-13 | Registro e inicio de sesión | Cuenta real por teléfono o correo, con recuperación de acceso. El simulador no tiene cuentas. | Pendiente |
| F-14 | Zona del barrio | La persona define su zona aproximada. Nunca se pide ni se muestra la dirección exacta en público. | Parcial: zona fija simulada |
| F-15 | Verificación de perfil | DNI, consentimiento y selfie, con insignia «Perfil verificado». En el prototipo es una pantalla simulada y etiquetada; la validación real con RENIEC (con consentimiento, Ley 29733) va en la hoja de ruta. | Parcial: simulada |
| F-16 | Perfil de proveedor visible | Reputación general, en servicios y entre vecinos, interacciones verificadas, ayudas vecinales, capacidades y comentarios recientes. Si te ayudó antes, la app se lo recuerda a ambos sin obligar a nadie. | En simulador |
| F-17 | Capacidades de emergencia | Activar primeros auxilios, movilidad, herramientas y ayuda a adultos mayores. Se usan en «Puedo ayudar». | En simulador |
| F-18 | Estado «disponible ahora» | El perfil muestra si la persona puede ayudar en este momento. | Pendiente (solo aparece escrito como beneficio) |
| F-19 | Cambio de idioma | Selector en el botón de arriba y en Perfil: español, inglés, quechua, francés, portugués, chino y japonés. Todo texto sale de un archivo de traducciones por claves; agregar un idioma no toca el diseño. Si no elige, se usa el del dispositivo. | Parcial: solo menús, títulos y estados |
| F-110 | Idiomas completos | Traducir el resto de pantallas, formatos de fecha, hora y moneda, textos largos (francés, portugués) y escrituras sin espacios (chino, japonés). El quechua lo revisa un hablante nativo. | Pendiente |
| F-111 | Traducción de mensajes | Botón opcional «traducir» en lo que escriben los vecinos. | Visión |
| F-112 | Alto contraste y texto grande | Se activan en Perfil y se aplican a toda la app. | En simulador |
| F-113 | Avisos visuales y con vibración | Ningún aviso depende solo del sonido: alerta visual en pantalla y vibración. | En simulador |
| F-114 | Cómo prefiero comunicarme | Voz o texto, solo texto, lengua de señas peruana o apoyo escrito. Lo ve quien va a ayudarte o a prestarte un servicio. | En simulador |
| F-115 | Sin audio ni llamadas obligatorias | Chat de texto con frases rápidas y pictogramas; videos con subtítulos; reporte de emergencia sin hablar. | En simulador |
| F-116 | Lector de pantalla | Etiquetas accesibles en botones y estados, y no depender solo del color. Botones de 44 px como mínimo. | Parcial: etiquetas y tamaños aplicados; falta una prueba con lector real |

### 18.2 Motor de pedidos: de la necesidad a la calificación

| ID | Función | Qué hace y reglas | Estado |
| --- | --- | --- | --- |
| F-21 | Publicar una necesidad | Tipo, descripción y publicar: tres clics como máximo. Lo opcional nunca suma clics. Atajos para necesidades comunes. | En simulador |
| F-22 | Cuatro tipos | Servicio, Producto, Préstamo y Ayuda; cada uno con sus pasos y su contexto de reputación (servicios o entre vecinos). | En simulador |
| F-23 | Plazo | Ahora mismo, hoy, mañana o esta semana. Cada propuesta indica si llega a tiempo. | En simulador |
| F-24 | Detalles opcionales | Preguntas guiadas según el tipo, texto, foto y video (máximo 30 s). Solo los ven quienes proponen. Se quitan los metadatos de ubicación de las fotos. | En simulador |
| F-25 | Modalidad en préstamos y ayudas | Préstamo, trueque, alquiler, donación, favor, intercambio de habilidades o movilidad solidaria. | En simulador |
| F-26 | Propuestas | Llegan 3 con precio o modalidad, distancia aproximada, disponibilidad, reputación y si llega a tiempo. Se ordenan y se abre el perfil de cada proveedor. | En simulador |
| F-27 | Elegir propuesta | Se acepta una; se abre el chat con esa persona. | En simulador |
| F-28 | Código de encuentro | Código de 4 dígitos que el cliente da al proveedor. Al validarlo se confirma el encuentro y arranca el cronómetro. | En simulador |
| F-29 | Cronómetro | Mide desde el código hasta «hecho»; es informativo y se muestra en el mensaje «trabajo realizado en X tiempo». | En simulador |
| F-210 | Visita de diagnóstico | El proveedor puede ofrecerla; se descuenta si lo contratan. | En simulador |
| F-211 | Resolución | Confirmar entrega o devolución según el tipo. Quien marca «hecho» (quien ayuda, quien recibe o ambos) es una decisión abierta. | En simulador |
| F-212 | Calificación de dos vías | Estrellas, etiquetas y comentario. Se revela cuando ambos terminan, para evitar represalias. | En simulador |
| F-213 | Estados de la necesidad | Pendiente, sincronizando, abierta, aceptada, esperando calificación, resuelta y cancelada. | En simulador |
| F-214 | Necesidad sin internet | Se guarda como pendiente y se envía sola al volver la conexión. | En simulador |
| F-215 | Prioridad solidaria | Quien es Vecino colaborador o superior recibe una etiqueta y prioridad en pedidos **no urgentes**; nunca en emergencias. | Parcial: solo la etiqueta |
| F-216 | Reportar una necesidad o un usuario | Denuncia con motivo, revisión y consecuencia gradual. | Pendiente |

### 18.3 Precio, ajustes, cancelaciones y sanciones

| ID | Función | Qué hace y reglas | Estado |
| --- | --- | --- | --- |
| F-31 | Precio estimado | El precio de un servicio es una estimación; no es definitivo hasta el trabajo. | En simulador |
| F-32 | Ajuste de precio por acuerdo mutuo | El proveedor propone un nuevo precio con motivo fijo obligatorio (problema distinto, más materiales, más trabajo u otro) y foto opcional. El cliente acepta, contraoferta o rechaza. Nunca cambia sin acuerdo. | En simulador |
| F-33 | Historial de ajustes | Cada proveedor muestra en cuántos trabajos ajustó el precio y su estado de cuenta. El cliente lo ve antes de elegir. | En simulador |
| F-34 | Rechazo sin acuerdo | Si el ajuste se rechaza, cualquiera puede cancelar sin penalización; el proveedor puede reportar un rechazo sin motivo y, si es frecuente, el cliente recibe avisos. | Parcial: se registra y se avisa; sin consecuencia real |
| F-35 | Cancelación con ventana de gracia | Unos minutos sin costo (30 s en la demo). | En simulador |
| F-36 | Cancelación tardía | Baja el cumplimiento 5 puntos; 10 si el trabajo ya empezó. El otro lado recibe un aviso. | En simulador |
| F-37 | Cancelación con causa | La otra persona no responde, el problema es distinto, no hubo acuerdo de precio u otra razón válida: no penaliza. | En simulador |
| F-38 | «No llegó» | Tras la espera (15 minutos en real, 15 s en la demo) se puede cancelar sin penalización; quien no apareció recibe una consecuencia. | En simulador |
| F-39 | Cumplimiento | Porcentaje privado que baja con cancelaciones tardías y se ve en Perfil. | En simulador |
| F-310 | Aviso contra salir de la app | Si el chat sugiere cancelar o pagar fuera de la app (WhatsApp, Yape, Plin), se muestra un aviso: no está permitido y afecta ambas cuentas. | En simulador |
| F-311 | Escala de sanciones | En regla, aviso, menos visibilidad, suspensión temporal y baja, siempre con derecho a apelar. Se mira el patrón con distintos clientes, no un caso aislado. | Parcial: se muestra, no se aplica |
| F-312 | Apelación | Flujo para que una persona sancionada pida revisión. | Pendiente |
| F-313 | Pagos y cobros por cancelación | Pago dentro de la app y costo por cancelar tarde. | Visión |

### 18.4 Ofrecer servicios y vender productos

| ID | Función | Qué hace y reglas | Estado |
| --- | --- | --- | --- |
| F-41 | Publicar mi servicio | Qué hago, cuánto cobro y cuándo puedo. Aparece como «Visible». | En simulador |
| F-42 | Solicitudes cercanas | Ver el problema, la distancia aproximada, el plazo y la calificación del cliente. La dirección exacta solo aparece si te aceptan. | En simulador |
| F-43 | Pedir más detalles | El proveedor pide al cliente información o fotos antes de cotizar. | En simulador |
| F-44 | Enviar propuesta | Precio estimado y, opcionalmente, visita de diagnóstico. | En simulador |
| F-45 | Validar código y trabajar | El proveedor ingresa el código que le da el cliente; un código incorrecto muestra error. Arranca el cronómetro. | En simulador |
| F-46 | Marcar hecho y calificar al cliente | Muestra el tiempo; la calificación se revela cuando ambos terminan. | En simulador |
| F-47 | Calificación y cumplimiento como cliente | Quien pide también tiene reputación (calificación, cumplimiento, ajustes rechazados). | En simulador |
| F-48 | Vender un producto | Foto, descripción y precio de lista. | En simulador |
| F-49 | Propuestas de compra | Los vecinos compran al precio de lista o proponen uno menor. El vendedor acepta, rechaza o contraoferta (máximo 2 rondas). | En simulador |
| F-410 | Cierre de venta | Mismo motor: código, chat, entrega y calificación de dos vías. | En simulador |
| F-411 | Comprar un producto (lado del comprador) | Ver productos, comprar al precio de lista o proponer menos, contraofertar y calificar al vendedor. Hoy solo existe el lado del vendedor y una vista de «Productos cerca». | Pendiente |
| F-412 | Productos cerca (vista del comprador) | Lista ordenable por recomendado, cercanía o precio. El orden recomendado suma un impulso por nivel solidario (ver F-65). | En simulador |
| F-413 | Negocios formales | Bodegas y minimarkets ofrecen productos. Si acumulan nivel solidario o tienen otro camino (por ejemplo, apoyar puntos de acopio) es una decisión abierta. | Pendiente |

### 18.5 Muro entre vecinos, chat y mensajes

| ID | Función | Qué hace y reglas | Estado |
| --- | --- | --- | --- |
| F-51 | Muro de pedidos y ofertas | Alterna entre Pedidos y Ofertas de los vecinos, sin dinero. | En simulador |
| F-52 | Filtro por modalidad | Préstamo, trueque, alquiler, donación, favor, intercambio de habilidades, movilidad solidaria. Si no hay resultados, invita a publicar. | En simulador |
| F-53 | Publicar un pedido | Se hace con el motor de pedidos (F-21), eligiendo modalidad. | En simulador |
| F-54 | Publicar una oferta | Modalidad y texto; sale en el muro con la zona aproximada. | En simulador |
| F-55 | «Lo quiero» | Desde una oferta se prepara un pedido ya redactado. | En simulador |
| F-56 | Ayudar a un pedido | Ofrecer, el vecino acepta, se ve su dirección exacta y el código, se valida, se marca hecho y el vecino califica. Al cierre se abre el balance (F-67). | En simulador |
| F-57 | Ayuda mutua en habilidades | Cualquier habilidad se puede ofrecer, incluida la Lengua de Señas Peruana; ayudar con ella suma al nivel solidario. | En simulador (como oferta) |
| F-58 | Chat | Conversación por pedido, con frases rápidas y pictogramas («¿Puedes repetir?», «Ya llegué», «Necesito ayuda», «Todo bien»). La dirección exacta no se comparte por el chat. | En simulador (respuestas automáticas) |
| F-59 | Chat sin internet | Los mensajes quedan «pendiente de envío» y salen al volver la conexión. | En simulador |
| F-510 | Lista de mensajes | Conversaciones que se abren solas cuando se acepta una propuesta o te aceptan. | En simulador |
| F-511 | Chat de emergencia | Chat entre quien pide ayuda y quien acepta; desde ahí se decide compartir la ubicación exacta. | En simulador |
| F-512 | Mensajes reales entre personas | Chat con servidor y notificaciones. Hoy las respuestas son simuladas. | Pendiente |
| F-513 | Reportar un mensaje o una conversación | Denuncia desde el chat. | Pendiente |

### 18.6 Reputación, nivel solidario, puntos, beneficios y constancia

Son **dos escalas separadas**: la reputación de servicio (estrellas, contextual) y el nivel solidario (solo un nombre público).

| ID | Función | Qué hace y reglas | Estado |
| --- | --- | --- | --- |
| F-61 | Reputación contextual | Nota en servicios y nota entre vecinos, cada una con su cantidad de interacciones. Solo cuentan interacciones confirmadas. | En simulador |
| F-62 | Niveles con nombre | Vecino nuevo, activo, colaborador y solidario. Umbrales propuestos: 3, 10 y 25 ayudas; para Solidario, además 8 personas distintas y promedio de 4,5 o más. | En simulador |
| F-63 | Puntos | Ayuda corta 1, ayuda larga 3, ayuda en emergencia 5, más 1 de bono por ayudar a una persona nueva. Solo cuentan ayudas confirmadas con código y calificadas con 4 o 5 estrellas. Los puntos nunca bajan. | En simulador |
| F-64 | Anti-trampa | La segunda ayuda a la misma persona vale la mitad y de la tercera en adelante, cero; tope diario de puntos (6 en la demo); sin código y calificación no hay puntos. | En simulador |
| F-65 | Visibilidad de productos y servicios | El nivel es un factor más en el orden recomendado, con **tope**, **etiqueta clara** y peso **ajustable**. Quien llega nuevo tiene exposición neutra; el comprador puede ordenar por cercanía o precio. A probar con usuarios reales. | En simulador |
| F-66 | Desbloqueos por nivel | Funcionales: etiqueta de prioridad solidaria (Colaborador), confirmar reportes con más peso, crear puntos de acopio y rol de brigadista (Solidario), constancia (Solidario). Solo escritos: estado «disponible ahora», ofertas destacadas y convocatoria prioritaria a brigadas. Nunca se bloquea nada básico ni de seguridad. | Parcial |
| F-67 | Balance al cerrar una ayuda | Para quien ayudó, en privado: a quién, tiempo, calificación, puntos con la razón, subida de nivel, ayudas dadas y recibidas y personas distintas. Una ayuda con menos de 4 estrellas se agradece sin exponer a nadie. | En simulador |
| F-68 | Constancia de ayuda vecinal | La emite la app con código y QR de verificación; nivel Solidario. Se puede mostrar nombre completo o solo código. Texto: verificada por la plataforma, no es documento oficial. | En simulador (QR ilustrativo) |
| F-69 | Puntos y puesto privados | Solo la propia persona ve sus puntos y su puesto en la zona. Quien no ayuda no ve ni se le muestra que está abajo. | En simulador (cifras de ejemplo) |
| F-610 | Insignia pública | Desde Vecino activo se ve el nombre del nivel; antes no hay insignia. | En simulador |
| F-611 | Parámetros ajustables | Umbrales, puntos, tope diario y peso de visibilidad en un solo archivo de configuración. En el simulador se ajustan el peso y el tope desde la guía. | Parcial |
| F-612 | Rol de brigadista | Se activa en Emergencia desde Vecino solidario. Requisito exacto (declarar capacidades o tener al menos una ayuda) es decisión abierta. | Parcial |
| F-613 | Balance mensual | Resumen mensual de ayudas, tiempo y puntos. | Pendiente |
| F-614 | Juntas vecinales y aliados | Aliadas opcionales y co-firmantes de constancias; nunca filtro de acceso. Piloto en un barrio. | Visión |

### 18.7 Emergencias: situaciones, muro, ubicación, recursos y donativos

| ID | Función | Qué hace y reglas | Estado |
| --- | --- | --- | --- |
| F-71 | Preparación | Antes de una emergencia: capacidades, rol de brigadista, servicios oficiales, grupos de apoyo y recursos del barrio. | En simulador |
| F-72 | Modo emergencia | La red cambia de reglas; la app pasa a rojo. En el prototipo se activa con un botón «Simular una emergencia». | En simulador |
| F-73 | Estado | Estoy bien, Necesito ayuda o Puedo ayudar. | En simulador |
| F-74 | Nueve situaciones | Incendio, emergencia médica, sismo o desastre, inundación o huaico, robo o asalto, persona mayor o sola, violencia o acoso, fallecimiento y persona desaparecida. | En simulador |
| F-75 | Institución primero | Al elegir la situación se muestra a quién llamar (Bomberos 116, SAMU 106, Defensa Civil 115, Policía 105, Línea 100) y se pregunta si ya llamó. **Los números están por verificar.** | En simulador |
| F-76 | Reporte con porqué y necesidades | Título según la situación, qué pasó en texto libre y necesidades elegibles; se publica en el muro de emergencia. | En simulador |
| F-77 | Casos sensibles | Violencia o acoso y fallecimiento no aparecen en el muro: se avisan en privado a contactos de confianza y brigadistas verificados. | En simulador |
| F-78 | Ubicación controlada | En público solo zona aproximada; nunca nombre ni dirección exacta. Quien acepta ayudar habla por chat y quien pide ayuda decide si comparte la ubicación exacta con **esa** persona mientras dure la ayuda. | En simulador |
| F-79 | Muro de emergencia | Avisos con título, porqué, necesidades, distancia aproximada, contacto oficial y cantidad de vecinos que confirmaron. Filtro por tipo de situación. | En simulador |
| F-710 | Confirmar un reporte | Otros vecinos confirman que es real; el voto de un Vecino solidario pesa más. Se pierde el peso si se abusa. | En simulador |
| F-711 | Ofrecer ayuda a una emergencia | Se ve la dirección exacta solo tras aceptar, se valida el código y se marca hecho; suma más puntos que una ayuda normal. | En simulador |
| F-712 | Recursos y donativos | Necesidades de recursos con barra de avance (agua, frazadas, alimentos), donativos sin dinero que se entregan en un punto de acopio y se confirman. | En simulador |
| F-713 | Puntos de acopio | Lista con zona aproximada y qué recibe cada uno. Crearlos requiere nivel Vecino solidario; quién más puede es decisión abierta. | En simulador |
| F-714 | Mapa esquemático | Tu posición, necesidades, recursos y grupos de apoyo en anillos de distancia. | En simulador (mapa ficticio) |
| F-715 | Grupos de apoyo | Brigada vecinal, serenazgo, centro de salud, bomberos y punto de apoyo con contacto guardado. | En simulador |
| F-716 | Reporte sin internet | Se guarda como pendiente y se envía al volver; mientras tanto, se recuerda llamar a la institución. | En simulador |
| F-717 | Contacto de confianza | Una persona designada que también ve tu ubicación exacta y recibe avisos privados. | Pendiente (decisión abierta) |
| F-718 | Contacto por texto con instituciones | Vía de texto o WhatsApp con policía, SAMU o bomberos para personas sordas o que no pueden hablar; por verificar que exista. | Visión |
| F-719 | Aviso automático a vecinos cercanos | Notificación push a vecinos y brigadistas en la zona al publicarse un reporte. Hoy solo se ve en el muro. | Pendiente |

### 18.8 Plataforma: offline, ubicación, notificaciones, seguridad, moderación y administración

| ID | Función | Qué hace y reglas | Estado |
| --- | --- | --- | --- |
| F-81 | Funcionamiento sin internet | Abrir la app, ver lo último guardado, crear solicitudes, reportes y mensajes como pendientes y sincronizarlos al volver. No se confirma ni califica sin red. **No se promete comunicación entre celulares sin red.** | Parcial: simulado con un botón; sin guardado real |
| F-82 | Geolocalización real | Ubicación del dispositivo con permiso explícito y HTTPS; distancias y mapa reales; siempre aproximada en público. | Pendiente (el simulador usa datos ficticios) |
| F-83 | Cuentas y base de datos compartida | Todos los vecinos ven los mismos pedidos y ofertas; los datos no se pierden al recargar. | Pendiente |
| F-84 | Notificaciones | Propuesta recibida, aceptaron la tuya, mensaje nuevo, aviso de emergencia, calificación disponible; con vibración y alerta visual. | Parcial: avisos dentro de la app |
| F-85 | Privacidad de datos | Nunca mostrar dirección exacta ni nombre de víctimas en público; quitar metadatos de las fotos; cumplimiento, estado de cuenta, puntos y puesto privados; cumplir la Ley 29733. | Parcial: reglas aplicadas en pantalla, sin datos reales |
| F-86 | Reportes y apelaciones | Denunciar usuarios, publicaciones y mensajes, con consecuencias graduales y derecho a apelar. | Pendiente |
| F-87 | Moderación de contenido | Revisión de fotos, videos y textos; detección de reportes falsos de emergencia. | Visión |
| F-88 | Panel de administración | Vista para el equipo: usuarios, reportes, parámetros (umbrales, puntos, peso de visibilidad), métricas como necesidades resueltas. | Visión |
| F-89 | Métricas | Necesidades resueltas (métrica principal), clics por publicación y conexión. El simulador las muestra en la guía. | Parcial |
| F-810 | Seguimiento en vivo y tiempo de llegada | Solo servicios del mismo día; la ubicación se comparte solo con quien se aceptó y mientras está en camino. Otro día: fecha y hora acordadas. | Visión |
| F-811 | Identidad oficial | Validación con RENIEC, con consentimiento. | Visión |
| F-812 | Pagos | Pagos dentro de la app. | Visión |
| F-813 | Guía de demo (solo para el prototipo) | 10 casos paso a paso, control de parámetros y atajos de nivel con ayudas ficticias. No existe en la versión real. | En simulador |

**Conteo (referencia):** de las funciones de las secciones 18.1 a 18.8, la mayoría está «En simulador»; lo «Pendiente» se concentra en cuentas reales, datos compartidos, ubicación real, reportes, compra del lado del comprador y contacto de confianza; lo «Visión» es la hoja de ruta de la sección 16.
