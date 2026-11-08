# Registro de decisiones

Formato: **ID · decisión · por qué · alternativa descartada · estado**. Las decisiones de arquitectura (D-1…D-16) se explican en `04-arquitectura.md` §e; aquí se registran las de **paquetes** y las que necesitan tu aprobación.

## Paquetes (propuesta de cambio sobre la recomendación del contexto)

| ID | Cambio | Justificación | Estado |
|---|---|---|---|
| P-1 | **Quitar `permission_handler`** | `geolocator` expone `checkPermission/requestPermission` y cubre ubicación, que es el único permiso crítico (R22). Cámara/galería los resuelve `image_picker` | Propuesto |
| P-2 | **Añadir `uuid`** | La cola de pendientes y la idempotencia (R3) exigen UUID de cliente | Propuesto |
| P-3 | **Añadir `url_launcher`** | Necesario para `tel:` de contactos oficiales, con confirmación previa | Propuesto |
| P-4 | **`flutter_riverpod` sin `riverpod_generator`** | Evita un segundo generador de código además de Drift | Propuesto |
| P-5 | **Sin `shared_preferences`** | Los ajustes viven en una tabla Drift (`SettingsRepository`) | Propuesto |
| P-6 | **Sin `vibration`** | `HapticFeedback` del SDK cubre las alertas; solo se añade si se necesitan patrones | Propuesto |
| P-7 | **`flutter_map` + tiles en línea + radar offline** (sin `flutter_map_tile_caching` al inicio) | La precarga masiva de tiles de OSM puede contravenir su política de uso (R43, **por verificar**) | Propuesto |
| P-8 | **Quechua con delegado de localización propio** | Flutter no trae `qu` para Material (R44) | Propuesto |
| P-9 | **Matrix: `matrix` (Dart) sin E2EE en rooms de demo; plan B de chat en Supabase primero** | R4: reducir el riesgo del chat; el jurado casi no verá la diferencia | Propuesto |

## Decisiones de producto que cambian el trabajo (necesito tu respuesta)

| ID | Pregunta | Por defecto propuesto |
|---|---|---|
| Q-1 | ¿Cuántas horas quedan del hackathon? (define el corte en `01-analisis.md` §m.2) | — (la preguntaré antes de la Fase 2) |
| Q-2 | ¿Se acepta la **interpretación estricta** de “3 clics” (contar el primer toque, no contar el teclear) y rediseñar pedir/ofrecer/vender/SOS para cumplirla? | Sí |
| Q-3 | ¿Se acepta **la regla única anti-inflado** (recomendación solo tras interacción confirmada, una vez por persona)? | Sí |
| Q-4 | En mobile-ux **sin servidor**, ¿mantenemos la contraparte de demostración (`DemoCounterpart`) marcada como “Ejemplo” para que el recorrido funcione, **sin** respuestas falsas en SOS/violencia? | Sí |
| Q-5 | ¿Quién **verifica los números de emergencia** con fuentes oficiales y en qué fecha? | Equipo, antes de la demo |
| Q-6 | ¿El nivel solidario (nombre del nivel) se queda **público** o solo “Ayudó a N vecinos”? | Solo un distintivo sin conteos |
| Q-7 | ¿Dónde está el remoto de GitHub para el primer *push*? (el repo ya tiene `origin`: `JoshRivas313/Proyecto_Hackaton_Comercio_2026`) | Confirmar |
| Q-8 | ¿Existen los **scripts de prueba automática** del PWA? No están en el repositorio | Pedirlos al equipo |

## Divergencias con documentos previos del repositorio

- **R42:** la *Guía técnica de implementación.md* propone **Capacitor + Vercel**; el equipo decidió **Flutter + Supabase + Matrix**. Se conserva su **modelo de datos (§5)** y la **lógica de negocio (§6)** como insumo para Postgres en mobile-mejoras; el resto queda reemplazado.
- El *Informe técnico y funcional* (§12) describe un **nivel solidario con puntos**; el informe de estado y las reglas inviolables lo prohíben en público. Prevalece la **regla 4**.
