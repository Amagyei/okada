// lib/data/models/ride_model.dart
import 'package:google_maps_flutter/google_maps_flutter.dart'; // For LatLng
// Import rating model if separate
// import 'ride_rating_model.dart';

// Helper function to safely parse doubles from various types (String, int, double)
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

// Helper function to safely parse DateTime
DateTime? _parseDateTime(String? value) {
  if (value == null) return null;
  return DateTime.tryParse(value);
}

class Ride {
  final int id;
  final String status;
  final String? pickupAddress;
  final String? destinationAddress;
  final double? pickupLocationLat;
  final double? pickupLocationLng;
  final double? destinationLocationLat;
  final double? destinationLocationLng;
  final User? driver;
  final User? rider;
  final double? fare;
  final String? paymentStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? acceptedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final String? cancellationNote;

  Ride({
    required this.id,
    required this.status,
    this.pickupAddress,
    this.destinationAddress,
    this.pickupLocationLat,
    this.pickupLocationLng,
    this.destinationLocationLat,
    this.destinationLocationLng,
    this.driver,
    this.rider,
    this.fare,
    this.paymentStatus,
    this.createdAt,
    this.updatedAt,
    this.acceptedAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.cancellationNote,
  });

  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride(
      id: json['id'],
      status: json['status'],
      pickupAddress: json['pickup_address'],
      destinationAddress: json['destination_address'],
      pickupLocationLat: _parseDouble(json['pickup_location_lat']),
      pickupLocationLng: _parseDouble(json['pickup_location_lng']),
      destinationLocationLat: _parseDouble(json['destination_lat']),
      destinationLocationLng: _parseDouble(json['destination_lng']),
      driver: json['driver'] != null ? User.fromJson(json['driver']) : null,
      rider: json['rider'] != null ? User.fromJson(json['rider']) : null,
      fare: _parseDouble(json['estimated_fare']),
      paymentStatus: json['payment_status'],
      createdAt: _parseDateTime(json['requested_at']),
      updatedAt: _parseDateTime(json['updated_at']),
      acceptedAt: _parseDateTime(json['accepted_at']),
      startedAt: _parseDateTime(json['trip_started_at']),
      completedAt: _parseDateTime(json['completed_at']),
      cancelledAt: _parseDateTime(json['cancelled_at']),
      cancellationReason: json['cancellation_reason'],
      cancellationNote: json['cancellation_note'],
    );
  }

  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Waiting for driver';
      case 'accepted':
        return 'Driver is on the way';
      case 'started':
        return 'Ride in progress';
      case 'completed':
        return 'Ride completed';
      case 'cancelled':
        return 'Ride cancelled';
      default:
        return status;
    }
  }

  bool get isActive => status == 'pending' || status == 'accepted' || status == 'started';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  LatLng? get pickupLatLng => (pickupLocationLat != null && pickupLocationLng != null)
      ? LatLng(pickupLocationLat!, pickupLocationLng!)
      : null;

  LatLng? get destinationLatLng => (destinationLocationLat != null && destinationLocationLng != null)
      ? LatLng(destinationLocationLat!, destinationLocationLng!)
      : null;
}

class User {
  final int id;
  final String fullName;
  final String? profilePicture;
  final double? numericRating;
  final String? vehicleModel;
  final String? vehicleNumber;
  final String? phoneNumber;

  User({
    required this.id,
    required this.fullName,
    this.profilePicture,
    this.numericRating,
    this.vehicleModel,
    this.vehicleNumber,
    this.phoneNumber,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullName: json['full_name'],
      profilePicture: json['profile_picture'],
      numericRating: json['numeric_rating']?.toDouble(),
      vehicleModel: json['vehicle_model'],
      vehicleNumber: json['vehicle_number'],
      phoneNumber: json['phone_number'],
    );
  }
}

// --- Placeholder RideRating Model ---
// TODO: Create a proper ride_rating_model.dart based on backend serializer
class RideRating {
  final int ratingDisplay;
  final String? commentDisplay;
  // Add rater/rated user if needed from RideRatingSerializer output

  RideRating({required this.ratingDisplay, this.commentDisplay});

  factory RideRating.fromJson(Map<String, dynamic> json) {
     return RideRating(
       ratingDisplay: _parseInt(json['rating_display']) ?? 0,
       commentDisplay: json['comment_display'] as String?,
     );
  }
}
// --- End Placeholder ---

