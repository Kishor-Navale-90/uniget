import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../database/app_database.dart';

/// The shared, append-only audit trail (concept doc: "Unified audit
/// trail — one exportable, timestamped log across all 3 modules").
///
/// Every feature repository calls [record] from the same write path
/// that does its optimistic local write + `SyncQueue` insert (see
/// `feature_asset_management`'s `AssetRepositoryImpl` for the
/// reference pattern) — this is what powers both the Audit Log screen
/// and the Gate/Movement Log screen without any feature package ever
/// importing another feature's tables.
@lazySingleton
class AuditLogger {
  AuditLogger(this._db);
  final AppDatabase _db;

  Future<void> record({
    required String module,
    required String event,
    required String entityType,
    required String entityId,
    String? entityLabel,
    String? actorId,
    String? actorName,
    String? departmentId,
  }) {
    return _db.into(_db.auditEvent).insert(
          AuditEventCompanion.insert(
            module: module,
            event: event,
            entityType: entityType,
            entityId: entityId,
            entityLabel: Value(entityLabel),
            actorId: Value(actorId),
            actorName: Value(actorName),
            departmentId: Value(departmentId),
          ),
        );
  }

  /// Live audit trail, optionally filtered by [module] (e.g. "Asset",
  /// "GatePass", "Visitor") and/or [departmentId] — feeds both the
  /// cross-module Audit Log screen and per-module activity widgets.
  Stream<List<AuditEventData>> watchAuditLog({String? module, String? departmentId}) {
    final query = _db.select(_db.auditEvent)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    if (module != null) {
      query.where((t) => t.module.equals(module));
    }
    if (departmentId != null) {
      query.where((t) => t.departmentId.equals(departmentId));
    }
    return query.watch();
  }
}
