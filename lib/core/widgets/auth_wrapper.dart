import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:okada_app/presentation/screens/auth/login_screen.dart'; // Adjust path
import 'package:okada_app/presentation/screens/home/home_screen.dart'; // Adjust path
import 'package:okada_app/presentation/screens/splash/splash_screen.dart'; // Adjust path
import 'package:okada_app/providers/auth_providers.dart'; // Adjust path
import 'package:okada_app/state/auth_state.dart'; // Adjust path

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    // --- Add this line for debugging ---
    print("[AuthWrapper] Build triggered. Received Auth Status = ${authState.status}");
    // --- End Add ---

    switch (authState.status) {
      case AuthStatus.unknown:
      case AuthStatus.authenticating:
        // --- Logging ---
        print("[AuthWrapper] Showing SplashScreen (Status: ${authState.status})");
        // --- End Logging ---
        return SplashScreen(); // Or loading indicator
      case AuthStatus.authenticated:
        // --- Logging ---
        print("[AuthWrapper] Showing HomeScreen (Status: ${authState.status})");
        // --- End Logging ---
        return HomeScreen();
      case AuthStatus.unauthenticated:
      default: // Include default for completeness
        // --- Logging ---
        print("[AuthWrapper] Showing LoginScreen (Status: ${authState.status})");
        // --- End Logging ---
        return LoginScreen();
    }
  }
}