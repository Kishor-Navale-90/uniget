import 'package:equatable/equatable.dart';

import 'gate_pass_status.dart';

/// Same modelling philosophy as `feature_asset_management`'s `Asset`
/// entity: plain Dart, mapped from both API JSON and a local Drift row
/// by a data-layer model (`GatePassModel`, not yet scaffolded here).
class GatePass extends Equatable {
  const GatePass({
    required this.id,
    required this.assetOrMaterialLabel,
    required this.requesterName,
    required this.status,
    required this.isReturnable,
    this.dueDate,
    this.vehicleNumber,
    this.driverName,
  });

  final String id;
  final String assetOrMaterialLabel;
  final String requesterName;
  final GatePassStatus status;
  final bool isReturnable;
  final DateTime? dueDate;
  final String? vehicleNumber;
  final String? driverName;

  @override
  List<Object?> get props =>
      [id, assetOrMaterialLabel, requesterName, status, isReturnable, dueDate];
}
