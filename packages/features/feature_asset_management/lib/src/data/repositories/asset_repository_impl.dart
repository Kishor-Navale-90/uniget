import 'dart:async';
import 'dart:convert';

import 'package:core/core.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/asset.dart';
import '../../domain/entities/asset_dashboard_stats.dart';
import '../../domain/entities/asset_status.dart';
import '../../domain/repositories/asset_repository.dart';
import '../datasources/asset_local_datasource.dart';
import '../datasources/asset_remote_datasource.dart';

/// The reference offline-first repository — every other feature's
/// repository (gate pass, visitor) should follow this exact shape:
///
///  * Reads are served from the local cache via [AssetLocalDataSource]
///    and returned as a `Stream`, so the UI never blocks on network.
///  * [refreshFromRemote] pulls fresh data in the background and
///    reconciles it into the cache — the stream above then emits
///    again automatically because Drift's `.watch()` is reactive.
///  * Writes ([transferAsset]) apply an optimistic local update AND
///    enqueue a row in `core`'s shared `SyncQueue`, in that order, so
///    the UI reflects the change instantly whether or not the device
///    is online.
@LazySingleton(as: AssetRepository)
class AssetRepositoryImpl implements AssetRepository {
  AssetRepositoryImpl(
    this._remote,
    this._local,
    this._networkInfo,
    this._db,
    this._syncEngine,
  ) {
    // Registering here (rather than requiring the app shell to know
    // this feature exists) is what lets feature_asset_management be
    // dropped into, or removed from, the app with a single pubspec
    // line — see ARCHITECTURE.md, "Feature package independence".
    _syncEngine.registerHandler(_AssetSyncHandler(_remote));
  }

  final AssetRemoteDataSource _remote;
  final AssetLocalDataSource _local;
  final NetworkInfo _networkInfo;
  final AppDatabase _db;
  final SyncEngine _syncEngine;
  static const _uuid = Uuid();

  @override
  Stream<Either<Failure, List<Asset>>> watchAssets({String? departmentId}) {
    return _local
        .watchAssets(departmentId: departmentId)
        .map<Either<Failure, List<Asset>>>(
          (models) => Right(models.map((m) => m.toEntity()).toList(growable: false)),
        )
        .handleError((Object e) => Left<Failure, List<Asset>>(CacheFailure(e.toString())));
  }

  @override
  Future<Either<Failure, Asset>> getAssetById(String id) async {
    try {
      final cached = await _local.getAssetById(id);
      if (cached != null) return Right(cached.toEntity());
      if (!await _networkInfo.isConnected) {
        return const Left(CacheFailure('Asset not cached and device is offline'));
      }
      final remoteModel = await _remote.getAssetById(id);
      await _local.upsertFromRemote([remoteModel]);
      return Right(remoteModel.toEntity(lastSyncedAt: DateTime.now()));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.statusCode?.toString()));
    }
  }

  @override
  Stream<Either<Failure, AssetDashboardStats>> watchDashboardStats({String? departmentId}) {
    return _local
        .watchAssets(departmentId: departmentId)
        .map<Either<Failure, AssetDashboardStats>>((models) {
      final byStatus = <String, int>{};
      final byDepartment = <String, int>{};
      var maintenanceDue = 0;
      var warrantyExpiring = 0;
      final soon = DateTime.now().add(const Duration(days: 30));

      for (final m in models) {
        byStatus.update(m.status.name, (v) => v + 1, ifAbsent: () => 1);
        byDepartment.update(m.departmentName, (v) => v + 1, ifAbsent: () => 1);
        if (m.status == AssetStatus.underMaintenance) maintenanceDue++;
        if (m.warrantyExpiry != null && m.warrantyExpiry!.isBefore(soon)) warrantyExpiring++;
      }

      return Right(AssetDashboardStats(
        totalAssets: models.length,
        byStatus: byStatus,
        byDepartment: byDepartment,
        maintenanceDueCount: maintenanceDue,
        warrantyExpiringCount: warrantyExpiring,
      ));
    }).handleError((Object e) => Left<Failure, AssetDashboardStats>(CacheFailure(e.toString())));
  }

  @override
  Future<Either<Failure, Unit>> transferAsset({
    required String assetId,
    required String toDepartmentId,
    required String reason,
  }) async {
    try {
      // 1. Optimistic local write — UI reflects the transfer instantly.
      await _local.applyOptimisticTransfer(assetId, toDepartmentId, toDepartmentId);

      // 2. Enqueue for sync in the SAME local database used by
      //    AppDatabase's SyncQueue, so this can never succeed locally
      //    but silently fail to queue.
      final idempotencyKey = _uuid.v4();
      await _db.into(_db.syncQueue).insert(
            SyncQueueCompanion.insert(
              entityType: 'asset',
              operation: 'transfer',
              payload: jsonEncode({
                'assetId': assetId,
                'toDepartmentId': toDepartmentId,
                'reason': reason,
              }),
              idempotencyKey: idempotencyKey,
            ),
          );

      // 3. Kick the engine immediately in case we're already online —
      //    no need to wait for the next connectivity-change event.
      unawaited(_syncEngine.drainQueue());

      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> refreshFromRemote() async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final remoteAssets = await _remote.getAssets();
      await _local.upsertFromRemote(remoteAssets);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.statusCode?.toString()));
    }
  }
}

/// Replays queued asset mutations against the API once connectivity
/// returns. Registered with [SyncEngine] by [AssetRepositoryImpl]
/// above — the engine itself has no idea what "transfer" means for an
/// asset.
class _AssetSyncHandler implements SyncHandler {
  _AssetSyncHandler(this._remote);
  final AssetRemoteDataSource _remote;

  @override
  String get entityType => 'asset';

  @override
  Future<void> replay(SyncTask task) async {
    switch (task.operation) {
      case 'transfer':
        try {
          await _remote.transferAsset(
            assetId: task.payload['assetId'] as String,
            toDepartmentId: task.payload['toDepartmentId'] as String,
            reason: task.payload['reason'] as String,
            idempotencyKey: task.idempotencyKey,
          );
        } on ServerException catch (e) {
          if (e.statusCode == 409) {
            throw SyncConflict('Asset was transferred by someone else first');
          }
          rethrow;
        }
    }
  }
}
