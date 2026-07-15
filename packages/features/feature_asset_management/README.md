# feature_asset_management — the reference feature module

This package is the fully-worked template. Every other feature package
(`feature_gate_pass`, `feature_visitor_management`, and any of the 100+
screens beyond them) should copy this exact shape:

```
lib/src/
  domain/                     <- pure Dart, zero Flutter/Drift/Dio imports
    entities/                 <- Asset, AssetStatus, AssetDashboardStats
    repositories/             <- AssetRepository (abstract contract)
    usecases/                 <- one class per action (GetAssetById, TransferAsset, ...)
  data/
    models/                   <- AssetModel: maps API JSON <-> Drift row <-> entity
    local/                    <- this feature's OWN Drift database + table
    datasources/               <- AssetRemoteDataSource (Dio), AssetLocalDataSource (Drift)
    repositories/              <- AssetRepositoryImpl: the ONLY class that knows
                                   both "network" and "cache" exist; owns the
                                   offline-first read/write pattern and registers
                                   this feature's SyncHandler with core's SyncEngine
  presentation/
    bloc/<slice>/              <- one Bloc per screen-slice (list, transfer, ...)
    pages/                     <- route targets
    widgets/                   <- feature-local widgets (shared ones live in design_system)
  di/                          <- usually empty; @injectable annotations do the work
```

## The offline-first pattern, in one paragraph

Reads are a `Stream<Either<Failure, T>>` sourced from this feature's own
local Drift database — never from the network directly. Writes apply an
optimistic local update and enqueue a row in `core`'s shared `SyncQueue`
in the same step, then return success immediately. A registered
`SyncHandler` (see the bottom of `asset_repository_impl.dart`) replays
queued mutations against the API once connectivity returns; a 409 from
the server surfaces as a `SyncConflict`, not a crash.

## Why this feature owns its own database instead of sharing one

Drift requires every table to be declared on a single `@DriftDatabase`
class. If `core` declared that class, it would have to import every
feature's tables — inverting the dependency direction feature packages
depend on core, never the reverse. Instead, each feature owns its own
Drift database (own file, own schema version), and `core` only
contributes the generic `SyncQueue` table plus the shared
`openSqliteConnection()` helper so every feature's database is
configured identically. Cross-feature reads are composed at the
repository/use-case layer, not via a raw SQL join.
