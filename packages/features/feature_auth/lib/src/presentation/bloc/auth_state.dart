import 'package:equatable/equatable.dart';

import '../../domain/entities/user.dart';

enum AuthStatus { initial, loading, awaitingOtp, authenticated, unauthenticated, failure }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  final AuthStatus status;
  final AppUser? user;
  final String? errorMessage;

  AuthState copyWith({AuthStatus? status, AppUser? user, String? errorMessage}) => AuthState(
        status: status ?? this.status,
        user: user ?? this.user,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, user, errorMessage];
}
