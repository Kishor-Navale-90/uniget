import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/get_current_session.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// One Bloc per screen/feature-slice is the rule across the whole app
/// (see ARCHITECTURE.md) — this one is the exception that's
/// app-global, since sign-in status gates the entire route tree.
/// It only checks/holds session status and signs out; the actual
/// sign-in/registration work lives in [LoginBloc] and
/// [RegistrationBloc], since successful login already persists the
/// session via `SessionManager` (which the router's redirect reacts to
/// directly — this Bloc doesn't need to be told about it separately).
@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._getCurrentSession, this._logout) : super(const AuthState()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  final GetCurrentSession _getCurrentSession;
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

  Future<void> _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await _logout(const NoParams());
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
