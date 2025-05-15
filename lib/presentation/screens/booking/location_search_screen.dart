import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// Import the places package for the TextField and Prediction model
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
// Import Flutter's http package for Places Details API call
import 'package:http/http.dart' as http;
// Import dotenv to access environment variables
import 'package:flutter_dotenv/flutter_dotenv.dart';
// Import theme constants if needed for styling
import 'package:okada_app/core/constants/theme.dart';

class LocationSearchScreen extends StatefulWidget {
  const LocationSearchScreen({super.key});

  @override
  _LocationSearchScreenState createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  // Read the key from the loaded environment variables
  final String _googleApiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? 'MISSING_API_KEY';
  // Flag to prevent multiple navigations if user taps quickly
  bool _isFetchingDetails = false;

  @override
  void initState() {
    super.initState();
    // Check if the key was loaded correctly during development
    if (_googleApiKey == 'MISSING_API_KEY') {
      print("[LocationSearchScreen] ERROR: GOOGLE_MAPS_API_KEY not found in loaded .env file!");
      // Use WidgetsBinding to show SnackBar after build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
         if (mounted) {
           _showError("Map search unavailable: API key missing.");
         }
      });
    } else {
       print("[LocationSearchScreen] API Key loaded successfully."); // Confirm key loaded
    }
  }


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Function to handle when a place prediction is tapped
  void _onPlaceSelected(Prediction prediction) async {
    if (_isFetchingDetails) return;
    setState(() => _isFetchingDetails = true);

    FocusScope.of(context).unfocus(); // Hide keyboard

    if (prediction.placeId == null) {
      _showError("Could not get place details (Missing Place ID).");
      setState(() => _isFetchingDetails = false);
      return;
    }
    if (_googleApiKey == 'MISSING_API_KEY') {
       _showError("Map search unavailable: API key missing.");
       setState(() => _isFetchingDetails = false);
      return;
    }

    print("[LocationSearchScreen] Fetching details for Place ID: ${prediction.placeId}");

    final String placeId = prediction.placeId!;
    final String fields = "geometry/location,name,formatted_address";
    final Uri url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json?placeid=$placeId&fields=$fields&key=$_googleApiKey'
    );

    print("[LocationSearchScreen] Calling Places Details API (key omitted)...");

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'OK' && data['result']?['geometry']?['location'] != null) {
          final location = data['result']['geometry']['location'];
          final double? lat = location['lat'] as double?;
          final double? lng = location['lng'] as double?;

          if (lat != null && lng != null) {
            final coords = LatLng(lat, lng);
            final placeName = data['result']?['formatted_address'] ?? prediction.description ?? data['result']?['name'] ?? 'Unknown Address';

            print("[LocationSearchScreen] Place details fetched successfully: $placeName at $coords");
            // --- Add Log before pop ---
            final resultData = {'name': placeName, 'coords': coords};
            print("[LocationSearchScreen] Popping with result: $resultData");
            // --- End Log ---
            Navigator.pop(context, resultData); // Return the map

          } else {
             print("[LocationSearchScreen] Places Details API Error: Lat/Lng missing.");
            _showError("Failed to get location coordinates from API response.");
             setState(() => _isFetchingDetails = false);
          }
        } else {
          final String apiErrorMsg = data['error_message'] ?? data['status'] ?? 'Unknown API error';
          print("[LocationSearchScreen] Places Details API Error: $apiErrorMsg");
          _showError("Failed to get location details: $apiErrorMsg");
           setState(() => _isFetchingDetails = false);
        }
      } else {
        print("[LocationSearchScreen] Places Details HTTP Error: ${response.statusCode}");
        _showError("Failed to get location details (HTTP ${response.statusCode}).");
         setState(() => _isFetchingDetails = false);
      }
    } on TimeoutException catch (_) {
        print("[LocationSearchScreen] Error calling Place Details API: Timeout");
        if (mounted) {
             _showError("Getting location details timed out.");
             setState(() => _isFetchingDetails = false);
        }
    } catch (e) {
        print("[LocationSearchScreen] Error calling Place Details API: $e");
        if (mounted) {
             _showError("Error getting location details: ${e.toString()}");
             setState(() => _isFetchingDetails = false);
        }
    }
  }

  void _showError(String message) {
     if (!mounted) return;
     ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
     );
  }

  @override
  Widget build(BuildContext context) {
    print("[LocationSearchScreen] Building widget. API Key: ${_googleApiKey == 'MISSING_API_KEY' ? '**MISSING**' : 'Loaded'}");

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Location'),
        bottom: PreferredSize(
           preferredSize: const Size.fromHeight(kToolbarHeight),
           child: Padding(
             padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 8.0),
             child: GooglePlaceAutoCompleteTextField(
                textEditingController: _searchController,
                googleAPIKey: _googleApiKey,
                inputDecoration: InputDecoration(
                  hintText: "Enter address or place name",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? Theme.of(context).scaffoldBackgroundColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                   prefixIcon: const Icon(Icons.search, color: textSecondary),
                   suffixIcon: _searchController.text.isNotEmpty
                     ? IconButton(
                          icon: const Icon(Icons.clear, color: textSecondary),
                          onPressed: () { _searchController.clear(); },
                       )
                     : null,
                ),
                debounceTime: 400,
                countries: const ["GH"],
                isLatLngRequired: false,
                getPlaceDetailWithLatLng: _onPlaceSelected,
                itemClick: (prediction) {
                   _searchController.text = prediction.description ?? "";
                   _searchController.selection = TextSelection.fromPosition(TextPosition(offset: prediction.description?.length ?? 0));
                },
                 itemBuilder: (context, index, Prediction prediction) {
                    return Container(
                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                       child: Row(
                          children: [
                             const Icon(Icons.location_on_outlined, color: textSecondary),
                             const SizedBox(width: 12),
                             Expanded( child: Text( prediction.description ?? '...', style: const TextStyle(fontSize: 15), overflow: TextOverflow.ellipsis))
                          ],
                       ),
                    );
                 },
                 seperatedBuilder: Divider(height: 1, color: Colors.grey.shade200),
                 isCrossBtnShown: false,
             ),
           ),
        ),
      ),
      body: _googleApiKey == 'MISSING_API_KEY'
         ? const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text("Map search is unavailable due to missing configuration.", textAlign: TextAlign.center)))
         : Container(),
    );
  }
}
