// lib/data/models/ride_model.dart
import 'package:google_maps_flutter/google_maps_flutter.dart'; // For LatLng
import 'package:okada_app/data/models/user_model.dart'; // Import your User model (adjust path)
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
  final User? rider; // Nested User object (use UserPublic model if available)
  final User? driver; // Nested User object (nullable)
  final String status; // e.g., REQUESTED, ACCEPTED, COMPLETED
  final String statusDisplay; // User-friendly status
  final String paymentStatus;
  final String paymentStatusDisplay;

  // Location Data
  final double pickupLocationLat;
  final double pickupLocationLng;
  final String? pickupAddress;
  final double destinationLat;
  final double destinationLng;
  final String? destinationAddress;

  // Timestamps (nullable)
  final DateTime requestedAt;
  final DateTime? acceptedAt;
  final DateTime? arrivedAtPickupAt;
  final DateTime? tripStartedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;

  // Ride Metrics (nullable)
  final double? distanceKm;
  final int? durationSeconds;

  // Fare Details (nullable)
  final double? estimatedFare;
  final double? baseFare;
  final double? distanceFare;
  final double? durationFare;
  final double? totalFare; // This is the 'actual_fare' from backend
  final double? cancellationFee;

  // Other Details
  final String? cancellationReason;
  final RideRating? rating; // Nested rating object (nullable)

  Ride({
    required this.id,
    required this.rider, // Make required if always present in detail view
    this.driver,
    required this.status,
    required this.statusDisplay,
    required this.paymentStatus,
    required this.paymentStatusDisplay,
    required this.pickupLocationLat,
    required this.pickupLocationLng,
    this.pickupAddress,
    required this.destinationLat,
    required this.destinationLng,
    this.destinationAddress,
    required this.requestedAt,
    this.acceptedAt,
    this.arrivedAtPickupAt,
    this.tripStartedAt,
    this.completedAt,
    this.cancelledAt,
    this.distanceKm,
    this.durationSeconds,
    this.estimatedFare,
    this.baseFare,
    this.distanceFare,
    this.durationFare,
    this.totalFare,
    this.cancellationFee,
    this.cancellationReason,
    this.rating,
  });

  // Convenience getter for LatLng objects
  LatLng get pickupLatLng => LatLng(pickupLocationLat, pickupLocationLng);
  LatLng get destinationLatLng => LatLng(destinationLat, destinationLng);

  factory Ride.fromJson(Map<String, dynamic> json) {
    // Helper to safely get nested user data
    User? parseUser(dynamic userData) {
      if (userData is Map<String, dynamic>) {
        try {
          return User.fromJson(userData); // Use your existing User.fromJson
        } catch (e) {
          print("Error parsing user data in Ride.fromJson: $e");
          return null;
        }
      }
      return null;
    }
     // Helper to safely get nested rating data
    RideRating? parseRating(dynamic ratingData) {
       if (ratingData is Map<String, dynamic>) {
         try {
           return RideRating.fromJson(ratingData); // Use RideRating.fromJson
         } catch (e) {
           print("Error parsing rating data in Ride.fromJson: $e");
           return null;
         }
       }
       return null;
    }


    return Ride(
      id: _parseInt(json['id']) ?? 0, // Should always have ID
      rider: parseUser(json['rider']),
      driver: parseUser(json['driver']),
      status: json['status'] as String? ?? 'UNKNOWN',
      statusDisplay: json['status_display'] as String? ?? 'Unknown',
      paymentStatus: json['payment_status'] as String? ?? 'UNKNOWN',
      paymentStatusDisplay: json['payment_status_display'] as String? ?? 'Unknown',
      pickupLocationLat: _parseDouble(json['pickup_location_lat']) ?? 0.0,
      pickupLocationLng: _parseDouble(json['pickup_location_lng']) ?? 0.0,
      pickupAddress: json['pickup_address'] as String?,
      destinationLat: _parseDouble(json['destination_lat']) ?? 0.0,
      destinationLng: _parseDouble(json['destination_lng']) ?? 0.0,
      destinationAddress: json['destination_address'] as String?,
      requestedAt: _parseDateTime(json['requested_at'] as String?) ?? DateTime.now(), // Should have requested_at
      acceptedAt: _parseDateTime(json['accepted_at'] as String?),
      arrivedAtPickupAt: _parseDateTime(json['arrived_at_pickup_at'] as String?),
      tripStartedAt: _parseDateTime(json['trip_started_at'] as String?),
      completedAt: _parseDateTime(json['completed_at'] as String?),
      cancelledAt: _parseDateTime(json['cancelled_at'] as String?),
      distanceKm: _parseDouble(json['distance_km']),
      durationSeconds: _parseInt(json['duration_seconds']),
      estimatedFare: _parseDouble(json['estimated_fare']),
      baseFare: _parseDouble(json['base_fare']),
      distanceFare: _parseDouble(json['distance_fare']),
      durationFare: _parseDouble(json['duration_fare']),
      totalFare: _parseDouble(json['actual_fare']), // Map actual_fare to total_fare
      cancellationFee: _parseDouble(json['cancellation_fee']),
      cancellationReason: json['cancellation_reason'] as String?,
      rating: parseRating(json['rating']),
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

