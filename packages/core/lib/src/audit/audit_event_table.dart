import 'package:drift/drift.dart';

/// The shared, append-only audit trail every module writes to — the
/// concept doc's "Unified audit trail: one exportable, timestamped log
/// across all 3 modules." Lives in `core` (like [SyncQueue]) so no
/// feature package ever has to import another feature's tables to
/// build a cross-module Audit Log or Movement Log screen.
///
/// Rows are only ever inserted, never updated or deleted — that's what
/// makes this an audit trail rather than just another cache table.
class AuditEvent extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// e.g. "Asset", "GatePass", "Visitor", "Employee", "Auth" — which
  /// module this event belongs to, used to filter the Audit Log screen.
  TextColumn get module => text()();

  /// Human-readable event description, e.g. "Asset transferred",
  /// "Gate pass approved", "Visitor checked in".
  TextColumn get event => text()();

  /// e.g. "asset", "gate_pass", "visitor" — mirrors [SyncQueue]'s
  /// `entityType` convention.
  TextColumn get entityType => text()();

  TextColumn get entityId => text()();

  /// Denormalized label (asset name, gate pass number, visitor name...)
  /// so the Audit/Movement Log screen never needs a cross-feature join.
  TextColumn get entityLabel => text().nullable()();

  /// Null for system-generated events (e.g. an auto-expiry sweep).
  TextColumn get actorId => text().nullable()();
  TextColumn get actorName => text().nullable()();

  /// Null for org-wide events (e.g. raised by Super Admin or Security).
  TextColumn get departmentId => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
