# GateFlow — Flutter Monorepo

Enterprise-grade Flutter project structure for GateFlow (Asset Register
& Lifecycle Management + Gate Pass Approval & Material Movement
Control + Visitor Management & Smart Reception), targeting **Android,
iOS, Web, Windows, and macOS** from one codebase.

This is a **scaffold**, not a finished app: it is the architecture,
directory structure, DI wiring, offline-first plumbing, and one fully
implemented reference feature (Asset Management) that a team builds
100+ screens on top of. See `ARCHITECTURE.md` for the full rationale;
this file is the "how do I run it" quick start.

## Directory map

```
gateflow_flutter/
├── apps/
│   └── gateflow_app/          # The runnable app shell — composition root for DI + routing.
├── packages/
│   ├── core/                  # Error handling, networking, offline DB/sync, DI, theming, RBAC.
│   ├── design_system/         # Shared adaptive widgets + design tokens.
│   └── features/
│       ├── feature_auth/                  # Login (SSO/OTP), session.
│       ├── feature_asset_management/      # ★ Reference implementation — copy this pattern.
│       ├── feature_gate_pass/             # Scaffolded — domain layer + stub UI.
│       └── feature_visitor_management/    # Scaffolded — domain layer + stub UI.
├── melos.yaml                 # Monorepo task runner (bootstrap/analyze/test/build_runner).
├── analysis_options.yaml      # One shared, strict lint policy for every package.
└── .github/workflows/ci.yaml  # Analyze + test, then 5 independent per-platform build jobs.
```

## Getting started

```bash
# 1. Install Melos (monorepo tool) once, globally.
dart pub global activate melos

# 2. Link all local packages together (like a monorepo-aware `pub get`).
melos bootstrap

# 3. Generate Drift tables, injectable DI graphs, and freezed models.
melos run build_runner

# 4. Run the app (dev flavor) on your platform of choice.
cd apps/gateflow_app
flutter run -t lib/main_dev.dart -d chrome      # Web
flutter run -t lib/main_dev.dart -d macos       # macOS
flutter run -t lib/main_dev.dart -d windows     # Windows
flutter run -t lib/main_dev.dart -d <device-id> # Android / iOS
```

## Common tasks

| Task | Command |
|---|---|
| Analyze every package | `melos run analyze` |
| Run every package's tests | `melos run test` |
| Regenerate codegen (Drift/injectable/freezed) | `melos run build_runner` |
| Format the whole workspace | `melos run format` |

## Adding feature #101

1. Copy `packages/features/feature_asset_management` as a starting
   point — rename the package, and gut the `data`/`domain`/`presentation`
   contents for your new entity.
2. Add the new package path to `apps/gateflow_app/pubspec.yaml`.
3. Add its routes to `apps/gateflow_app/lib/routing/app_router.dart`.
4. Run `melos bootstrap && melos run build_runner`.

No other package needs to change — that isolation is the point (see
`ARCHITECTURE.md`, "Why a monorepo of packages, not one big app").
