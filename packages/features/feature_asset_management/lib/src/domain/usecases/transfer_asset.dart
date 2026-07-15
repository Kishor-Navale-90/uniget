import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../repositories/asset_repository.dart';

/// One class, one responsibility: initiate an inter-team/inter-project
/// transfer. All the approval routing to both the releasing and
/// receiving department owners (concept doc §5.1) happens server-side
/// once this syncs — the client's job is only to record the intent
/// reliably, online or offline.
@injectable
class TransferAsset implements UseCase<Unit, TransferAssetParams> {
  TransferAsset(this._repository);
  final AssetRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(TransferAssetParams params) {
    if (params.reason.trim().isEmpty) {
      return Future.value(const Left(ValidationFailure('A transfer reason is required')));
    }
    return _repository.transferAsset(
      assetId: params.assetId,
      toDepartmentId: params.toDepartmentId,
      reason: params.reason,
    );
  }
}

class TransferAssetParams extends Equatable {
  const TransferAssetParams({
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
