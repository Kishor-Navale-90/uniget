import 'package:core/core.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../repositories/auth_repository.dart';

/// First step of self-registration: confirms [email] was pre-added by
/// an admin and hasn't been activated yet, before an OTP is sent.
@injectable
class CheckRegistrationEmail implements UseCase<Unit, String> {
  CheckRegistrationEmail(this._repository);
  final AuthRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(String email) => _repository.checkRegistrationEmail(email);
}
