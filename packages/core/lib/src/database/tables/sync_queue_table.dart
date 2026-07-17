import 'package:drift/drift.dart';

/// Every offline-created/updated mutation (asset transfer, gate pass
/// request, visitor check-in, etc.) is written here FIRST, in the same
/// local transaction as the optimistic UI-facing row. The SyncEngine
/// drains this table in FIFO order once connectivity returns.
///
/// This table lives in `core` (not per-feature) because the sync
/// engine that drains it is a cross-cutting concern — but the
/// `entityType`/`payload` columns keep it feature-agnostic.
class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// e.g. "asset", "gate_pass", "visitor" — used to route the payload
  /// to the right feature repository on replay.
  TextColumn get entityType => text()();

  /// e.g. "create", "update", "transfer" — the operation to replay.
  TextColumn get operation => text()();

  /// JSON-encoded request body for the queued mutation.
  TextColumn get payload => text()();

  /// Client-generated UUID so the server can dedupe if the same
  /// mutation is replayed twice (e.g. app killed mid-sync).
  TextColumn get idempotencyKey => text()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  IntColumn get retryCount => integer().withDefault(const Constant(0))();

  /// pending | in_flight | failed | conflict
  TextColumn get status => text().withDefault(const Constant('pending'))();

  TextColumn get lastError => text().nullable()();
}
