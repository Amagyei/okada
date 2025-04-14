// lib/core/services/token_storage_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// TokenStorageService: Handles secure storage and retrieval of authentication tokens.
///
/// This service caches tokens in memory to reduce the number of asynchronous
/// storage reads and provides enhanced error handling.
class TokenStorageService {
  // Instance of FlutterSecureStorage for secure storage
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Keys for storing tokens
  static const String _accessTokenKey = 'okada_access_token';
  static const String _refreshTokenKey = 'okada_refresh_token';

  // In-memory caches for tokens
  String? _cachedAccessToken;
  String? _cachedRefreshToken;

  /// Saves both access and refresh tokens securely and updates in-memory caches.
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      await _storage.write(key: _accessTokenKey, value: accessToken);
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
      _cachedAccessToken = accessToken;
      _cachedRefreshToken = refreshToken;
      print("TokenStorageService: Tokens saved successfully.");
    } catch (e) {
      print("TokenStorageService: Error saving tokens - $e");
      rethrow;
    }
  }

  /// Retrieves the stored access token, using in-memory cache if available.
  Future<String?> getAccessToken() async {
    if (_cachedAccessToken != null) {
      return _cachedAccessToken;
    }
    try {
      _cachedAccessToken = await _storage.read(key: _accessTokenKey);
      return _cachedAccessToken;
    } catch (e) {
      print("TokenStorageService: Error reading access token - $e");
      rethrow;
    }
  }

  /// Retrieves the stored refresh token, using in-memory cache if available.
  Future<String?> getRefreshToken() async {
    if (_cachedRefreshToken != null) {
      return _cachedRefreshToken;
    }
    try {
      _cachedRefreshToken = await _storage.read(key: _refreshTokenKey);
      return _cachedRefreshToken;
    } catch (e) {
      print("TokenStorageService: Error reading refresh token - $e");
      rethrow;
    }
  }

  /// Deletes both access and refresh tokens from secure storage and clears the in-memory cache.
  Future<void> deleteTokens() async {
    try {
      await _storage.delete(key: _accessTokenKey);
      await _storage.delete(key: _refreshTokenKey);
      _cachedAccessToken = null;
      _cachedRefreshToken = null;
      print("TokenStorageService: Tokens deleted successfully.");
    } catch (e) {
      print("TokenStorageService: Error deleting tokens - $e");
      rethrow;
    }
  }
}