-- Servicios de ejemplo de los vecinos de demostración (oficios que atienden urgencias).
-- Se aplica en cada apertura con INSERT OR IGNORE: llega también a bases que ya estaban sembradas,
-- y no pisa lo que el vecino haya cambiado después. Solo se inserta si el vecino existe.

INSERT OR IGNORE INTO service_offers (id, provider_id, trade, description, urgent, available_now, schedule, active, created_at, updated_at)
SELECT 'o_miguel_gas', 'u_miguel', 'Gasfitería', 'Fugas, cañerías y termas. Llevo herramientas y repuestos básicos.', 1, 1, 'Hasta las 10 p. m.', 1,
       '2026-10-25T12:00:00.000Z', '2026-10-25T12:00:00.000Z'
 WHERE EXISTS (SELECT 1 FROM users WHERE id = 'u_miguel');

INSERT OR IGNORE INTO service_offers (id, provider_id, trade, description, urgent, available_now, schedule, active, created_at, updated_at)
SELECT 'o_miguel_elec', 'u_miguel', 'Electricidad', 'Cortocircuitos, tomacorrientes y tableros. Reviso la instalación antes de dejarla.', 1, 0, '7 a. m. – 9 p. m.', 1,
       '2026-10-25T12:00:00.000Z', '2026-10-25T12:00:00.000Z'
 WHERE EXISTS (SELECT 1 FROM users WHERE id = 'u_miguel');

INSERT OR IGNORE INTO service_offers (id, provider_id, trade, description, urgent, available_now, schedule, active, created_at, updated_at)
SELECT 'o_rosa_enf', 'u_rosa', 'Enfermería', 'Primeros auxilios, curaciones, inyectables y botiquín a domicilio.', 1, 1, '24 horas', 1,
       '2026-10-25T12:00:00.000Z', '2026-10-25T12:00:00.000Z'
 WHERE EXISTS (SELECT 1 FROM users WHERE id = 'u_rosa');

INSERT OR IGNORE INTO service_offers (id, provider_id, trade, description, urgent, available_now, schedule, active, created_at, updated_at)
SELECT 'o_julio_trans', 'u_julio', 'Transporte', 'Camioneta para trasladar personas, enseres o una mudanza de emergencia.', 1, 0, 'Desde las 6 a. m.', 1,
       '2026-10-25T12:00:00.000Z', '2026-10-25T12:00:00.000Z'
 WHERE EXISTS (SELECT 1 FROM users WHERE id = 'u_julio');

INSERT OR IGNORE INTO service_offers (id, provider_id, trade, description, urgent, available_now, schedule, active, created_at, updated_at)
SELECT 'o_ana_cerr', 'u_ana', 'Cerrajería', 'Apertura de puertas, cambio de chapas y copias de llaves.', 1, 1, '24 horas', 1,
       '2026-10-25T12:00:00.000Z', '2026-10-25T12:00:00.000Z'
 WHERE EXISTS (SELECT 1 FROM users WHERE id = 'u_ana');

-- Oficios del día a día (no urgentes): alimentan el directorio de Vecinos.
INSERT OR IGNORE INTO service_offers (id, provider_id, trade, description, urgent, available_now, schedule, active, created_at, updated_at)
SELECT 'o_ana_costura', 'u_ana', 'Costura y arreglos', 'Bastas, cierres, ajustes y arreglos de ropa. Entrego en 2 días.', 0, 0, 'Lun a sáb, 9 a. m. – 6 p. m.', 1,
       '2026-10-26T12:00:00.000Z', '2026-10-26T12:00:00.000Z'
 WHERE EXISTS (SELECT 1 FROM users WHERE id = 'u_ana');

INSERT OR IGNORE INTO service_offers (id, provider_id, trade, description, urgent, available_now, schedule, active, created_at, updated_at)
SELECT 'o_julio_mascotas', 'u_julio', 'Paseo de mascotas', 'Paseo diario de perros en el parque, de uno o dos a la vez.', 0, 1, '6–8 a. m. y 5–7 p. m.', 1,
       '2026-10-26T12:00:00.000Z', '2026-10-26T12:00:00.000Z'
 WHERE EXISTS (SELECT 1 FROM users WHERE id = 'u_julio');

INSERT OR IGNORE INTO service_offers (id, provider_id, trade, description, urgent, available_now, schedule, active, created_at, updated_at)
SELECT 'o_rosa_clases', 'u_rosa', 'Clases y refuerzo escolar', 'Refuerzo de matemática y comunicación, primaria y secundaria.', 0, 0, 'Tardes, previa cita', 1,
       '2026-10-26T12:00:00.000Z', '2026-10-26T12:00:00.000Z'
 WHERE EXISTS (SELECT 1 FROM users WHERE id = 'u_rosa');
