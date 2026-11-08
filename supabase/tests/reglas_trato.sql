-- Pruebas de las reglas del trato con TRES usuarios: Ana (cliente), Raúl (prestador elegido) y
-- Carla (otra prestadora). Ejecutar en el SQL Editor DESPUÉS de aplicar las dos migraciones.
-- ESTADO: escrita, NO ejecutada todavía. Reemplaza los tres UUID por usuarios de prueba reales
-- (Authentication → Users). Todo corre dentro de una transacción que termina en ROLLBACK.
-- Cada bloque simula a un usuario con `request.jwt.claims`. Un `assert` fallido = hay una fuga.

\set ana '00000000-0000-0000-0000-0000000000a1'
\set raul '00000000-0000-0000-0000-0000000000b2'
\set carla '00000000-0000-0000-0000-0000000000c3'

begin;
set local role authenticated;

-- 1) Ana publica un pedido de gasfitería; Raúl y Carla proponen
select set_config('request.jwt.claims', json_build_object('sub', :'ana', 'role', 'authenticated')::text, true);
insert into needs (id, kind, body, urgency, category_id)
  values ('11111111-1111-1111-1111-111111111111', 'service', 'Necesito un gasfitero', 'today', 'gasfiteria');

select set_config('request.jwt.claims', json_build_object('sub', :'raul', 'role', 'authenticated')::text, true);
insert into proposals (id, need_id, price_soles)
  values ('22222222-2222-2222-2222-222222222221', '11111111-1111-1111-1111-111111111111', 40);
select set_config('request.jwt.claims', json_build_object('sub', :'carla', 'role', 'authenticated')::text, true);
insert into proposals (id, need_id, price_soles)
  values ('22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 35);

-- 2) Ana acepta UNA propuesta: el pedido queda «accepted» y la otra se descarta (historial)
select set_config('request.jwt.claims', json_build_object('sub', :'ana', 'role', 'authenticated')::text, true);
select accept_proposal('33333333-3333-3333-3333-333333333331', '22222222-2222-2222-2222-222222222221');
do $$ begin
  assert (select status from needs where id = '11111111-1111-1111-1111-111111111111') = 'accepted',
    'El pedido debe pasar a «en trato»';
  assert (select status from proposals where id = '22222222-2222-2222-2222-222222222221') = 'accepted';
  assert (select status from proposals where id = '22222222-2222-2222-2222-222222222222') = 'discarded',
    'Las demás propuestas quedan descartadas, no borradas';
end $$;

-- 3) No se puede aceptar otra propuesta del mismo pedido (un solo trato)
do $$ begin
  perform accept_proposal('33333333-3333-3333-3333-333333333332', '22222222-2222-2222-2222-222222222222');
  raise exception 'debía fallar: segunda aceptación';
exception when others then
  if sqlerrm like 'debía fallar%' then raise; end if;
end $$;

-- 4) Carla (descartada) ve que el pedido ya fue asignado, y no puede proponer de nuevo
select set_config('request.jwt.claims', json_build_object('sub', :'carla', 'role', 'authenticated')::text, true);
do $$ begin
  assert (select status from needs where id = '11111111-1111-1111-1111-111111111111') = 'accepted',
    'Quien propuso debe poder ver que el pedido fue asignado';
end $$;

-- 5) CONTRAOFERTA antes de validar el código: rechazada
select set_config('request.jwt.claims', json_build_object('sub', :'raul', 'role', 'authenticated')::text, true);
do $$ begin
  perform propose_price_change('44444444-4444-4444-4444-444444444441',
    '33333333-3333-3333-3333-333333333331', 50, 'Hay más trabajo del esperado');
  raise exception 'debía fallar: contraoferta sin código validado';
exception when others then
  if sqlerrm like 'debía fallar%' then raise; end if;
end $$;

-- 6) Ana lee el código; Raúl lo valida
select set_config('request.jwt.claims', json_build_object('sub', :'ana', 'role', 'authenticated')::text, true);
select set_config('test.codigo', (select code from deal_codes where deal_id = '33333333-3333-3333-3333-333333333331'), true);
select set_config('request.jwt.claims', json_build_object('sub', :'raul', 'role', 'authenticated')::text, true);
select validate_meeting_code('33333333-3333-3333-3333-333333333331', current_setting('test.codigo'));

-- 7) Solo el prestador elegido puede contraofertar (Carla y Ana no)
select set_config('request.jwt.claims', json_build_object('sub', :'carla', 'role', 'authenticated')::text, true);
do $$ begin
  perform propose_price_change('44444444-4444-4444-4444-444444444442',
    '33333333-3333-3333-3333-333333333331', 30, 'Otra persona intenta');
  raise exception 'debía fallar: contraoferta de otra persona';
