import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../audit/audit_event_table.dart';
import 'sqlite_connection.dart';
import 'tables/sync_queue_table.dart';

part 'app_database.g.dart';

/// The **cross-cutting** offline-first database — today just the
/// shared [SyncQueue] that [SyncEngine] drains and the shared
/// [AuditEvent] trail that [AuditLogger] writes to. Deliberately does
/// NOT hold feature entity tables (assets, gate passes, visitors): if
/// it did, `core` would have to import every feature package to know
/// their table classes, which would invert the dependency graph
/// (features depend on core, never the reverse) and make core
/// impossible to release independently.
///
/// Instead, **each feature package owns its own Drift database** with
/// its own tables and its own schema version (see
/// `feature_asset_management/lib/src/data/local/asset_local_database.dart`
/// for the reference), opened via [openSqliteConnection] below so
/// every feature's database is configured identically across mobile,
/// desktop, and web. Cross-feature reads (e.g. "assets currently out
/// AND awaiting gate-pass approval") are composed at the
/// repository/use-case layer instead of a raw SQL join — a deliberate
/// trade-off that keeps 100+ screens across many packages independently
/// versionable and testable.
@DriftDatabase(tables: [SyncQueue, AuditEvent])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? openSqliteConnection('uniget_core'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(onCreate: (m) => m.createAll());
}

@module
abstract class DatabaseModule {
  @lazySingleton
  AppDatabase database() => AppDatabase();
}
