// lib/core/services/auth_service.dart
import 'dart:convert'; // For jsonEncode, jsonDecode
import 'dart:io';     // For HttpStatus
import 'package:http/http.dart' as http; // Standard HTTP client

// --- Adjust these import paths based on your project structure ---
import '../../data/models/auth_response_model.dart';
import 'token_storage_service.dart'; // Ensure this path is correct
import 'api_client.dart';          // Import the API client setup (with interceptors)
import 'api_error_model.dart'; // Adjust path if needed

/// AuthService: Handles all authentication-related API interactions.
///
/// Uses an intercepted HTTP client (from api_client.dart) to automatically
/// handle authorization headers and token refreshing.
class AuthService {
  // --- Configuration ---
  // Use environment variables for production URLs.
  // Pass during build: flutter build apk --dart-define=API_BASE_URL=https://your.api.domain/api
  final String _baseUrl = const String.fromEnvironment(
      'API_BASE_URL', defaultValue: 'http://10.0.2.2:8000/api'); // Default for Android Emulator

  // --- Services ---
  // Use the globally configured API client with interceptors
  final http.Client _client = createApiClient();
  // Local storage for tokens
  final TokenStorageService _tokenStorageService = TokenStorageService();

  // --- Helper to handle API responses consistently ---
  /// Processes HTTP response, handling success and common error patterns.
  /// Returns decoded JSON body on success, throws Exception on failure.
  dynamic _handleResponse(http.Response response) {
    final dynamic responseBody;
    try {
      responseBody = json.decode(response.body);
    } catch (e) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print("API Warning: Success status code (${response.statusCode}) but invalid JSON body.");
        return null;
      } else {
        print("API Error (${response.statusCode}): Non-JSON response body: ${response.body}");
        throw Exception('Server returned an unexpected error (Status ${response.statusCode}).');
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseBody;
    } else {
      String errorMessage = "An unexpected API error occurred.";
      try {
        final apiError = ApiError.fromJson(responseBody as Map<String, dynamic>);
        errorMessage = apiError.firstError;
      } catch (_) {
        if (responseBody is Map<String, dynamic>) {
          if (responseBody.containsKey('detail')) {
            errorMessage = responseBody['detail'].toString();
          } else if (responseBody.isNotEmpty) {
            var firstValue = responseBody.values.first;
            if (firstValue is List && firstValue.isNotEmpty) {
              errorMessage = firstValue.first.toString();
            } else {
              errorMessage = firstValue.toString();
            }
          }
        } else if (responseBody is String) {
          errorMessage = responseBody;
        }
      }
      print('API Error (${response.statusCode}): $errorMessage');
      throw Exception(errorMessage);
    }
  }

  // --- Login Method ---
  Future<AuthResponse> login(String phoneNumber, String password) async {
    final url = Uri.parse('$_baseUrl/auth/login/');
    print('AuthService: Attempting login for $phoneNumber');

    try {
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'}, 
        body: json.encode({
          'phone_number': phoneNumber,
          'password': password,
        }),
      );

      final responseBody = _handleResponse(response);
      final authResponse = AuthResponse.fromJson(responseBody);

      await _tokenStorageService.saveTokens(
        accessToken: authResponse.access,
        refreshToken: authResponse.refresh,
      );
      print('AuthService: Login successful, tokens saved.');
      await requestOtp(); // Request OTP after successful login
      return authResponse;
    } catch (e) {
      print("AuthService: Login failed - $e");
      if (e is! Exception) {
        throw Exception('Unable to connect. Please check network.');
      }
      rethrow;
    }
  }

  // --- Registration Method ---
  Future<AuthResponse> register({
    required String password,
    required String phoneNumber,
    required String firstName,
    required String lastName,
    required String userType, // 'rider' or 'driver'
    String? email,
    String? username,

  }) async {
    final url = Uri.parse('$_baseUrl/users/');

    try {
      final Map<String, dynamic> requestBody = {
        'username': phoneNumber,
        'password': password,
        'phone_number': phoneNumber,
        'first_name': firstName,
        'last_name': lastName,
        'user_type': userType,
      };
      if (email != null && email.isNotEmpty) {
        requestBody['email'] = email;
      }

      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'}, 
        body: json.encode(requestBody),
      );

      final responseBody = _handleResponse(response);
      final authResponse = AuthResponse.fromJson(responseBody);

      await _tokenStorageService.saveTokens(
        accessToken: authResponse.access,
        refreshToken: authResponse.refresh,
      );
      print('AuthService: Registration successful, tokens saved.');
      return authResponse;
    } catch (e) {
      print("AuthService: Registration failed - $e");
      if (e is! Exception) {
        throw Exception('Unable to connect. Please check network.');
      }
      rethrow;
    }
  }

  // --- Request OTP ---
  Future<void> requestOtp() async {
    final url = Uri.parse('$_baseUrl/auth/otp/request/');
    print('AuthService: Requesting OTP');
    try {
      final response = await _client.post(url);
      _handleResponse(response);
      print('AuthService: OTP Request successful.');
    } catch (e) {
      print("AuthService: OTP Request failed - $e");
      if (e is! Exception) {
        throw Exception('Unable to connect. Please check network.');
      }
      rethrow;
    }
  }

  // --- Verify OTP ---
  Future<void> verifyOtp(String otp) async {
    final url = Uri.parse('$_baseUrl/auth/otp/verify/');
    print('AuthService: Verifying OTP $otp');

    try {
      final response = await _client.post(
        url,
        body: json.encode({
          'otp': otp,
        }),
      );
      _handleResponse(response);
      print('AuthService: OTP Verification successful.');
    } catch (e) {
      print("AuthService: OTP Verification failed - $e");
      if (e is! Exception) {
        throw Exception('Unable to connect. Please check network.');
      }
      rethrow;
    }
  }

  // --- Password Reset Request ---
  Future<void> requestPasswordReset(String phoneNumber) async {
    final url = Uri.parse('$_baseUrl/auth/password/reset/request/');
    print('AuthService: Requesting password reset for $phoneNumber');
    try {
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'phone_number': phoneNumber}),
      );
      _handleResponse(response);
      print('AuthService: Password Reset Request successful.');
    } catch (e) {
      print("AuthService: Password Reset Request failed - $e");
      if (e is! Exception) {
        throw Exception('Unable to connect. Please check network.');
      }
      rethrow;
    }
  }

  // --- Password Reset Confirmation ---
  Future<void> confirmPasswordReset({
    required String phoneNumber,
    required String otp,
    required String newPassword,
  }) async {
    final url = Uri.parse('$_baseUrl/auth/password/reset/confirm/');
    print('AuthService: Confirming password reset for $phoneNumber');
    try {
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phone_number': phoneNumber,
          'otp': otp,
          'new_password': newPassword,
        }),
      );
      _handleResponse(response);
      print('AuthService: Password Reset Confirmation successful.');
    } catch (e) {
      print("AuthService: Password Reset Confirmation failed - $e");
      if (e is! Exception) {
        throw Exception('Unable to connect. Please check network.');
      }
      rethrow;
    }
  }

  // --- Logout ---
  Future<void> logout() async {
    print('AuthService: Performing logout.');
    final String? refreshToken = await _tokenStorageService.getRefreshToken();

    if (refreshToken != null) {
      final url = Uri.parse('$_baseUrl/auth/logout/');
      try {
        await _client.post(
          url,
          body: json.encode({'refresh': refreshToken}),
        );
        print('AuthService: Backend logout call successful or token already invalid.');
      } catch (e) {
        print("AuthService: Backend logout failed (token might be already invalid/expired): $e");
      }
    }

    await _tokenStorageService.deleteTokens();
    print('AuthService: Local tokens deleted.');
  }

  // --- Check Authentication Status ---
  Future<bool> isAuthenticated() async {
    final token = await _tokenStorageService.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // --- Dispose ---
  void dispose() {
    _client.close();
    print("AuthService disposed, client closed.");
  }
}