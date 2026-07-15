import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../entities/user.dart';
import '../repositories/auth_repository.dart';

@injectable
class RequestOtp implements UseCase<AppUser, String> {
  RequestOtp(this._repository);
  final AuthRepository _repository;

  @override
  Future<Either<Failure, AppUser>> call(String email) => _repository.requestOtp(email);
}

@injectable
class VerifyOtp implements UseCase<AppUser, VerifyOtpParams> {
  VerifyOtp(this._repository);
  final AuthRepository _repository;

  @override
  Future<Either<Failure, AppUser>> call(VerifyOtpParams params) =>
      _repository.verifyOtp(email: params.email, otp: params.otp);
}

class VerifyOtpParams extends Equatable {
  const VerifyOtpParams({required this.email, required this.otp});
  final String email;
  final String otp;

  @override
  List<Object?> get props => [email, otp];
}
