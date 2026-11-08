-- Red del barrio · segunda migración: alinea el servidor con la app Flutter (esquema local v12).
-- ESTADO: escrita y revisada a mano, AÚN NO APLICADA NI PROBADA en un proyecto real.
-- Se aplica DESPUÉS de 20261108000000_init.sql.
--
-- Principio: las reglas críticas viven AQUÍ (servidor), no solo en la pantalla, porque desde otro
-- dispositivo se puede intentar saltarlas:
--   · Un solo trato por pedido (bloqueo de la fila del pedido al aceptar).
--   · Contraofertas: solo del prestador, solo con el código validado, máx. 2 por trato,
--     nunca dos pendientes, y no se acepta una contraoferta obsoleta.
--   · Calificación bidireccional: una por participante y trato, sin autoevaluación.
--   · Cancelar guarda el motivo; no hay multas ni se baja la reputación.

-- ---------------------------------------------------------------------------
-- Categorías de servicio (mismos ids que la app: lib/features/directory/domain/trades.dart)
-- ---------------------------------------------------------------------------
create table public.trade_categories (
  id text primary key,
  label text not null,
  person text not null
);
insert into public.trade_categories (id, label, person) values
  ('gasfiteria', 'Gasfitería', 'Gasfitero'),
  ('electricidad', 'Electricidad', 'Electricista'),
  ('carpinteria', 'Carpintería', 'Carpintero'),
  ('cerrajeria', 'Cerrajería', 'Cerrajero'),
  ('costura', 'Costura', 'Costura'),
  ('clases', 'Clases', 'Clases'),
  ('mascotas', 'Mascotas', 'Mascotas');

alter table public.needs
  add column category_id text references public.trade_categories (id),
  add column details text check (details is null or char_length(details) <= 600);

-- Capacidades del prestador: puede registrar varias; no todos los vecinos son prestadores.
create table public.provider_capabilities (
  id uuid primary key,
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  category_id text not null references public.trade_categories (id),
  availability text not null default '' check (char_length(availability) <= 80),
  created_at timestamptz not null default now(),
  unique (user_id, category_id)
);
create index provider_capabilities_cat_idx on public.provider_capabilities (category_id);

-- ---------------------------------------------------------------------------
-- Propuestas: se conservan en el historial (aceptada / rechazada / descartada)
-- ---------------------------------------------------------------------------
alter table public.proposals
  add column status text not null default 'pending'
    check (status in ('pending', 'accepted', 'rejected', 'discarded')),
  add column price_label text,
  add column resolved_at timestamptz;

-- Tratos: estado «cancelado» con motivo
alter table public.deals drop constraint if exists deals_status_check;
alter table public.deals add constraint deals_status_check
  check (status in ('accepted', 'in_progress', 'awaiting_rating', 'closed', 'cancelled'));
alter table public.deals
  add column cancel_reason text,
  add column cancelled_at timestamptz,
  add column cancelled_by uuid references auth.users (id);

-- Contraofertas presenciales (máx. 2 por trato, nunca hay edición directa)
create table public.price_changes (
  id uuid primary key,
  deal_id uuid not null references public.deals (id) on delete cascade,
  previous_price int not null check (previous_price > 0),
  new_price int not null check (new_price > 0 and new_price <> previous_price),
  reason text not null check (char_length(trim(reason)) >= 5 and char_length(reason) <= 200),
  status text not null default 'pending' check (status in ('pending', 'accepted', 'rejected')),
  author_id uuid not null references auth.users (id),
  created_at timestamptz not null default now(),
  resolved_at timestamptz
);
create index price_changes_deal_idx on public.price_changes (deal_id, created_at);
-- Una sola contraoferta pendiente por trato (defensa en profundidad).
create unique index price_changes_one_pending on public.price_changes (deal_id) where status = 'pending';

create or replace function public.price_changes_limit() returns trigger
language plpgsql as $$
begin
  if (select count(*) from public.price_changes where deal_id = new.deal_id) >= 2 then
    raise exception 'Ya se usaron las 2 contraofertas de este trato';
  end if;
  return new;
end $$;
create trigger price_changes_limit_trg before insert on public.price_changes
  for each row execute function public.price_changes_limit();

