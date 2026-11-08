-- ============================================================
--  Red del barrio — muro de emergencia: permitir "Puedo ayudar"
--  Pegar completo en Supabase → SQL Editor → New query → Run.
--  Es seguro ejecutarlo más de una vez.
-- ============================================================

alter table public.records drop constraint if exists records_entity_ok;

alter table public.records add constraint records_entity_ok check (entity in
  ('need', 'proposal', 'interaction', 'message', 'rating', 'recommendation',
   'emergency', 'emergency_response'));
