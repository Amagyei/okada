// lib/data/models/user_model.dart

import 'package:flutter/foundation.dart'; // For @immutable if desired
// You might want a LatLng class if you parse current_location
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// Helper function to safely parse doubles from various types
double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

// Helper function to safely parse integers
int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

// Helper function to safely parse booleans
bool? _parseBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is String) return value.toLowerCase() == 'true';
  if (value is int) return value == 1;
  return null;
}


@immutable
class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String? profilePicture; // URL string
  final String userType; // 'rider' or 'driver'

  // Verification & Profile Status
  final bool isPhoneVerified;
  final bool isEmailVerified;
  final String? rating; // Stored as DecimalField (String) in Django, parsed to double on use
  final int? totalTrips;

  // Common Optional Fields
  final String? emergencyContact;
  final String? emergencyContactName;

  // New Fields (Potentially Nullable)
  final String? ghanaCardNumber;
  final String? ghanaCardImage; // URL string

  // Driver-Specific Fields (Nullable)
  final bool? isOnline;
  // For simplicity, keep as Map. Could be a dedicated LatLng class.
  final Map<String, dynamic>? currentLocation; // e.g., {'latitude': 5.0, 'longitude': -0.1}
  final String? vehicleType;
  final String? vehicleNumber;
  final String? vehicleColor;
  final String? vehicleModel;
  final int? vehicleYear;

  // Rider-Specific Fields (Nullable)
  // final Map<String, dynamic>? savedLocationsData; // This was in Django model, but you have a SavedLocation model now.
                                                 // Usually, this would be a list of SavedLocation objects fetched separately.
                                                 // Keeping it if your API directly embeds this.
  final String? preferredPaymentMethod;

  const User({
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
    this.ghanaCardNumber,
    this.ghanaCardImage,
    this.isOnline,
    this.currentLocation,
    this.vehicleType,
    this.vehicleNumber,
    this.vehicleColor,
    this.vehicleModel,
    this.vehicleYear,
    // this.savedLocationsData,
    this.preferredPaymentMethod,
  });

  String get fullName => '$firstName $lastName'.trim();

  double? get numericRating {
    if (rating == null) return null;
    return double.tryParse(rating!);
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: _parseInt(json['id']) ?? 0,
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      profilePicture: json['profile_picture'] as String?,
      userType: json['user_type'] as String? ?? 'rider',
      rating: json['rating'] as String?, // Keep as String, parse with getter
      totalTrips: _parseInt(json['total_trips']),
      isPhoneVerified: _parseBool(json['is_phone_verified']) ?? false,
      isEmailVerified: _parseBool(json['is_email_verified']) ?? false,
      emergencyContact: json['emergency_contact'] as String?,
      emergencyContactName: json['emergency_contact_name'] as String?,
      ghanaCardNumber: json['ghana_card_number'] as String?,
      ghanaCardImage: json['ghana_card_image'] as String?,
      isOnline: _parseBool(json['is_online']),
      currentLocation: json['current_location'] as Map<String, dynamic>?,
      vehicleType: json['vehicle_type'] as String?,
      vehicleNumber: json['vehicle_number'] as String?,
      vehicleColor: json['vehicle_color'] as String?,
      vehicleModel: json['vehicle_model'] as String?,
      vehicleYear: _parseInt(json['vehicle_year']),
      // savedLocationsData: json['saved_locations_data'] as Map<String, dynamic>?,
      preferredPaymentMethod: json['preferred_payment_method'] as String?,
    );
  }

  // Method to convert User object to a Map for PATCH requests (only include updatable fields)
  Map<String, dynamic> toUpdateJson() {
    final Map<String, dynamic> data = {};
    // Fields that are typically user-updatable
    // Note: Do not include read-only fields like id, username, user_type, phone_number (usually requires re-verification)
    if (email.isNotEmpty) data['email'] = email; // Assuming email can be updated
    if (firstName.isNotEmpty) data['first_name'] = firstName;
    if (lastName.isNotEmpty) data['last_name'] = lastName;
    if (emergencyContact != null) data['emergency_contact'] = emergencyContact;
    if (emergencyContactName != null) data['emergency_contact_name'] = emergencyContactName;
    if (ghanaCardNumber != null) data['ghana_card_number'] = ghanaCardNumber;
    // profile_picture and ghana_card_image are handled as Files in multipart requests, not directly in JSON
    // Driver specific updatable fields (if applicable for user to update directly)
    // if (isOnline != null) data['is_online'] = isOnline; // Usually updated via a separate action
    // if (vehicleType != null) data['vehicle_type'] = vehicleType;
    // ... add other driver fields if user can update them via this profile PATCH
    return data;
  }

  // Optional: copyWith method for immutability
  User copyWith({
    int? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    ValueGetter<String?>? profilePicture, // Use ValueGetter for nullable fields
    String? userType,
    ValueGetter<String?>? rating,
    ValueGetter<int?>? totalTrips,
    bool? isPhoneVerified,
    bool? isEmailVerified,
    ValueGetter<String?>? emergencyContact,
    ValueGetter<String?>? emergencyContactName,
    ValueGetter<String?>? ghanaCardNumber,
    ValueGetter<String?>? ghanaCardImage,
    ValueGetter<bool?>? isOnline,
    ValueGetter<Map<String, dynamic>?>? currentLocation,
    ValueGetter<String?>? vehicleType,
    ValueGetter<String?>? vehicleNumber,
    ValueGetter<String?>? vehicleColor,
    ValueGetter<String?>? vehicleModel,
    ValueGetter<int?>? vehicleYear,
    ValueGetter<String?>? preferredPaymentMethod,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePicture: profilePicture != null ? profilePicture() : this.profilePicture,
      userType: userType ?? this.userType,
      rating: rating != null ? rating() : this.rating,
      totalTrips: totalTrips != null ? totalTrips() : this.totalTrips,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      emergencyContact: emergencyContact != null ? emergencyContact() : this.emergencyContact,
      emergencyContactName: emergencyContactName != null ? emergencyContactName() : this.emergencyContactName,
      ghanaCardNumber: ghanaCardNumber != null ? ghanaCardNumber() : this.ghanaCardNumber,
      ghanaCardImage: ghanaCardImage != null ? ghanaCardImage() : this.ghanaCardImage,
      isOnline: isOnline != null ? isOnline() : this.isOnline,
      currentLocation: currentLocation != null ? currentLocation() : this.currentLocation,
      vehicleType: vehicleType != null ? vehicleType() : this.vehicleType,
      vehicleNumber: vehicleNumber != null ? vehicleNumber() : this.vehicleNumber,
      vehicleColor: vehicleColor != null ? vehicleColor() : this.vehicleColor,
      vehicleModel: vehicleModel != null ? vehicleModel() : this.vehicleModel,
      vehicleYear: vehicleYear != null ? vehicleYear() : this.vehicleYear,
      preferredPaymentMethod: preferredPaymentMethod != null ? preferredPaymentMethod() : this.preferredPaymentMethod,
    );
  }
}