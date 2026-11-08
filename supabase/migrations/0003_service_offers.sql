-- ============================================================
--  Red del barrio — servicios de urgencia: permitir la entidad "service_offer"
--  Pegar completo en Supabase → SQL Editor → New query → Run.
--  Es seguro ejecutarlo más de una vez.
-- ============================================================

alter table public.records drop constraint if exists records_entity_ok;

alter table public.records add constraint records_entity_ok check (entity in
  ('need', 'proposal', 'interaction', 'message', 'rating', 'recommendation',
   'emergency', 'emergency_response', 'service_offer'));
