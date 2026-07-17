import 'package:core/core.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../repositories/auth_repository.dart';

@injectable
class RequestRegistrationOtp implements UseCase<Unit, String> {
  RequestRegistrationOtp(this._repository);
  final AuthRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(String email) => _repository.requestRegistrationOtp(email);
}
