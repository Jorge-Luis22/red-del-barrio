-- Red del barrio · cuarta migración: client_stats deja de ser pública (regla inviolable 4).
-- Las vistas corren con los permisos de su dueño y se saltan las políticas RLS; sin este filtro,
-- cualquier usuario con sesión podía leer el promedio como cliente de cualquier otra persona.
-- Ahora cada persona ve SOLO su propio promedio. Se aplica DESPUÉS de 20261108020000.

create or replace view public.client_stats as
  select rated_id as client_id,
         count(*) as ratings,
         round(avg(stars)::numeric, 2) as avg_stars
  from public.interactions
  where rated_role = 'client' and rated_id = auth.uid()
  group by rated_id;

revoke all on public.client_stats from public, anon;
grant select on public.client_stats to authenticated;
