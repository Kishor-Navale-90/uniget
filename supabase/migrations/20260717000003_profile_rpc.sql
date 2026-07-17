-- Backs the "user object" shape every endpoint in docs/api/auth.md
-- returns (id/name/email/role/departmentId/departmentName). Called by
-- the Flutter client right after any successful auth event
-- (verifyOTP, updateUser/set-password, signInWithPassword,
-- getUser-on-cold-start) to assemble `AppUser` — RLS already limits a
-- caller to their own row, but SECURITY DEFINER lets this join
-- `departments` for the denormalized name without a second grant.
create or replace function public.get_my_profile()
returns table (
  id uuid,
  email text,
  name text,
  role text,
  department_id uuid,
  department_name text,
  is_active boolean
)
language sql
security definer
set search_path = public
as $$
  select
    e.auth_user_id as id,
    e.email::text,
    e.name,
    e.role,
    e.department_id,
    d.name as department_name,
    e.is_active
  from public.employees e
  left join public.departments d on d.id = e.department_id
  where e.auth_user_id = auth.uid();
$$;

revoke all on function public.get_my_profile() from public;
grant execute on function public.get_my_profile() to authenticated;
