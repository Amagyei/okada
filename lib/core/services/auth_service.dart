// lib/core/services/auth_service.dart

import 'dart:convert'; // For jsonEncode, jsonDecode
import 'dart:io';     // For HttpStatus and SocketException
import 'package:http/http.dart' as http; // Standard HTTP client

// Adjust these import paths based on your project structure
import '../../data/models/auth_response_model.dart';
import '../../data/models/user_model.dart'; // Import User model
import 'token_storage_service.dart';
import 'api_client.dart';          // Import the API client setup (with interceptors)
import 'api_error_model.dart';

// Needed if reading provider here
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  // --- Configuration ---
  final String _baseUrl = dotenv.env['API_BASE_URL']!;
  // --- Services ---
  final http.Client _client = createApiClient(); // Use intercepted client
  final TokenStorageService _tokenStorageService = TokenStorageService();

  // --- Helper to handle API responses consistently ---
  dynamic _handleResponse(http.Response response) {
    // (Keep the existing _handleResponse method as defined previously)
    final dynamic responseBody;
    try {
      // Handle cases where backend might return empty body on success (e.g., 204 No Content)
      if (response.body.isEmpty && response.statusCode >= 200 && response.statusCode < 300) {
         return null; // Return null for empty success responses
      }
      responseBody = json.decode(response.body);
    } catch (e) {
      // If decoding fails on a non-success status code, throw a generic error
      if (response.statusCode < 200 || response.statusCode >= 300) {
         print("API Error (${response.statusCode}): Non-JSON response body: ${response.body}");
         throw Exception('Server returned an unexpected error (Status ${response.statusCode}).');
      }
      // If decoding fails on success, return null or handle as needed
      print("API Warning: Success status code (${response.statusCode}) but invalid JSON body.");
      return null;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseBody; // Return decoded body on success
    } else {
      // Handle error responses
      String errorMessage = "An unexpected API error occurred.";
      try {
        // Try parsing structured error first
        final apiError = ApiError.fromJson(responseBody as Map<String, dynamic>);
        errorMessage = apiError.firstError;
      } catch (_) {
         // Fallback parsing for various error formats
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
      // Throw the specific error message extracted
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
        // Interceptor adds token if present, login view ignores it but middleware might not
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phone_number': phoneNumber,
          'password': password,
        }),
      );

      // Throws exception on non-200 response
      final responseBody = _handleResponse(response);
      final authResponse = AuthResponse.fromJson(responseBody);

      await _tokenStorageService.saveTokens(
        accessToken: authResponse.access,
        refreshToken: authResponse.refresh,
      );
      print('AuthService: Login successful, tokens saved.');
      return authResponse;

    } on Exception catch (e) { // Catch specific Exception from _handleResponse or client errors
      print("AuthService: Login failed - $e");

      // --- Add specific check for 401-like errors during LOGIN ---
      String errorString = e.toString().toLowerCase();
      if (errorString.contains('unauthorized') ||
          errorString.contains('401') ||
          errorString.contains('token not valid') ||
          errorString.contains('authentication credentials were not provided'))
      {
        print("AuthService: Login failed likely due to invalid/stale token being sent. Clearing stored tokens.");
        // Clear potentially stale tokens if login fails due to auth issue
        await _tokenStorageService.deleteTokens();
        // Throw a specific error message
        throw Exception('Login failed. Please try again. (Session cleared)');
      }
      // --- End Add ---

      // Re-throw other specific exceptions (like those from _handleResponse)
      rethrow;
    } catch (e) { // Catch other potential errors (network, etc.)
       print("AuthService: Unexpected error during login - $e");
       if (e is SocketException) {
          throw Exception('Unable to connect. Please check network.');
       }
       // Re-throw other types of errors
       rethrow;
    }
  }

  // --- Registration Method ---
  Future<AuthResponse> register({
    required String password,
    required String phoneNumber,
    required String firstName,
    required String lastName,
    required String userType,
    String? email,
    String? username,
  }) async {
    final url = Uri.parse('$_baseUrl/users/');
    print('AuthService: Attempting registration for $phoneNumber');

    try {
      final Map<String, dynamic> requestBody = {
        'username': username ?? phoneNumber,
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

    } on Exception catch (e) { // Catch specific Exception
      print("AuthService: Registration failed - $e");

      // --- Specific check for 401-like errors during REGISTER ---
      String errorString = e.toString().toLowerCase();
      if (errorString.contains('unauthorized') ||
          errorString.contains('401') ||
          errorString.contains('token not valid') ||
          errorString.contains('authentication credentials were not provided'))
      {
        print("AuthService: Registration failed likely due to invalid token. Clearing stored tokens.");
        await _tokenStorageService.deleteTokens();
        throw Exception('Registration failed. Please try again. (Session cleared)');
      }
      // --- End Add ---
      rethrow; // Re-throw other specific exceptions
    } catch (e) { // Catch other potential errors
       print("AuthService: Unexpected error during registration - $e");
       if (e is SocketException) {
          throw Exception('Unable to connect. Please check network.');
       }
       rethrow;
    }
  }

  // --- Get User Profile Method ---
  Future<User> getUserProfile() async {
    final url = Uri.parse('$_baseUrl/users/me/');
    print('AuthService: Fetching user profile from $url');
    try {
      final response = await _client.get(url); // Interceptor adds token
      final responseBody = _handleResponse(response); // Handles errors (like 401)
      final user = User.fromJson(responseBody as Map<String, dynamic>);
      print('AuthService: User profile fetched successfully for ${user.username}');
      return user;
    } catch (e) {
      print("AuthService: Failed to get user profile - $e");
      rethrow; // Propagate error to notifier
    }
  }

  // --- Request OTP Method ---
  Future<void> requestOtp({required String phoneNumber}) async {
    final url = Uri.parse('$_baseUrl/auth/otp/request/');
    print('AuthService: Requesting OTP for $phoneNumber');
    try {
      final response = await _client.post(
        url,
        // This endpoint is AllowAny, but interceptor might still add token if present
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'phone_number': phoneNumber}),
      );
      _handleResponse(response); // Check for success/failure
      print('AuthService: OTP Request successful.');
    } catch (e) {
      print("AuthService: OTP Request failed - $e");
      if (e is! Exception) { // Handle non-Exception errors if needed
           throw Exception('Unable to connect. Please check network.');
      }
      rethrow;
    }
  }

  // --- Verify OTP Method ---
  // Assumes backend uses IsAuthenticated and gets user from token
  Future<void> verifyOtp(String otp) async {
    final url = Uri.parse('$_baseUrl/auth/otp/verify/');
    print('AuthService: Verifying OTP $otp');
    try {
      final response = await _client.post( // Interceptor adds token
        url,
        headers: {'Content-Type': 'application/json'}, // Ensure content type
        body: json.encode({'otp': otp}),
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

  // --- Password Reset Request Method ---
  Future<void> requestPasswordReset(String phoneNumber) async {
    final url = Uri.parse('$_baseUrl/auth/password/reset/request/');
    print('AuthService: Requesting password reset for $phoneNumber');
    try {
      // No auth token needed for this request usually
      final response = await http.post( // Use plain http client or ensure interceptor doesn't add token
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'phone_number': phoneNumber}),
      );
      // Use _handleResponse or manual status check
      if (response.statusCode < 200 || response.statusCode >= 300) {
          // Attempt to parse error, fallback to status code
          String errorMsg = "Error ${response.statusCode}";
          try { errorMsg = jsonDecode(response.body)['detail'] ?? errorMsg; } catch (_) {}
          throw Exception("Password reset request failed: $errorMsg");
      }
      print('AuthService: Password Reset Request successful.');
    } catch (e) {
      print("AuthService: Password Reset Request failed - $e");
       if (e is! Exception) {
           throw Exception('Unable to connect. Please check network.');
       }
      rethrow;
    }
  }

  // --- Password Reset Confirmation Method ---
  Future<void> confirmPasswordReset({
    required String phoneNumber,
    required String otp,
    required String newPassword,
  }) async {
    final url = Uri.parse('$_baseUrl/auth/password/reset/confirm/');
    print('AuthService: Confirming password reset for $phoneNumber');
    try {
       // No auth token needed
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phone_number': phoneNumber,
          'otp': otp,
          'new_password': newPassword,
        }),
      );
       if (response.statusCode < 200 || response.statusCode >= 300) {
          String errorMsg = "Error ${response.statusCode}";
          try { errorMsg = jsonDecode(response.body)['detail'] ?? errorMsg; } catch (_) {}
          throw Exception("Password reset confirmation failed: $errorMsg");
       }
      print('AuthService: Password Reset Confirmation successful.');
    } catch (e) {
      print("AuthService: Password Reset Confirmation failed - $e");
       if (e is! Exception) {
           throw Exception('Unable to connect. Please check network.');
       }
      rethrow;
    }
  }


  // --- Logout Method ---
  Future<void> logout() async {
    print('AuthService: Performing logout.');
    final String? refreshToken = await _tokenStorageService.getRefreshToken();

    // Attempt backend logout first (optional but good practice)
    if (refreshToken != null) {
      final url = Uri.parse('$_baseUrl/auth/logout/');
      try {
        // Use intercepted client as logout might require auth on some backends
        // Or use plain client if backend logout is public but takes refresh token
        await _client.post(
          url,
           headers: {'Content-Type': 'application/json'}, // Ensure content type
          body: json.encode({'refresh': refreshToken}),
        );
        print('AuthService: Backend logout call successful or token already invalid.');
      } catch (e) {
        // Log error but proceed with local logout regardless
        print("AuthService: Backend logout failed (token might be already invalid/expired): $e");
      }
    }

    // Always delete local tokens
    await _tokenStorageService.deleteTokens();
    print('AuthService: Local tokens deleted.');
  }

  // --- Check Authentication Status Helper ---
  Future<bool> isAuthenticated() async {
    final token = await _tokenStorageService.getAccessToken();
    // Basic check - a more robust check involves verifying token expiry or calling backend
    return token != null && token.isNotEmpty;
  }

  // --- Dispose ---
  // Close the HTTP client when the service is no longer needed
  // This is typically handled when the Provider is disposed if using Riverpod's autoDispose
  void dispose() {
    try {
       _client.close();
       print("AuthService disposed, HTTP client closed.");
    } catch(e) {
       print("Error closing HTTP client: $e");
    }
  }
}
