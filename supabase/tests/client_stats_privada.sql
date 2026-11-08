-- Prueba de la regla 4: el promedio como cliente solo lo ve la propia persona.
-- Ejecutada en un proyecto real de Supabase el 2026-11-08 y pasó. Crea sus usuarios y termina en ROLLBACK.
begin;

insert into auth.users (id, aud, role, email) values
  ('00000000-0000-0000-0000-0000000000a1', 'authenticated', 'authenticated', 'ana@prueba.test'),
  ('00000000-0000-0000-0000-0000000000b2', 'authenticated', 'authenticated', 'raul@prueba.test'),
  ('00000000-0000-0000-0000-0000000000c3', 'authenticated', 'authenticated', 'carla@prueba.test');

set local role authenticated;

-- Ana pide, Raúl propone, Ana acepta, Raúl valida el código, Ana marca hecho
select set_config('request.jwt.claims', json_build_object('sub', '00000000-0000-0000-0000-0000000000a1', 'role', 'authenticated')::text, true);
insert into needs (id, kind, body, urgency) values ('11111111-1111-1111-1111-111111111111', 'service', 'Necesito un gasfitero', 'today');
select set_config('request.jwt.claims', json_build_object('sub', '00000000-0000-0000-0000-0000000000b2', 'role', 'authenticated')::text, true);
insert into proposals (id, need_id, price_soles) values ('22222222-2222-2222-2222-222222222221', '11111111-1111-1111-1111-111111111111', 40);
select set_config('request.jwt.claims', json_build_object('sub', '00000000-0000-0000-0000-0000000000a1', 'role', 'authenticated')::text, true);
select accept_proposal('33333333-3333-3333-3333-333333333331', '22222222-2222-2222-2222-222222222221');
select set_config('test.codigo', (select code from deal_codes where deal_id = '33333333-3333-3333-3333-333333333331'), true);
select set_config('request.jwt.claims', json_build_object('sub', '00000000-0000-0000-0000-0000000000b2', 'role', 'authenticated')::text, true);
select validate_meeting_code('33333333-3333-3333-3333-333333333331', current_setting('test.codigo'));
select set_config('request.jwt.claims', json_build_object('sub', '00000000-0000-0000-0000-0000000000a1', 'role', 'authenticated')::text, true);
select complete_deal('33333333-3333-3333-3333-333333333331');

-- Raúl califica a Ana como CLIENTE
select set_config('request.jwt.claims', json_build_object('sub', '00000000-0000-0000-0000-0000000000b2', 'role', 'authenticated')::text, true);
select rate_participant('55555555-5555-5555-5555-555555555552', '33333333-3333-3333-3333-333333333331', 4, 'Buen trato', false);

-- Ana ve SU promedio como cliente
select set_config('request.jwt.claims', json_build_object('sub', '00000000-0000-0000-0000-0000000000a1', 'role', 'authenticated')::text, true);
do $$ begin
  assert (select count(*) from client_stats) = 1, 'Ana debe ver su propio promedio como cliente';
end $$;

-- Raúl y Carla NO ven el promedio de Ana
select set_config('request.jwt.claims', json_build_object('sub', '00000000-0000-0000-0000-0000000000b2', 'role', 'authenticated')::text, true);
do $$ begin
  assert (select count(*) from client_stats) = 0, 'Raúl no debe ver el promedio de Ana';
end $$;
select set_config('request.jwt.claims', json_build_object('sub', '00000000-0000-0000-0000-0000000000c3', 'role', 'authenticated')::text, true);
do $$ begin
  assert (select count(*) from client_stats) = 0, 'Carla no debe ver el promedio de Ana';
end $$;

rollback;
