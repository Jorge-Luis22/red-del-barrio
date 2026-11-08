-- Red del barrio · esquema inicial para Supabase (Postgres + PostGIS)
-- ESTADO: escrito y revisado a mano, AÚN NO APLICADO NI PROBADO en un proyecto real.
-- Reglas inviolables que este esquema fuerza (no solo la interfaz):
--   3. La ubicación exacta nunca es pública: solo hay una ZONA redondeada (~1 km) y la exacta vive
--      en otra tabla que solo ven su dueño y quien aceptó ayudar.
--   4. No hay puntos ni puestos públicos: solo conteos agregados (vista provider_stats).
--   5. Los pedidos de emergencia privados (violencia) nunca se leen por otra persona.
-- Idempotencia: todas las claves primarias son UUID generados en el cliente (cola de pendientes).

create extension if not exists postgis;
create extension if not exists pgcrypto;

-- ---------------------------------------------------------------------------
-- Utilidades
-- ---------------------------------------------------------------------------
create or replace function public.round_zone(g geography) returns geography
language sql immutable as $$
  select st_setsrid(
           st_makepoint(round(st_x(g::geometry)::numeric, 2), round(st_y(g::geometry)::numeric, 2)),
           4326)::geography
$$;

-- ---------------------------------------------------------------------------
-- Perfiles (sin ubicación)
-- ---------------------------------------------------------------------------
create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text not null default 'Vecino del barrio',
  created_at timestamptz not null default now()
);

create or replace function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id) values (new.id) on conflict do nothing;
  return new;
end $$;

create trigger on_auth_user_created after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------------------
-- Necesidades (zona aproximada pública)
-- ---------------------------------------------------------------------------
create table public.needs (
  id uuid primary key,
  author_id uuid not null default auth.uid() references auth.users (id),
  kind text not null check (kind in ('service', 'product', 'loan', 'help')),
  body text not null check (char_length(body) between 3 and 200),
  urgency text not null check (urgency in ('now', 'today', 'tomorrow', 'thisWeek')),
  status text not null default 'open' check (status in ('open', 'accepted', 'closed', 'cancelled')),
  zone geography (point, 4326),
  is_demo boolean not null default false,
  created_at timestamptz not null default now()
);
create index needs_zone_gix on public.needs using gist (zone);
create index needs_status_idx on public.needs (status, created_at desc);

create or replace function public.needs_round_zone() returns trigger
language plpgsql as $$
begin
  if new.zone is not null then new.zone := public.round_zone(new.zone); end if;
  return new;
end $$;
create trigger needs_round_zone_trg before insert or update of zone on public.needs
  for each row execute function public.needs_round_zone();

-- Ubicación EXACTA: tabla aparte con políticas estrictas.
create table public.need_exact_locations (
  need_id uuid primary key references public.needs (id) on delete cascade,
  owner_id uuid not null default auth.uid() references auth.users (id),
  location geography (point, 4326) not null
);

-- ---------------------------------------------------------------------------
-- Propuestas, tratos y códigos de encuentro
-- ---------------------------------------------------------------------------
create table public.proposals (
  id uuid primary key,
  need_id uuid not null references public.needs (id) on delete cascade,
  provider_id uuid not null default auth.uid() references auth.users (id),
  price_soles int not null check (price_soles >= 0),
  availability text not null default '',
  created_at timestamptz not null default now(),
  unique (need_id, provider_id)
);

create table public.deals (
  id uuid primary key,
  need_id uuid not null unique references public.needs (id),
  requester_id uuid not null references auth.users (id),
  provider_id uuid not null references auth.users (id),
  price_soles int not null check (price_soles >= 0),
  status text not null default 'accepted'
    check (status in ('accepted', 'in_progress', 'awaiting_rating', 'closed')),
  accepted_at timestamptz not null default now(),
  started_at timestamptz,
  completed_at timestamptz
);

-- El código de 4 dígitos lo ve solo quien pidió; quien presta lo ingresa.
create table public.deal_codes (
  deal_id uuid primary key references public.deals (id) on delete cascade,
  code text not null check (code ~ '^[0-9]{4}$')
);

