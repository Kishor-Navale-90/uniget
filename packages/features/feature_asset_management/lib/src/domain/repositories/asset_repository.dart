import 'package:core/core.dart';
import 'package:fpdart/fpdart.dart';

import '../entities/asset.dart';
import '../entities/asset_dashboard_stats.dart';

/// Domain contract for everything Asset Management needs. Notice this
/// interface has NO concept of "remote" vs "local" vs "sync queue" —
/// that offline-first plumbing is entirely an implementation detail of
/// [AssetRepositoryImpl] in the data layer. UseCases and Blocs code
/// against this interface only.
abstract class AssetRepository {
  /// Reactive stream backed by the local Drift table — emits
  /// immediately from cache, then again whenever a background refresh
  /// or sync updates a row. This is what makes the list screen
  /// "offline-first" rather than "offline-fallback": the cache IS the
  /// primary read path, not an afterthought.
  Stream<Either<Failure, List<Asset>>> watchAssets({String? departmentId});

  Future<Either<Failure, Asset>> getAssetById(String id);

  Stream<Either<Failure, AssetDashboardStats>> watchDashboardStats({String? departmentId});

  /// Initiates an inter-team/inter-project transfer (concept doc
  /// §5.1). Writes optimistically and queues for sync if offline —
  /// see AssetRepositoryImpl.transferAsset.
  Future<Either<Failure, Unit>> transferAsset({
    required String assetId,
    required String toDepartmentId,
    required String reason,
  });

  /// Pulls the latest from the API and reconciles into the local
  /// cache. Called on pull-to-refresh and periodically in the
  /// background — never required for the UI to function, only to
  /// freshen it.
  Future<Either<Failure, Unit>> refreshFromRemote();
}
