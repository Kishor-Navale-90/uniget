import 'package:equatable/equatable.dart';

sealed class RegistrationEvent extends Equatable {
  const RegistrationEvent();
  @override
  List<Object?> get props => [];
}

/// Step 1: the employee enters their official (admin-pre-added) email.
class RegistrationEmailSubmitted extends RegistrationEvent {
  const RegistrationEmailSubmitted(this.email);
  final String email;
  @override
  List<Object?> get props => [email];
}

/// Step 2: the employee enters the OTP just emailed to them.
class RegistrationOtpSubmitted extends RegistrationEvent {
  const RegistrationOtpSubmitted(this.otp);
  final String otp;
  @override
  List<Object?> get props => [otp];
}

/// Step 3: the employee sets their password, activating the account.
class RegistrationPasswordSubmitted extends RegistrationEvent {
  const RegistrationPasswordSubmitted(this.password);
  final String password;
  @override
  List<Object?> get props => [password];
}
