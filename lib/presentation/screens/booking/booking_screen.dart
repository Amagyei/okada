import 'dart:async';
import 'dart:convert'; // For jsonDecode
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
// Import the places package for the TextField and Prediction model
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
// Import Flutter's http package for Places Details API call
import 'package:http/http.dart' as http;
// Import dotenv to access environment variables
import 'package:flutter_dotenv/flutter_dotenv.dart';
// Adjust import paths
import 'package:okada_app/core/constants/theme.dart';
import 'package:okada_app/core/widgets/ghana_widgets.dart';
import 'package:okada_app/routes.dart';
import 'package:okada_app/core/services/location_service.dart';
import 'package:okada_app/core/services/ride_service.dart';
import 'package:okada_app/providers/app_providers.dart';
import 'package:okada_app/presentation/screens/booking/widgets/payment_method_selector.dart';
import 'package:okada_app/presentation/screens/booking/widgets/driver_card.dart';
// LocationInput widget is no longer used here
// Geocoding package might still be used for reverse geocoding current location
import 'package:geocoding/geocoding.dart';


class BookingScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final Completer<GoogleMapController> _mapControllerCompleter = Completer<GoogleMapController>();
  GoogleMapController? _mapController;

  // State variables
  LatLng? _pickupLatLng;
  LatLng? _destinationLatLng;
  double? _estimatedFare;
  bool _isFetchingFare = false;
  bool _isRequestingRide = false;
  final Set<Marker> _markers = {};
  PaymentMethod _selectedPaymentMethod = PaymentMethod.mobileMoney;

  static const LatLng _defaultCenter = LatLng(5.6037, -0.1870); // Accra
  bool _showRideOptions = false;
  bool _isInitializingLocation = true;
  String _initErrorMsg = '';
  bool _isFetchingPlaceDetails = false;

  // API Key from .env
  final String _googleApiKey = 'AIzaSyCXiEOWU-1EsfTuL9PQ4negxlFQqN3XXB8';

  // Focus Nodes to control focus between fields
  final FocusNode _pickupFocusNode = FocusNode();
  final FocusNode _destinationFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Listeners removed as geocoding is triggered by autocomplete selection now
    WidgetsBinding.instance.addPostFrameCallback((_) {
       if (_googleApiKey == 'MISSING_API_KEY') {
          print("ERROR: GOOGLE_MAPS_API_KEY missing. Geocoding/Maps/Places will fail.");
          _showError("Map/Search unavailable: API key missing.");
          setState(() => _isInitializingLocation = false);
       } else {
          _initializePickupLocation(setAsDefault: true);
       }
    });
  }

  // Fetches current location and sets it as the default pickup
  Future<void> _initializePickupLocation({bool setAsDefault = false}) async {
    print("[BookingScreen] Start _initializePickupLocation (setAsDefault: $setAsDefault)");
    if (!mounted) return;
    if (!_isInitializingLocation) setState(() => _isInitializingLocation = true);
    if (_initErrorMsg.isNotEmpty) setState(() => _initErrorMsg = '');

    final locationService = ref.read(locationServiceProvider);
    try {
      bool granted = await locationService.requestLocationPermission();
      if (!mounted) return;
      if (!granted) {
        final errorMsg = "Location permission is required.";
        setState(() {
          if (setAsDefault) _pickupController.text = "Permission Denied";
          _initErrorMsg = errorMsg; _isInitializingLocation = false;
        });
        _showError(errorMsg); return;
      }

      final currentPosition = await locationService.getCurrentLocation().timeout(const Duration(seconds: 15));
      if (!mounted) return;

      final coords = LatLng(currentPosition.latitude, currentPosition.longitude);
      String address = "Current Location";

      try {
         final fetchedAddress = await _getAddressFromCoords(coords);
         if (fetchedAddress != null && mounted) { address = fetchedAddress; }
      } catch (geoError) { print("[BookingScreen] Reverse geocoding failed: $geoError"); }

      if (!mounted) return;

      print("[BookingScreen] Setting state: Location fetched, Initializing=false");
      setState(() {
        if (setAsDefault || _pickupLatLng == null) {
           _pickupLatLng = coords;
           _pickupController.text = address;
           _updateMarkersDirectly('pickup', coords, 'Pickup: $address');
           _checkShowRideOptions();
           if (setAsDefault && _destinationLatLng != null) _fetchEstimatedFare();
        }
        _isInitializingLocation = false;
      });
      _animateMapToPosition(coords);

    } catch (e) {
      print("[BookingScreen] Error during location initialization: $e");
      if (mounted) {
        final errorMsg = e.toString().replaceFirst("Exception: ", "");
        print("[BookingScreen] Setting state: Error occurred, Initializing=false");
        setState(() {
           if (setAsDefault) _pickupController.text = "Error getting location";
           _initErrorMsg = "Failed to get current location: $errorMsg";
           _isInitializingLocation = false;
        });
         _showError(_initErrorMsg);
      }
    }
  }

  @override
  void dispose() {
    // Listeners removed
    _pickupController.dispose();
    _destinationController.dispose();
    _mapController?.dispose();
    _pickupFocusNode.dispose();
    _destinationFocusNode.dispose();
    super.dispose();
  }

  // --- Map Helper Methods ---
  void _updateMarkersDirectly(String id, LatLng position, String title) {
     _markers.removeWhere((m) => m.markerId.value == id);
     _markers.add( Marker( markerId: MarkerId(id), position: position, infoWindow: InfoWindow(title: title), icon: BitmapDescriptor.defaultMarkerWithHue( id == 'pickup' ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed, ), ), );
     print("[BookingScreen] _updateMarkersDirectly: Updated _markers set for $id. Current markers: ${_markers.length}");
     WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_pickupLatLng != null && _destinationLatLng != null) { _zoomToFitMarkers(); }
        else { _animateMapToPosition(position); }
     });
  }
  Future<void> _animateMapToPosition(LatLng position, {double zoom = 15.0}) async {
     try {
        final controller = await _mapControllerCompleter.future;
        if (mounted) { controller.animateCamera( CameraUpdate.newCameraPosition( CameraPosition(target: position, zoom: zoom)), ); }
     } catch (e) { print("Error animating map: $e"); }
  }
  Future<void> _zoomToFitMarkers() async {
     if (_markers.length < 2 || _pickupLatLng == null || _destinationLatLng == null) return;
     try {
        final controller = await _mapControllerCompleter.future;
        if (!mounted) return;
        LatLngBounds bounds = LatLngBounds( southwest: LatLng( _pickupLatLng!.latitude < _destinationLatLng!.latitude ? _pickupLatLng!.latitude : _destinationLatLng!.latitude, _pickupLatLng!.longitude < _destinationLatLng!.longitude ? _pickupLatLng!.longitude : _destinationLatLng!.longitude ), northeast: LatLng( _pickupLatLng!.latitude > _destinationLatLng!.latitude ? _pickupLatLng!.latitude : _destinationLatLng!.latitude, _pickupLatLng!.longitude > _destinationLatLng!.longitude ? _pickupLatLng!.longitude : _destinationLatLng!.longitude ) );
        controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 60.0));
     } catch (e) { print("Error zooming map to fit markers: $e"); }
  }
  // --- End Map Helper Methods ---


  // --- Geocoding Logic REMOVED ---

  // --- Helper for reverse geocoding using Google API ---
  Future<String?> _getAddressFromCoords(LatLng coords) async {
     if (_googleApiKey == 'MISSING_API_KEY') return null;
     final Uri url = Uri.parse(
       'https://maps.googleapis.com/maps/api/geocode/json?latlng=${coords.latitude},${coords.longitude}&key=$_googleApiKey&language=en&result_type=street_address|route|locality|political'
     );
     try {
        final response = await http.get(url).timeout(const Duration(seconds: 5));
        if (response.statusCode == 200) {
           final data = jsonDecode(response.body);
           if (data['status'] == 'OK' && data['results'] != null && (data['results'] as List).isNotEmpty) {
              return data['results'][0]['formatted_address'] as String?;
           } else { print("[BookingScreen] Reverse Geocode API Error: ${data['status']} - ${data['error_message'] ?? ''}"); }
        } else { print("[BookingScreen] Reverse Geocode HTTP Error: ${response.statusCode}"); }
     } catch(e) { print("[BookingScreen] Reverse Geocode Exception: $e"); }
     return null;
  }
  // --- End Reverse Geocoding Helper ---

  // --- Unified Place Selection Handler (from Autocomplete) ---
  void _onPlaceSelected(Prediction prediction, String fieldType) async {
    if (_isFetchingPlaceDetails) return;
    setState(() => _isFetchingPlaceDetails = true);

    // *** Unfocus the correct text field ***
    if (fieldType == 'pickup') _pickupFocusNode.unfocus();
    else _destinationFocusNode.unfocus();
    // *** Also ensure general unfocus happens ***
    FocusScope.of(context).unfocus();

    if (prediction.placeId == null) { /* ... error handling ... */ setState(() => _isFetchingPlaceDetails = false); return; }
    if (_googleApiKey == 'MISSING_API_KEY') { /* ... error handling ... */ setState(() => _isFetchingPlaceDetails = false); return; }

    print("[BookingScreen] Fetching details for $fieldType - Place ID: ${prediction.placeId}");

    final String placeId = prediction.placeId!;
    final String fields = "geometry/location,name,formatted_address";
    final Uri url = Uri.parse('https://maps.googleapis.com/maps/api/place/details/json?placeid=$placeId&fields=$fields&key=$_googleApiKey');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (!mounted) { setState(() => _isFetchingPlaceDetails = false); return; }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK' && data['result']?['geometry']?['location'] != null) {
          final location = data['result']['geometry']['location'];
          final double? lat = location['lat'] as double?;
          final double? lng = location['lng'] as double?;

          if (lat != null && lng != null) {
            final coords = LatLng(lat, lng);
            final placeName = data['result']?['formatted_address'] ?? prediction.description ?? data['result']?['name'] ?? 'Unknown Address';
            print("[BookingScreen] $fieldType details fetched: $placeName at $coords");

            setState(() {
              if (fieldType == 'pickup') {
                _pickupLatLng = coords;
                _pickupController.text = placeName;
                _pickupController.selection = TextSelection.fromPosition(TextPosition(offset: _pickupController.text.length));
                _updateMarkersDirectly('pickup', coords, 'Pickup: $placeName');
                 // Don't automatically move focus here, let user decide
                 // FocusScope.of(context).requestFocus(_destinationFocusNode);
              } else {
                _destinationLatLng = coords;
                _destinationController.text = placeName;
                _destinationController.selection = TextSelection.fromPosition(TextPosition(offset: _destinationController.text.length));
                _updateMarkersDirectly('destination', coords, 'Destination: $placeName');
                 // Keep unfocus here
                 _destinationFocusNode.unfocus();
              }
              _checkShowRideOptions();
            });
            _fetchEstimatedFare();
          } else { /* ... error handling ... */ }
        } else { /* ... error handling ... */ }
      } else { /* ... error handling ... */ }
    } on TimeoutException catch (_) { /* ... error handling ... */ }
    catch (e) { /* ... error handling ... */ }
    finally { if (mounted) setState(() => _isFetchingPlaceDetails = false); }
  }
  // --- End Place Selection Handler ---


  // --- Check if Ride Options should be shown ---
  void _checkShowRideOptions() {
     final shouldShow = _pickupLatLng != null && _destinationLatLng != null;
     print("[BookingScreen] Checking showRideOptions: Pickup=${_pickupLatLng!=null}, Dest=${_destinationLatLng!=null} -> ShouldShow=$shouldShow");
     if (_showRideOptions != shouldShow) {
        print("[BookingScreen] Updating _showRideOptions state to $shouldShow");
        if (mounted) setState(() { _showRideOptions = shouldShow; });
     }
  }

  // --- Fare Estimation ---
  Future<void> _fetchEstimatedFare() async {
    if (_pickupLatLng == null || _destinationLatLng == null) {
      print("[BookingScreen] Skipping fare estimate: Locations incomplete.");
      if (_estimatedFare != null) { if (mounted) setState(() { _estimatedFare = null; }); }
      return;
    }
    print("[BookingScreen] Fetching estimated fare...");
    if (mounted) setState(() { _isFetchingFare = true; _estimatedFare = null; });
    try {
      print("[BookingScreen] Simulating fare estimate API call..."); // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 800));
      final fare = 50.00; // Placeholder fare
      print("[BookingScreen] Fare estimate received: $fare");
      if (mounted) setState(() { _estimatedFare = fare; });
    } catch (e) {
       print("[BookingScreen] Error fetching fare: $e");
       if (mounted) _showError("Could not get fare: ${e.toString().replaceFirst("Exception: ", "")}");
    } finally {
       if (mounted) setState(() { _isFetchingFare = false; });
    }
  }

  // --- Ride Request ---
  Future<void> _requestRide() async {
     final pickupAddress = _pickupController.text.trim();
     final destinationAddress = _destinationController.text.trim();

     if (_pickupLatLng == null || pickupAddress.isEmpty || pickupAddress == "Current Location") {
        _showError("Please enter or select a valid pickup location."); return;
     }
      if (_destinationLatLng == null || destinationAddress.isEmpty) {
        _showError("Please enter or select a valid destination."); return;
     }

     print("[BookingScreen] Attempting ride request...");
     if (mounted) setState(() { _isRequestingRide = true; });
     final rideService = ref.read(rideServiceProvider);
     try {
        print("[BookingScreen] Calling createRideRequest Service...");
        final ride = await rideService.createRideRequest(
           pickupCoords: _pickupLatLng!, pickupAddress: pickupAddress,
           destinationCoords: _destinationLatLng!, destinationAddress: destinationAddress,
        );
        if (mounted) {
           print("[BookingScreen] Ride Requested! ID: ${ride.id}");
           // TODO: Navigate to 'Searching for Driver' or 'Ride Tracking' screen
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Ride requested! Searching... (ID: ${ride.id})'), backgroundColor: ghanaGreen),
           );
        }
     } catch (e) {
        print("[BookingScreen] Ride request failed: $e");
        if (mounted) _showError("Failed to request ride: ${e.toString().replaceFirst("Exception: ", "")}");
     } finally {
        if (mounted) setState(() { _isRequestingRide = false; });
     }
  }

  // --- Show Error Helper ---
  void _showError(String message) {
     if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }


  @override
  Widget build(BuildContext context) {
    LatLng initialCenter = _pickupLatLng ?? _defaultCenter;
    print("[BookingScreen] Build method called. Initializing: $_isInitializingLocation, ShowOptions: $_showRideOptions");

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book a Ride'), centerTitle: true, elevation: 0,
        backgroundColor: Colors.transparent, systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      extendBodyBehindAppBar: true,
      // *** Wrap body with GestureDetector ***
      body: GestureDetector(
         // When tapping outside of focusable widgets (like TextFields), unfocus them
         onTap: () {
            print("[BookingScreen] GestureDetector tapped - Unfocusing"); // Log tap
            FocusScope.of(context).unfocus();
         },
         // Use opaque to catch taps on empty areas of the stack
         behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            // --- Map View ---
            Positioned.fill(
              child: GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition( target: initialCenter, zoom: 14.5),
                markers: _markers,
                myLocationEnabled: true, myLocationButtonEnabled: true, zoomControlsEnabled: true,
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * (_showRideOptions ? 0.60 : 0.40), top: 100),
                onMapCreated: (GoogleMapController controller) {
                   if (!_mapControllerCompleter.isCompleted) { _mapControllerCompleter.complete(controller); }
                   _mapController = controller;
                   print("[BookingScreen] Map Created/Updated.");
                   if (_pickupLatLng != null) { _animateMapToPosition(_pickupLatLng!); }
                },
                // *** Add onTap to Map to unfocus text fields ***
                onTap: (LatLng position) {
                   print("[BookingScreen] Map tapped - Unfocusing");
                   FocusScope.of(context).unfocus();
                },
              ),
            ),
            // --- End Map View ---

            // --- Loading/Error Indicator during Init ---
            if (_isInitializingLocation)
                Container(
                   color: Colors.black.withOpacity(0.1),
                   child: const Center(child: CircularProgressIndicator())
                ),
            if (!_isInitializingLocation && _initErrorMsg.isNotEmpty)
                Positioned(
                   bottom: MediaQuery.of(context).size.height * 0.4 + 10, left: 16, right: 16,
                   child: Card( color: Colors.red.withOpacity(0.9), child: Padding( padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0), child: Text( _initErrorMsg, style: const TextStyle(color: Colors.white), textAlign: TextAlign.center, ), ) )
                ),
            // --- End Loading/Error Indicator ---

            // --- Bottom Sheet ---
            if (!_isInitializingLocation)
               DraggableScrollableSheet(
                  initialChildSize: _showRideOptions ? 0.65 : 0.45, minChildSize: 0.25, maxChildSize: 0.9,
                  builder: (context, scrollController) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).canvasColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, spreadRadius: 2)],
                      ),
                      child: ListView( // Use ListView for better scroll behavior
                        controller: scrollController,
                        padding: EdgeInsets.zero,
                        children: [
                           Center(child: Container(width: 40, height: 5, margin: const EdgeInsets.only(top: 12, bottom: 12), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(3)))),
                           Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // *** Use GooglePlaceAutoCompleteTextField directly ***
                                  _buildPlacesSearchField(
                                     controller: _pickupController, labelText: 'Pickup Location',
                                     prefixIcon: Icons.my_location, focusNode: _pickupFocusNode,
                                     fieldType: 'pickup',
                                     trailing: IconButton( // Button to use current location
                                       icon: const Icon(Icons.gps_fixed, size: 20, color: textSecondary),
                                       tooltip: 'Use Current Location', padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                                       onPressed: _isInitializingLocation ? null : () => _initializePickupLocation(setAsDefault: true),
                                     ),
                                  ),
                                  const SizedBox(height: 12),
                                   _buildPlacesSearchField(
                                     controller: _destinationController, labelText: 'Destination',
                                     prefixIcon: Icons.location_on_outlined, focusNode: _destinationFocusNode,
                                     fieldType: 'destination',
                                  ),
                                  // *** End GooglePlaceAutoCompleteTextField ***
                                  const SizedBox(height: 16),
                                  AnimatedSwitcher( // Ride Options Section
                                    duration: const Duration(milliseconds: 300),
                                    transitionBuilder: (child, animation) => SizeTransition(sizeFactor: animation, child: child),
                                    child: _showRideOptions ? _buildRideOptionsSection() : const SizedBox.shrink(key: ValueKey('empty')),
                                  ),
                                  const SizedBox(height: 16), // Bottom padding
                                ],
                              ),
                           ),
                        ],
                      ),
                    );
                  },
                ),
            // --- End Bottom Sheet ---
          ],
        ),
      ),
    );
  }

  // --- Helper to build the Autocomplete TextField ---
  Widget _buildPlacesSearchField({
      required TextEditingController controller,
      required String labelText,
      required IconData prefixIcon,
      required String fieldType,
      required FocusNode focusNode,
      Widget? trailing,
  }) {
     bool isApiKeyMissing = _googleApiKey == 'MISSING_API_KEY';

     return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         Text(labelText, style: const TextStyle(fontWeight: FontWeight.w500, color: textPrimary)),
         const SizedBox(height: 8),
         GooglePlaceAutoCompleteTextField(
           textEditingController: controller,
           focusNode: focusNode,
           googleAPIKey: _googleApiKey,
           inputDecoration: InputDecoration(
             hintText: "Search $labelText",
             prefixIcon: Icon(prefixIcon, color: ghanaGreen),
             suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                   if (trailing != null) trailing,
                   ValueListenableBuilder<TextEditingValue>(
                     valueListenable: controller,
                     builder: (context, value, child) {
                        if (value.text.isNotEmpty) {
                           return IconButton(
                              icon: const Icon(Icons.clear, size: 20, color: textSecondary),
                              tooltip: 'Clear',
                              padding: const EdgeInsets.only(right: 8.0),
                              constraints: const BoxConstraints(),
                              onPressed: !isApiKeyMissing ? () {
                                 controller.clear();
                                 setState(() {
                                    if (fieldType == 'pickup') _pickupLatLng = null;
                                    else _destinationLatLng = null;
                                    _markers.removeWhere((m) => m.markerId.value == fieldType);
                                    _checkShowRideOptions(); _fetchEstimatedFare();
                                 });
                              } : null,
                           );
                        }
                        return const SizedBox.shrink();
                     },
                   ),
                   if (trailing != null && controller.text.isNotEmpty) const SizedBox(width: 4),
                ],
             ),
             filled: true, fillColor: Colors.grey.shade100,
             border: OutlineInputBorder( borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
             enabledBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0)),
             focusedBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: ghanaGreen, width: 1.5)),
             contentPadding: const EdgeInsets.only(left:16, right: 4, top: 14, bottom: 14),
           ),
           debounceTime: 400, countries: const ["GH"], isLatLngRequired: false,
           getPlaceDetailWithLatLng: (prediction) => _onPlaceSelected(prediction, fieldType),
           itemClick: (prediction) {
              controller.text = prediction.description ?? "";
              controller.selection = TextSelection.fromPosition(TextPosition(offset: prediction.description?.length ?? 0));
              // *** Explicitly unfocus after item click ***
              if (fieldType == 'pickup') _pickupFocusNode.unfocus();
              else _destinationFocusNode.unfocus();
              // *** Let getPlaceDetailWithLatLng handle fetching details ***
           },
           itemBuilder: (context, index, Prediction prediction) {
              return Material(
                 color: Colors.transparent,
                 child: InkWell(
                   onTap: () {
                      // Manually trigger selection logic when tapping item
                      _onPlaceSelected(prediction, fieldType);
                      // Update text field immediately
                      controller.text = prediction.description ?? "";
                      controller.selection = TextSelection.fromPosition(TextPosition(offset: prediction.description?.length ?? 0));
                      // *** Explicitly unfocus after item tap ***
                      if (fieldType == 'pickup') _pickupFocusNode.unfocus();
                      else _destinationFocusNode.unfocus();
                   },
                   child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                         children: [
                            const Icon(Icons.location_on_outlined, color: textSecondary),
                            const SizedBox(width: 12),
                            Expanded(child: Text(prediction.description ?? '...', style: const TextStyle(fontSize: 15), overflow: TextOverflow.ellipsis))
                         ],
                      ),
                   ),
                 ),
              );
           },
           seperatedBuilder: Divider(height: 1, color: Colors.grey.shade200),
           isCrossBtnShown: false, // Use custom suffixIcon logic
         ),
       ],
     );
  }
  // --- End Helper ---


  // --- Extracted Ride Options Section ---
  Widget _buildRideOptionsSection() {
    print("[BookingScreen] Building Ride Options Section...");
    return Column(
      key: const ValueKey('rideOptions'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 24),
        const Text('Ride Option', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        DriverCard(
          name: "Available Okada", rating: 4.5,
          price: _isFetchingFare ? "..." : (_estimatedFare != null ? 'GH₵ ${_estimatedFare!.toStringAsFixed(2)}' : 'N/A'),
          eta: _isFetchingFare ? "..." : "5 min", // Placeholder
          isSelected: true,
          onTap: () { /* Select this option if multiple later */ },
        ),
        const Divider(height: 24),
        const Text('Payment Method', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        PaymentMethodSelector(
          onPaymentMethodSelected: (method) {
            setState(() { _selectedPaymentMethod = method; });
            print("Selected Payment: $method");
          },
        ),
        const SizedBox(height: 24),
        GhanaButton(
          text: 'Request Okada Ride',
          isLoading: _isRequestingRide,
          onPressed: (_isRequestingRide || _pickupLatLng == null || _destinationLatLng == null) ? null : _requestRide,
        ),
      ],
    );
  }
  // --- End Ride Options Section ---

} // End of _BookingScreenState
