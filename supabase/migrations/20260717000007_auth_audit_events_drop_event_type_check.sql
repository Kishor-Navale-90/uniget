-- Drops the event_type CHECK added in
-- 20260717000005_auth_audit_events.sql — the original pasted schema
-- had no such constraint, and its own column comment allows
-- 'login_failed' in addition to account_activated/login/logout, which
-- the 3-value CHECK rejected.
alter table public.auth_audit_events drop constraint auth_audit_events_event_type_check;
