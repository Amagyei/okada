import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:okada_app/data/models/user_model.dart';

enum AuthStatus { unknown, authenticating, authenticated, unauthenticated}

@immutable 
class AuthState {
  final AuthStatus status;
  final User? user;

  const AuthState({required this.status, this.user});

  const AuthState.unknown() : status = AuthStatus.unknown, user = null;

  AuthState copyWith({
    AuthStatus? status,
    User? user, 
    bool clearUser = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          user == other.user;

  @override
  int get hashCode => status.hashCode ^ user.hashCode;

  @override
  String toString() {
    return 'AuthState{status: $status, user: ${user?.username ?? 'null'}}';
  }
}