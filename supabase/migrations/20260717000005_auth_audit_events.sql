-- Server-side audit log for docs/api/auth.md's "Notes for implementation"
-- requirement: every state-changing call (account activated, login,
-- logout) is written to a server-side audit log. Mirrors the shape of
-- the client's local AuditEvent table (packages/core/lib/src/audit/)
-- for the module column "Auth" — this table is that server-side half.
--
-- Deliberately separate from `employees`/`auth.users`: written only by
-- triggers/Edge Functions running as service role (RLS below denies
-- all client access), never by the Flutter client directly.
create table public.auth_audit_events (
  id uuid primary key default gen_random_uuid(),
  employee_id uuid references public.employees (id) on delete set null,
  module text not null default 'Auth',
  -- e.g. 'account_activated' | 'login' | 'logout' | 'login_failed' —
  -- no CHECK constraint (dropped in
  -- 20260717000007_auth_audit_events_drop_event_type_check.sql).
  event_type text not null,
  ip_address inet,
  user_agent text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

comment on table public.auth_audit_events is
  'Server-side mirror of the client local AuditEvent table for module "Auth" — account_activated/login/logout events, written by triggers/Edge Functions (service role) only.';

create index auth_audit_events_employee_id_idx on public.auth_audit_events (employee_id, created_at desc);
create index auth_audit_events_event_type_idx on public.auth_audit_events (event_type, created_at desc);

alter table public.auth_audit_events enable row level security;

-- No policies: this table has no client-facing reads or writes. Rows
-- are inserted by service-role code (e.g. a future extension of the
-- activation trigger, or the login/logout paths) which bypasses RLS.