-- ---------------------------------------------------------------------------
-- Calificación bidireccional
-- ---------------------------------------------------------------------------
alter table public.interactions
  add column rated_role text not null default 'provider' check (rated_role in ('provider', 'client')),
  add column rated_id uuid references auth.users (id);
update public.interactions set rated_id = provider_id where rated_id is null;
alter table public.interactions alter column rated_id set not null;
alter table public.interactions drop constraint if exists interactions_deal_id_key;
create unique index interactions_one_per_role on public.interactions (deal_id, rated_role);
alter table public.interactions
  add constraint interactions_no_self_rating check (rater_id <> rated_id),
  add constraint interactions_client_not_recommended check (rated_role = 'provider' or not recommended);

-- Reputación como PRESTADOR (la única que alimenta el Visto Bueno) y como CLIENTE, por separado.
create or replace view public.provider_stats as
  select provider_id,
         count(*) as ratings,
         round(avg(stars)::numeric, 2) as avg_stars,
         count(distinct rater_id) filter (where recommended) as visto_bueno
  from public.interactions
  where rated_role = 'provider'
  group by provider_id;

create view public.client_stats as
  select rated_id as client_id,
         count(*) as ratings,
         round(avg(stars)::numeric, 2) as avg_stars
  from public.interactions
  where rated_role = 'client'
  group by rated_id;
grant select on public.client_stats to authenticated;

-- ---------------------------------------------------------------------------
-- Chat del trato
-- ---------------------------------------------------------------------------
create table public.messages (
  id uuid primary key,
  deal_id uuid not null references public.deals (id) on delete cascade,
  sender_id uuid not null default auth.uid() references auth.users (id),
  body text not null check (char_length(trim(body)) between 1 and 300),
  created_at timestamptz not null default now()
);
create index messages_deal_idx on public.messages (deal_id, created_at);

create table public.chat_reads (
  deal_id uuid not null references public.deals (id) on delete cascade,
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  read_at timestamptz not null default now(),
  primary key (deal_id, user_id)
);

-- ---------------------------------------------------------------------------
-- Muro de vecinos (pedidos y ofertas sin dinero) y respuestas
-- ---------------------------------------------------------------------------
create table public.wall_posts (
  id uuid primary key,
  author_id uuid not null default auth.uid() references auth.users (id),
  is_request boolean not null,
  mode text not null check (mode in
    ('Préstamo', 'Trueque', 'Alquiler', 'Donación', 'Favor', 'Intercambio de habilidades', 'Movilidad solidaria')),
  body text not null check (char_length(body) between 3 and 200),
  zone geography (point, 4326),
  created_at timestamptz not null default now()
);
create trigger wall_posts_round_zone_trg before insert or update of zone on public.wall_posts
  for each row execute function public.needs_round_zone();

create table public.post_responses (
  id uuid primary key,
  post_id uuid not null references public.wall_posts (id) on delete cascade,
  responder_id uuid not null default auth.uid() references auth.users (id),
  kind text not null check (kind in ('serviceRequest', 'productRequest', 'productSale', 'loanRequest',
    'loanOffer', 'favorRequest', 'favorOffer', 'donationOffer', 'barter', 'emergency')),
  values jsonb not null default '{}'::jsonb,
  status text not null default 'sent' check (status in ('sent', 'accepted', 'rejected')),
  created_at timestamptz not null default now(),
  unique (post_id, responder_id)           -- sin envíos duplicados
);

-- ---------------------------------------------------------------------------
-- Funciones del ciclo del trato (security definer: validan quién es quién)
-- ---------------------------------------------------------------------------

