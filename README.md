# UNIGET — Flutter Monorepo

Enterprise-grade Flutter project structure for UNIGET (Asset Register
& Lifecycle Management + Gate Pass Approval & Material Movement
Control + Visitor Management & Smart Reception), targeting **Android
and iOS** as first-class native targets, with macOS/Windows desktop
shells scaffolded (see **Known issues** below for current platform
caveats).

Rebranded from "GateFlow" — if you see that name anywhere (old docs,
screenshots, a stray comment), it's stale.

This is a **scaffold under active build-out**, not a finished app: it's
the architecture, directory structure, DI wiring, offline-first
plumbing, and one fully implemented reference feature (Asset
Management) plus a fully implemented auth flow that a team builds
100+ screens on top of. See `ARCHITECTURE.md` for the full rationale;
this file is the "how do I run it" quick start.

## Directory map

```
gateflow_flutter/
├── apps/
│   └── uniget_app/            # The runnable app shell — composition root for DI + routing.
│       ├── android/           # applicationId / namespace: com.softdel.unigate
│       ├── ios/                # PRODUCT_BUNDLE_IDENTIFIER: com.softdel.unigate; GoogleService-Info.plist lives in ios/Runner/
│       ├── macos/, windows/, web/
│       └── lib/firebase_options.dart  # Hand-authored (not flutterfire-CLI-generated) — android + ios only
├── packages/
│   ├── core/                  # Error handling, networking, offline DB/sync, DI, theming, RBAC, audit log, push notifications.
│   ├── design_system/         # Shared adaptive widgets + design tokens.
│   └── features/
│       ├── feature_auth/                  # Registration (admin-added email → OTP → set password) + login. No SSO.
│       ├── feature_asset_management/      # ★ Reference implementation — copy this pattern.
│       ├── feature_gate_pass/             # Scaffolded — domain layer + stub UI.
│       └── feature_visitor_management/    # Scaffolded — domain layer + stub UI.
├── docs/api/                  # Mock API contracts for the backend team (auth.md so far).
├── melos.yaml                 # Monorepo task runner (bootstrap/analyze/test/build_runner).
├── pubspec.yaml                # Workspace root — also the ONLY place dependency_overrides may live (see below).
├── analysis_options.yaml      # One shared, strict lint policy for every package.
└── .github/workflows/ci.yaml  # Analyze + test, then 5 independent per-platform build jobs.
```

## Prerequisites

- **Flutter 3.38.5** (or compatible) — install however you like; this
  repo doesn't pin a version manager.
