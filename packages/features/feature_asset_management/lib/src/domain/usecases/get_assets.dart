import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../entities/asset.dart';
import '../repositories/asset_repository.dart';

/// A `StreamUseCase` (see core/usecase.dart) rather than a one-shot
/// `UseCase` — the asset list screen wants to keep updating as local
/// sync/cache changes happen, not just render once.
@injectable
class WatchAssets implements StreamUseCase<List<Asset>, WatchAssetsParams> {
  WatchAssets(this._repository);
  final AssetRepository _repository;

  @override
  Stream<Either<Failure, List<Asset>>> call(WatchAssetsParams params) =>
      _repository.watchAssets(departmentId: params.departmentId);
}

class WatchAssetsParams extends Equatable {
  const WatchAssetsParams({this.departmentId});
  final String? departmentId;

  @override
  List<Object?> get props => [departmentId];
}
