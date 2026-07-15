import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:feature_auth/feature_auth.dart';
import 'package:feature_auth/src/domain/usecases/get_current_session.dart';
import 'package:feature_auth/src/domain/usecases/login_with_otp.dart';
import 'package:feature_auth/src/domain/usecases/login_with_sso.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetCurrentSession extends Mock implements GetCurrentSession {}
class _MockLoginWithSso extends Mock implements LoginWithSso {}
class _MockRequestOtp extends Mock implements RequestOtp {}
class _MockVerifyOtp extends Mock implements VerifyOtp {}
class _MockLogout extends Mock implements Logout {}

void main() {
  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(const LoginWithSsoParams(''));
    registerFallbackValue(const VerifyOtpParams(email: '', otp: ''));
  });

  late _MockGetCurrentSession getCurrentSession;
  late _MockLoginWithSso loginWithSso;
  late _MockRequestOtp requestOtp;
  late _MockVerifyOtp verifyOtp;
  late _MockLogout logout;

  setUp(() {
    getCurrentSession = _MockGetCurrentSession();
    loginWithSso = _MockLoginWithSso();
    requestOtp = _MockRequestOtp();
    verifyOtp = _MockVerifyOtp();
    logout = _MockLogout();
  });

  AuthBloc buildBloc() =>
      AuthBloc(getCurrentSession, loginWithSso, requestOtp, verifyOtp, logout);

  const user = AppUser(id: '1', name: 'Rupesh', email: 'r@company.com', role: UserRole.approver);

  blocTest<AuthBloc, AuthState>(
    'emits [loading, authenticated] when SSO login succeeds',
    setUp: () {
      when(() => loginWithSso(any())).thenAnswer((_) async => const Right(user));
    },
    build: buildBloc,
    act: (bloc) => bloc.add(const AuthSsoLoginRequested('id-token')),
    expect: () => [
      const AuthState(status: AuthStatus.loading),
      const AuthState(status: AuthStatus.authenticated, user: user),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [loading, failure] when SSO login fails',
    setUp: () {
      when(() => loginWithSso(any()))
          .thenAnswer((_) async => const Left(ServerFailure('SSO rejected')));
    },
    build: buildBloc,
    act: (bloc) => bloc.add(const AuthSsoLoginRequested('bad-token')),
    expect: () => [
      const AuthState(status: AuthStatus.loading),
      const AuthState(status: AuthStatus.failure, errorMessage: 'SSO rejected'),
    ],
  );
}
