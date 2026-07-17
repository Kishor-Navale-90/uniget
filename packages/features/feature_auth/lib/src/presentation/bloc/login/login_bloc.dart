import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/usecases/login_with_password.dart';
import 'login_event.dart';
import 'login_state.dart';

/// A separate screen-slice Bloc from [AuthBloc] (house rule: one Bloc
/// per screen-slice) — this owns only the login form's submit action.
/// On success, `AuthRepositoryImpl` has already persisted the session
/// via `SessionManager`, so the app-shell router's redirect fires on
/// its own; this Bloc doesn't need to notify anyone.
@injectable
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc(this._loginWithPassword) : super(const LoginState()) {
    on<LoginSubmitted>(_onSubmitted);
  }

  final LoginWithPassword _loginWithPassword;

  Future<void> _onSubmitted(LoginSubmitted event, Emitter<LoginState> emit) async {
    emit(state.copyWith(status: LoginStatus.submitting));
    final result = await _loginWithPassword(
      LoginWithPasswordParams(email: event.email, password: event.password),
    );
    result.when(
      failure: (f) => emit(state.copyWith(status: LoginStatus.failure, errorMessage: f.message)),
      success: (_) => emit(state.copyWith(status: LoginStatus.success)),
    );
  }
}
