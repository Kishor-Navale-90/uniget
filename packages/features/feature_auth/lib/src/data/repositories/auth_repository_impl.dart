import 'package:core/core.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

/// Implements the domain contract; this is the ONLY class in the
/// feature that is allowed to know both "network" and "local cache"
/// exist at the same time — everything above it just sees
/// `Either<Failure, T>`.
@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._local, this._session, this._networkInfo);

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;
  final SessionManager _session;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, Unit>> checkRegistrationEmail(String email) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      await _remote.checkRegistrationEmail(email);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.statusCode?.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> requestRegistrationOtp(String email) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      await _remote.requestRegistrationOtp(email);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.statusCode?.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> verifyRegistrationOtp({required String email, required String otp}) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final registrationToken = await _remote.verifyRegistrationOtp(email: email, otp: otp);
      return Right(registrationToken);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.statusCode?.toString()));
    }
  }

  @override
  Future<Either<Failure, AppUser>> setPassword({
    required String registrationToken,
    required String password,
  }) =>
      _completeLogin(
        () => _remote.setPassword(registrationToken: registrationToken, password: password),
      );

  @override
  Future<Either<Failure, AppUser>> loginWithPassword({required String email, required String password}) =>
      _completeLogin(() => _remote.loginWithPassword(email: email, password: password));

  /// Shared tail of every successful login path: cache the user,
  /// persist the session (token + role + department claims), return
  /// the domain entity.
  Future<Either<Failure, AppUser>> _completeLogin(
    Future<(UserModel user, String token)> Function() call,
  ) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final (user, token) = await call();
      await _local.cacheUser(user);
      await _session.setSession(
        AppSession(token: token, role: user.role, departmentId: user.departmentId),
      );
      return Right(user.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.statusCode?.toString()));
    }
  }

  @override
  Future<Either<Failure, AppUser?>> getCurrentUser() async {
    final cached = await _local.getCachedUser();
    return Right(cached?.toEntity());
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    await _local.clear();
    return const Right(unit);
  }
}
