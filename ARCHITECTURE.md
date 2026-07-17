# UNIGET — Architecture Rationale

This document explains *why* the project is shaped the way it is. For
*how to run it*, see `README.md`. For the product requirements this
architecture serves, see the companion `GateFlow_Combined_Concept_and_Architecture.docx`
and `GATEFLOW_PROJECT_CONTEXT.md` (the original concept documents this
project started from — role names and some workflows have since
evolved under the UNIGET brand, see the per-module `docs/api/*.md`
contracts for the current source of truth).

## Why a monorepo of packages, not one big app

A single `lib/` folder with 100+ screens and several developers
working simultaneously fails in three specific ways: merge conflicts
concentrate in shared files (one giant `router.dart`, one giant DI
setup), it's impossible to enforce "the Visitor Management team can't
reach into Asset Management's internals" other than by convention, and
CI has to rebuild/retest everything for every change.

Splitting into **Melos-managed packages** (`core`, `design_system`, one
package per feature, and the `apps/uniget_app` shell) fixes all
three: package boundaries are enforced by the Dart compiler, not code
review discipline; a feature package's public surface is exactly its
barrel file (`feature_x.dart`) — everything under `src/` is invisible
to other packages; and CI/tooling can operate per-package.

Each feature package is small enough for one team/developer to own
end-to-end (data + domain + presentation), which is what actually lets
"multiple developers working simultaneously" mean *in parallel on
different packages*, not *in parallel on the same files*.

## Clean Architecture — the layer rule

Every feature package has exactly three layers, and dependencies only
ever point inward:

```
presentation  →  domain  ←  data
   (Bloc,          (entities,     (models, datasources,
    pages,          repository     repository impl)
    widgets)        interfaces,
                    usecases)
```

`domain` has **zero** imports of Flutter, Dio, or Drift — it's pure
Dart. That's not a style preference, it's what makes a `UseCase`
testable in milliseconds with no mocks beyond a fake repository (see
`feature_asset_management/test/src/domain/usecases/transfer_asset_test.dart`).
`presentation` never imports a datasource or Drift row type directly —
only `domain` entities and repository *interfaces*. `data` is the only
layer allowed to know both "network" and "local cache" exist
simultaneously (see `AssetRepositoryImpl`).

## SOLID, concretely

- **Single Responsibility** — one class per action. `TransferAsset` does
  exactly one thing; it doesn't also validate department permissions
  or fetch the asset list. Look at `domain/usecases/*.dart` in
  `feature_asset_management`: one file, one class, one job.
- **Open/Closed** — adding gate-pass-specific approval rules doesn't
  require modifying `core`'s `SyncEngine` or `AuthInterceptor`; you
  register a new `SyncHandler` or add a new `RouteGuard` instance.
- **Liskov Substitution** — any `AssetRepository` implementation (the
  real `AssetRepositoryImpl`, or a `FakeAssetRepository` in tests) is
  interchangeable everywhere the interface is used.
- **Interface Segregation** — `AuthRepository` only exposes what auth
  needs; it doesn't bolt on unrelated user-management methods.
- **Dependency Inversion** — `AssetListBloc` depends on `WatchAssets`
  (an abstraction), which depends on `AssetRepository` (an
  abstraction). The concrete `AssetRepositoryImpl` is only ever
  mentioned once, in its own `@LazySingleton(as: AssetRepository)`
  annotation — nowhere else in the codebase.

## Repository Pattern — the one class that's allowed to be "impure"

`AssetRepositoryImpl` is deliberately the single seam between the pure
domain layer and the messy realities of network + local storage. It
decides: serve from cache first (offline-first), when to hit the
network, how to reconcile the two, and how to translate exceptions
into `Failure` values. Every feature's repository follows this same
shape — see its class-level doc comment for the exact contract.

## Dependency Injection — `get_it` + `injectable`

Every injectable class is annotated at its declaration
(`@injectable`, `@LazySingleton(as: SomeInterface)`, or `@module` for
third-party types) — nobody hand-writes a giant `GetIt` registration
file. `injectable_generator` scans every package the app depends on
and generates `injection.config.dart` at the app-shell composition
root (`apps/uniget_app/lib/di/injection.dart`).

This is what makes feature package addition/removal a one-line
`pubspec.yaml` change (see README, "Adding feature #101") instead of a
multi-file registration change — and what makes every Bloc trivially
testable by constructing it directly with mock dependencies (see
`bloc_test` examples) rather than needing a `GetIt` container in tests.

