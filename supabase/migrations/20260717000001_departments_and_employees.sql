-- Backing tables for docs/api/auth.md's contract. `employees` is the
-- admin-pre-added record ("account exists but is inactive") that the
-- OTP + set-password flow activates; it is intentionally separate
-- from `auth.users` (which GoTrue owns) so an employee row can exist
-- before any credential does.

create extension if not exists citext;

create table public.departments (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  created_at timestamptz not null default now()
);

comment on table public.departments is
  'Org departments. Every role except superAdmin/security is scoped to exactly one.';

create table public.employees (
  id uuid primary key default gen_random_uuid(),
  -- Null until the admin-add step creates the matching shadow
  -- auth.users row (see functions/admin-add-employee) — set exactly
  -- once, never reassigned.
  auth_user_id uuid unique references auth.users (id) on delete set null,
  email citext not null unique,
  name text not null,
  role text not null check (role in ('superAdmin', 'manager', 'itAdmin', 'adminTeam', 'security', 'employee')),
  department_id uuid references public.departments (id),
  -- Flips true the moment set-password succeeds (see the trigger in
  -- 20260717000004_activation_trigger.sql) — never before.
  is_active boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint department_scope_matches_role check (
    (role in ('superAdmin', 'security') and department_id is null)
    or
    (role not in ('superAdmin', 'security') and department_id is not null)
  )
);

comment on table public.employees is
  'Admin-pre-added employee records — the source of truth for role/department. auth.users only ever holds the credential half.';

create index employees_department_id_idx on public.employees (department_id);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger employees_set_updated_at
  before update on public.employees
  for each row
  execute function public.set_updated_at();

alter table public.departments enable row level security;
alter table public.employees enable row level security;

-- Departments: readable by any signed-in employee (needed to resolve
-- departmentName for display); no client-side writes — department
-- management is an admin-only, service-role operation.
create policy "departments are readable by authenticated users"
  on public.departments for select
  to authenticated
  using (true);

-- Employees: an employee may only ever read their own row, and only
-- once activated. Nothing is ever written to this table from the
-- client — inserts happen via the admin-add-employee Edge Function
-- (service role), updates happen via the activation trigger.
create policy "employees can read their own row"
  on public.employees for select
  to authenticated
  using (auth_user_id = auth.uid());
