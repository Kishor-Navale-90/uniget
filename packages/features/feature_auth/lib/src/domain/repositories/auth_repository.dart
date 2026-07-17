import 'package:core/core.dart';
import 'package:fpdart/fpdart.dart';

import '../entities/user.dart';

/// Domain-level contract. UseCases depend on THIS interface, never on
/// `AuthRepositoryImpl` — the concrete implementation is only wired up
/// at DI-registration time (see `di/auth_injection.dart`). This is
/// what makes every usecase trivially testable with a fake repository
/// and no network/DB involved.
///
/// Registration flow (no SSO — every employee is pre-added by an admin
/// with their official email, then activates their own account):
/// [checkRegistrationEmail] → [requestRegistrationOtp] →
/// [verifyRegistrationOtp] → [setPassword] (which also logs the user
/// in). After that, [loginWithPassword] is the regular sign-in path.
///
/// Backed by Supabase (see `supabase/README.md`): [verifyRegistrationOtp]
/// establishes a live Supabase session directly rather than returning a
/// separate short-lived token — that session is itself the transitional
/// credential scoping the following [setPassword] call to this one user.
abstract class AuthRepository {
  /// Left(ValidationFailure) if [email] wasn't pre-added by an admin or
  /// is already activated; Right(unit) if eligible to receive an OTP.
  Future<Either<Failure, Unit>> checkRegistrationEmail(String email);

  /// Sends a one-time code to [email] for registration verification.
  Future<Either<Failure, Unit>> requestRegistrationOtp(String email);

  /// Verifies the code, establishing the session that [setPassword]
  /// then acts on.
  Future<Either<Failure, Unit>> verifyRegistrationOtp({required String email, required String otp});

  /// Sets the account's password, activates it, and logs the user in.
  Future<Either<Failure, AppUser>> setPassword({required String password});

  Future<Either<Failure, AppUser>> loginWithPassword({required String email, required String password});

  /// Cached user if one exists locally; otherwise revalidates against
  /// Supabase (`auth.getUser()` + the `get_my_profile` RPC) so a cold
  /// start with a still-valid persisted session comes back signed in.
  Future<Either<Failure, AppUser?>> getCurrentUser();
  Future<Either<Failure, Unit>> logout();
}
