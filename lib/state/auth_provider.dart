import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_state.dart';

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState.unknown());

  void login(String phone, String password) {
    state = state.copyWith(status: AuthStatus.authenticating);
    // Login logic will be implemented here
  }

  void logout() {
    state = state.copyWith(status: AuthStatus.unauthenticated, clearUser: true);
  }
} 