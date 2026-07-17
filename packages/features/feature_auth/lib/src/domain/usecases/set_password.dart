import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Final step of self-registration — activates the account and logs
/// the user straight in (no separate login step needed right after).
@injectable
class SetPassword implements UseCase<AppUser, SetPasswordParams> {
  SetPassword(this._repository);
  final AuthRepository _repository;

  @override
  Future<Either<Failure, AppUser>> call(SetPasswordParams params) =>
      _repository.setPassword(password: params.password);
}

class SetPasswordParams extends Equatable {
  const SetPasswordParams({required this.password});
  final String password;

  @override
  List<Object?> get props => [password];
}
