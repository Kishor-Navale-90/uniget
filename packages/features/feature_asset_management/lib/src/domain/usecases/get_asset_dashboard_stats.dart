import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../entities/asset_dashboard_stats.dart';
import '../repositories/asset_repository.dart';

/// Backs the Asset Management Dashboard (concept doc §6.1) — a
/// dedicated in-module dashboard distinct from the org-wide Admin
/// Dashboard, scoped to the caller's department for anyone below
/// Super Admin (department-wise RBAC, concept doc §7.2).
@injectable
class WatchAssetDashboardStats
    implements StreamUseCase<AssetDashboardStats, WatchDashboardStatsParams> {
  WatchAssetDashboardStats(this._repository);
  final AssetRepository _repository;

  @override
  Stream<Either<Failure, AssetDashboardStats>> call(WatchDashboardStatsParams params) =>
      _repository.watchDashboardStats(departmentId: params.departmentId);
}

class WatchDashboardStatsParams extends Equatable {
  const WatchDashboardStatsParams({this.departmentId});
  final String? departmentId;

  @override
  List<Object?> get props => [departmentId];
}
