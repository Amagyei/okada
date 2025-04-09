// lib/data/models/auth_response_model.dart
import 'user_model.dart'; // Import the User model

// Consider adding json_annotation if using code generation
// import 'package:json_annotation/json_annotation.dart';
// part 'auth_response_model.g.dart';
// @JsonSerializable(explicitToJson: true) // explicitToJson needed for nested User

/// Represents the successful response structure from login/registration APIs.
/// Contains authentication tokens and the authenticated User object.
class AuthResponse {
  final String refresh; // Refresh token
  final String access;  // Access token
  final User user;      // Nested User object

  AuthResponse({
    required this.refresh,
    required this.access,
    required this.user,
  });

  /// Factory constructor to create an AuthResponse instance from a JSON map.
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Perform null checks for robustness, although these fields are expected
    final String? refresh = json['refresh'] as String?;
    final String? access = json['access'] as String?;
    final Map<String, dynamic>? userData = json['user'] as Map<String, dynamic>?;

    if (refresh == null || access == null || userData == null) {
        // Log the problematic JSON if possible for debugging
        print("Invalid AuthResponse JSON received: $json");
        throw FormatException("Invalid AuthResponse JSON: Missing required fields (refresh, access, or user).");
    }

    return AuthResponse(
      refresh: refresh,
      access: access,
      // Parse the nested User object using its own factory constructor
      user: User.fromJson(userData),
    );
  }

  // If using json_serializable:
  // factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);
  // Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}