-- Acepta UNA propuesta. El bloqueo de la fila del pedido (FOR UPDATE) hace que dos aceptaciones
-- simultáneas se atiendan de a una: la segunda ve el pedido ya asignado y falla.
create or replace function public.accept_proposal(p_deal_id uuid, p_proposal_id uuid) returns uuid
language plpgsql security definer set search_path = public as $$
declare v_prop public.proposals; v_need public.needs;
begin
  select * into v_prop from public.proposals where id = p_proposal_id;
  if not found then raise exception 'Propuesta no encontrada'; end if;
  select * into v_need from public.needs where id = v_prop.need_id for update;
  if v_need.author_id <> auth.uid() then raise exception 'Solo quien pidió puede aceptar'; end if;
  if exists (select 1 from public.deals where id = p_deal_id) then return p_deal_id; end if; -- idempotente
  if v_need.status <> 'open' then raise exception 'Este pedido ya está en trato con otra propuesta'; end if;
  if v_prop.status <> 'pending' then raise exception 'Esta propuesta ya no está disponible'; end if;
  insert into public.deals (id, need_id, requester_id, provider_id, price_soles)
    values (p_deal_id, v_need.id, v_need.author_id, v_prop.provider_id, v_prop.price_soles);
  insert into public.deal_codes (deal_id, code)
    values (p_deal_id, lpad((floor(random() * 9000) + 1000)::int::text, 4, '0'));
  -- La elegida queda aceptada; las demás, descartadas (se conservan en el historial).
  update public.proposals
     set status = case when id = p_proposal_id then 'accepted' else 'discarded' end,
         resolved_at = now()
   where need_id = v_need.id and status = 'pending';
  update public.needs set status = 'accepted' where id = v_need.id;
  return p_deal_id;
end $$;

-- El cliente rechaza una propuesta inicial (sin contraoferta): sale de las disponibles.
create or replace function public.reject_proposal(p_proposal_id uuid) returns void
language plpgsql security definer set search_path = public as $$
declare v_prop public.proposals; v_need public.needs;
begin
  select * into v_prop from public.proposals where id = p_proposal_id;
  if not found then raise exception 'Propuesta no encontrada'; end if;
  select * into v_need from public.needs where id = v_prop.need_id for update;
  if v_need.author_id <> auth.uid() then raise exception 'Solo quien pidió puede rechazar'; end if;
  if v_need.status <> 'open' or v_prop.status <> 'pending' then
    raise exception 'Esta propuesta ya no está disponible';
  end if;
  update public.proposals set status = 'rejected', resolved_at = now() where id = p_proposal_id;
end $$;

-- Contraoferta presencial: SOLO el prestador seleccionado, con el código ya validado.
create or replace function public.propose_price_change(
  p_id uuid, p_deal_id uuid, p_new_price int, p_reason text
) returns uuid
language plpgsql security definer set search_path = public as $$
declare v_deal public.deals;
begin
  select * into v_deal from public.deals where id = p_deal_id for update;
  if not found or v_deal.provider_id <> auth.uid() then
    raise exception 'Solo el prestador seleccionado puede hacer una contraoferta';
  end if;
  if exists (select 1 from public.price_changes where id = p_id) then return p_id; end if; -- idempotente
  if v_deal.status <> 'in_progress' then
    raise exception 'La contraoferta se habilita solo después de validar el código de encuentro';
  end if;
  if v_deal.price_soles <= 0 then raise exception 'Este trato no se negocia por precio'; end if;
  if p_new_price is null or p_new_price <= 0 or p_new_price = v_deal.price_soles then
    raise exception 'Escribe un monto nuevo, mayor que cero y distinto al vigente';
  end if;
  if p_reason is null or char_length(trim(p_reason)) < 5 then
    raise exception 'Cuenta el motivo del cambio';
  end if;
  if exists (select 1 from public.price_changes where deal_id = p_deal_id and status = 'pending') then
    raise exception 'Ya hay una contraoferta pendiente: espera la respuesta';
  end if;
  if (select count(*) from public.price_changes where deal_id = p_deal_id) >= 2 then
    raise exception 'Ya se usaron las 2 contraofertas de este trato';
  end if;
  insert into public.price_changes (id, deal_id, previous_price, new_price, reason, author_id)
    values (p_id, p_deal_id, v_deal.price_soles, p_new_price, trim(p_reason), auth.uid());
  return p_id;
end $$;

