-- Ejemplos para el muro "Sin dinero" y para "Recursos críticos" (vecinos de demostración).
-- Se aplica en cada apertura con INSERT OR IGNORE: llega también a bases ya sembradas y no pisa cambios.
-- Solo se inserta si el vecino existe. Las fechas son relativas a la primera vez que se aplica.

-- Cadena de favores (sin dinero) ------------------------------------------------------------------
INSERT OR IGNORE INTO needs (id, author_id, type, title, description, category, zone, lat_public, lng_public, lat_exact, lng_exact, status, is_emergency, created_at)
SELECT 'n_s_escalera', 'u_ana', 'prestamo', 'Ofrezco: Escalera de 3 metros',
       'La presto por el día para pintar o arreglar un techo. Se recoge en mi casa y se devuelve limpia.',
       'Préstamo de herramientas', 'San Martín de Porres, Lima', -11.9800, -77.0800, -11.9801, -77.0801, 'abierta', 0,
       strftime('%Y-%m-%dT%H:%M:%fZ','now','-3 hours')
 WHERE EXISTS (SELECT 1 FROM users WHERE id = 'u_ana');

INSERT OR IGNORE INTO needs (id, author_id, type, title, description, category, zone, lat_public, lng_public, lat_exact, lng_exact, status, is_emergency, created_at)
SELECT 'n_s_ropa', 'u_rosa', 'producto', 'Ofrezco: Ropa de abrigo para niños',
       'Tengo casacas y buzos en buen estado para donar a familias con niños pequeños.',
       'Donación de materiales', 'Los Olivos, Lima', -11.9930, -77.0680, -11.9931, -77.0679, 'abierta', 0,
       strftime('%Y-%m-%dT%H:%M:%fZ','now','-5 hours')
 WHERE EXISTS (SELECT 1 FROM users WHERE id = 'u_rosa');

INSERT OR IGNORE INTO needs (id, author_id, type, title, description, category, zone, lat_public, lng_public, lat_exact, lng_exact, status, is_emergency, created_at)
SELECT 'n_s_ingles', 'u_miguel', 'servicio', 'Necesito: Clases de inglés para mi hija',
       'A cambio reparo electrodomésticos pequeños (licuadora, plancha, cargadores). Es un intercambio, sin dinero.',
       'Intercambio de habilidades', 'Los Olivos, Lima', -11.9860, -77.0740, -11.9862, -77.0742, 'abierta', 0,
       strftime('%Y-%m-%dT%H:%M:%fZ','now','-8 hours')
 WHERE EXISTS (SELECT 1 FROM users WHERE id = 'u_miguel');

INSERT OR IGNORE INTO needs (id, author_id, type, title, description, category, zone, lat_public, lng_public, lat_exact, lng_exact, status, is_emergency, created_at)
SELECT 'n_s_posta', 'u_julio', 'servicio', 'Necesito: Movilidad a la posta el sábado',
       'Mi mamá camina poco. Busco un vecino con auto que la lleve y la traiga a su control médico.',
       'Movilidad solidaria', 'Los Olivos, Lima', -11.9950, -77.0650, -11.9952, -77.0648, 'abierta', 0,
       strftime('%Y-%m-%dT%H:%M:%fZ','now','-10 hours')
 WHERE EXISTS (SELECT 1 FROM users WHERE id = 'u_julio');

-- Recursos críticos en emergencia (sin dinero; zona de ~1 km, como las alertas) ----------------------
INSERT OR IGNORE INTO needs (id, author_id, type, title, description, category, zone, lat_public, lng_public, lat_exact, lng_exact, status, is_emergency, created_at)
SELECT 'n_r_agua', 'u_rosa', 'producto', 'Ofrezco: Agua',
       'Tengo 2 bidones de 20 litros para repartir a familias que se quedaron sin agua.',
       'Recurso · Agua', 'Los Olivos, Lima', -11.99, -77.07, -11.9930, -77.0680, 'abierta', 1,
       strftime('%Y-%m-%dT%H:%M:%fZ','now','-1 hours')
 WHERE EXISTS (SELECT 1 FROM users WHERE id = 'u_rosa');

INSERT OR IGNORE INTO needs (id, author_id, type, title, description, category, zone, lat_public, lng_public, lat_exact, lng_exact, status, is_emergency, created_at)
SELECT 'n_r_medicinas', 'u_julio', 'producto', 'Necesito: Medicinas y botiquín',
       'Busco paracetamol, gasas y alcohol para una familia con un adulto mayor.',
       'Recurso · Medicinas y botiquín', 'Los Olivos, Lima', -12.0, -77.07, -11.9950, -77.0650, 'abierta', 1,
       strftime('%Y-%m-%dT%H:%M:%fZ','now','-30 minutes')
 WHERE EXISTS (SELECT 1 FROM users WHERE id = 'u_julio');
