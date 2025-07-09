import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PlaceSuggestion {
  final String placeId;
  final String description;

  PlaceSuggestion(this.placeId, this.description);

  @override
  String toString() {
    return 'Suggestion(description: $description, placeId: $placeId)';
  }
}

class PlaceDetails {
  final double latitude;
  final double longitude;
  final String street; // e.g., Osu Badu Street
  final String city; // e.g., Accra

  PlaceDetails({
    required this.latitude,
    required this.longitude,
    required this.street,
    required this.city,
  });
}

class PlacesService {
  String get _apiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? 'MISSING_API_KEY';
  
  /// Fetches place autocomplete suggestions from Google Places API.
  ///
  /// [input] is the user's search query.
  /// [sessionToken] is a unique token for the user's search session (for billing).
  /// [language] defaults to 'en' (English).
  /// [components] restricts search to a specific country (e.g., 'country:gh' for Ghana).
  Future<List<PlaceSuggestion>> getAutocomplete(String input, String sessionToken, {String language = 'en', String components = 'country:gh'}) async {
    if (input.isEmpty || _apiKey == 'MISSING_API_KEY') {
      return [];
    }

    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/autocomplete/json',
      {
        'input': input,
        'key': _apiKey,
        'sessiontoken': sessionToken,
        'language': language,
        'components': components, // Restrict to Ghana
      },
    );

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final List<dynamic> predictions = data['predictions'];
          return predictions.map((p) => PlaceSuggestion(p['place_id'], p['description'])).toList();
        } else {
          // Handle API errors (e.g., ZERO_RESULTS, REQUEST_DENIED)
          print('Google Places API Error: ${data['status']} - ${data['error_message']}');
          return [];
        }
      } else {
        // Handle HTTP errors
        print('HTTP Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Failed to fetch suggestions: $e');
      return [];
    }
  }

  /// Fetches detailed information for a place using its [placeId].
  ///
  /// [sessionToken] must be the same one used for the autocomplete request.
  Future<PlaceDetails?> getPlaceDetails(String placeId, String sessionToken) async {
    if (_apiKey == 'MISSING_API_KEY') {
      return null;
    }

    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/details/json',
      {
        'place_id': placeId,
        'key': _apiKey,
        'sessiontoken': sessionToken,
        'fields': 'address_component,geometry', // Request geometry (lat/lng) and address components
      },
    );

     try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == 'OK') {
           final result = data['result'];
           final lat = result['geometry']['location']['lat'];
           final lng = result['geometry']['location']['lng'];
           
           // Extract address components (this part might need tweaking based on Google's address format for Ghana)
           String street = '';
           String city = 'Accra'; // Default or find from components
           for (var component in result['address_components']) {
             if (component['types'].contains('route')) {
               street = component['long_name'];
             }
             if (component['types'].contains('locality') || component['types'].contains('administrative_area_level_2')) {
               city = component['long_name'];
             }
           }

           return PlaceDetails(latitude: lat, longitude: lng, street: street, city: city);
        }
      }
      return null;
    } catch (e) {
      print('Failed to fetch place details: $e');
      return null;
    }
  }
} 