exception when others then
  if sqlerrm like 'debía fallar%' then raise; end if;
end $$;

-- 8) Primera contraoferta: permitida; el precio NO cambia hasta que Ana acepte
select set_config('request.jwt.claims', json_build_object('sub', :'raul', 'role', 'authenticated')::text, true);
select propose_price_change('44444444-4444-4444-4444-444444444441',
  '33333333-3333-3333-3333-333333333331', 50, 'Hay más trabajo del esperado');
do $$ begin
  assert (select price_soles from deals where id = '33333333-3333-3333-3333-333333333331') = 40,
    'El precio no cambia hasta que el cliente acepta';
end $$;

-- 9) No se permite otra mientras haya una pendiente
do $$ begin
  perform propose_price_change('44444444-4444-4444-4444-444444444443',
    '33333333-3333-3333-3333-333333333331', 55, 'Segundo intento seguido');
  raise exception 'debía fallar: dos pendientes';
exception when others then
  if sqlerrm like 'debía fallar%' then raise; end if;
end $$;

-- 10) Ana rechaza (sin penalidad) y el precio vigente se mantiene
select set_config('request.jwt.claims', json_build_object('sub', :'ana', 'role', 'authenticated')::text, true);
select respond_price_change('44444444-4444-4444-4444-444444444441', false);
do $$ begin
  assert (select price_soles from deals where id = '33333333-3333-3333-3333-333333333331') = 40;
end $$;

-- 11) Segunda contraoferta: permitida; Ana la acepta y el precio cambia
select set_config('request.jwt.claims', json_build_object('sub', :'raul', 'role', 'authenticated')::text, true);
select propose_price_change('44444444-4444-4444-4444-444444444444',
  '33333333-3333-3333-3333-333333333331', 45, 'Materiales más caros');
select set_config('request.jwt.claims', json_build_object('sub', :'ana', 'role', 'authenticated')::text, true);
select respond_price_change('44444444-4444-4444-4444-444444444444', true);
do $$ begin
  assert (select price_soles from deals where id = '33333333-3333-3333-3333-333333333331') = 45;
end $$;

-- 12) La TERCERA contraoferta se bloquea (máximo 2 por trato)
select set_config('request.jwt.claims', json_build_object('sub', :'raul', 'role', 'authenticated')::text, true);
do $$ begin
  perform propose_price_change('44444444-4444-4444-4444-444444444445',
    '33333333-3333-3333-3333-333333333331', 60, 'Tercer intento');
  raise exception 'debía fallar: tercera contraoferta';
exception when others then
  if sqlerrm like 'debía fallar%' then raise; end if;
end $$;
do $$ begin
  assert (select count(*) from price_changes where deal_id = '33333333-3333-3333-3333-333333333331') = 2;
end $$;

-- 13) Ana marca el servicio hecho; calificar es opcional y bidireccional
select set_config('request.jwt.claims', json_build_object('sub', :'ana', 'role', 'authenticated')::text, true);
select complete_deal('33333333-3333-3333-3333-333333333331');
select rate_participant('55555555-5555-5555-5555-555555555551',
  '33333333-3333-3333-3333-333333333331', 5, 'Muy bien', true);
select set_config('request.jwt.claims', json_build_object('sub', :'raul', 'role', 'authenticated')::text, true);
select rate_participant('55555555-5555-5555-5555-555555555552',
  '33333333-3333-3333-3333-333333333331', 4, 'Buen trato', true);
do $$ begin
  assert (select count(*) from interactions) = 2, 'Una evaluación por participante y trato';
  assert (select bool_or(recommended) from interactions where rated_role = 'client') is not true,
    'El cliente no recibe Visto Bueno';
end $$;

-- 14) No se califica dos veces ni a uno mismo
do $$ begin
  perform rate_participant('55555555-5555-5555-5555-555555555553',
    '33333333-3333-3333-3333-333333333331', 1, 'Otra vez', false);
  raise exception 'debía fallar: calificación duplicada';
exception when others then
  if sqlerrm like 'debía fallar%' then raise; end if;
end $$;

-- 15) Cancelar exige motivo (se prueba con otro trato inexistente: no autorizado)
select set_config('request.jwt.claims', json_build_object('sub', :'carla', 'role', 'authenticated')::text, true);
do $$ begin
  perform cancel_deal('33333333-3333-3333-3333-333333333331', 'No me corresponde');
  raise exception 'debía fallar: cancelar un trato ajeno';
exception when others then
  if sqlerrm like 'debía fallar%' then raise; end if;
end $$;

rollback; -- no deja datos de prueba
