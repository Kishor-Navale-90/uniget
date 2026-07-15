import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../entities/user.dart';
import '../repositories/auth_repository.dart';

@injectable
class LoginWithSso implements UseCase<AppUser, LoginWithSsoParams> {
  LoginWithSso(this._repository);
  final AuthRepository _repository;

  @override
  Future<Either<Failure, AppUser>> call(LoginWithSsoParams params) =>
      _repository.loginWithSso(params.ssoIdToken);
}

class LoginWithSsoParams extends Equatable {
  const LoginWithSsoParams(this.ssoIdToken);
  final String ssoIdToken;

  @override
  List<Object?> get props => [ssoIdToken];
}
