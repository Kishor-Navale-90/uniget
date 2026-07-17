import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:feature_auth/feature_auth.dart';
import 'package:feature_auth/src/domain/usecases/get_current_session.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetCurrentSession extends Mock implements GetCurrentSession {}

class _MockLogout extends Mock implements Logout {}

void main() {
  setUpAll(() {
    registerFallbackValue(const NoParams());
  });

  late _MockGetCurrentSession getCurrentSession;
  late _MockLogout logout;

  setUp(() {
    getCurrentSession = _MockGetCurrentSession();
    logout = _MockLogout();
  });

  AuthBloc buildBloc() => AuthBloc(getCurrentSession, logout);

  const user = AppUser(id: '1', name: 'Rupesh', email: 'r@company.com', role: UserRole.manager);

  blocTest<AuthBloc, AuthState>(
    'emits [loading, authenticated] when a cached session exists',
    setUp: () {
      when(() => getCurrentSession(any())).thenAnswer((_) async => const Right(user));
    },
    build: buildBloc,
    act: (bloc) => bloc.add(const AuthCheckRequested()),
    expect: () => [
      const AuthState(status: AuthStatus.loading),
      const AuthState(status: AuthStatus.authenticated, user: user),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [loading, unauthenticated] when there is no cached session',
    setUp: () {
      when(() => getCurrentSession(any())).thenAnswer((_) async => const Right(null));
    },
    build: buildBloc,
    act: (bloc) => bloc.add(const AuthCheckRequested()),
    expect: () => [
      const AuthState(status: AuthStatus.loading),
      const AuthState(status: AuthStatus.unauthenticated),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [unauthenticated] on logout',
    setUp: () {
      when(() => logout(any())).thenAnswer((_) async => const Right(unit));
    },
    build: buildBloc,
    act: (bloc) => bloc.add(const AuthLogoutRequested()),
    expect: () => [const AuthState(status: AuthStatus.unauthenticated)],
  );
}
