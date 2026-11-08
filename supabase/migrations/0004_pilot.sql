-- ============================================================
--  Red del barrio — PILOTO REAL: cuentas, privacidad y moderación
--  Pegar completo en Supabase → SQL Editor → New query → Run.
--  Es seguro ejecutarlo más de una vez. NO toca la tabla `records` de la demo.
--
--  Antes de usarlo:
--   1) Authentication → Sign In / Providers → activar "Allow anonymous sign-ins".
--   2) Fijar el código del barrio (solo lo conocen los vecinos que invites):
--        select public.pilot_set_code('TU-CODIGO');
--
--  Cómo se protege:
--   - Cada vecino entra con una cuenta anónima de Supabase (sin correo) + el código del barrio.
--   - Nadie puede LEER ni ESCRIBIR las tablas directamente: solo a través de estas funciones.
--   - Un registro tiene `owner` (quien lo escribió, lo pone el servidor) y `audience`
--     (null = todos los vecinos; si no, solo esas personas). El chat y los tratos son de dos.
--   - Nadie puede publicar a nombre de otro: el servidor revisa que el autor sea quien llama.
-- ============================================================

-- ---------- Tablas ----------

create table if not exists public.pilot_config (
  key   text primary key,
  value text not null
);

create table if not exists public.pilot_members (
  user_id      uuid primary key references auth.users (id) on delete cascade,
  display_name text        not null check (char_length(display_name) between 1 and 60),
  zone         text        not null default '' check (char_length(zone) <= 60),
  banned       boolean     not null default false,
  joined_at    timestamptz not null default now()
);

create table if not exists public.pilot_join_attempts (
  user_id uuid primary key,
  fails   integer     not null default 0,
  last_at timestamptz not null default now()
);

create table if not exists public.pilot_records (
  entity     text        not null,
  id         text        not null,
  owner      uuid        not null,
  audience   uuid[],
  data       jsonb       not null,
  updated_at timestamptz not null default now(),
  primary key (entity, id),
  constraint pilot_entity_ok check (entity in
    ('user', 'need', 'proposal', 'interaction', 'message', 'rating', 'recommendation',
     'emergency', 'emergency_response', 'service_offer')),
  -- El servidor NUNCA guarda coordenadas exactas ni el hash del código de encuentro.
  constraint pilot_no_exact check (not (data ?| array['lat_exact', 'lng_exact', 'meet_code_hash', 'meet_code_expires_at'])),
  constraint pilot_size_ok check (pg_column_size(data) < 20000)
);
create index if not exists pilot_records_updated_idx on public.pilot_records (updated_at);
create index if not exists pilot_records_owner_idx on public.pilot_records (owner);

create table if not exists public.pilot_reports (
  id         uuid        primary key default gen_random_uuid(),
  reporter   uuid        not null,
  target     uuid,
  entity     text        not null default '',
  entity_id  text        not null default '',
  reason     text        not null default '',
  created_at timestamptz not null default now()
);

-- ---------- Permisos: nada directo, todo por funciones ----------

alter table public.pilot_config        enable row level security;
alter table public.pilot_members       enable row level security;
alter table public.pilot_join_attempts enable row level security;
alter table public.pilot_records       enable row level security;
alter table public.pilot_reports       enable row level security;

revoke all on public.pilot_config, public.pilot_members, public.pilot_join_attempts,
              public.pilot_records, public.pilot_reports from anon, authenticated;
grant select on public.pilot_records to authenticated;
grant select on public.pilot_members to authenticated;

-- ---------- Funciones de apoyo ----------

create or replace function public.pilot_is_member() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from public.pilot_members m where m.user_id = auth.uid() and not m.banned
  );
$$;

