// lib/notifiers/auth_notifier.dart 

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:okada_app/core/services/auth_service.dart';
import 'package:okada_app/core/services/token_storage_service.dart';
import 'package:okada_app/state/auth_state.dart'; // Import the state definition
import 'package:okada_app/data/models/user_model.dart'; // Import User model

class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final TokenStorageService _tokenStorageService;

  AuthStateNotifier(this._authService, this._tokenStorageService)
      : super(const AuthState.unknown()) { // Initial state
    checkAuthStatus(); // Check status when notifier is created
  }

  /// Checks secure storage for tokens on app start.
  Future<void> checkAuthStatus() async {
    // Use mounted check if necessary, although less common in Notifiers
    // if (!mounted) return; // Not applicable for StateNotifier unless managed specially

    state = state.copyWith(status: AuthStatus.authenticating);

    try {
      final token = await _tokenStorageService.getAccessToken();
      if (token != null && token.isNotEmpty) {
        // Token exists, try fetching user profile to validate and get data
        await _fetchUserProfile(); // This updates state internally
         // If fetching profile failed and logged out, ensure status reflects it
        if (state.status != AuthStatus.authenticated) {
           state = state.copyWith(status: AuthStatus.unauthenticated);
        }
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      print("Error during checkAuthStatus: $e");
      state = state.copyWith(status: AuthStatus.unauthenticated, clearUser: true);
    }
    // Final state is set within the try/catch branches or _fetchUserProfile
  }

  /// Helper to fetch user profile (often needed after login/app start)
  Future<void> _fetchUserProfile() async {
    try {
      // TODO: Implement and call _authService.getUserProfile()
      // This should return a User object on success
      // final fetchedUser = await _authService.getUserProfile();
      print("Simulating fetch user profile - ASSUME SUCCESS for example");
      // Placeholder User - replace with actual fetchedUser
      final fetchedUser = User(id: 1, username: 'testuser', email: 'test@test.com', firstName: 'Test', lastName: 'User', phoneNumber: '0241234567', userType: 'rider', isPhoneVerified: true, isEmailVerified: false); // EXAMPLE ONLY

      state = state.copyWith(status: AuthStatus.authenticated, user: fetchedUser);
    } catch (e) {
      print("Failed to fetch user profile, likely invalid token: $e");
      // If fetching fails, logout locally and update state
      await logout(notify: false); // Logout without double notification
      state = state.copyWith(status: AuthStatus.unauthenticated, clearUser: true);
    }
  }

  /// Handles user login.
  Future<void> login(String phoneNumber, String password) async {
    state = state.copyWith(status: AuthStatus.authenticating);
    try {
      final authResponse = await _authService.login(phoneNumber, password);
      // Login successful, update state
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: authResponse.user,
      );
      // Navigation logic based on authResponse.user.isPhoneVerified will happen in the UI/LoginScreen
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated, clearUser: true);
      throw e; // Re-throw for UI error handling
    }
  }

  /// Handles user registration.
  Future<void> register({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String password,
    String? email,
    required String userType,
  }) async {
     state = state.copyWith(status: AuthStatus.authenticating);
    try {
      final authResponse = await _authService.register(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        password: password,
        email: email,
        userType: userType,
        // username: phoneNumber // Handled by AuthService
      );
      // Registration successful, user is logged in but needs verification
      state = state.copyWith(
        status: AuthStatus.authenticated, // Treat as authenticated
        user: authResponse.user, // Store user (contains isPhoneVerified=false)
      );
      // UI (RegisterScreen) navigates to OTP screen
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated, clearUser: true);
      throw e;
    }
  }

  /// Handles OTP verification.
  Future<void> verifyOtp(String otp, phoneNumber) async {
    // Add specific loading state if desired, e.g., state = state.copyWith(status: AuthStatus.verifyingOtp);
    try {
      await _authService.verifyOtp(otp, phoneNumber);
      // OTP verified, update local user state or refetch profile
       print("OTP Verified! User phone should now be marked as verified.");
      // Best practice: Refetch profile to ensure consistent state
      await _fetchUserProfile();
      // Or manually update if User model has copyWith and isPhoneVerified can be set:
      // if (state.user != null) {
      //   state = state.copyWith(user: state.user!.copyWith(isPhoneVerified: true));
      // }
    } catch (e) {
      print("OTP Verification failed: $e");
       // Reset status if using a specific verifyingOtp status
       // state = state.copyWith(status: AuthStatus.authenticated); // Revert status if needed
      throw e;
    }
  }

  /// Handles user logout.
  Future<void> logout({bool notify = true}) async {
     // Use notify parameter carefully if called internally where state is already being set
     if (notify) {
       state = state.copyWith(status: AuthStatus.authenticating);
     }
    try {
      await _authService.logout();
    } catch (e) {
      print("Error during backend logout: $e");
    } finally {
      // Always clear local state
      state = state.copyWith(status: AuthStatus.unauthenticated, clearUser: true);
    }
  }
}