// lib/providers/auth_providers.dart (Create directory/file)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:okada_app/core/services/auth_service.dart';
import 'package:okada_app/core/services/token_storage_service.dart';
import 'package:okada_app/notifiers/auth_notifier.dart'; // Adjust path
import 'package:okada_app/state/auth_state.dart';      // Adjust path
import 'package:okada_app/providers/config_provider.dart';

// Provider for TokenStorageService (singleton)
final tokenStorageServiceProvider = Provider<TokenStorageService>((ref) {
  return TokenStorageService();
});

// Provider for AuthService (singleton, depends on TokenStorageService - though AuthService manages internally now)
final authServiceProvider = Provider<AuthService>((ref) {
  final config = ref.watch(appConfigProvider);
  return AuthService(config.apiBaseUrl);
});

// StateNotifierProvider for authentication state
// It depends on AuthService and TokenStorageService
final authNotifierProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final authService = ref.read(authServiceProvider);
  final tokenStorageService = ref.read(tokenStorageServiceProvider);
  return AuthStateNotifier(authService, tokenStorageService);
});