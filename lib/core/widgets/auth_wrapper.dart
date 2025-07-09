import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:okada/presentation/screens/auth/login_screen.dart'; // Adjust path
import 'package:okada/presentation/screens/home/home_screen.dart'; // Adjust path
import 'package:okada/presentation/screens/splash/splash_screen.dart'; // Adjust path
import 'package:okada/providers/auth_providers.dart'; // Adjust path
import 'package:okada/state/auth_state.dart'; // Adjust path
import 'package:okada/core/services/notification_service.dart';

class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  bool _notificationInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authState = ref.read(authNotifierProvider);
    
    // Initialize notification service when user is authenticated
    if (authState.status == AuthStatus.authenticated && !_notificationInitialized) {
      print("[AuthWrapper] User authenticated, initializing notification service");
      _notificationInitialized = true;
      
      // Initialize notification service
      final notificationService = ref.read(notificationServiceProvider);
      notificationService.initialize().then((_) {
        notificationService.onUserLogin();
      }).catchError((e) {
        print("[AuthWrapper] Error initializing notification service: $e");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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