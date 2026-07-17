import 'package:core/core.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../entities/asset.dart';
import '../repositories/asset_repository.dart';

@injectable
class GetAssetById implements UseCase<Asset, String> {
  GetAssetById(this._repository);
  final AssetRepository _repository;

  @override
  Future<Either<Failure, Asset>> call(String assetId) => _repository.getAssetById(assetId);
}
