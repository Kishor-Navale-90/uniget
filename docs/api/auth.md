# Auth API — mock contract

Backing implementation: `packages/features/feature_auth`. These shapes
match the client's `UserModel`/`AppUser` and `AuthRemoteDataSource`
exactly (`packages/features/feature_auth/lib/src/data/`) — if a field
name changes here, update that file too, and vice versa.

## Flow

There is no SSO and no self-service sign-up. An admin (Super Admin or
a manager, via the employee-management module) pre-adds an employee
with their **official email**, name, department, and role — the
account exists but is inactive. The employee then activates it
themselves:

```
check-email → otp/request → otp/verify → set-password → (logged in)
```

After activation, employees sign in with `POST /v1/auth/login`
(email + password) going forward.

## User object

Every endpoint that returns a user uses this shape:

```json
{
  "id": "usr_8f2a1c",
  "name": "Priya Sharma",
  "email": "priya.sharma@company.com",
  "role": "employee",
  "departmentId": "dept_eng",
  "departmentName": "Engineering"
}
```

`role` is one of: `superAdmin`, `manager`, `itAdmin`, `adminTeam`,
`security`, `employee`. `departmentId`/`departmentName` are `null` for
`superAdmin` (cross-department) and `security` (org-wide, site-scoped
rather than department-scoped) — every other role is scoped to exactly
one department.

---

## `POST /v1/auth/register/check-email`

Confirms the email was pre-added by an admin and hasn't been
activated yet. No OTP is sent by this call.

**Request**
```json
{ "email": "priya.sharma@company.com" }
```

**Response `200`** — empty body; eligible to continue.

**Response `422`** — not eligible (unknown email, or already active):
```json
{ "message": "This email is not registered, or the account is already active." }
```

---

## `POST /v1/auth/register/otp/request`

Sends a one-time code to the email via the org's email gateway.

**Request**
```json
{ "email": "priya.sharma@company.com" }
```

**Response `200`** — empty body.

**Response `429`** — rate-limited (too many requests for this email in
a short window):
```json
{ "message": "Please wait before requesting another code." }
```

---

## `POST /v1/auth/register/otp/verify`

**Request**
```json
{ "email": "priya.sharma@company.com", "otp": "482913" }
```

**Response `200`**
```json
{ "registrationToken": "regtok_9f1c2e8a" }
```

`registrationToken` is short-lived (recommend 10–15 min TTL) and is
**not** a session token — it only authorizes the following
`set-password` call, scoped to this one email.

**Response `400`** — invalid or expired code:
```json
{ "message": "That code is invalid or has expired." }
```

---

## `POST /v1/auth/register/set-password`

Activates the account and logs the user in.

**Request**
```json
{ "registrationToken": "regtok_9f1c2e8a", "password": "a-strong-password" }
```

**Response `200`**
```json
{
  "token": "eyJhbGciOi...",
  "user": {
    "id": "usr_8f2a1c",
    "name": "Priya Sharma",
    "email": "priya.sharma@company.com",
    "role": "employee",
    "departmentId": "dept_eng",
    "departmentName": "Engineering"
  }
}
```

`token` is the session token — the client attaches it as
`Authorization: Bearer <token>` on every subsequent request (see
`core/network/interceptors/auth_interceptor.dart`).

**Response `400`** — expired/invalid `registrationToken`, or password
doesn't meet the policy:
```json
{ "message": "This registration link has expired — request a new code." }
```

---

## `POST /v1/auth/login`

Regular sign-in once the account is active.

**Request**
```json
{ "email": "priya.sharma@company.com", "password": "a-strong-password" }
```

**Response `200`** — same shape as `set-password`'s response
(`token` + `user`).

**Response `401`**
```json
{ "message": "Invalid email or password." }
```

---

## `POST /v1/auth/logout`

Invalidates the session token server-side (revoke/blacklist it — the
client clears its local cache regardless of the response).

**Request** — no body; `Authorization: Bearer <token>` header only.

**Response `204`** — empty.

---

## `GET /v1/auth/me`

Returns the current user for the session token in the `Authorization`
header — used to validate a cached session on cold start.

**Response `200`** — the user object (see above).

**Response `401`** — token invalid/expired/revoked; the client treats
this as "not logged in" and forces a logout locally.

---

## Notes for implementation

- **Idempotency**: `check-email` and `otp/request` should be safe to
  call repeatedly (rate-limit `otp/request`, don't error on repeats of
  `check-email`).
- **Audit**: every state-changing call here (account activated, login,
  logout) should be written to the server-side audit log — the client
  mirrors this with its own local `AuditEvent` table
  (`packages/core/lib/src/audit/`) for the module column `"Auth"`.
- **Password policy**: enforce server-side (client does not duplicate
  policy rules) — return `400` with a clear `message` on rejection so
  the client can surface it directly in the set-password step.
