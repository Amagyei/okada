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
    // --- Logging ---
    print("[AuthNotifier] Initializing...");
    // --- End Logging ---
    checkAuthStatus(); // Check status when notifier is created
  }

  /// Checks secure storage for tokens on app start.
  Future<void> checkAuthStatus() async {
    // --- Logging ---
    print("[AuthNotifier] checkAuthStatus() called.");
    // --- End Logging ---
    // Set state immediately ONLY IF current state is unknown
    if (state.status == AuthStatus.unknown) {
        state = state.copyWith(status: AuthStatus.authenticating);
        // --- Logging ---
        print("[AuthNotifier] State set to authenticating (from unknown).");
        // --- End Logging ---
    } else {
        // Ensure loading state if called again
         state = state.copyWith(status: AuthStatus.authenticating);
         // --- Logging ---
         print("[AuthNotifier] State set to authenticating.");
         // --- End Logging ---
    }

    try {
      final token = await _tokenStorageService.getAccessToken();
      // --- Logging ---
      print("[AuthNotifier] Token check result: ${token != null && token.isNotEmpty ? 'Token Found' : 'No Token Found'}");
      // --- End Logging ---
      if (token != null && token.isNotEmpty) {
        // Token exists, try fetching user profile to validate and get data
        await _fetchUserProfile(); // This updates state internally
         // If fetching profile failed and logged out, ensure status reflects it
        if (state.status != AuthStatus.authenticated) {
           // --- Logging ---
           print("[AuthNotifier] Fetch profile resulted in non-authenticated state, ensuring unauthenticated.");
           // --- End Logging ---
           state = state.copyWith(status: AuthStatus.unauthenticated);
        }
      } else {
        // --- Logging ---
        print("[AuthNotifier] Setting state to unauthenticated (no token).");
        // --- End Logging ---
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      // --- Logging ---
      print("[AuthNotifier] Error during checkAuthStatus: $e. Setting state to unauthenticated.");
      // --- End Logging ---
      state = state.copyWith(status: AuthStatus.unauthenticated, clearUser: true);
    }
    // --- Logging ---
    print("[AuthNotifier] checkAuthStatus() finished. Final state: ${state.status}");
    // --- End Logging ---
  }

  /// Helper to fetch user profile (often needed after login/app start)
  Future<void> _fetchUserProfile() async {
     // --- Logging ---
     print("[AuthNotifier] _fetchUserProfile() called.");
     // --- End Logging ---
    try {
      // TODO: Implement and call _authService.getUserProfile()
      // This should return a User object on success
      // final fetchedUser = await _authService.getUserProfile();
      print("[AuthNotifier] Simulating fetch user profile - ASSUME SUCCESS for example");
      print("[AuthNotifier] Attempting to fetch user profile via AuthService...");
      final fetchedUser = await _authService.getUserProfile();
      state = state.copyWith(status: AuthStatus.authenticated, user: fetchedUser);
      } catch (e) {
        print("[AuthNotifier] Failed to fetch user profile: $e. Logging out.");
        await logout(notify: false); // Logout clears invalid token
        if (state.status != AuthStatus.unauthenticated) {
              state = state.copyWith(status: AuthStatus.unauthenticated, clearUser: true);
        }
      await logout(notify: false); // Logout without double notification
       // Ensure state is marked unauthenticated if logout didn't already trigger it somehow
      if (state.status != AuthStatus.unauthenticated) {
           state = state.copyWith(status: AuthStatus.unauthenticated, clearUser: true);
           // --- Logging ---
           print("[AuthNotifier] State explicitly set to unauthenticated after failed profile fetch.");
           // --- End Logging ---
      }
    }
  }

  /// Handles user login.
  Future<void> login(String phoneNumber, String password) async {
     // --- Logging ---
     print("[AuthNotifier] login() called for $phoneNumber.");
     // --- End Logging ---
    state = state.copyWith(status: AuthStatus.authenticating);
     // --- Logging ---
     print("[AuthNotifier] State set to authenticating (during login).");
     // --- End Logging ---
    try {
      final authResponse = await _authService.login(phoneNumber, password);
      // --- Logging ---
      print("[AuthNotifier] Login API successful. Setting state to authenticated.");
      // --- End Logging ---
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: authResponse.user,
      );
      // Navigation logic based on authResponse.user.isPhoneVerified will happen in the UI/LoginScreen
    } catch (e) {
       // --- Logging ---
       print("[AuthNotifier] Login API failed: $e. Setting state to unauthenticated.");
       // --- End Logging ---
      state = state.copyWith(status: AuthStatus.unauthenticated, clearUser: true);
      rethrow; // Re-throw for UI error handling
    }
     // --- Logging ---
     print("[AuthNotifier] login() finished. Final state: ${state.status}");
     // --- End Logging ---
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
     // --- Logging ---
     print("[AuthNotifier] register() called for $phoneNumber.");
     // --- End Logging ---
     state = state.copyWith(status: AuthStatus.authenticating);
      // --- Logging ---
      print("[AuthNotifier] State set to authenticating (during register).");
      // --- End Logging ---
    try {
      final authResponse = await _authService.register(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        password: password,
        email: email,
        userType: userType,
        username: phoneNumber // Pass phone as username
      );
       // --- Logging ---
       print("[AuthNotifier] Register API successful. Setting state to authenticated.");
       // --- End Logging ---
      state = state.copyWith(
        status: AuthStatus.authenticated, // Treat as authenticated
        user: authResponse.user, // Store user (contains isPhoneVerified=false)
      );
      // UI (RegisterScreen) navigates to OTP screen
    } catch (e) {
       // --- Logging ---
       print("[AuthNotifier] Register API failed: $e. Setting state to unauthenticated.");
       // --- End Logging ---
      state = state.copyWith(status: AuthStatus.unauthenticated, clearUser: true);
      rethrow;
    }
     // --- Logging ---
     print("[AuthNotifier] register() finished. Final state: ${state.status}");
     // --- End Logging ---
  }

  /// Handles OTP verification.
  Future<void> verifyOtp(String otp) async { // Kept phoneNumber based on previous code
     // --- Logging ---
     print("[AuthNotifier] verifyOtp() called for with OTP $otp.");
     // --- End Logging ---
    // Add specific loading state if desired
    try {
      // TODO: Confirm if AuthService.verifyOtp needs phoneNumber
      await _authService.verifyOtp(otp); // Assuming service only needs OTP if backend uses token
       print("[AuthNotifier] verifyOtp API call successful.");
      await _fetchUserProfile(); // Refetch profile to update verification status
    } catch (e) {
       // --- Logging ---
       print("[AuthNotifier] OTP Verification failed: $e");
       // --- End Logging ---
      rethrow;
    }
  }

  /// Handles user logout.
  Future<void> logout({bool notify = true}) async {
     // --- Logging ---
     print("[AuthNotifier] logout() called.");
     // --- End Logging ---
     if (notify && state.status != AuthStatus.authenticating) {
       state = state.copyWith(status: AuthStatus.authenticating);
        // --- Logging ---
        print("[AuthNotifier] State set to authenticating (during logout).");
        // --- End Logging ---
     }
    try {
      await _authService.logout();
       // --- Logging ---
       print("[AuthNotifier] Backend logout finished.");
       // --- End Logging ---
    } catch (e) {
       // --- Logging ---
       print("[AuthNotifier] Error during backend logout: $e");
       // --- End Logging ---
    } finally {
       // --- Logging ---
       print("[AuthNotifier] Setting state to unauthenticated (logout).");
       // --- End Logging ---
      state = state.copyWith(status: AuthStatus.unauthenticated, clearUser: true);
    }
     // --- Logging ---
     print("[AuthNotifier] logout() finished. Final state: ${state.status}");
     // --- End Logging ---
  }

  // Add logs to updateUserProfile and requestOtp if needed for debugging those flows later
  Future<void> updateUserProfile({ required String firstName, required String lastName, String? email }) async { /* ... */ }
  Future<void> requestOtp(String phoneNumber) async { /* ... */ }

} // End of AuthStateNotifier