-- El cliente acepta o rechaza. El precio solo cambia si acepta y la contraoferta sigue vigente.
create or replace function public.respond_price_change(p_change_id uuid, p_accept boolean) returns void
language plpgsql security definer set search_path = public as $$
declare v_change public.price_changes; v_deal public.deals;
begin
  select * into v_change from public.price_changes where id = p_change_id;
  if not found then raise exception 'No encontramos esta contraoferta'; end if;
  select * into v_deal from public.deals where id = v_change.deal_id for update;
  if v_deal.requester_id <> auth.uid() then raise exception 'Solo quien pidió responde'; end if;
  if v_deal.status <> 'in_progress' then raise exception 'Este trato ya no admite cambios de precio'; end if;
  select * into v_change from public.price_changes where id = p_change_id;  -- relee tras el bloqueo
  if v_change.status <> 'pending' or v_change.previous_price <> v_deal.price_soles then
    raise exception 'Esta contraoferta ya no está vigente';
  end if;
  update public.price_changes
     set status = case when p_accept then 'accepted' else 'rejected' end, resolved_at = now()
   where id = p_change_id;
  if p_accept then
    update public.deals set price_soles = v_change.new_price where id = v_deal.id;
  end if;
end $$;

-- Cancelar con motivo (cualquiera de las dos partes). Sin multas ni baja de reputación.
create or replace function public.cancel_deal(p_deal_id uuid, p_reason text) returns void
language plpgsql security definer set search_path = public as $$
declare v_deal public.deals;
begin
  select * into v_deal from public.deals where id = p_deal_id for update;
  if not found or auth.uid() not in (v_deal.requester_id, v_deal.provider_id) then
    raise exception 'No autorizado';
  end if;
  if v_deal.status not in ('accepted', 'in_progress') then
    raise exception 'Este trato ya no se puede cancelar';
  end if;
  if p_reason is null or char_length(trim(p_reason)) < 3 then
    raise exception 'Cuenta el motivo de la cancelación';
  end if;
  update public.deals
     set status = 'cancelled', cancel_reason = trim(p_reason), cancelled_at = now(), cancelled_by = auth.uid()
   where id = p_deal_id;
  update public.needs set status = 'cancelled' where id = v_deal.need_id;
end $$;

-- Calificar es OPCIONAL e independiente: cada parte califica a la otra, una vez por trato.
drop function if exists public.close_and_rate(uuid, uuid, int, text, boolean);

create or replace function public.rate_participant(
  p_interaction_id uuid, p_deal_id uuid, p_stars int, p_comment text, p_recommend boolean
) returns void
language plpgsql security definer set search_path = public as $$
declare v_deal public.deals; v_role text; v_rated uuid; v_rec boolean;
begin
  select * into v_deal from public.deals where id = p_deal_id;
  if not found then raise exception 'No encontramos este trato'; end if;
  if auth.uid() = v_deal.requester_id then v_role := 'provider'; v_rated := v_deal.provider_id;
  elsif auth.uid() = v_deal.provider_id then v_role := 'client'; v_rated := v_deal.requester_id;
  else raise exception 'No autorizado'; end if;
  if v_deal.status not in ('awaiting_rating', 'closed') then
    raise exception 'Se puede calificar cuando el servicio ya terminó';
  end if;
  if exists (select 1 from public.interactions where id = p_interaction_id) then return; end if; -- idempotente
  if exists (select 1 from public.interactions where deal_id = p_deal_id and rated_role = v_role) then
    raise exception 'Ya calificaste en este trato';
  end if;
  -- Visto Bueno solo para prestadores y una recomendación por persona y prestador (anti-inflado).
  v_rec := v_role = 'provider' and coalesce(p_recommend, false) and not exists (
    select 1 from public.interactions
     where provider_id = v_deal.provider_id and rater_id = auth.uid() and recommended);
  insert into public.interactions
    (id, deal_id, provider_id, rater_id, rated_id, rated_role, stars, comment, recommended)
    values (p_interaction_id, p_deal_id, v_deal.provider_id, auth.uid(), v_rated, v_role,
            p_stars, coalesce(p_comment, ''), v_rec);
end $$;

-- Cerrar el trato terminado SIN calificar (calificar no es requisito para cerrar).
create or replace function public.close_without_rating(p_deal_id uuid) returns void
language plpgsql security definer set search_path = public as $$
declare v_deal public.deals;
begin
  select * into v_deal from public.deals where id = p_deal_id for update;
  if not found or v_deal.requester_id <> auth.uid() then raise exception 'No autorizado'; end if;
  if v_deal.status <> 'awaiting_rating' then raise exception 'Este trato no está por cerrar'; end if;
  update public.deals set status = 'closed' where id = p_deal_id;
  update public.needs set status = 'closed' where id = v_deal.need_id;
