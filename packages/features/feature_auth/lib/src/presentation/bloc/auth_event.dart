import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthSsoLoginRequested extends AuthEvent {
  const AuthSsoLoginRequested(this.idToken);
  final String idToken;
  @override
  List<Object?> get props => [idToken];
}

class AuthOtpRequested extends AuthEvent {
  const AuthOtpRequested(this.email);
  final String email;
  @override
  List<Object?> get props => [email];
}

class AuthOtpVerifyRequested extends AuthEvent {
  const AuthOtpVerifyRequested({required this.email, required this.otp});
  final String email;
  final String otp;
  @override
  List<Object?> get props => [email, otp];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
