import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/get_current_session.dart';
import '../../domain/usecases/login_with_otp.dart';
import '../../domain/usecases/login_with_sso.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// One Bloc per screen/feature-slice is the rule across the whole
/// app (see ARCHITECTURE.md) — this one is the exception that's
/// app-global, since login status gates the entire route tree.
/// Every event handler calls exactly one UseCase; the Bloc itself
/// contains zero business logic, only state transitions.
@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(
    this._getCurrentSession,
    this._loginWithSso,
    this._requestOtp,
    this._verifyOtp,
    this._logout,
  ) : super(const AuthState()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthSsoLoginRequested>(_onSsoLoginRequested);
    on<AuthOtpRequested>(_onOtpRequested);
    on<AuthOtpVerifyRequested>(_onOtpVerifyRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  final GetCurrentSession _getCurrentSession;
  final LoginWithSso _loginWithSso;
  final RequestOtp _requestOtp;
  final VerifyOtp _verifyOtp;
  final Logout _logout;

  Future<void> _onCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await _getCurrentSession(const NoParams());
    result.when(
      failure: (f) => emit(state.copyWith(status: AuthStatus.unauthenticated)),
      success: (user) => emit(
        user == null
            ? state.copyWith(status: AuthStatus.unauthenticated)
            : state.copyWith(status: AuthStatus.authenticated, user: user),
      ),
    );
  }

  Future<void> _onSsoLoginRequested(AuthSsoLoginRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await _loginWithSso(LoginWithSsoParams(event.idToken));
    result.when(
      failure: (f) => emit(state.copyWith(status: AuthStatus.failure, errorMessage: f.message)),
      success: (user) => emit(state.copyWith(status: AuthStatus.authenticated, user: user)),
    );
  }

  Future<void> _onOtpRequested(AuthOtpRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await _requestOtp(event.email);
    // requestOtp intentionally resolves as a "failure" carrying an
    // informational message (see AuthRepositoryImpl) since there's no
    // user/token yet — the Bloc translates that into `awaitingOtp`.
    result.when(
      failure: (f) => emit(state.copyWith(status: AuthStatus.awaitingOtp, errorMessage: f.message)),
      success: (user) => emit(state.copyWith(status: AuthStatus.authenticated, user: user)),
    );
  }

  Future<void> _onOtpVerifyRequested(AuthOtpVerifyRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await _verifyOtp(VerifyOtpParams(email: event.email, otp: event.otp));
    result.when(
      failure: (f) => emit(state.copyWith(status: AuthStatus.failure, errorMessage: f.message)),
      success: (user) => emit(state.copyWith(status: AuthStatus.authenticated, user: user)),
    );
  }

  Future<void> _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await _logout(const NoParams());
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
