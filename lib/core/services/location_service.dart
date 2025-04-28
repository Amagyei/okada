// lib/services/location_service.dart
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {

  /// Checks the current location permission status.
  Future<PermissionStatus> checkPermissionStatus() async {
    return await Permission.locationWhenInUse.status;
  }

  /// Requests location permission if not already granted.
  /// Returns true if permission is granted (or limited), false otherwise.
  Future<bool> requestLocationPermission() async {
    PermissionStatus status = await Permission.locationWhenInUse.request();
    print("[LocationService] Permission Request Status: $status");
    // Treat limited access as granted for getting current location
    return status == PermissionStatus.granted || status == PermissionStatus.limited;
  }

  /// Opens app settings for the user to manually change permissions.
  Future<void> openAppSettings() async {
    await openAppSettings();
  }

  /// Gets the current device location.
  ///
  /// Throws specific exceptions for:
  /// - Location services disabled.
  /// - Permissions denied.
  /// - Permissions permanently denied.
  /// - Other errors during position fetching (e.g., timeout).
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Check if location services are enabled on the device.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("[LocationService] Location services are disabled.");
      // Consider prompting user to enable services via Geolocator.openLocationSettings()
      throw Exception('Location services are disabled.');
    }

    // 2. Check current permission status.
    permission = await Geolocator.checkPermission();

    // 3. If denied, request permission.
    if (permission == LocationPermission.denied) {
      print("[LocationService] Permission denied, requesting...");
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("[LocationService] Permission denied after request.");
        throw Exception('Location permissions are denied.');
      }
    }

    // 4. Handle permanently denied permissions.
    if (permission == LocationPermission.deniedForever) {
      print("[LocationService] Permission permanently denied.");
      // Suggest opening settings. The UI should handle calling openAppSettings().
      throw Exception('Location permissions are permanently denied.');
    }

    // 5. Permissions are granted (or whileInUse/always). Fetch location.
    print("[LocationService] Permissions granted. Fetching current location...");
    try {
      // Get current position with desired accuracy.
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        // Optional: Add a time limit to prevent indefinite waiting
        // timeLimit: const Duration(seconds: 15),
      );
    } on TimeoutException catch (_) {
        print("[LocationService] Getting location timed out.");
        throw Exception('Getting location timed out. Please try again.');
    } catch (e) {
      print("[LocationService] Error getting location: $e");
      throw Exception('Failed to get current location.');
    }
  }

  // Optional: Method to get continuous location updates (Stream)
  // Stream<Position> getPositionStream({
  //   LocationAccuracy desiredAccuracy = LocationAccuracy.high,
  //   int distanceFilter = 10, // Minimum distance (meters) before update
  // }) {
  //   final LocationSettings locationSettings = LocationSettings(
  //     accuracy: desiredAccuracy,
  //     distanceFilter: distanceFilter,
  //   );
  //   return Geolocator.getPositionStream(locationSettings: locationSettings);
  // }
}