-- Un vecino vetado: sus registros dejan de verse. Va en función security definer porque la tabla de
-- miembros solo deja ver la fila propia (dentro de la política no se vería quién está vetado).
create or replace function public.pilot_owner_ok(p_owner uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select not exists (select 1 from public.pilot_members b where b.user_id = p_owner and b.banned);
$$;

-- Lectura: solo vecinos activos; solo lo público (audience null) o lo suyo; nada de gente vetada.
drop policy if exists pilot_records_select on public.pilot_records;
create policy pilot_records_select on public.pilot_records for select to authenticated using (
  (select public.pilot_is_member())
  and (audience is null or auth.uid() = any (audience) or owner = auth.uid())
  and (select public.pilot_owner_ok(owner))
);

drop policy if exists pilot_members_select on public.pilot_members;
create policy pilot_members_select on public.pilot_members for select to authenticated
  using (user_id = auth.uid());

-- ---------- Administración (solo desde el SQL Editor de Supabase) ----------

create or replace function public.pilot_set_code(p_code text) returns void
language plpgsql security definer set search_path = public as $$
begin
  if char_length(trim(p_code)) < 6 then
    raise exception 'El código debe tener al menos 6 caracteres';
  end if;
  insert into public.pilot_config (key, value)
  values ('join_code_hash', encode(sha256(convert_to(lower(trim(p_code)), 'UTF8')), 'hex'))
  on conflict (key) do update set value = excluded.value;
end;
$$;
revoke all on function public.pilot_set_code(text) from public, anon, authenticated;

-- ---------- Unirse al barrio ----------

create or replace function public.pilot_join(p_code text, p_name text, p_zone text) returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  uid uuid := auth.uid();
  expected text;
  tries public.pilot_join_attempts%rowtype;
begin
  if uid is null then
    return jsonb_build_object('ok', false, 'error', 'no_auth');
  end if;
  select value into expected from public.pilot_config where key = 'join_code_hash';
  if expected is null then
    return jsonb_build_object('ok', false, 'error', 'not_configured');
  end if;
  if char_length(trim(coalesce(p_name, ''))) not between 1 and 60 then
    return jsonb_build_object('ok', false, 'error', 'bad_name');
  end if;

  select * into tries from public.pilot_join_attempts where user_id = uid;
  if found and tries.fails >= 8 and tries.last_at > now() - interval '1 hour' then
    return jsonb_build_object('ok', false, 'error', 'too_many_attempts');
  end if;

  if encode(sha256(convert_to(lower(trim(coalesce(p_code, ''))), 'UTF8')), 'hex') <> expected then
    insert into public.pilot_join_attempts (user_id, fails, last_at) values (uid, 1, now())
    on conflict (user_id) do update
      set fails = case when public.pilot_join_attempts.last_at > now() - interval '1 hour'
                       then public.pilot_join_attempts.fails + 1 else 1 end,
          last_at = now();
    return jsonb_build_object('ok', false, 'error', 'bad_code');
  end if;

  if exists (select 1 from public.pilot_members where user_id = uid and banned) then
    return jsonb_build_object('ok', false, 'error', 'banned');
  end if;
  insert into public.pilot_members (user_id, display_name, zone)
  values (uid, trim(p_name), left(trim(coalesce(p_zone, '')), 60))
  on conflict (user_id) do update
    set display_name = excluded.display_name, zone = excluded.zone;
  delete from public.pilot_join_attempts where user_id = uid;
  return jsonb_build_object('ok', true);
end;
$$;

-- ---------- Subir registros ----------
-- Recibe [{entity, id, data}]. El servidor decide owner y audience; la app no puede forzarlos.
-- Devuelve cuántos se guardaron y cuántos se descartaron (no autorizados o mal formados).

create or replace function public.pilot_push(p_records jsonb) returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  uid uuid := auth.uid();
  r jsonb;
  ent text;
  rid text;
  d jsonb;
  aud uuid[];
  inter_aud uuid[];
  ident text;
  ex public.pilot_records%rowtype;
  need_owner uuid;
  allowed boolean;
  ok int := 0;
  skipped int := 0;
  recent int;
begin
  if uid is null or not public.pilot_is_member() then
    raise exception 'not_member' using errcode = '42501';
  end if;
  if jsonb_typeof(p_records) <> 'array' then
    raise exception 'bad_payload';
  end if;
  select count(*) into recent from public.pilot_records
   where owner = uid and updated_at > now() - interval '1 minute';
  if recent > 400 then
    raise exception 'rate_limited';
  end if;

  for r in select value from jsonb_array_elements(p_records) loop
    begin
      ent := r ->> 'entity';
      rid := r ->> 'id';
      d := r -> 'data';
      if ent is null or rid is null or d is null or jsonb_typeof(d) <> 'object' then
        skipped := skipped + 1;
        continue;
      end if;

      -- Campo que identifica al autor de cada tipo de registro.
      ident := case ent
        when 'user' then 'id'
        when 'need' then 'author_id'
        when 'proposal' then 'provider_id'
        when 'message' then 'sender_id'
        when 'rating' then 'from_user'
        when 'recommendation' then 'voter_id'
        when 'emergency' then 'author_id'
        when 'emergency_response' then 'helper_id'
        when 'service_offer' then 'provider_id'
        else null end;

      select * into ex from public.pilot_records where entity = ent and id = rid for update;

      if found then
        allowed := ex.owner = uid or (ex.audience is not null and uid = any (ex.audience));
        if not allowed and ent = 'proposal' then
          -- Quien publicó la necesidad puede aceptar o rechazar las propuestas que recibe.
          select owner into need_owner from public.pilot_records
           where entity = 'need' and id = ex.data ->> 'need_id';
          allowed := need_owner = uid;
        end if;
        if not allowed then
          skipped := skipped + 1;
          continue;
        end if;
        -- La identidad no se puede cambiar al actualizar.
        if ent = 'interaction' then
          if d ->> 'requester_id' is distinct from ex.data ->> 'requester_id'
             or d ->> 'provider_id' is distinct from ex.data ->> 'provider_id' then
            skipped := skipped + 1;
            continue;
          end if;
        elsif ident is not null and d ->> ident is distinct from ex.data ->> ident then
          skipped := skipped + 1;
          continue;
        end if;
        update public.pilot_records set data = d, updated_at = now() where entity = ent and id = rid;
      else
        if ent = 'interaction' then
          if not (d ->> 'requester_id' = uid::text or d ->> 'provider_id' = uid::text) then
            skipped := skipped + 1;
            continue;
          end if;
          aud := array[(d ->> 'requester_id')::uuid, (d ->> 'provider_id')::uuid];
        elsif ent = 'message' then
          select audience into inter_aud from public.pilot_records
           where entity = 'interaction' and id = d ->> 'interaction_id';
          if inter_aud is null or not (uid = any (inter_aud))
             or d ->> 'sender_id' not in (uid::text, 'system') then
            skipped := skipped + 1;
            continue;
          end if;
          aud := inter_aud;
        else
          if ident is not null and d ->> ident is distinct from uid::text then
            skipped := skipped + 1;
            continue;
          end if;
          aud := null;
        end if;
        insert into public.pilot_records (entity, id, owner, audience, data)
        values (ent, rid, uid, aud, d);
      end if;
      ok := ok + 1;
    exception when others then
      skipped := skipped + 1;
    end;
  end loop;

  return jsonb_build_object('ok', ok, 'skipped', skipped);
end;
$$;

-- ---------- Reportar ----------

create or replace function public.pilot_report(p_entity text, p_id text, p_target uuid, p_reason text) returns void
language plpgsql security definer set search_path = public as $$
begin
  if not public.pilot_is_member() then
    raise exception 'not_member' using errcode = '42501';
  end if;
  if (select count(*) from public.pilot_reports
       where reporter = auth.uid() and created_at > now() - interval '1 day') >= 20 then
    raise exception 'rate_limited';
  end if;
  insert into public.pilot_reports (reporter, target, entity, entity_id, reason)
  values (auth.uid(), p_target, left(coalesce(p_entity, ''), 40), left(coalesce(p_id, ''), 120),
          left(coalesce(p_reason, ''), 500));
end;
$$;

-- ---------- Eliminar mi cuenta y mis datos ----------

create or replace function public.pilot_delete_me() returns void
language plpgsql security definer set search_path = public as $$
declare
  uid uuid := auth.uid();
begin
  if uid is null then
    raise exception 'no_auth';
  end if;
  delete from public.pilot_records where owner = uid;
  delete from public.pilot_join_attempts where user_id = uid;
  delete from public.pilot_members where user_id = uid;
  delete from auth.users where id = uid;
end;
$$;

revoke all on function public.pilot_is_member(), public.pilot_owner_ok(uuid), public.pilot_join(text, text, text),
  public.pilot_push(jsonb), public.pilot_report(text, text, uuid, text), public.pilot_delete_me()
  from public, anon;
grant execute on function public.pilot_is_member(), public.pilot_owner_ok(uuid), public.pilot_join(text, text, text),
  public.pilot_push(jsonb), public.pilot_report(text, text, uuid, text), public.pilot_delete_me()
  to authenticated;
