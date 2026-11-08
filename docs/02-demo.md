# Guion de demo — 3 minutos + escenario sin conexión

**Principio rector:** una sola historia, recorrida de punta a punta. *“Necesito un gasfitero de confianza hoy.”* La emergencia y lo solidario aparecen **como la misma red**, no como más funciones.
**Etiquetas:** lo que el guion dice que es **real hoy** (PWA) / **objetivo** (app Flutter con servidor). Las pantallas con nombre siguen la app actual; en Flutter conservarán el nombre salvo que `01-analisis.md` §f/§g pida cambiarlo.

## Antes de subir al escenario (checklist)

- [ ] App instalada, ubicación **ya concedida** (Perfil → “Usar mi ubicación” hecho antes).
- [ ] Datos limpios: Perfil → “Borrar mis datos de este dispositivo”, luego abrir y cerrar el tutorial.
- [ ] Modo avión **probado** una vez con la app abierta; wifi del lugar **no** necesaria (usar datos móviles de respaldo).
- [ ] Brillo alto, “No molestar”, notificaciones apagadas, batería > 50 %.
- [ ] Video de respaldo (R5) y capturas de cada paso en el teléfono.
- [ ] Números de emergencia: **no marcar** (no verificados).
- [ ] Una persona ajena al equipo debe haber probado el recorrido (R15).

## Guion principal (≈ 2 min 30)

| Tiempo | Pantalla | Qué haces (toques) | Qué dices |
|---|---|---|---|
| 0:00-0:15 | Inicio | Mostrar “Red del barrio” y la zona aproximada | “Cuando se rompe una tubería, lo difícil no es encontrar a alguien: es saber **en quién confiar** y que **alguien cercano responda**.” |
| 0:15-0:35 | Inicio → Explorar cerca | Mostrar la tarjeta de un gasfitero: **Visto Bueno**, distancia, disponibilidad | “Los oficios del barrio con recomendaciones de vecinos. *Estos vecinos son de ejemplo*; la distancia sale de mi ubicación.” |
| 0:35-0:50 | Explorar cerca | **Toque 1:** “Pedir este servicio” → **toque 2:** “Publicar” | “Dos toques. Ya lo publiqué.” (mostrar el contador de toques) |
| 0:50-1:15 | Detalle de la necesidad | Mostrar 3 propuestas con precio, distancia, reputación; ordenar por precio y por cercanía; abrir un perfil 3 s | “Aquí **el proveedor pone su precio** al ver el problema. Yo elijo.” |
| 1:15-1:35 | Detalle | **Aceptar** una propuesta → aparece el **código de 4 dígitos** | “El código confirma que **nos encontramos de verdad**. Sin código, esa ayuda no cuenta.” |
| 1:35-1:50 | Detalle | (Objetivo con servidor: el proveedor ingresa el código en su teléfono) → cronómetro corre | “El precio solo cambia si **yo** acepto.” (no abrir el ajuste de precio salvo que sobre tiempo) |
| 1:50-2:15 | Detalle | “Servicio hecho” → estrellas → Enviar | “Los dos nos calificamos. **Ahí nace la confianza**, sin puntos públicos ni rankings.” |
| 2:15-2:30 | Resultado | Mostrar “antes → después” de la reputación del proveedor y “Necesidades resueltas: 1” | “Cada necesidad resuelta deja al barrio mejor preparado para la siguiente.” |

## Escenario sin conexión (≈ 30 s)

| Tiempo | Qué haces | Qué dices | Resultado esperado |
|---|---|---|---|
| 2:30-2:40 | Activar **modo avión** (sistema, no el botón de la app) | “Sin internet.” | La app muestra el aviso “Sin internet. Ves lo último guardado…” |
| 2:40-2:50 | Publicar una necesidad (atajo) | “Se guarda en mi teléfono.” | Estado **Pendiente** visible (“Guardada en tu teléfono, se enviará cuando haya internet”) |
| 2:50-3:00 | Quitar modo avión | “Al volver la señal…” | **Objetivo con servidor:** pasa a *Enviada* o muestra *Error · Reintentar*. **PWA hoy:** pasa a “Abierta” por una simulación → **decir** que en la versión actual la sincronización es de demostración |

> **No simular nunca que llegó al servidor si sigue pendiente** (regla del reto): si no hay servidor, la etiqueta correcta es “Enviada · barrio de ejemplo (demo)”.

## Cierre (10-15 s, si sobra tiempo)

“Esta misma red, en un sismo, se convierte en el tablero de ayuda: **primero las instituciones oficiales**, después los vecinos que tienen herramientas, botiquín o una camioneta. Hoy mostramos el ciclo cotidiano real; la parte de emergencia es una simulación con datos de ejemplo.”

## Corte de emergencia opcional (30-40 s, solo si hay holgura)

| Pantalla | Qué haces | Qué dices |
|---|---|---|
| Emergencia (barrio preparado) | Mostrar capacidades y la lista de oficios que pueden ayudar | “Esto se prepara **antes**: yo declaro que tengo primeros auxilios.” |
| Emergencia activa (simulación) | Mostrar que **las instituciones oficiales van primero** y el aviso de simulación | “No sustituimos a los servicios oficiales.” |
| *(No abrir SOS ni violencia salvo que pregunten)* | — | — |

## Qué NO tocar (y cómo decirlo)

| No tocar | Por qué | Cómo decirlo sin restarle fuerza |
|---|---|---|
| Botones **“Simular…”**, **“Demo: avanzar 45 min”**, **“Código de demo”** | Son andamios de la maqueta | Si alguien pregunta: “Es el modo de ensayo para la demostración; con dos teléfonos, la otra persona hace ese paso.” |
| Interruptor **Online/Offline** de la barra | Persistente y ambiguo | Usar el modo avión real |
| **Violencia / acoso** y **SOS** | Respuestas simuladas; riesgo ético | “Lo dejamos desactivado en la demo; no queremos simular una respuesta ante una persona en peligro.” |
| **Verificación de identidad** | Simulada (DNI) | “RENIEC es de una fase posterior.” |
| **Idiomas (quechua)** | Sin revisión nativa | “El quechua es un ejemplo; lo revisará un hablante nativo.” |
| **Vender / contraoferta / constancia / niveles** | Código muerto o contradice reglas | No mostrar |
| **Mapa de emergencia** | Esquemático, no geolocalizado | “Es una vista de apoyo; la ubicación real vendrá del servidor.” |
| **Chat con frases rápidas** | Respuestas guionadas | Solo si preguntan: “Las respuestas de ejemplo se reemplazan por la persona real.” |

## Frases de honestidad (1 sola vez, al principio o al final)

- Real hoy: **ubicación, funcionamiento sin internet, guardado en el teléfono, instalación**.
- De ejemplo: **vecinos, precios, respuestas, verificación de identidad, números de emergencia**.
- “No es un resultado medido: es una **hipótesis** que queremos validar con un barrio piloto.”

## Plan B de la demo

1. Falla la red del lugar → seguir con datos móviles; si la app no abre, mostrar el **video de respaldo** (R5).
2. Falla el GPS → “Usar mi ubicación” → si no responde, seguir con la zona ya guardada (R11).
3. Falla la app Flutter → abrir el **PWA publicado** (`main` es el respaldo definitivo).
4. Falla todo → capturas de pantalla ordenadas por el guion.

## Ensayo recomendado

- Cronometrar 3 veces; recortar el cierre si pasa de 3:00.
- Ensayar con **datos móviles** y con **modo avión** real.
- Que una persona ajena al equipo haga la parte de “publicar” sin ayuda (valida el requisito de 3 clics y el lenguaje claro).
