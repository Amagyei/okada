import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:okada_app/data/models/user_model.dart';

enum AuthStatus { unknown, authenticating, authenticated, unauthenticated, error }

@immutable
class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  const AuthState({required this.status, this.user, this.errorMessage});

  const AuthState.unknown()
      : status = AuthStatus.unknown,
        user = null,
        errorMessage = null;

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
    bool clearUser = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          user == other.user &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode => status.hashCode ^ user.hashCode ^ errorMessage.hashCode;

  @override
  String toString() {
    return 'AuthState{status: $status, user: ${user?.username ?? 'null'}, errorMessage: $errorMessage}';
  }
}