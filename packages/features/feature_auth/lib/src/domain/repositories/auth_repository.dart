import 'package:core/core.dart';
import 'package:fpdart/fpdart.dart';

import '../entities/user.dart';

/// Domain-level contract. UseCases depend on THIS interface, never on
/// `AuthRepositoryImpl` — the concrete implementation is only wired up
/// at DI-registration time (see `di/auth_injection.dart`). This is
/// what makes every usecase trivially testable with a fake repository
/// and no network/DB involved.
abstract class AuthRepository {
  Future<Either<Failure, AppUser>> loginWithSso(String ssoIdToken);
  Future<Either<Failure, AppUser>> requestOtp(String email);
  Future<Either<Failure, AppUser>> verifyOtp({required String email, required String otp});
  Future<Either<Failure, AppUser?>> getCurrentUser();
  Future<Either<Failure, Unit>> logout();
}
