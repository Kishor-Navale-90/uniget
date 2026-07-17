import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../database/app_database.dart';
import '../utils/logger.dart';
import 'connectivity_service.dart';
import 'sync_task.dart';

/// The offline-first heartbeat of the app.
///
/// Every mutation in every feature repository follows the same
/// pattern (see feature_asset_management's AssetRepositoryImpl for
/// the reference implementation):
///
///   1. Write optimistically to the local Drift table (UI updates
///      instantly, no spinner).
///   2. Enqueue a [SyncTask] row in the shared `sync_queue` table in
///      the SAME local transaction, so the two can never drift apart.
///   3. The SyncEngine, triggered by connectivity changes or a timer,
///      drains the queue FIFO and calls the matching [SyncHandler].
///   4. On success: delete the queue row. On transient failure: bump
///      retryCount with backoff. On a 409 conflict: mark the row
///      `conflict` and surface it to the feature's repository, which
///      decides the resolution policy (e.g. last-write-wins for an
///      asset's "last known location", but a "gate pass approval" is
///      never auto-resolved — it re-routes for approval).
///
/// This class only knows about the generic queue; it has no idea what
/// an "asset" or "visitor" is, which is what lets 100+ screens across
/// many feature packages share one sync mechanism without core
/// depending on any of them (dependency inversion at the package
/// level, not just the class level).
@lazySingleton
class SyncEngine {
  SyncEngine(this._db, this._connectivity) {
    _connSub = _connectivity.onStatusChanged.listen((online) {
      if (online) drainQueue();
    });
  }

  final AppDatabase _db;
  final ConnectivityService _connectivity;
  final Map<String, SyncHandler> _handlers = {};
  late final StreamSubscription<bool> _connSub;
  bool _isDraining = false;

  /// Feature packages call this once, at DI composition time
  /// (`configureDependencies`), to plug their handler in.
  void registerHandler(SyncHandler handler) {
    _handlers[handler.entityType] = handler;
  }

  /// Number of mutations still waiting to reach the server — feature
  /// UIs bind this to an "N changes pending sync" indicator.
  Stream<int> watchPendingCount() {
    final query = _db.select(_db.syncQueue)..where((t) => t.status.equals('pending'));
    return query.watch().map((rows) => rows.length);
  }

  Future<void> drainQueue() async {
    if (_isDraining) return;
    _isDraining = true;
    try {
      final pending = await (_db.select(_db.syncQueue)
            ..where((t) => t.status.equals('pending'))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .get();

      for (final row in pending) {
        final handler = _handlers[row.entityType];
        if (handler == null) {
          appLogger.w('No SyncHandler registered for "${row.entityType}" — skipping');
          continue;
        }
        await _replayOne(row, handler);
      }
    } finally {
      _isDraining = false;
    }
  }

  Future<void> _replayOne(SyncQueueData row, SyncHandler handler) async {
    await (_db.update(_db.syncQueue)..where((t) => t.id.equals(row.id)))
        .write(const SyncQueueCompanion(status: Value('in_flight')));

    try {
      final task = SyncTask(
        id: row.id,
        entityType: row.entityType,
        operation: row.operation,
        payload: jsonDecode(row.payload) as Map<String, dynamic>,
        idempotencyKey: row.idempotencyKey,
        retryCount: row.retryCount,
      );
      await handler.replay(task);
      await (_db.delete(_db.syncQueue)..where((t) => t.id.equals(row.id))).go();
    } on SyncConflict catch (e) {
      await (_db.update(_db.syncQueue)..where((t) => t.id.equals(row.id))).write(
        SyncQueueCompanion(status: const Value('conflict'), lastError: Value(e.message)),
      );
    } catch (e) {
      final nextRetry = row.retryCount + 1;
      await (_db.update(_db.syncQueue)..where((t) => t.id.equals(row.id))).write(
        SyncQueueCompanion(
          status: const Value('pending'),
          retryCount: Value(nextRetry),
          lastError: Value(e.toString()),
        ),
      );
    }
  }

  void dispose() => _connSub.cancel();
}

/// Thrown by a [SyncHandler] when the server rejects a replay because
/// the record changed since the mutation was queued (HTTP 409).
class SyncConflict implements Exception {
  SyncConflict(this.message, {this.serverVersion});
  final String message;
  final Map<String, dynamic>? serverVersion;
}
