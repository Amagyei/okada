// lib/data/models/user_model.dart

// Consider adding json_annotation if using code generation
// import 'package:json_annotation/json_annotation.dart';
// part 'user_model.g.dart'; // Code generation part file
// @JsonSerializable()

/// Represents the User data received from the backend API.
/// Matches the structure returned by the Django UserSerializer.
class User {
  final int id;
  final String username;
  final String email; // Ensure backend handles potential null/empty string
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String? profilePicture; // Nullable if it can be absent in the JSON
  final String userType; // 'rider' or 'driver'
  final String? rating; // Often returned as String from DecimalField
  final int? totalTrips; // Often returned as int

  // Flags indicating verification status
  final bool isPhoneVerified;
  final bool isEmailVerified;

  // Optional emergency contact info
  final String? emergencyContact;
  final String? emergencyContactName;


  User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    this.profilePicture,
    required this.userType,
    this.rating,
    this.totalTrips,
    required this.isPhoneVerified,
    required this.isEmailVerified,
    this.emergencyContact,
    this.emergencyContactName,
  });

  /// Factory constructor to create a User instance from a JSON map.
  /// Provides default values or handles nulls defensively.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int? ?? 0, // Provide default if ID can be null (unlikely)
      username: json['username'] as String? ?? '', // Default to empty if null
      email: json['email'] as String? ?? '', // Default to empty if null
      firstName: json['first_name'] as String? ?? '', // Default to empty if null
      lastName: json['last_name'] as String? ?? '', // Default to empty if null
      phoneNumber: json['phone_number'] as String? ?? '', // Default to empty if null
      profilePicture: json['profile_picture'] as String?, // Keep as null if absent
      userType: json['user_type'] as String? ?? 'rider', // Default type if needed
      rating: json['rating'] as String?, // Keep as null if absent
      totalTrips: json['total_trips'] as int?, // Keep as null if absent
      isPhoneVerified: json['is_phone_verified'] as bool? ?? false, // Default to false
      isEmailVerified: json['is_email_verified'] as bool? ?? false, // Default to false
      emergencyContact: json['emergency_contact'] as String?, // Keep as null
      emergencyContactName: json['emergency_contact_name'] as String?, // Keep as null
    );
  }

  // If using json_serializable:
  // factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  // Map<String, dynamic> toJson() => _$UserToJson(this);

  /// Helper getter for display name.
  String get fullName => '$firstName $lastName'.trim();
}