end $$;

revoke execute on function public.reject_proposal, public.propose_price_change,
  public.respond_price_change, public.cancel_deal, public.rate_participant,
  public.close_without_rating from public, anon;
grant execute on function public.reject_proposal, public.propose_price_change,
  public.respond_price_change, public.cancel_deal, public.rate_participant,
  public.close_without_rating to authenticated;

-- ---------------------------------------------------------------------------
-- RLS en las tablas nuevas y ajustes de las existentes
-- ---------------------------------------------------------------------------
alter table public.trade_categories enable row level security;
alter table public.provider_capabilities enable row level security;
alter table public.price_changes enable row level security;
alter table public.messages enable row level security;
alter table public.chat_reads enable row level security;
alter table public.wall_posts enable row level security;
alter table public.post_responses enable row level security;

create policy categories_read on public.trade_categories for select to authenticated using (true);

-- Capacidades: visibles para el barrio (no llevan ubicación); cada quien edita las suyas.
create policy capabilities_read on public.provider_capabilities for select to authenticated using (true);
create policy capabilities_insert on public.provider_capabilities for insert to authenticated
  with check (user_id = auth.uid());
create policy capabilities_update on public.provider_capabilities for update to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy capabilities_delete on public.provider_capabilities for delete to authenticated
  using (user_id = auth.uid());

-- Propuestas nuevas: solo mientras el pedido siga abierto (bloquea nuevas si ya fue asignado).
drop policy if exists proposals_insert on public.proposals;
create policy proposals_insert on public.proposals for insert to authenticated with check (
  provider_id = auth.uid()
  and status = 'pending'
  and exists (select 1 from public.needs n
               where n.id = need_id and n.status = 'open' and n.author_id <> auth.uid()));

-- Los demás prestadores pueden ver que el pedido en el que propusieron ya fue asignado.
create policy needs_read_proposer on public.needs for select to authenticated
  using (exists (select 1 from public.proposals p where p.need_id = needs.id and p.provider_id = auth.uid()));

-- Contraofertas: las ven las dos partes; solo se crean y responden por funciones.
create policy price_changes_read on public.price_changes for select to authenticated using (
  exists (select 1 from public.deals d where d.id = price_changes.deal_id
           and (d.requester_id = auth.uid() or d.provider_id = auth.uid())));

-- Chat: solo las dos partes del trato.
create policy messages_read on public.messages for select to authenticated using (
  exists (select 1 from public.deals d where d.id = messages.deal_id
           and (d.requester_id = auth.uid() or d.provider_id = auth.uid())));
create policy messages_insert on public.messages for insert to authenticated with check (
  sender_id = auth.uid()
  and exists (select 1 from public.deals d where d.id = deal_id
               and (d.requester_id = auth.uid() or d.provider_id = auth.uid())
               and d.status in ('accepted', 'in_progress', 'awaiting_rating')));
create policy chat_reads_own on public.chat_reads for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

-- Muro: público para el barrio (zona redondeada). Respuestas: solo su autor y el autor del post.
create policy wall_read on public.wall_posts for select to authenticated using (true);
create policy wall_insert on public.wall_posts for insert to authenticated with check (author_id = auth.uid());
create policy wall_delete_own on public.wall_posts for delete to authenticated using (author_id = auth.uid());
create policy responses_read on public.post_responses for select to authenticated using (
  responder_id = auth.uid()
  or exists (select 1 from public.wall_posts w where w.id = post_responses.post_id and w.author_id = auth.uid()));
create policy responses_insert on public.post_responses for insert to authenticated with check (
  responder_id = auth.uid()
  and exists (select 1 from public.wall_posts w where w.id = post_id and w.author_id <> auth.uid()));

-- ---------------------------------------------------------------------------
-- Realtime (propuestas, tratos, contraofertas y chat) — solo si la publicación existe
-- ---------------------------------------------------------------------------
do $$
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    alter publication supabase_realtime add table
      public.proposals, public.deals, public.price_changes, public.messages;
  end if;
end $$;
