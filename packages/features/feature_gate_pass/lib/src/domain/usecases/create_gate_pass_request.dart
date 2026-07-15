import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../repositories/gate_pass_repository.dart';

@injectable
class CreateGatePassRequest implements UseCase<Unit, CreateGatePassRequestParams> {
  CreateGatePassRequest(this._repository);
  final GatePassRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(CreateGatePassRequestParams params) => _repository.createRequest(
        assetOrMaterialLabel: params.assetOrMaterialLabel,
        reason: params.reason,
        isReturnable: params.isReturnable,
      );
}

class CreateGatePassRequestParams extends Equatable {
  const CreateGatePassRequestParams({
    required this.assetOrMaterialLabel,
    required this.reason,
    required this.isReturnable,
  });

  final String assetOrMaterialLabel;
  final String reason;
  final bool isReturnable;

  @override
  List<Object?> get props => [assetOrMaterialLabel, reason, isReturnable];
}
