import 'dart:convert'; // For jsonEncode/Decode
import 'dart:io'; // For SocketException
import 'package:google_maps_flutter/google_maps_flutter.dart'; // For LatLng
import 'package:http/http.dart' as http; // Import http client
// Adjust paths as needed
import 'package:okada/core/services/api_client.dart';
import 'package:okada/core/services/api_error_model.dart';
import 'package:okada/data/models/ride_model.dart'; // Assuming Ride model exists
import 'package:flutter_dotenv/flutter_dotenv.dart'; // For dotenv
import 'package:flutter_riverpod/flutter_riverpod.dart';

final rideServiceProvider = Provider<RideService>((ref) => RideService());

class RideService {
  final http.Client _client = createApiClient(); // Use intercepted client
  final String _baseUrl = dotenv.env['API_BASE_URL']!;

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
         final apiError = ApiError.fromJson(responseBody as Map<String, dynamic>);
         errorMessage = apiError.firstError;
       } catch (_) {
          if (responseBody is Map<String, dynamic>) {
            if (responseBody.containsKey('detail')) { errorMessage = responseBody['detail'].toString(); }
            else if (responseBody.isNotEmpty) { var firstValue = responseBody.values.first; if (firstValue is List && firstValue.isNotEmpty) { errorMessage = firstValue.first.toString(); } else { errorMessage = firstValue.toString(); } }
          } else if (responseBody is String) { errorMessage = responseBody; }
       }
       print('API Error (${response.statusCode}): $errorMessage');
       throw Exception(errorMessage);
     }
  }

  // --- Create Ride Request ---
  Future<Ride> createRideRequest({
    required LatLng pickupCoords,
    String? pickupAddress,
    required LatLng destinationCoords,
    String? destinationAddress,
    required double estimatedFare,
  }) async {
    final url = Uri.parse('$_baseUrl/rides/'); // POST to list endpoint for creation
    print("RideService: Creating ride request...");

    try {
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'}, // Interceptor adds Auth token
        body: json.encode({
          'pickup_location_lat': pickupCoords.latitude.toStringAsFixed(7),
          'pickup_location_lng': pickupCoords.longitude.toStringAsFixed(7),
          'pickup_address': pickupAddress,
          'destination_lat': destinationCoords.latitude.toStringAsFixed(7),
          'destination_lng': destinationCoords.longitude.toStringAsFixed(7),
          'destination_address': destinationAddress,
          'estimated_fare': estimatedFare.toStringAsFixed(2), // Send as string matching DecimalField
        }),
      );
      final responseBody = _handleResponse(response);
      print("RideService: Create ride response body: $responseBody");
      return Ride.fromJson(responseBody as Map<String, dynamic>);
    } on Exception catch (e) {
        print("RideService: Failed to create ride request - $e");
        rethrow;
    } catch (e) {
        print("RideService: Unexpected error creating ride - $e");
         if (e is SocketException) { throw Exception('Network error. Please check connection.'); }
        throw Exception('An unknown error occurred while requesting the ride.');
    }
  }

  // --- Get Estimated Fare ---
  Future<double> getEstimatedFare({
      required LatLng pickupCoords,
      required LatLng destinationCoords,
  }) async {
      final url = Uri.parse('$_baseUrl/rides/estimate_fare/'); // Endpoint for estimation
      print("RideService: Requesting fare estimate...");
      print("  Pickup: ${pickupCoords.latitude}, ${pickupCoords.longitude}");
      print("  Dest: ${destinationCoords.latitude}, ${destinationCoords.longitude}");

      try {
          final response = await _client.post(
              url,
              headers: {'Content-Type': 'application/json'}, // Interceptor adds Auth token
              body: json.encode({
                  'pickup_location_lat': pickupCoords.latitude.toStringAsFixed(7),
                  'pickup_location_lng': pickupCoords.longitude.toStringAsFixed(7),
                  'destination_lat': destinationCoords.latitude.toStringAsFixed(7),
                  'destination_lng': destinationCoords.longitude.toStringAsFixed(7),
              }),
          );

          final responseBody = _handleResponse(response);

          if (responseBody != null && responseBody is Map && responseBody.containsKey('estimated_fare')) {
              final fareValue = responseBody['estimated_fare'];
              double? fare = double.tryParse(fareValue.toString());
              if (fare != null) {
                  print("RideService: Estimated fare received: $fare");
                  return fare;
              } else {
                  throw Exception("Invalid fare format received from server.");
              }
          } else {
              throw Exception("Estimated fare not found in server response.");
          }
      } on Exception catch (e) {
          print("RideService: Failed to get estimated fare - $e");
          rethrow;
      } catch (e) {
          print("RideService: Unexpected error getting fare - $e");
          if (e is SocketException) { throw Exception('Network error. Please check connection.'); }
          throw Exception('An unknown error occurred while estimating the fare.');
      }
  }

  Future<Ride> getRideDetails(int rideId) async {
    final url = Uri.parse('$_baseUrl/rides/$rideId/');
    try {
      final response = await _client.get(url);
      final responseBody = _handleResponse(response);
      return Ride.fromJson(responseBody as Map<String, dynamic>);
    } catch (e) {
      print("RideService: Failed to get ride details - $e");
      throw Exception('Failed to load ride details');
    }
  }

  Future<void> cancelRide(int rideId, String reason) async {
    final url = Uri.parse('$_baseUrl/rides/$rideId/cancel_ride/');
    try {
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'cancellation_reason': reason}),
      );
      _handleResponse(response);
    } catch (e) {
      print("RideService: Failed to cancel ride - $e");
      throw Exception('Failed to cancel ride');
    }
  }
}