import 'package:drift/drift.dart';

/// This feature's own local cache table — offline-first reads
/// (`AssetRepositoryImpl.watchAssets`) query this directly instead of
/// hitting the network, and the UI updates reactively whenever a
/// background sync writes to it.
class AssetTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get category => text()();
  TextColumn get qrCode => text()();
  TextColumn get status => text()(); // stored as AssetStatus.name
  TextColumn get departmentId => text()();
  TextColumn get departmentName => text()();
  TextColumn get assignedToUserId => text().nullable()();
  TextColumn get assignedToUserName => text().nullable()();
  TextColumn get location => text().nullable()();
  DateTimeColumn get warrantyExpiry => dateTime().nullable()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  /// True while a locally-made change (e.g. a transfer) is still
  /// sitting in `core`'s shared SyncQueue awaiting confirmation from
  /// the server — surfaced in the UI as an "unsynced" badge.
  BoolColumn get hasPendingLocalChanges =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
