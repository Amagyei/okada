// lib/core/services/api_client.dart
import 'dart:convert'; // For jsonEncode/Decode and utf8
import 'package:http/http.dart' as http;
import 'package:http_interceptor/http_interceptor.dart';
import 'token_storage_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Interceptor for adding the Authorization header.
class AuthInterceptor implements InterceptorContract {
  final TokenStorageService _tokenStorageService = TokenStorageService();

  @override
  Future<http.BaseRequest> interceptRequest({required http.BaseRequest request}) async {
    final token = await _tokenStorageService.getAccessToken();
    if (token != null && token.isNotEmpty) {
      print("[AuthInterceptor] Adding Auth Header for request to ${request.url}"); // Add log
      request.headers.putIfAbsent('Authorization', () => 'Bearer $token');
    } else {
       print("[AuthInterceptor] No token found, NOT adding Auth Header for request to ${request.url}"); // Add log
    }
    // Explicitly set content-type and accept headers
    request.headers.putIfAbsent('Content-Type', () => 'application/json');
    request.headers.putIfAbsent('Accept', () => 'application/json');
    return request;
  }

  @override
  Future<http.BaseResponse> interceptResponse({required http.BaseResponse response}) async {
    return response;
  }

  @override
  Future<bool> shouldInterceptRequest() async => true;

  @override
  Future<bool> shouldInterceptResponse() async => true;
}

/// Interceptor for handling 401 errors by refreshing the token.
/// Uses a shared Future so that concurrent 401 responses trigger only one refresh.
class TokenRefreshInterceptor implements InterceptorContract {
  final TokenStorageService _tokenStorageService = TokenStorageService();
  // Holds a shared Future for the token refresh operation.
  Future<String?>? _refreshFuture;
  final String _baseUrl = dotenv.env['API_BASE_URL']!;

  @override
  Future<http.BaseRequest> interceptRequest({required http.BaseRequest request}) async {
    return request;
  }

  @override
  Future<http.BaseResponse> interceptResponse({required http.BaseResponse response}) async {
    if (response is http.Response && response.statusCode == 401) {
      final originalRequest = response.request;
      // If this is the refresh token request itself, logout.
      if (originalRequest != null &&
          originalRequest.url.toString().contains('/auth/token/refresh/')) {
        print('TokenRefreshInterceptor: Refresh token request failed with 401. Logging out.');
        await _logout();
        return response;
      }

      // If a refresh is already in progress, wait for it.
      _refreshFuture ??= _refreshToken();
      final newAccessToken = await _refreshFuture;
      _refreshFuture = null; // Clear future for future 401's

      if (newAccessToken != null && originalRequest != null) {
        print('TokenRefreshInterceptor: Token refreshed. Retrying original request.');
        // Update Authorization header with new token.
        final headers = Map<String, String>.from(originalRequest.headers);
        headers['Authorization'] = 'Bearer $newAccessToken';

        // Ensure method is a String and URL is a Uri.
        final String method = originalRequest.method.toString();
        final Uri url = originalRequest.url is Uri
            ? originalRequest.url
            : Uri.parse(originalRequest.url.toString());

        final plainClient = http.Client();
        try {
          http.StreamedResponse streamedResponse;
          if (originalRequest is http.Request) {
            final retryRequest = http.Request(method, url)
              ..headers.addAll(headers)
              ..encoding = originalRequest.encoding ?? utf8
              ..body = originalRequest.body;
            streamedResponse = await plainClient.send(retryRequest)
                .timeout(const Duration(seconds: 30));
          } else {
            // For non-Request types, construct a basic Request
            final retryRequest = http.Request(method, url)
              ..headers.addAll(headers);
            streamedResponse = await plainClient.send(retryRequest)
                .timeout(const Duration(seconds: 30));
          }
          final retriedResponse = await http.Response.fromStream(streamedResponse);
          print('TokenRefreshInterceptor: Retried request returned status: ${retriedResponse.statusCode}');
          return retriedResponse;
        } catch (e) {
          print("TokenRefreshInterceptor: Error retrying request: $e");
        } finally {
          plainClient.close();
        }
      } else {
        print('TokenRefreshInterceptor: Token refresh failed. Logging out.');
        await _logout();
      }
    }
    return response;
  }

  @override
  Future<bool> shouldInterceptRequest() async => true;

  @override
  Future<bool> shouldInterceptResponse() async => true;

  /// Attempts to refresh the access token using the current refresh token.
  Future<String?> _refreshToken() async {
    final String? currentRefreshToken = await _tokenStorageService.getRefreshToken();
    if (currentRefreshToken == null) {
      print("TokenRefreshInterceptor: No refresh token found.");
      return null;
    }

    final url = Uri.parse('$_baseUrl/auth/token/refresh/');
    print("TokenRefreshInterceptor: Attempting token refresh via $url");
    final plainClient = http.Client();
    try {
      final response = await plainClient.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refresh': currentRefreshToken}),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final newAccessToken = responseBody['access'];
        final newRefreshToken = responseBody.containsKey('refresh')
            ? responseBody['refresh']
            : currentRefreshToken;
        if (newAccessToken != null) {
          await _tokenStorageService.saveTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
          );
          print("TokenRefreshInterceptor: Tokens refreshed and saved.");
          return newAccessToken;
        }
      } else {
        print('TokenRefreshInterceptor: Token refresh failed with status: ${response.statusCode}');
        if (response.statusCode == 401) {
          await _logout();
        }
      }
    } catch (e) {
      print("TokenRefreshInterceptor: Exception during token refresh: $e");
    } finally {
      plainClient.close();
    }
    return null;
  }

  /// Logs out the user by deleting stored tokens.
  Future<void> _logout() async {
    await _tokenStorageService.deleteTokens();
    print("TokenRefreshInterceptor: User logged out.");
    // Optionally, you can add additional logout handling here, like navigation.
  }
}

/// Factory method to create an HTTP client with the defined interceptors.
http.Client createApiClient() {
  return InterceptedClient.build(
    interceptors: [
      AuthInterceptor(),
      TokenRefreshInterceptor(),
    ],
    requestTimeout: const Duration(seconds: 30),
  );
}