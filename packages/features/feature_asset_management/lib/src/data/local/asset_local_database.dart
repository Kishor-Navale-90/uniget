import 'package:core/core.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import 'asset_table.dart';

part 'asset_local_database.g.dart';

/// This feature's own Drift database — schema-versioned and migrated
/// independently of every other feature (see `core/database/app_database.dart`
/// for why tables aren't centralized). A team can add a column to
/// `AssetTable` and ship a migration without touching, or even
/// redeploying, feature_gate_pass or feature_visitor_management.
@DriftDatabase(tables: [AssetTable])
class AssetLocalDatabase extends _$AssetLocalDatabase {
  AssetLocalDatabase() : super(openSqliteConnection('asset_management'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(onCreate: (m) => m.createAll());

  Stream<List<AssetTableData>> watchAll({String? departmentId}) {
    final query = select(assetTable);
    if (departmentId != null) {
      query.where((t) => t.departmentId.equals(departmentId));
    }
    return query.watch();
  }

  Future<AssetTableData?> getById(String id) =>
      (select(assetTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> upsertAll(List<AssetTableCompanion> rows) => batch((b) {
        b.insertAllOnConflictUpdate(assetTable, rows);
      });

  Future<void> upsertOne(AssetTableCompanion row) =>
      into(assetTable).insertOnConflictUpdate(row);
}

@module
abstract class AssetDatabaseModule {
  @lazySingleton
  AssetLocalDatabase assetLocalDatabase() => AssetLocalDatabase();
}