-- Interacciones confirmadas = única fuente de reputación y Visto Bueno reales.
create table public.interactions (
  id uuid primary key,
  deal_id uuid not null unique references public.deals (id),
  provider_id uuid not null references auth.users (id),
  rater_id uuid not null references auth.users (id),
  stars int not null check (stars between 1 and 5),
  comment text not null default '' check (char_length(comment) <= 200),
  recommended boolean not null default false,
  closed_at timestamptz not null default now()
);
-- REGLA ANTI-INFLADO: una recomendación por persona y por proveedor.
create unique index interactions_one_recommendation_per_rater
  on public.interactions (provider_id, rater_id) where recommended;

-- Conteos agregados (sin puntos ni puestos). La vista corre como su dueño a propósito.
create view public.provider_stats as
  select provider_id,
         count(*) as ratings,
         round(avg(stars)::numeric, 2) as avg_stars,
         count(distinct rater_id) filter (where recommended) as visto_bueno
  from public.interactions
  group by provider_id;

-- ---------------------------------------------------------------------------
-- Emergencias
-- ---------------------------------------------------------------------------
create table public.emergency_posts (
  id uuid primary key,
  author_id uuid not null default auth.uid() references auth.users (id),
  type text not null check (type in ('quake', 'fire', 'medical', 'elder', 'violence')),
  why text not null check (char_length(why) between 3 and 200),
  needs text[] not null default '{}',
  zone geography (point, 4326),
  is_private boolean not null default false,
  created_at timestamptz not null default now()
);
create index emergency_zone_gix on public.emergency_posts using gist (zone);

create or replace function public.emergency_force_private() returns trigger
language plpgsql as $$
begin
  if new.type = 'violence' then new.is_private := true; end if;
  if new.zone is not null then new.zone := public.round_zone(new.zone); end if;
  return new;
end $$;
create trigger emergency_force_private_trg before insert or update on public.emergency_posts
  for each row execute function public.emergency_force_private();

-- ---------------------------------------------------------------------------
-- Funciones del ciclo del trato (security definer: validan quién es quién)
-- ---------------------------------------------------------------------------
create or replace function public.accept_proposal(p_deal_id uuid, p_proposal_id uuid) returns uuid
language plpgsql security definer set search_path = public as $$
declare v_prop public.proposals; v_need public.needs;
begin
  select * into v_prop from public.proposals where id = p_proposal_id;
  if not found then raise exception 'Propuesta no encontrada'; end if;
  select * into v_need from public.needs where id = v_prop.need_id;
  if v_need.author_id <> auth.uid() then raise exception 'Solo quien pidió puede aceptar'; end if;
  if exists (select 1 from public.deals where id = p_deal_id) then return p_deal_id; end if; -- idempotente
  if v_need.status <> 'open' then raise exception 'El pedido ya no está abierto'; end if;
  insert into public.deals (id, need_id, requester_id, provider_id, price_soles)
    values (p_deal_id, v_need.id, v_need.author_id, v_prop.provider_id, v_prop.price_soles);
  insert into public.deal_codes (deal_id, code)
    values (p_deal_id, lpad((floor(random() * 9000) + 1000)::int::text, 4, '0'));
  update public.needs set status = 'accepted' where id = v_need.id;
  return p_deal_id;
end $$;

create or replace function public.validate_meeting_code(p_deal_id uuid, p_code text) returns void
language plpgsql security definer set search_path = public as $$
declare v_deal public.deals;
begin
  select * into v_deal from public.deals where id = p_deal_id;
  if not found or v_deal.provider_id <> auth.uid() then raise exception 'No autorizado'; end if;
  if v_deal.status <> 'accepted' then raise exception 'El código ya fue validado'; end if;
  if not exists (select 1 from public.deal_codes where deal_id = p_deal_id and code = trim(p_code)) then
    raise exception 'El código no coincide';
  end if;
  update public.deals set status = 'in_progress', started_at = now() where id = p_deal_id;
end $$;

create or replace function public.complete_deal(p_deal_id uuid) returns void
language plpgsql security definer set search_path = public as $$
begin
  update public.deals set status = 'awaiting_rating', completed_at = now()
   where id = p_deal_id and requester_id = auth.uid() and status = 'in_progress';
  if not found then raise exception 'Primero hay que validar el código de encuentro'; end if;
end $$;

