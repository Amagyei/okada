// lib/widgets/auth_wrapper.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:okada_app/presentation/screens/auth/login_screen.dart';
import 'package:okada_app/presentation/screens/home/home_screen.dart';
import 'package:okada_app/presentation/screens/splash/splash_screen.dart';
import 'package:okada_app/providers/auth_providers.dart'; // Import providers
import 'package:okada_app/state/auth_state.dart';       // Import AuthState/Status

// Change StatelessWidget to ConsumerWidget
class AuthWrapper extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) { // Add WidgetRef ref
    // Watch the authNotifierProvider for changes
    final authState = ref.watch(authNotifierProvider);

    // Decide which screen to show based on the authentication status
    switch (authState.status) {
      case AuthStatus.unknown:
      case AuthStatus.authenticating:
        return SplashScreen(); // Or loading indicator
      case AuthStatus.authenticated:
        return HomeScreen();
      case AuthStatus.unauthenticated:
      default:
        return LoginScreen();
    }
  }
}