- **Dart SDK ≥ 3.6.0** — required because this repo is a native
  [Dart pub workspace](https://dart.dev/tools/pub/workspaces) (see
  root `pubspec.yaml`'s `workspace:` field). This is *not optional* —
  without it, cross-package dependency injection silently breaks (see
  "Dependency injection across packages" below).
- Xcode + CocoaPods (`pod` on PATH) for iOS/macOS.
- Android SDK (`ANDROID_HOME` set, `platform-tools`/`emulator` on
  PATH) for Android.

## Getting started

```bash
# 1. Install Melos (monorepo tool) once, globally.
dart pub global activate melos

# 2. Resolve the whole workspace in one shot (native Dart pub
#    workspace — this replaces the old "melos bootstrap does path
#    overrides" model; melos bootstrap still works too and is
#    equivalent here).
flutter pub get

# 3. Generate Drift tables, injectable DI graphs, and freezed models —
#    MUST run in dependency order (core → design_system → features →
#    app shell). `melos run build_runner` now enforces this via
#    `concurrency: 1` — don't run build_runner per-package by hand
#    unless you preserve that same order yourself.
melos run build_runner

# 4. Add your own Firebase config if you don't already have
#    google-services.json / GoogleService-Info.plist in place (see
#    "Firebase / push notifications" below) — the app will crash on
#    Android/iOS launch without them.

# 5. Run the app (dev flavor) on your platform of choice.
cd apps/uniget_app
flutter run -t lib/main_dev.dart -d chrome      # Web
flutter run -t lib/main_dev.dart -d macos       # macOS
flutter run -t lib/main_dev.dart -d windows     # Windows
flutter run -t lib/main_dev.dart -d <device-id> # Android / iOS
```

Web and macOS are **not currently runnable** — see "Known issues."

## Dependency injection across packages

Every package's own classes are annotated `@injectable` /
`@LazySingleton` / `@module` as usual — **but** a single
`dart run build_runner build` invocation only ever discovers
annotations within the package you ran it from. The app's own
`@InjectableInit` cannot see across package boundaries by itself, no
matter how many packages it depends on — this was silently broken
(GetIt was completely empty at runtime) until this was diagnosed and
fixed.

The fix has two parts, both already in place — you don't need to touch
either when adding an ordinary new `@injectable` class, only when
adding a **new package**:

1. **A native Dart pub workspace** (root `pubspec.yaml`'s `workspace:`
   list) so every package shares one `.dart_tool` and one dependency
   resolution. `dependency_overrides` (e.g. the `dart_style` pin
   needed for `drift_dev` + `bloc_test` to compile together) can now
   **only** be declared in the root `pubspec.yaml` — member packages
   are not allowed their own.
2. **`injectable`'s micro-package pattern**: every package with
   annotated classes has one file like
   `core/lib/src/di/core_injectable_init.dart` —
   `@InjectableInit.microPackage()` on an otherwise-empty function,
   generating a `<Package>PackageModule` class. The app's
   `apps/uniget_app/lib/di/injection.dart` explicitly instantiates and
   calls each package's module, **in dependency order** (`core` first,
   since every feature resolves types like `Dio`/`SessionManager` that
   only `core`'s module provides).

**Adding a new package that needs its own DI graph:** copy the
`core_injectable_init.dart` pattern (see that file's doc comment),
export the generated `<name>_injection.module.dart` from your
package's barrel, and add one line to `apps/uniget_app/lib/di/injection.dart`
calling your new `<Package>PackageModule().init(gh)` — after `core`'s,
before anything that depends on your package.

## Auth flow

No SSO, no self-service sign-up. A Super Admin (or, once
`feature_employee_management` exists — not built yet — a manager)
pre-adds an employee with their **official email**; the account exists
but is inactive. The employee then self-activates:

```
check-email → otp/request → otp/verify → set-password (auto-login)
```

After that, `POST /v1/auth/login` (email + password) is the regular
sign-in path. Full endpoint contracts for the backend team: `docs/api/auth.md`.
Roles (`core/lib/src/auth/session.dart`'s `UserRole` enum):
`superAdmin, manager, itAdmin, adminTeam, security, employee` —
visitors never get a persistent account (guest session only).

## Firebase / push notifications

`firebase_core` + `firebase_messaging` are wired for **Android and iOS
only** (no web/macOS/Windows Firebase app registered). Bundle/package
ID is **`com.softdel.unigate`** — note the spelling (unig**ate**, not
unig**et**) — chosen to match an existing Firebase project
(`unigate-dba17`); don't "fix" it back to `uniget` without also
re-registering apps in the Firebase console.

- `google-services.json` → `apps/uniget_app/android/app/google-services.json`
- `GoogleService-Info.plist` → `apps/uniget_app/ios/Runner/GoogleService-Info.plist`
  (also wired into the Xcode project's Resources build phase — a
  filesystem copy alone won't get it bundled)
- `apps/uniget_app/lib/firebase_options.dart` is hand-authored from
  those two files, not `flutterfire configure`-generated

**Still needs your action, not code:** open `ios/Runner.xcworkspace` in
Xcode once and add the "Push Notifications" capability (sets up
entitlements against your own Apple Developer signing setup), and
upload an APNs key to the Firebase console under Cloud
Messaging — otherwise iOS push won't arrive regardless of code
correctness.

## Known issues (environment, not app code)

- **macOS**: `flutter run -d macos` currently fails at the CodeSign
  step with `resource fork, Finder information, or similar detritus
  not allowed`. This reproduces even on a from-scratch build and
  survives `xattr -cr`/`COPYFILE_DISABLE=1` — it looks like a macOS
  Gatekeeper "provenance" tracking quirk on this specific macOS/Xcode
  combination (macOS 26.2 / Xcode 26.2), not an app bug. Workaround:
  build/run via Android or iOS instead; if you need macOS specifically,
  try opening the project in Xcode directly and building from there
  (Xcode's own signing flow sometimes resolves this where the CLI
  doesn't) — flag this to whoever owns this Mac's setup if it persists.
- **Web**: does not compile. `drift`'s `sqlite_connection.dart` uses
  `NativeDatabase` (`dart:ffi`-based) unconditionally — despite this
  repo's docs claiming "works on mobile, desktop AND web via
  sqlite3/wasm," no conditional web implementation (`drift`'s WASM/
  `sqlite3.wasm` setup) has actually been written yet. Needs proper
  conditional-import work (`sqlite_connection_native.dart` /
  `sqlite_connection_web.dart`) before `-d chrome` will work — not a
  quick fix, tracked as a real gap, not attempted yet.
- **This machine's shell**: `~/.zshenv` has a corrupted line (a stray
  `//` before `export PATH=...`) that breaks the intended Flutter SDK
  PATH export on every shell init (harmless-looking error on every
  command). Flutter lives at
  `/Users/rupeshkumar/Projects/Flutter_SDK/flutter_3.38.5/bin` —
  invoke it by full path, or `export PATH` manually, until that line
  is fixed.

## Common tasks

| Task | Command |
|---|---|
| Analyze every package | `melos run analyze` |
| Run every package's tests | `melos run test` |
| Regenerate codegen (Drift/injectable/freezed), in the required order | `melos run build_runner` |
| Format the whole workspace | `melos run format` |
| Wipe all build artifacts | `melos run clean` |

## Adding feature #101

1. Copy `packages/features/feature_asset_management` as a starting
   point — rename the package, and gut the `data`/`domain`/`presentation`
   contents for your new entity.
2. Add the new package path to `apps/uniget_app/pubspec.yaml`
   **and** to the root `pubspec.yaml`'s `workspace:` list.
3. Copy the micro-package DI trigger pattern (see "Dependency
   injection across packages" above) and add one line to
   `apps/uniget_app/lib/di/injection.dart` calling your new module.
4. Add its routes to `apps/uniget_app/lib/routing/app_router.dart`.
5. Run `flutter pub get && melos run build_runner`.

Everything else stays isolated — that's the point (see
`ARCHITECTURE.md`, "Why a monorepo of packages, not one big app").
