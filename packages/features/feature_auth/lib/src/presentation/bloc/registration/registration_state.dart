import 'package:equatable/equatable.dart';

enum RegistrationStep { enterEmail, verifyOtp, setPassword, completed }

enum RegistrationStatus { idle, submitting, failure }

class RegistrationState extends Equatable {
  const RegistrationState({
    this.step = RegistrationStep.enterEmail,
    this.status = RegistrationStatus.idle,
    this.email,
    this.errorMessage,
  });

  final RegistrationStep step;
  final RegistrationStatus status;
  final String? email;
  final String? errorMessage;

  RegistrationState copyWith({
    RegistrationStep? step,
    RegistrationStatus? status,
    String? email,
    String? errorMessage,
  }) =>
      RegistrationState(
        step: step ?? this.step,
        status: status ?? this.status,
        email: email ?? this.email,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [step, status, email, errorMessage];
}
