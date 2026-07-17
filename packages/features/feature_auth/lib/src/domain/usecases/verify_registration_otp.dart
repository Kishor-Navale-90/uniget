import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../repositories/auth_repository.dart';

/// Returns a short-lived registration token (not a session token) that
/// authorizes the following [SetPassword] call.
@injectable
class VerifyRegistrationOtp implements UseCase<String, VerifyRegistrationOtpParams> {
  VerifyRegistrationOtp(this._repository);
  final AuthRepository _repository;

  @override
  Future<Either<Failure, String>> call(VerifyRegistrationOtpParams params) =>
      _repository.verifyRegistrationOtp(email: params.email, otp: params.otp);
}

class VerifyRegistrationOtpParams extends Equatable {
  const VerifyRegistrationOtpParams({required this.email, required this.otp});
  final String email;
  final String otp;

  @override
  List<Object?> get props => [email, otp];
}
