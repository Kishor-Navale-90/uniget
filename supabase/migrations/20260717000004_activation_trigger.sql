-- Flips `employees.is_active` the moment the employee actually sets
-- their password (docs/api/auth.md's "activates the account and logs
-- the user in" for set-password). The client flow is:
--   verifyOTP (GoTrue session established, email confirmed)
--   -> auth.updateUser(password: ...)   [this is the signal]
-- The shadow user already has SOME password from
-- admin-add-employee's admin.createUser call, so "password changed"
-- (not "password set for the first time") is the right signal —
-- encrypted_password is guaranteed to differ once GoTrue re-hashes
-- with a new salt.
create or replace function public.handle_employee_password_set()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.encrypted_password is distinct from old.encrypted_password then
    update public.employees
    set is_active = true
    where auth_user_id = new.id
      and is_active = false;
  end if;
  return new;
end;
$$;

create trigger on_auth_user_password_set
  after update on auth.users
  for each row
  execute function public.handle_employee_password_set();
