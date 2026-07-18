-- Objects requested explicitly as-is, kept alongside the GoTrue-based
-- auth already implemented in migrations 1-4 and
-- packages/features/feature_auth/lib/src/data/datasources/auth_remote_datasource.dart.
-- NOTE: auth_role, auth_credentials, otp_codes, and registration_tokens
-- are NOT referenced by any current code path — GoTrue (auth.users)
-- already owns password hashing and OTP verification, and the live
-- Supabase session (not a registrationToken) is what bridges
-- otp/verify -> set-password (see supabase/README.md's "Note on
-- registrationToken"). These exist only because they were asked for
-- explicitly; wiring anything to write to them is a separate task.
create type public.auth_role as enum (
  'super_admin',
  'manager',
  'it_admin',
  'admin_team',
  'security',
  'employee'
);

-- Kept separate from `employees` on purpose: keeps password hashes out
-- of a table read/written far more broadly by other modules. Unused
-- while GoTrue owns credentials (see note above).
create table public.auth_credentials (
  employee_id         uuid primary key references public.employees (id) on delete cascade,
  password_hash        text not null,
  password_algo        text not null default 'argon2id',
  activated_at         timestamptz not null default now(),
  updated_at           timestamptz not null default now(),
  failed_login_count   integer not null default 0,
  locked_until         timestamptz
);

comment on table public.auth_credentials is
  'Password-credential store, kept separate from employees. Currently unused: GoTrue (auth.users) owns password hashing for this app.';

-- One row per code sent; never reused. Unused while GoTrue's
-- signInWithOtp/verifyOTP manage OTPs internally (see note above).
create table public.otp_codes (
  id             uuid primary key default gen_random_uuid(),
  email          citext not null,
  otp_hash       text not null,
  purpose        text not null default 'registration',
  attempt_count  integer not null default 0,
  expires_at     timestamptz not null,
  consumed_at    timestamptz,
  created_at     timestamptz not null default now()
);

comment on table public.otp_codes is
  'One-time-code store. Currently unused: GoTrue signInWithOtp/verifyOTP manage OTPs internally for this app.';

create index otp_codes_email_created_idx on public.otp_codes (email, created_at desc);

-- Issued by otp/verify, consumed by set-password in the original mock
-- REST contract (docs/api/auth.md). Unused while the live Supabase
-- session (established directly by verifyOTP) plays this role instead.
create table public.registration_tokens (
  id            uuid primary key default gen_random_uuid(),
  token_hash    text not null unique,
  email         citext not null,
  otp_code_id   uuid references public.otp_codes (id) on delete set null,
  expires_at    timestamptz not null,
  used_at       timestamptz,
  created_at    timestamptz not null default now()
);

comment on table public.registration_tokens is
  'Short-lived registration-token store from the original mock REST contract. Currently unused: a live Supabase session plays this role instead (see supabase/README.md).';

create index registration_tokens_email_idx on public.registration_tokens (email);

-- JWTs are stateless, so logout revocation needs an explicit
-- blacklist-by-jti if it's ever enforced beyond GoTrue's own
-- signOut() (which invalidates the refresh token but not a still-live
-- access token). Not currently checked by anything — enforcing it
-- would need a custom JWT verification hook.
create table public.revoked_tokens (
  jti           text primary key,
  employee_id   uuid not null references public.employees (id) on delete cascade,
  revoked_at    timestamptz not null default now(),
  expires_at    timestamptz not null
);

comment on table public.revoked_tokens is
  'JWT-id blacklist for logout revocation. Not currently enforced by any JWT verification hook.';

create index revoked_tokens_employee_id_idx on public.revoked_tokens (employee_id);

-- All four hold credential/PII-adjacent material (password hashes, OTP
-- hashes, token hashes) — RLS on with no policies denies all
-- anon/authenticated access via PostgREST; only service-role writes
-- would ever touch these, consistent with auth_audit_events.
alter table public.auth_credentials enable row level security;
alter table public.otp_codes enable row level security;
alter table public.registration_tokens enable row level security;
alter table public.revoked_tokens enable row level security;
