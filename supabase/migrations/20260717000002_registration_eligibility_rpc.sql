-- Backs `POST /v1/auth/register/check-email` (docs/api/auth.md): true
-- only if an admin pre-added this email and it hasn't been activated
-- yet. SECURITY DEFINER so an anonymous caller can evaluate it without
-- needing direct SELECT on `employees` (which would otherwise leak
-- name/role/department for every row via other RLS-bypassing tricks —
-- this function returns a single boolean, nothing else).
create or replace function public.is_eligible_for_registration(p_email text)
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.employees
    where email = p_email::citext
      and is_active = false
      and auth_user_id is not null
  );
$$;

revoke all on function public.is_eligible_for_registration(text) from public;
grant execute on function public.is_eligible_for_registration(text) to anon, authenticated;
