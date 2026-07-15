import 'package:core/core.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../entities/user.dart';
import '../repositories/auth_repository.dart';

@injectable
class GetCurrentSession implements UseCase<AppUser?, NoParams> {
  GetCurrentSession(this._repository);
  final AuthRepository _repository;

  @override
  Future<Either<Failure, AppUser?>> call(NoParams params) => _repository.getCurrentUser();
}

@injectable
class Logout implements UseCase<Unit, NoParams> {
  Logout(this._repository);
  final AuthRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(NoParams params) => _repository.logout();
}
