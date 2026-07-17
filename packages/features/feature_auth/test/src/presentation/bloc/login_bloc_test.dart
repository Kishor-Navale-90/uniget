import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:feature_auth/feature_auth.dart';
import 'package:feature_auth/src/domain/usecases/login_with_password.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLoginWithPassword extends Mock implements LoginWithPassword {}

void main() {
  setUpAll(() {
    registerFallbackValue(const LoginWithPasswordParams(email: '', password: ''));
  });

  late _MockLoginWithPassword loginWithPassword;

  setUp(() {
    loginWithPassword = _MockLoginWithPassword();
  });

  LoginBloc buildBloc() => LoginBloc(loginWithPassword);

  const user = AppUser(id: '1', name: 'Rupesh', email: 'r@company.com', role: UserRole.employee);

  blocTest<LoginBloc, LoginState>(
    'emits [submitting, success] when login succeeds',
    setUp: () {
      when(() => loginWithPassword(any())).thenAnswer((_) async => const Right(user));
    },
    build: buildBloc,
    act: (bloc) => bloc.add(const LoginSubmitted(email: 'r@company.com', password: 'secret')),
    expect: () => [
      const LoginState(status: LoginStatus.submitting),
      const LoginState(status: LoginStatus.success),
    ],
  );

  blocTest<LoginBloc, LoginState>(
    'emits [submitting, failure] when login fails',
    setUp: () {
      when(() => loginWithPassword(any()))
          .thenAnswer((_) async => const Left(ServerFailure('Invalid email or password')));
    },
    build: buildBloc,
    act: (bloc) => bloc.add(const LoginSubmitted(email: 'r@company.com', password: 'wrong')),
    expect: () => [
      const LoginState(status: LoginStatus.submitting),
      const LoginState(status: LoginStatus.failure, errorMessage: 'Invalid email or password'),
    ],
  );
}
