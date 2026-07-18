// Admin-only: pre-adds an employee (docs/api/auth.md's "An admin...
// pre-adds an employee with their official email, name, department,
// and role — the account exists but is inactive"). There is no
// employee-management feature package yet, so this Edge Function is
// the temporary stand-in for that admin action — call it from Studio,
// curl, or Postman until that module exists.
//
// It creates BOTH halves of an employee record:
//   1. a shadow `auth.users` row (unconfirmed, throwaway password) so
//      the standard GoTrue OTP flow has a real user to send a code to
//   2. the `public.employees` row (is_active = false) that is the
//      actual source of truth for role/department
//
// Only callers whose own employee row has role `superAdmin` or
// `manager` may call this (matches auth.md's "admin (Super Admin or a
// manager)... pre-adds an employee").
import { createClient } from 'npm:@supabase/supabase-js@2';
import { corsHeaders } from '../_shared/cors.ts';

const ALLOWED_ROLES = ['superAdmin', 'manager', 'itAdmin', 'adminTeam', 'security', 'employee'];
const CALLER_ROLES_ALLOWED_TO_ADD = new Set(['superAdmin', 'manager']);
const DEPARTMENT_FREE_ROLES = new Set(['superAdmin', 'security']);

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  const jsonResponse = (status: number, body: Record<string, unknown>) =>
    new Response(JSON.stringify(body), {
      status,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });

  try {
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return jsonResponse(401, { message: 'Missing Authorization header.' });
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!;
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

    // Scoped to the caller's own JWT — RLS decides what they can see,
    // so `get_my_profile` only ever returns the caller's own role.
    const callerClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authHeader } },
    });
    const { data: callerProfile, error: callerError } = await callerClient
      .rpc('get_my_profile')
      .maybeSingle();

    if (callerError || !callerProfile) {
      return jsonResponse(401, { message: 'Could not verify the calling account.' });
    }
    if (!CALLER_ROLES_ALLOWED_TO_ADD.has(callerProfile.role)) {
      return jsonResponse(403, { message: 'Only a Super Admin or manager can pre-add an employee.' });
    }

    const body = await req.json().catch(() => null);
    const email = typeof body?.email === 'string' ? body.email.trim().toLowerCase() : null;
    const name = typeof body?.name === 'string' ? body.name.trim() : null;
    const role = typeof body?.role === 'string' ? body.role : null;
    const departmentName = typeof body?.departmentName === 'string' ? body.departmentName.trim() : null;

    if (!email || !name || !role || !ALLOWED_ROLES.includes(role)) {
      return jsonResponse(400, {
        message: 'email, name, and a valid role are required.',
      });
    }
    const departmentRequired = !DEPARTMENT_FREE_ROLES.has(role);
    if (departmentRequired && !departmentName) {
      return jsonResponse(400, { message: `departmentName is required for role "${role}".` });
    }
    if (!departmentRequired && departmentName) {
      return jsonResponse(400, { message: `role "${role}" is org-wide and must not have a department.` });
    }

    const adminClient = createClient(supabaseUrl, serviceRoleKey);

    let departmentId: string | null = null;
    if (departmentName) {
      const { data: department, error: departmentError } = await adminClient
        .from('departments')
        .select('id')
        .eq('name', departmentName)
        .maybeSingle();
      if (departmentError) {
        return jsonResponse(500, { message: 'Could not resolve department.' });
      }
      departmentId = department?.id ?? null;
      if (!departmentId) {
        const { data: created, error: createError } = await adminClient
          .from('departments')
          .insert({ name: departmentName })
          .select('id')
          .single();
        if (createError) {
          return jsonResponse(500, { message: 'Could not create department.' });
        }
        departmentId = created.id;
      }
    }

    const { data: existing } = await adminClient
      .from('employees')
      .select('id')
      .eq('email', email)
      .maybeSingle();
    if (existing) {
      return jsonResponse(409, { message: 'This email is already pre-added.' });
    }

    // Throwaway password: the employee never sees or uses it — they
    // set their own via the OTP + set-password flow, which is what
    // flips `is_active` (see the activation trigger migration).
    const { data: created, error: createUserError } = await adminClient.auth.admin.createUser({
      email,
      password: crypto.randomUUID(),
      email_confirm: false,
    });
    if (createUserError || !created?.user) {
      return jsonResponse(500, { message: createUserError?.message ?? 'Could not create the auth user.' });
    }

    const { data: employee, error: insertError } = await adminClient
      .from('employees')
      .insert({
        email,
        name,
        role,
        department_id: departmentId,
        auth_user_id: created.user.id,
        is_active: false,
      })
      .select('id, email, name, role, department_id, is_active')
      .single();

    if (insertError) {
      // Roll back the shadow auth user so a failed pre-add doesn't
      // leave an orphaned, uneligible-for-registration account behind.
      await adminClient.auth.admin.deleteUser(created.user.id);
      return jsonResponse(500, { message: 'Could not create the employee record.' });
    }

    return jsonResponse(201, { employee });
  } catch (error) {
    return jsonResponse(500, { message: error instanceof Error ? error.message : 'Unexpected error.' });
  }
});
