-- Prueba de RLS con DOS usuarios (regla inviolable 3 y 5). Ejecutar en el SQL Editor de Supabase
-- DESPUÉS de aplicar las tres migraciones.
-- ESTADO: ejecutada en un proyecto real de Supabase el 2026-11-08 y pasó (necesitó la migración 3).
-- Versión para el SQL Editor: crea los usuarios de prueba dentro de la transacción (no usa comandos de psql).
-- Cada bloque simula a un usuario con `set local role authenticated` + `request.jwt.claims`.


begin;

insert into auth.users (id, aud, role, email) values
  ('00000000-0000-0000-0000-0000000000a1', 'authenticated', 'authenticated', 'ana@prueba.test'),
  ('00000000-0000-0000-0000-0000000000b2', 'authenticated', 'authenticated', 'raul@prueba.test');

-- Ana publica un pedido y su ubicación exacta
set local role authenticated;
select set_config('request.jwt.claims', json_build_object('sub', '00000000-0000-0000-0000-0000000000a1', 'role', 'authenticated')::text, true);
insert into needs (id, kind, body, urgency, zone)
  values ('11111111-1111-1111-1111-111111111111', 'service', 'Necesito un gasfitero', 'today',
          st_setsrid(st_makepoint(-77.04281, -12.04637), 4326)::geography);
insert into need_exact_locations (need_id, location)
  values ('11111111-1111-1111-1111-111111111111', st_setsrid(st_makepoint(-77.04281, -12.04637), 4326)::geography);

-- La zona se guardó REDONDEADA (~1 km), no exacta
do $$ begin
  assert (select st_x(zone::geometry) from needs where id = '11111111-1111-1111-1111-111111111111') = -77.04,
    'La zona pública debe estar redondeada';
end $$;

-- Raúl ve el pedido abierto, pero NO la ubicación exacta (aún no es su proveedor)
select set_config('request.jwt.claims', json_build_object('sub', '00000000-0000-0000-0000-0000000000b2', 'role', 'authenticated')::text, true);
do $$ begin
  assert (select count(*) from needs where id = '11111111-1111-1111-1111-111111111111') = 1, 'Raúl ve el pedido abierto';
  assert (select count(*) from need_exact_locations) = 0, 'Raúl NO debe ver la ubicación exacta';
end $$;

-- Raúl propone, Ana acepta: ahora Raúl SÍ ve la ubicación exacta
insert into proposals (id, need_id, price_soles)
  values ('22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 35);
select set_config('request.jwt.claims', json_build_object('sub', '00000000-0000-0000-0000-0000000000a1', 'role', 'authenticated')::text, true);
select accept_proposal('33333333-3333-3333-3333-333333333333', '22222222-2222-2222-2222-222222222222');
select set_config('request.jwt.claims', json_build_object('sub', '00000000-0000-0000-0000-0000000000b2', 'role', 'authenticated')::text, true);
do $$ begin
  assert (select count(*) from need_exact_locations) = 1, 'Quien aceptó ayudar SÍ ve la ubicación exacta';
  assert (select count(*) from deal_codes) = 0, 'El proveedor NO ve el código: lo ingresa, no lo lee';
end $$;

-- Emergencia privada: Ana publica un caso de violencia; Raúl no puede leerlo
select set_config('request.jwt.claims', json_build_object('sub', '00000000-0000-0000-0000-0000000000a1', 'role', 'authenticated')::text, true);
insert into emergency_posts (id, type, why) values ('44444444-4444-4444-4444-444444444444', 'violence', 'Necesito ayuda');
select set_config('request.jwt.claims', json_build_object('sub', '00000000-0000-0000-0000-0000000000b2', 'role', 'authenticated')::text, true);
do $$ begin
  assert (select count(*) from emergency_posts where id = '44444444-4444-4444-4444-444444444444') = 0,
    'Un caso privado NUNCA lo lee otra persona';
end $$;

rollback; -- no deja datos de prueba
