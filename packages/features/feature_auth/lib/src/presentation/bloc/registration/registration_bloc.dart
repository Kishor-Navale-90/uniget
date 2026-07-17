import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/usecases/check_registration_email.dart';
import '../../../domain/usecases/request_registration_otp.dart';
import '../../../domain/usecases/set_password.dart';
import '../../../domain/usecases/verify_registration_otp.dart';
import 'registration_event.dart';
import 'registration_state.dart';

/// Owns the whole self-registration wizard (email → OTP → set
/// password) as one screen-slice Bloc — the three steps share a
/// single lifecycle (the email and registration token from earlier
/// steps are needed by later ones), unlike [LoginBloc] which is a
/// single, independent action.
@injectable
class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  RegistrationBloc(
    this._checkRegistrationEmail,
    this._requestRegistrationOtp,
    this._verifyRegistrationOtp,
    this._setPassword,
  ) : super(const RegistrationState()) {
    on<RegistrationEmailSubmitted>(_onEmailSubmitted);
    on<RegistrationOtpSubmitted>(_onOtpSubmitted);
    on<RegistrationPasswordSubmitted>(_onPasswordSubmitted);
  }

  final CheckRegistrationEmail _checkRegistrationEmail;
  final RequestRegistrationOtp _requestRegistrationOtp;
  final VerifyRegistrationOtp _verifyRegistrationOtp;
  final SetPassword _setPassword;

  Future<void> _onEmailSubmitted(
    RegistrationEmailSubmitted event,
    Emitter<RegistrationState> emit,
  ) async {
    emit(state.copyWith(status: RegistrationStatus.submitting, email: event.email));
    final checkResult = await _checkRegistrationEmail(event.email);
    final checkFailure = checkResult.fold((f) => f, (_) => null);
    if (checkFailure != null) {
      emit(state.copyWith(status: RegistrationStatus.failure, errorMessage: checkFailure.message));
      return;
    }
    final otpResult = await _requestRegistrationOtp(event.email);
    otpResult.when(
      failure: (f) => emit(state.copyWith(status: RegistrationStatus.failure, errorMessage: f.message)),
      success: (_) => emit(
        state.copyWith(status: RegistrationStatus.idle, step: RegistrationStep.verifyOtp),
      ),
    );
  }

  Future<void> _onOtpSubmitted(RegistrationOtpSubmitted event, Emitter<RegistrationState> emit) async {
    emit(state.copyWith(status: RegistrationStatus.submitting));
    final result = await _verifyRegistrationOtp(
      VerifyRegistrationOtpParams(email: state.email ?? '', otp: event.otp),
    );
    result.when(
      failure: (f) => emit(state.copyWith(status: RegistrationStatus.failure, errorMessage: f.message)),
      success: (registrationToken) => emit(
        state.copyWith(
          status: RegistrationStatus.idle,
          step: RegistrationStep.setPassword,
          registrationToken: registrationToken,
        ),
      ),
    );
  }

  Future<void> _onPasswordSubmitted(
    RegistrationPasswordSubmitted event,
    Emitter<RegistrationState> emit,
  ) async {
    emit(state.copyWith(status: RegistrationStatus.submitting));
    final result = await _setPassword(
      SetPasswordParams(registrationToken: state.registrationToken ?? '', password: event.password),
    );
    result.when(
      failure: (f) => emit(state.copyWith(status: RegistrationStatus.failure, errorMessage: f.message)),
      // The repository already persisted the session on success — the
      // app-shell router's redirect reacts to that on its own, so this
      // Bloc just needs to record that the wizard is done.
      success: (_) => emit(state.copyWith(status: RegistrationStatus.idle, step: RegistrationStep.completed)),
    );
  }
}
