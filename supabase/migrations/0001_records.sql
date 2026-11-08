-- ============================================================
--  Red del barrio — servidor mínimo para sincronizar teléfonos
--  Pegar completo en Supabase → SQL Editor → New query → Run.
--  Es seguro ejecutarlo más de una vez.
-- ============================================================

create table if not exists public.records (
  entity     text        not null,
  id         text        not null,
  data       jsonb       not null,
  updated_at timestamptz not null default now(),
  primary key (entity, id),
  -- Privacidad: el servidor NUNCA guarda coordenadas exactas ni el hash del código de encuentro.
  constraint records_no_exact check (not (data ?| array['lat_exact', 'lng_exact', 'meet_code_hash'])),
  constraint records_entity_ok check (entity in
    ('need', 'proposal', 'interaction', 'message', 'rating', 'recommendation', 'emergency')),
  constraint records_size_ok check (pg_column_size(data) < 20000)
);

create index if not exists records_updated_idx on public.records (updated_at);

-- updated_at lo pone el servidor (no el reloj del teléfono).
create or replace function public.records_touch() returns trigger
language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists records_touch on public.records;
create trigger records_touch before insert or update on public.records
  for each row execute function public.records_touch();

-- Seguridad a nivel de fila. Prototipo: lectura/escritura abiertas para la clave pública,
-- sin borrado. (Con cuentas reales, aquí se filtra por usuario.)
alter table public.records enable row level security;

drop policy if exists records_select on public.records;
create policy records_select on public.records for select to anon, authenticated using (true);

drop policy if exists records_insert on public.records;
create policy records_insert on public.records for insert to anon, authenticated with check (true);

drop policy if exists records_update on public.records;
create policy records_update on public.records for update to anon, authenticated
  using (true) with check (true);

grant select, insert, update on public.records to anon, authenticated;
