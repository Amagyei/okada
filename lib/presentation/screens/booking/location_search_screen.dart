import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// Import our custom places autocomplete widget
import 'package:okada/core/widgets/places_autocomplete_field.dart';
import 'package:okada/data/services/places_service.dart';
// Import Flutter's http package for Places Details API call
import 'package:http/http.dart' as http;
// Import dotenv to access environment variables
import 'package:flutter_dotenv/flutter_dotenv.dart';
// Import theme constants if needed for styling
import 'package:okada/core/constants/theme.dart';

class LocationSearchScreen extends StatefulWidget {
  const LocationSearchScreen({super.key});

  @override
  _LocationSearchScreenState createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
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

  // Function to handle when a place is selected
  void _onPlaceSelected(PlaceDetails details) async {
    if (_isFetchingDetails) return;
    setState(() => _isFetchingDetails = true);

    FocusScope.of(context).unfocus(); // Hide keyboard

    if (_googleApiKey == 'MISSING_API_KEY') {
       _showError("Map search unavailable: API key missing.");
       setState(() => _isFetchingDetails = false);
      return;
    }

    print("[LocationSearchScreen] Place selected: ${details.street}, ${details.city}");

    try {
      final coords = LatLng(details.latitude, details.longitude);
      final placeName = details.street.isNotEmpty ? '${details.street}, ${details.city}' : details.city;

      print("[LocationSearchScreen] Place details fetched successfully: $placeName at $coords");
      // --- Add Log before pop ---
      final resultData = {'name': placeName, 'coords': coords};
      print("[LocationSearchScreen] Popping with result: $resultData");
      // --- End Log ---
      Navigator.pop(context, resultData); // Return the map

    } catch (e) {
        print("[LocationSearchScreen] Error processing place details: $e");
        if (mounted) {
             _showError("Error processing location details: ${e.toString()}");
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
             child: PlacesAutocompleteField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onPlaceSelected: _onPlaceSelected,
                countries: const ["GH"],
                debounceTime: 400,
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