## Offline-First Architecture

Three pieces work together:

1. **Reads are reactive and local-first.** Every `watch*` repository
   method returns a `Stream` sourced from that feature's own Drift
   database — never awaited against the network. The UI is never
   blocked on connectivity.
2. **Writes are optimistic + queued.** A mutation (asset transfer,
   gate pass request, visitor check-in) updates the local row and
   inserts a row into `core`'s shared `SyncQueue` table, in that
   order, inside the repository. The UI treats this as success
   immediately.
3. **`SyncEngine` (in `core`) drains the queue** the moment
   connectivity returns (or on a periodic sweep), calling whichever
   feature's registered `SyncHandler` matches the queued row's
   `entityType`. A 409 from the server becomes a `SyncConflict`
   instead of crashing the sync loop; the row is marked `conflict` for
   the feature to resolve (see `AssetRepositoryImpl`'s
   `_AssetSyncHandler`).

**Why each feature owns its own Drift database instead of one shared
schema:** Drift requires every table to be declared on a single
`@DriftDatabase` class. Centralizing that in `core` would force `core`
to import every feature's table definitions — inverting the
dependency direction (features depend on core, never the reverse) and
making `core` impossible to release or version independently. Instead,
`core` owns only the generic `SyncQueue` table and a shared
`openSqliteConnection()` helper; each feature's database is scoped,
schema-versioned, and migrated independently. The trade-off — no raw
SQL joins across feature tables — is deliberate: cross-feature reads
are composed at the repository/use-case layer, which keeps 100+
screens across many packages independently testable and deployable.

**Why Drift over Isar/Hive:** Drift has a real SQL surface and a
genuine (if newer) Wasm/IndexedDB backend for Flutter Web, so the same
schema and query code runs on mobile, desktop, *and* web — a hard
requirement here.

## BLoC Pattern — one Bloc per screen-slice

The rule enforced throughout every feature package: **a Bloc owns
exactly one screen or one cohesive UI slice**, never a whole feature.
`feature_asset_management` has `AssetListBloc` (the list screen) and a
*separate* `AssetTransferBloc` (the transfer action), even though both
operate on "assets" — they have different lifecycles (list persists
across the screen, transfer is transient per action) and testing them
separately is simpler than one mega-Bloc with a dozen event types.

Every Bloc's event handler calls exactly one UseCase and does no
business logic of its own — it only maps `Either<Failure, T>` onto a
UI state via the `when()` extension in `core/utils/result_extensions.dart`.
This is what keeps Blocs thin enough that adding screen #101 means
writing a new, small Bloc, not extending an existing 500-line one.

## Adaptive UI, not per-platform screens

`design_system`'s `AdaptiveScaffold` renders a bottom nav bar on mobile
and a nav rail on desktop/web from the *same* destination list and the
*same* route tree (`apps/uniget_app/lib/routing/app_router.dart`).
Screens are written once; `core/theme/responsive.dart`'s breakpoints
decide layout, not a forked widget tree per platform. This is what
makes "100+ screens, 5 platforms" tractable — it is not 500 screens.

## Security & RBAC, enforced structurally

`SessionManager` (core) is the single source of truth for the signed-in
user's role and department. `RouteGuard`/`RoleGuard` (core) are
declared per-route in `app_router.dart`'s `redirect`, not as `if`
checks scattered inside page widgets — so a new protected route can't
forget its check. `AuthInterceptor` (core) attaches the session token
to every outgoing request and force-logs-out on 401. The actual
department-scoped data filtering happens server-side (see the
companion Solution Architecture Document, §19) — the client-side guard
is a UX nicety, not the security boundary.

## What's intentionally NOT in this scaffold

- Concrete Firebase/REST endpoint implementations — `Dio` calls are
  written against `AppConstants.apiBaseUrl` and realistic-looking
  paths, but there is no backend behind them yet.
- `feature_gate_pass` and `feature_visitor_management`'s data and
  presentation layers — their domain layers are scaffolded; follow
  `feature_asset_management`'s pattern (see its README) to complete
  them.
- Generated code (`*.g.dart`, `*.config.dart`, `*.freezed.dart`) —
  run `melos run build_runner` after cloning.
- CI secrets / signing configs for store releases.

These are deliberate scope cuts so the architecture itself — the part
that's expensive to change later — is reviewable on its own.