create or replace function public.close_and_rate(
  p_deal_id uuid, p_interaction_id uuid, p_stars int, p_comment text, p_recommend boolean
) returns void
language plpgsql security definer set search_path = public as $$
declare v_deal public.deals; v_rec boolean;
begin
  select * into v_deal from public.deals where id = p_deal_id;
  if not found or v_deal.requester_id <> auth.uid() then raise exception 'No autorizado'; end if;
  if v_deal.status <> 'awaiting_rating' then raise exception 'Primero marca el servicio como hecho'; end if;
  -- una recomendación por persona y proveedor: si ya recomendó antes, esta calificación no suma otra
  v_rec := p_recommend and not exists (
    select 1 from public.interactions
     where provider_id = v_deal.provider_id and rater_id = auth.uid() and recommended);
  insert into public.interactions (id, deal_id, provider_id, rater_id, stars, comment, recommended)
    values (p_interaction_id, p_deal_id, v_deal.provider_id, auth.uid(), p_stars, coalesce(p_comment, ''), v_rec)
    on conflict (id) do nothing;
  update public.deals set status = 'closed' where id = p_deal_id;
  update public.needs set status = 'closed' where id = v_deal.need_id;
end $$;

revoke execute on function public.accept_proposal, public.validate_meeting_code,
  public.complete_deal, public.close_and_rate from public, anon;
grant execute on function public.accept_proposal, public.validate_meeting_code,
  public.complete_deal, public.close_and_rate to authenticated;

-- ---------------------------------------------------------------------------
-- RLS en TODAS las tablas
-- ---------------------------------------------------------------------------
alter table public.profiles enable row level security;
alter table public.needs enable row level security;
alter table public.need_exact_locations enable row level security;
alter table public.proposals enable row level security;
alter table public.deals enable row level security;
alter table public.deal_codes enable row level security;
alter table public.interactions enable row level security;
alter table public.emergency_posts enable row level security;

-- profiles
create policy profiles_read on public.profiles for select to authenticated using (true);
create policy profiles_update_own on public.profiles for update to authenticated
  using (id = auth.uid()) with check (id = auth.uid());

-- needs: abiertas visibles a todos (solo con zona aproximada); lo demás, a su autor y a su proveedor
create policy needs_read on public.needs for select to authenticated using (
  status = 'open' or author_id = auth.uid()
  or exists (select 1 from public.deals d where d.need_id = needs.id and d.provider_id = auth.uid()));
create policy needs_insert on public.needs for insert to authenticated with check (author_id = auth.uid());
create policy needs_update_own on public.needs for update to authenticated
  using (author_id = auth.uid()) with check (author_id = auth.uid());

-- ubicación exacta: SOLO su dueño y quien aceptó ayudar (regla inviolable 3)
create policy exact_read on public.need_exact_locations for select to authenticated using (
  owner_id = auth.uid()
  or exists (select 1 from public.deals d where d.need_id = need_exact_locations.need_id and d.provider_id = auth.uid()));
create policy exact_insert on public.need_exact_locations for insert to authenticated with check (owner_id = auth.uid());
create policy exact_delete on public.need_exact_locations for delete to authenticated using (owner_id = auth.uid());

-- propuestas
create policy proposals_read on public.proposals for select to authenticated using (
  provider_id = auth.uid()
  or exists (select 1 from public.needs n where n.id = proposals.need_id and n.author_id = auth.uid()));
create policy proposals_insert on public.proposals for insert to authenticated with check (
  provider_id = auth.uid()
  and not exists (select 1 from public.needs n where n.id = need_id and n.author_id = auth.uid()));

-- tratos: solo lectura para las dos partes; los cambios van por funciones
create policy deals_read on public.deals for select to authenticated
  using (requester_id = auth.uid() or provider_id = auth.uid());

-- código de encuentro: solo quien pidió
create policy codes_read on public.deal_codes for select to authenticated using (
  exists (select 1 from public.deals d where d.id = deal_codes.deal_id and d.requester_id = auth.uid()));

-- interacciones: cada parte ve las suyas; el público ve solo la vista provider_stats
create policy interactions_read on public.interactions for select to authenticated
  using (rater_id = auth.uid() or provider_id = auth.uid());

-- emergencias: lo privado jamás lo lee otra persona
create policy emergency_read on public.emergency_posts for select to authenticated
  using (author_id = auth.uid() or not is_private);
create policy emergency_insert on public.emergency_posts for insert to authenticated
  with check (author_id = auth.uid());

grant select on public.provider_stats to authenticated;
