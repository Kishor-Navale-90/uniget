import 'package:equatable/equatable.dart';

enum RegistrationStep { enterEmail, verifyOtp, setPassword, completed }

enum RegistrationStatus { idle, submitting, failure }

class RegistrationState extends Equatable {
  const RegistrationState({
    this.step = RegistrationStep.enterEmail,
    this.status = RegistrationStatus.idle,
    this.email,
    this.registrationToken,
    this.errorMessage,
  });

  final RegistrationStep step;
  final RegistrationStatus status;
  final String? email;

  /// Short-lived token returned by OTP verification, authorizing the
  /// following set-password call — never a session token.
  final String? registrationToken;
  final String? errorMessage;

  RegistrationState copyWith({
    RegistrationStep? step,
    RegistrationStatus? status,
    String? email,
    String? registrationToken,
    String? errorMessage,
  }) =>
      RegistrationState(
        step: step ?? this.step,
        status: status ?? this.status,
        email: email ?? this.email,
        registrationToken: registrationToken ?? this.registrationToken,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [step, status, email, registrationToken, errorMessage];
}
