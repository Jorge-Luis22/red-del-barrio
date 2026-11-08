-- Red del barrio · tercera migración: corrige la recursión infinita entre las políticas de
-- `needs` y `proposals` (error 42P17 detectado al probar tests/reglas_trato.sql en Supabase).
-- La política de lectura de `needs` consultaba `proposals`, y la de `proposals` consultaba `needs`.
-- Una función security definer lee `proposals` sin pasar por sus políticas y rompe el ciclo.
-- Se aplica DESPUÉS de 20261108010000_reglas_app_v12.sql.

create or replace function public.has_proposed(p_need_id uuid) returns boolean
language sql security definer stable set search_path = public as $$
  select exists (
    select 1 from public.proposals
     where need_id = p_need_id and provider_id = auth.uid())
$$;

revoke execute on function public.has_proposed(uuid) from public, anon;
grant execute on function public.has_proposed(uuid) to authenticated;

drop policy if exists needs_read_proposer on public.needs;
create policy needs_read_proposer on public.needs for select to authenticated
  using (public.has_proposed(id));
