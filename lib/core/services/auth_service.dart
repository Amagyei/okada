// lib/core/services/auth_service.dart
import 'dart:convert'; // For jsonEncode, jsonDecode
import 'dart:io';     // For File, HttpStatus and SocketException
import 'package:http/http.dart' as http; // Standard HTTP client
import 'package:http_parser/http_parser.dart'; // For MediaType
import 'package:path/path.dart' as p; // For getting file extension
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

// Adjust these import paths based on your project structure
import '../../data/models/auth_response_model.dart';
import '../../data/models/user_model.dart';
import 'token_storage_service.dart';
import 'api_client.dart';          // Import the API client setup (with interceptors)
import 'api_error_model.dart';
// Removed direct dotenv import, baseUrl is now injected

class AuthService {
  // --- Configuration ---
  final String _baseUrl; 
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  // --- Services ---
  final http.Client _client = createApiClient(); // Use intercepted client
  final TokenStorageService _tokenStorageService = TokenStorageService();

  // Constructor that accepts the base URL (injected by Riverpod provider)
  AuthService(this._baseUrl) {
    print("[AuthService] Initialized with baseUrl: $_baseUrl");
    if (_baseUrl == 'MISSING_BASE_URL' || _baseUrl.isEmpty) {
        print("[AuthService] CRITICAL WARNING: AuthService initialized with an invalid baseUrl: $_baseUrl");
        // Consider throwing an exception here or having a fallback,
        // but this should ideally be caught during app startup (main_dev.dart)
    }
  }


  // --- Helper to handle API responses consistently ---
  dynamic _handleResponse(http.Response response) {
    final dynamic responseBody;
    try {
      if (response.body.isEmpty && response.statusCode >= 200 && response.statusCode < 300) {
         return null;
      }
      responseBody = json.decode(response.body);
    } catch (e) {
      if (response.statusCode < 200 || response.statusCode >= 300) {
         print("API Error (${response.statusCode}): Non-JSON response body: ${response.body}");
         throw Exception('Server returned an unexpected error (Status ${response.statusCode}).');
      }
      print("API Warning: Success status code (${response.statusCode}) but invalid JSON body.");
      return null;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseBody;
    } else {
      String errorMessage = "An unexpected API error occurred.";
      try {
        // Try parsing structured error first
        final apiError = ApiError.fromJson(responseBody as Map<String, dynamic>);
        errorMessage = apiError.firstError;
      } catch (_) {
         // Fallback parsing for various error formats
         if (responseBody is Map<String, dynamic>) {
           if (responseBody.containsKey('detail')) { errorMessage = responseBody['detail'].toString(); }
           else if (responseBody.isNotEmpty) { var firstValue = responseBody.values.first; if (firstValue is List && firstValue.isNotEmpty) { errorMessage = firstValue.first.toString(); } else { errorMessage = firstValue.toString(); } }
         } else if (responseBody is String) { errorMessage = responseBody; }
      }
      print('API Error (${response.statusCode}): $errorMessage');
      throw Exception(errorMessage);
    }
  }


