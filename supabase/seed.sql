-- Local dev seed. Only departments — employee rows need a matching
-- `auth.users` shadow account, which requires the Admin API
-- (service-role key), not plain SQL. Use the admin-add-employee Edge
-- Function to seed test employees locally (see supabase/README.md).
insert into public.departments (name) values
  ('Engineering'),
  ('Facilities'),
  ('Human Resources')
on conflict (name) do nothing;
