-- Datos de demostración. Solo se cargan si la tabla `users` está vacía.
-- Coordenadas de Los Olivos, Lima (aproximadas, no son direcciones reales).

INSERT INTO users (id, display_name, zone, lat, lng, solid_level, avatar_color, created_at) VALUES
  ('u_lucia',  'Lucía',            'Los Olivos, Lima', -11.9890, -77.0710, 'Colaborador', '#0a6b66', '2026-10-01T12:00:00.000Z'),
  ('u_rosa',   'Rosa Quispe',      'Los Olivos, Lima', -11.9930, -77.0680, 'Solidario',   '#7a4bd6', '2026-10-02T12:00:00.000Z'),
  ('u_miguel', 'Miguel Á. Torres', 'Los Olivos, Lima', -11.9860, -77.0740, 'Colaborador', '#2a5ea8', '2026-10-03T12:00:00.000Z'),
  ('u_julio',  'Don Julio Ramos',  'Los Olivos, Lima', -11.9950, -77.0650, 'Vecino',      '#b35a00', '2026-10-04T12:00:00.000Z'),
  ('u_ana',    'Ana Belén Cruz',   'San Martín de Porres, Lima', -11.9800, -77.0800, 'Colaborador', '#a3275f', '2026-10-05T12:00:00.000Z');

INSERT INTO needs (id, author_id, type, title, description, category, zone, lat_public, lng_public, lat_exact, lng_exact, status, is_emergency, created_at) VALUES
  ('n_gasfitero', 'u_rosa', 'servicio', 'Fuga de agua en el baño',
   'Se rompió el tubo debajo del lavadero. Necesito a alguien hoy si puede.',
   'Gasfitería', 'Los Olivos, Lima', -11.9930, -77.0680, -11.9931, -77.0679, 'abierta', 0,
   strftime('%Y-%m-%dT%H:%M:%fZ','now','-40 minutes')),
  ('n_taladro', 'u_miguel', 'prestamo', 'Préstamo de taladro por un día',
   'Es para colgar una repisa. Lo devuelvo el mismo día, con broca incluida.',
   'Herramientas', 'Los Olivos, Lima', -11.9860, -77.0740, -11.9862, -77.0742, 'abierta', 0,
   strftime('%Y-%m-%dT%H:%M:%fZ','now','-2 hours')),
  ('n_menu', 'u_ana', 'producto', 'Menú casero por encargo',
   'Preparo menú completo (sopa, segundo y refresco) para 4 personas. Entrego en la zona.',
   'Comida', 'San Martín de Porres, Lima', -11.9800, -77.0800, -11.9801, -77.0801, 'abierta', 0,
   strftime('%Y-%m-%dT%H:%M:%fZ','now','-4 hours')),
  ('n_hospital', 'u_julio', 'ayuda', 'Acompañar a mi mamá al hospital',
   'Tengo cita el jueves a las 8 a. m. y no puedo faltar al trabajo. Busco una vecina que la acompañe.',
   'Cuidado', 'Los Olivos, Lima', -11.9950, -77.0650, -11.9952, -77.0648, 'abierta', 0,
   strftime('%Y-%m-%dT%H:%M:%fZ','now','-6 hours')),
  ('n_tomacorriente', 'u_rosa', 'servicio', 'Instalar un tomacorriente',
   'Ya compré el tomacorriente. Es en la cocina, pared de concreto.',
   'Electricidad', 'Los Olivos, Lima', -11.9930, -77.0680, -11.9931, -77.0679, 'abierta', 0,
   strftime('%Y-%m-%dT%H:%M:%fZ','now','-1 day'));

INSERT INTO proposals (id, need_id, provider_id, price_cents, message, eta, status, created_at) VALUES
  ('p_1', 'n_gasfitero', 'u_miguel', 6000, 'Puedo pasar a las 4 p. m. Llevo tubo y sellador.', 'Hoy 4:00 p. m.', 'enviada',
   strftime('%Y-%m-%dT%H:%M:%fZ','now','-20 minutes')),
  ('p_2', 'n_tomacorriente', 'u_miguel', 4500, 'Lo instalo mañana temprano, 30 minutos de trabajo.', 'Mañana 9:00 a. m.', 'enviada',
   strftime('%Y-%m-%dT%H:%M:%fZ','now','-3 hours')),
  ('p_taladro', 'n_taladro', 'u_lucia', 0, 'Te lo presto sin costo. Solo devuélvelo el mismo día.', 'Hoy 6:00 p. m.', 'aceptada',
   strftime('%Y-%m-%dT%H:%M:%fZ','now','-1 hour'));

INSERT INTO interactions (id, need_id, proposal_id, requester_id, provider_id, room_id, meet_code_hash, meet_code_expires_at, price_cents, status, created_at) VALUES
  ('i_taladro', 'n_taladro', 'p_taladro', 'u_miguel', 'u_lucia', '!demo:i_taladro', 'demo', NULL, 0, 'acordado',
   strftime('%Y-%m-%dT%H:%M:%fZ','now','-1 hour'));

INSERT INTO messages (id, interaction_id, room_id, sender_id, body, txn_id, status, created_at) VALUES
  ('m_1', 'i_taladro', '!demo:i_taladro', 'u_miguel', 'Hola Lucía, ¿te sirve si paso a las 6 p. m.?', 'txn_seed_1', 'enviado',
   strftime('%Y-%m-%dT%H:%M:%fZ','now','-50 minutes')),
  ('m_2', 'i_taladro', '!demo:i_taladro', 'u_lucia', 'Perfecto, te espero. Es el tercer piso.', 'txn_seed_2', 'enviado',
   strftime('%Y-%m-%dT%H:%M:%fZ','now','-45 minutes')),
  ('m_3', 'i_taladro', '!demo:i_taladro', 'u_lucia', '¿Traes broca para concreto?', 'txn_seed_3', 'pendiente',
   strftime('%Y-%m-%dT%H:%M:%fZ','now','-5 minutes'));

INSERT INTO recommendations (id, provider_id, voter_id, created_at) VALUES
  ('r_1', 'u_miguel', 'u_rosa',  '2026-10-20T12:00:00.000Z'),
  ('r_2', 'u_miguel', 'u_julio', '2026-10-21T12:00:00.000Z'),
  ('r_3', 'u_miguel', 'u_ana',   '2026-10-22T12:00:00.000Z'),
  ('r_4', 'u_rosa',  'u_lucia',  '2026-10-23T12:00:00.000Z'),
  ('r_5', 'u_rosa',  'u_julio',  '2026-10-24T12:00:00.000Z');