  // --- Login Method ---
  Future<AuthResponse> login(String phoneNumber, String password) async {
    final url = Uri.parse('$_baseUrl/auth/login/');
    print('AuthService: Attempting login for $phoneNumber using $_baseUrl');
    try {
      final fcmToken = await _fcm.getToken();
      print('AuthService: FCM token: $fcmToken');
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'phone_number': phoneNumber, 'password': password, 'fcm_token': fcmToken}),
      );
      final responseBody = _handleResponse(response);
      final authResponse = AuthResponse.fromJson(responseBody);
      await _tokenStorageService.saveTokens(accessToken: authResponse.access, refreshToken: authResponse.refresh);
      print('AuthService: Login successful, tokens saved.');
      return authResponse;
    } on Exception catch (e) {
      print("AuthService: Login failed - $e");
      String errorString = e.toString().toLowerCase();
      if (errorString.contains('unauthorized') || errorString.contains('401') || errorString.contains('token not valid') || errorString.contains('authentication credentials were not provided')) {
        print("AuthService: Login failed likely due to invalid/stale token. Clearing stored tokens.");
        await _tokenStorageService.deleteTokens();
        throw Exception('Login failed. Please try again. (Session cleared)');
      }
      rethrow;
    } catch (e) {
       print("AuthService: Unexpected error during login - $e");
       if (e is SocketException) { throw Exception('Unable to connect. Please check network.'); }
       rethrow;
    }
  }

  // --- Registration Method ---
  Future<AuthResponse> register({
    required String password, required String phoneNumber, required String firstName,
    required String lastName, required String userType, String? email, String? username,
  }) async {
    final url = Uri.parse('$_baseUrl/users/');
    print('AuthService: Attempting registration for $phoneNumber using $_baseUrl');
    try {
      final fcmToken = await _fcm.getToken();
      print('AuthService: FCM token: $fcmToken');
      final Map<String, dynamic> requestBody = {
        'username': username ?? phoneNumber, 'password': password, 'phone_number': phoneNumber,
        'first_name': firstName, 'last_name': lastName, 'user_type': userType,
        'fcm_token': fcmToken,
      };
      if (email != null && email.isNotEmpty) { requestBody['email'] = email; }

      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );
      final responseBody = _handleResponse(response);
      final authResponse = AuthResponse.fromJson(responseBody);
      await _tokenStorageService.saveTokens(accessToken: authResponse.access, refreshToken: authResponse.refresh);
      print('AuthService: Registration successful, tokens saved.');
      return authResponse;
    } on Exception catch (e) {
      print("AuthService: Registration failed - $e");
      String errorString = e.toString().toLowerCase();
      if (errorString.contains('unauthorized') || errorString.contains('401') || errorString.contains('token not valid') || errorString.contains('authentication credentials were not provided')) {
        print("AuthService: Registration failed likely due to invalid token. Clearing stored tokens.");
        await _tokenStorageService.deleteTokens();
        throw Exception('Registration failed. Please try again. (Session cleared)');
      }
      rethrow;
    } catch (e) {
       print("AuthService: Unexpected error during registration - $e");
       if (e is SocketException) { throw Exception('Unable to connect. Please check network.'); }
       rethrow;
    }
  }

  // --- Get User Profile Method ---
  Future<User> getUserProfile() async {
    final url = Uri.parse('$_baseUrl/users/me/');
    print('AuthService: Fetching user profile from $url');
    try {
      final response = await _client.get(url);
      final responseBody = _handleResponse(response);
      final user = User.fromJson(responseBody as Map<String, dynamic>);
      print('AuthService: User profile fetched successfully for ${user.username}');
      return user;
    } catch (e) {
      print("AuthService: Failed to get user profile - $e");
      rethrow;
    }
  }

  // --- Update User Profile Method ---
  Future<User> updateUserProfile({
    required String firstName,
    required String lastName,
    String? email,
    String? emergencyContact,
    String? emergencyContactName,
    String? ghanaCardNumber,
    File? profilePictureFile,
    File? ghanaCardImageFile,
  }) async {
    final url = Uri.parse('$_baseUrl/users/me/'); // PATCH to /api/users/me/
    print('AuthService: Updating user profile via $url');

    try {
      var request = http.MultipartRequest('PATCH', url);
      final token = await _tokenStorageService.getAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception("Not authenticated. Cannot update profile.");
      }
      request.headers['Authorization'] = 'Bearer $token';

      // Add text fields only if they are not null and not empty to avoid overwriting with empty
      // This behavior depends on how your backend PATCH handles empty strings vs. nulls
      if (firstName.isNotEmpty) request.fields['first_name'] = firstName;
      if (lastName.isNotEmpty) request.fields['last_name'] = lastName;
      if (email != null && email.isNotEmpty) request.fields['email'] = email;
      if (emergencyContact != null && emergencyContact.isNotEmpty) request.fields['emergency_contact'] = emergencyContact;
      if (emergencyContactName != null && emergencyContactName.isNotEmpty) request.fields['emergency_contact_name'] = emergencyContactName;
      if (ghanaCardNumber != null && ghanaCardNumber.isNotEmpty) request.fields['ghana_card_number'] = ghanaCardNumber;

      if (profilePictureFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profile_picture', // Must match backend field name
          profilePictureFile.path,
          contentType: MediaType('image', p.extension(profilePictureFile.path).substring(1)),
        ));
        print("AuthService: Added profile_picture file to request.");
      }

      if (ghanaCardImageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'ghana_card_image', // Must match backend field name
          ghanaCardImageFile.path,
          contentType: MediaType('image', p.extension(ghanaCardImageFile.path).substring(1)),
        ));
        print("AuthService: Added ghana_card_image file to request.");
      }

      print("AuthService: Sending update profile request with fields: ${request.fields.keys} and files: ${request.files.map((f) => f.field).toList()}");
      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);
      print("AuthService: Update profile response status: ${response.statusCode}");
      print("AuthService: Update profile response body: ${response.body}");

      final responseBody = _handleResponse(response);
      final updatedUser = User.fromJson(responseBody as Map<String, dynamic>);
      print('AuthService: User profile updated successfully for ${updatedUser.username}');
      return updatedUser;

    } on Exception catch (e) {
      print("AuthService: Failed to update profile - $e");
      rethrow;
    } catch (e) {
      print("AuthService: Unexpected error updating profile - $e");
      if (e is SocketException) { throw Exception('Network error. Please check connection.'); }
      throw Exception('An unknown error occurred while updating profile.');
    }
  }
  // --- End Update User Profile Method ---


  // --- Request OTP Method ---
  Future<void> requestOtp({required String phoneNumber}) async {
    final url = Uri.parse('$_baseUrl/auth/otp/request/');
    print('AuthService: Requesting OTP for $phoneNumber');
    try {
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'phone_number': phoneNumber}),
      );
      _handleResponse(response);
      print('AuthService: OTP Request successful.');
    } catch (e) {
      print("AuthService: OTP Request failed - $e");
      if (e is! Exception) { throw Exception('Unable to connect. Please check network.'); }
      rethrow;
    }
  }

  // --- Verify OTP Method ---
  Future<void> verifyOtp(String otp) async {
    final url = Uri.parse('$_baseUrl/auth/otp/verify/');
    print('AuthService: Verifying OTP $otp');
    try {
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'otp': otp}),
      );
      _handleResponse(response);
      print('AuthService: OTP Verification successful.');
    } catch (e) {
      print("AuthService: OTP Verification failed - $e");
       if (e is! Exception) { throw Exception('Unable to connect. Please check network.'); }
      rethrow;
    }
  }

  // --- Password Reset Request Method ---
  Future<void> requestPasswordReset(String phoneNumber) async {
    final url = Uri.parse('$_baseUrl/auth/password/reset/request/');
    print('AuthService: Requesting password reset for $phoneNumber');
    try {
      final response = await http.post( // Use plain http client
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'phone_number': phoneNumber}),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
          String errorMsg = "Error ${response.statusCode}";
          try { errorMsg = jsonDecode(response.body)['detail'] ?? errorMsg; } catch (_) {}
          throw Exception("Password reset request failed: $errorMsg");
      }
      print('AuthService: Password Reset Request successful.');
    } catch (e) {
      print("AuthService: Password Reset Request failed - $e");
       if (e is! Exception) { throw Exception('Unable to connect. Please check network.'); }
      rethrow;
    }
  }

  // --- Password Reset Confirmation Method ---
  Future<void> confirmPasswordReset({
    required String phoneNumber, required String otp, required String newPassword,
  }) async {
    final url = Uri.parse('$_baseUrl/auth/password/reset/confirm/');
    print('AuthService: Confirming password reset for $phoneNumber');
    try {
      final response = await http.post( // Use plain http client
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'phone_number': phoneNumber, 'otp': otp, 'new_password': newPassword}),
      );
       if (response.statusCode < 200 || response.statusCode >= 300) {
          String errorMsg = "Error ${response.statusCode}";
          try { errorMsg = jsonDecode(response.body)['detail'] ?? errorMsg; } catch (_) {}
          throw Exception("Password reset confirmation failed: $errorMsg");
       }
      print('AuthService: Password Reset Confirmation successful.');
    } catch (e) {
      print("AuthService: Password Reset Confirmation failed - $e");
       if (e is! Exception) { throw Exception('Unable to connect. Please check network.'); }
      rethrow;
    }
  }

  // --- Logout Method ---
  Future<void> logout() async {
    print('AuthService: Performing logout.');
    final String? refreshToken = await _tokenStorageService.getRefreshToken();
    if (refreshToken != null) {
      final url = Uri.parse('$_baseUrl/auth/logout/');
      try {
        await _client.post(
          url,
           headers: {'Content-Type': 'application/json'},
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

  // --- Check Authentication Status Helper ---
  Future<bool> isAuthenticated() async {
    final token = await _tokenStorageService.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // --- Update FCM Token Method ---
  Future<void> updateFcmToken(String token) async {
    final url = Uri.parse('$_baseUrl/users/me/fcm_token/');
    print('AuthService: Updating FCM token');
    try {
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'fcm_token': token}),
      );
      _handleResponse(response);
      print('AuthService: FCM token updated successfully');
    } catch (e) {
      print("AuthService: Failed to update FCM token - $e");
      rethrow;
    }
  }


  // A helper function to get the device token
  Future<String?> getDeviceToken() async {
    // This condition checks if you are in debug mode AND running on an iOS device/simulator
    if (kDebugMode && Platform.isIOS) {
      // Since you don't have a Developer Account, we bypass the real getToken() call
      print("--- iOS-DEBUG: Returning a FAKE FCM token. Push notifications will NOT work. ---");
      return "fake-ios-token-for-development-only";
    }

    // This is the normal code that will run on Android and in production
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      print("FCM Token: $fcmToken");
      return fcmToken;
    } catch (e) {
      print("An error occurred while getting FCM token: $e");
      rethrow; // Rethrow the error to be handled by the login logic
    }
  }

  // --- Dispose ---
  void dispose() {
    try { _client.close(); print("AuthService disposed, HTTP client closed.");
    } catch(e) { print("Error closing HTTP client: $e"); }
  }
}
