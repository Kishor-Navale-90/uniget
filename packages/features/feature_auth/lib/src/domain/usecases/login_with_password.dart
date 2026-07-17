import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../entities/user.dart';
import '../repositories/auth_repository.dart';

@injectable
class LoginWithPassword implements UseCase<AppUser, LoginWithPasswordParams> {
  LoginWithPassword(this._repository);
  final AuthRepository _repository;

  @override
  Future<Either<Failure, AppUser>> call(LoginWithPasswordParams params) =>
      _repository.loginWithPassword(email: params.email, password: params.password);
}

class LoginWithPasswordParams extends Equatable {
  const LoginWithPasswordParams({required this.email, required this.password});
  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}
