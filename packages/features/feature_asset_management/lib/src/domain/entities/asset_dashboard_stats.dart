import 'package:equatable/equatable.dart';

/// Backs the in-module Asset Management Dashboard (concept doc §6.1) —
/// deliberately a read-model of its own rather than derived ad hoc in
/// the UI, so the counts are computed once (in the repository, from
/// local Drift queries) and reused by both the dashboard screen and
/// any future widget/report that needs the same numbers.
class AssetDashboardStats extends Equatable {
  const AssetDashboardStats({
    required this.totalAssets,
    required this.byStatus,
    required this.byDepartment,
    required this.maintenanceDueCount,
    required this.warrantyExpiringCount,
  });

  final int totalAssets;
  final Map<String, int> byStatus;
  final Map<String, int> byDepartment;
  final int maintenanceDueCount;
  final int warrantyExpiringCount;

  @override
  List<Object?> get props =>
      [totalAssets, byStatus, byDepartment, maintenanceDueCount, warrantyExpiringCount];
}
