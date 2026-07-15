import 'package:core/core.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../entities/gate_pass.dart';
import '../repositories/gate_pass_repository.dart';

@injectable
class VerifyGatePassAtGate implements UseCase<GatePass, String> {
  VerifyGatePassAtGate(this._repository);
  final GatePassRepository _repository;

  @override
  Future<Either<Failure, GatePass>> call(String qrPayload) =>
      _repository.verifyAndReleaseAtGate(qrPayload);
}
