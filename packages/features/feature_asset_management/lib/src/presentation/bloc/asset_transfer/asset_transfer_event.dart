import 'package:equatable/equatable.dart';

sealed class AssetTransferEvent extends Equatable {
  const AssetTransferEvent();
  @override
  List<Object?> get props => [];
}

class AssetTransferSubmitted extends AssetTransferEvent {
  const AssetTransferSubmitted({
    required this.assetId,
    required this.toDepartmentId,
    required this.reason,
  });

  final String assetId;
  final String toDepartmentId;
  final String reason;

  @override
  List<Object?> get props => [assetId, toDepartmentId, reason];
}
