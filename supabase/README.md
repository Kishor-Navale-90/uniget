# UNIGET auth — Supabase backend

Implements `docs/api/auth.md` on top of Supabase (Postgres + GoTrue +
one Edge Function). The Flutter client talks to this directly via
`supabase_flutter` — see `packages/features/feature_auth`.

## What's here

| Path | Purpose |
|---|---|
| `migrations/20260717000001_departments_and_employees.sql` | `departments` + `employees` tables, RLS. `employees` is the admin-pre-added record (role/department/active flag) — separate from `auth.users`, which only ever holds the credential. |
| `migrations/20260717000002_registration_eligibility_rpc.sql` | `is_eligible_for_registration(email)` — backs `check-email`. |
| `migrations/20260717000003_profile_rpc.sql` | `get_my_profile()` — assembles the `{id,name,email,role,departmentId,departmentName}` shape every endpoint in auth.md returns. |
| `migrations/20260717000004_activation_trigger.sql` | Flips `employees.is_active` the moment set-password succeeds. |
| `migrations/20260717000005_auth_audit_events.sql` | `auth_audit_events` — server-side audit log (account_activated/login/logout) backing auth.md's audit requirement; service-role-only, no client access. |
| `functions/admin-add-employee` | Service-role Edge Function that pre-adds an employee (creates the shadow `auth.users` row + the `employees` row). Stand-in for the not-yet-built employee-management module — restricted to callers whose own `employees.role` is `superAdmin` or `manager`. |
| `seed.sql` | Local dev departments only (employee rows need the Admin API — see below). |

## How the auth.md flow maps onto Supabase

| auth.md endpoint | Supabase equivalent (called from Flutter via `supabase_flutter`) |
|---|---|
| admin pre-adds employee | `functions/admin-add-employee` (service role; no client route yet) |
| `check-email` | `supabase.rpc('is_eligible_for_registration', {p_email: email})` |
| `otp/request` | `supabase.auth.signInWithOtp(email: email, shouldCreateUser: false)` |
| `otp/verify` | `supabase.auth.verifyOTP(email: email, token: otp, type: OtpType.email)` — establishes a live Supabase session directly (see note below) |
| `set-password` | `supabase.auth.updateUser(UserAttributes(password: password))`, then `supabase.rpc('get_my_profile')` |
| `login` | `supabase.auth.signInWithPassword(email: email, password: password)` |
| `logout` | `supabase.auth.signOut()` |
| `me` | `supabase.auth.getUser()` + `supabase.rpc('get_my_profile')` |

**Note on `registrationToken`:** auth.md's mock contract has `otp/verify`
return a short-lived `registrationToken` that is *not* a session, only
authorizing the following `set-password` call. GoTrue's OTP verify
doesn't have that two-step shape — a successful `verifyOTP` always
establishes a real session immediately. The Flutter client (per your
choice to use the native SDK) adapts to this: the live Supabase session
*is* the transitional credential between OTP verify and set-password,
scoped to that one user exactly like the mock token was, just without
an explicit token string changing hands. `employees.is_active` still
only flips to `true` once the password is actually set, so a verified
but not-yet-password-set account still isn't a "real" activated login
as far as the rest of the app (RLS, route guards) is concerned.

## Project

Linked to **uniget-dev** (ref `wzjlekgijefwqcvkxovt`, org `posbill` /
`hbyrnbgqvuujkqmmfmxx`, region `ap-south-1`) — a dedicated project,
separate from the org's other `posbill` project. Dashboard:
https://supabase.com/dashboard/project/wzjlekgijefwqcvkxovt

No global CLI install needed — `npx supabase <command>` works fine and
is what every command below uses (v2.109.1 confirmed working). If you
prefer a global install: `brew install supabase/tap/supabase`.

## One-time setup (only needed again for a fresh clone/machine)

```bash
cd /Users/kishornavale/flutter/uniget
npx supabase login
npx supabase link --project-ref wzjlekgijefwqcvkxovt
```

## Deploy

Already run once for `uniget-dev` — repeat after changing any
migration/function:

```bash
# Push schema (tables, RLS, RPCs, trigger)
npx supabase db push

# Seed departments — `--linked` runs it against the linked remote
# project via the Management API (works without Docker/local Postgres)
npx supabase db query --linked -f seed.sql

# Deploy the admin Edge Function
npx supabase functions deploy admin-add-employee
```

`npx supabase status` / `db push`'s local preview require Docker
running locally — not needed for the remote-only workflow above.

## Dashboard configuration (not scriptable via migrations)

1. **SMTP** — Project Settings → Auth → SMTP Settings. Configure your
   org's mail gateway (matches auth.md's "sent... via the org's email
   gateway"). Until configured, Supabase's default mailer works for
   testing but is rate-limited and not for production use.
2. **Email template** — Authentication → Email Templates → "Magic
   Link" / "OTP" — customize copy; the `{{ .Token }}` variable is the
   6-digit OTP code used by `signInWithOtp` / `verifyOTP`.
3. **Site URL / Redirect URLs** — not used by this flow (OTP is
   code-based, not link-based), but set them anyway if you later add
   magic-link sign-in.

## Bootstrapping the first Super Admin

There's no employee-management UI yet, so pre-add employees by calling
the Edge Function directly. It requires a *caller* JWT belonging to an
existing `superAdmin`/`manager` employee — for the very first employee
in a fresh project, there's no admin yet to call it with, so create
that one row directly instead (needs the service-role key — Project
Settings → API on the dashboard, or `npx supabase projects api-keys
--project-ref wzjlekgijefwqcvkxovt`):

```bash
# 1. Create the shadow auth user (replace the email/password)
curl -X POST "https://wzjlekgijefwqcvkxovt.supabase.co/auth/v1/admin/users" \
  -H "Authorization: Bearer <service-role-key>" \
  -H "apikey: <service-role-key>" \
  -H "Content-Type: application/json" \
  -d '{"email":"you@company.com","password":"<throwaway>","email_confirm":false}'
# note the returned "id" — that's <auth-user-id> below

# 2. Insert the matching employees row
npx supabase db query --linked \
  "insert into public.employees (email, name, role, is_active, auth_user_id) values ('you@company.com', 'Founding Admin', 'superAdmin', false, '<auth-user-id>');"
```

The founding admin then goes through the normal `check-email` →
`otp/request` → `otp/verify` → `set-password` flow in the app to
actually activate and log in — from then on, use the Edge Function for
every subsequent employee:

```bash
curl -X POST "https://wzjlekgijefwqcvkxovt.supabase.co/functions/v1/admin-add-employee" \
  -H "Authorization: Bearer <superAdmin-or-manager-session-token>" \
  -H "Content-Type: application/json" \
  -d '{"email":"priya.sharma@company.com","name":"Priya Sharma","role":"employee","departmentName":"Engineering"}'
```

## Flutter-side configuration

Pass these via `--dart-define` (see `apps/uniget_app/lib/flavors/` and
CI's `--dart-define-from-file=env/<flavor>.json` — never commit real
values):

```
SUPABASE_URL=https://wzjlekgijefwqcvkxovt.supabase.co
SUPABASE_ANON_KEY=sb_publishable_PmtB6U3tBRH72OFYe4qOog_bFJcuJ92
```

(The publishable key is the current, non-deprecated equivalent of the
legacy `anon` key — see Project Settings → API on the dashboard if you
ever need to rotate it or fetch the legacy JWT form instead.)
