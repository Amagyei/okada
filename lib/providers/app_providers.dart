// lib/providers/app_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart'; // For Position type
import 'package:okada/core/services/location_service.dart'; // Adjust path
import 'package:okada/core/services/ride_service.dart'; // Adjust path
import 'package:okada/core/services/directions_service.dart'; // Add import

// --- Location Providers ---

// Provider for the LocationService instance
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

// StreamProvider for continuous location updates (optional)
// final locationStreamProvider = StreamProvider<Position>((ref) {
//   final locationService = ref.watch(locationServiceProvider);
//   // TODO: Handle permissions before starting stream
//   return locationService.getPositionStream();
// });

// FutureProvider for getting a single current location update
// Useful for initial load or manual refresh. Automatically handles loading/error.
final currentLocationProvider = FutureProvider<Position>((ref) async {
  final locationService = ref.read(locationServiceProvider);
  // Ensure permissions are handled before calling this (e.g., in initState)
  // Or add permission check inside here if preferred
  bool granted = await locationService.requestLocationPermission();
  if (!granted) {
    throw Exception("Location permission not granted.");
  }
  return locationService.getCurrentLocation();
});


// --- Ride Service Provider ---

// Provider for the RideService instance
final rideServiceProvider = Provider<RideService>((ref) {
  // If RideService needs dependencies (like http client), read them here:
  // final apiClient = ref.read(apiClientProvider); // Assuming apiClientProvider exists
  return RideService();
});

// --- Directions Service Provider ---
final directionsServiceProvider = Provider<DirectionsService>((ref) {
  return DirectionsService();
});

// You might add FutureProviders or StreamProviders related to rides later
// e.g., fetching ride details, polling ride status, fetching ride history
