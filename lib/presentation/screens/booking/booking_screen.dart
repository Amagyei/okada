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
// Geocoding package might still be used for reverse geocoding current location
import 'package:geocoding/geocoding.dart';
import 'dart:math'; // Import math for min function


class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({Key? key}) : super(key: key);

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
  bool _isRequestingRide = false; // For the "Request Okada Ride" button's loading state
  final Set<Marker> _markers = {};
  PaymentMethod _selectedPaymentMethod = PaymentMethod.mobileMoney;

  static const LatLng _defaultCenter = LatLng(5.6037, -0.1870); // Accra
  bool _showRideOptions = false; // To show/hide DriverCard, PaymentMethodSelector etc.
  bool _isInitializingLocation = true;
  String _initErrorMsg = '';
  bool _isFetchingPlaceDetails = false;

  // *** New state variable for searching UI ***
  bool _isSearchingForDriver = false;
  String? _currentRideId; // To store the ID of the requested ride for polling
  Timer? _rideStatusTimer;


  final String _googleApiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? 'MISSING_API_KEY';
  final FocusNode _pickupFocusNode = FocusNode();
  final FocusNode _destinationFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
       if (_googleApiKey == 'MISSING_API_KEY') {
          print("[BookingScreen] ERROR: GOOGLE_MAPS_API_KEY missing. Geocoding/Maps/Places will fail.");
          _showError("Map/Search unavailable: API key missing.");
          if (mounted) setState(() => _isInitializingLocation = false);
       } else {
          _initializePickupLocation(setAsDefault: true);
       }
    });
  }

  Future<void> _initializePickupLocation({bool setAsDefault = false}) async {
    print("[BookingScreen] Start _initializePickupLocation (setAsDefault: $setAsDefault)");
    if (!mounted) return;
    if (setAsDefault || !_isInitializingLocation) { // Ensure loading is true if re-initializing
      setState(() => _isInitializingLocation = true);
    }
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
    _pickupController.dispose();
    _destinationController.dispose();
    _mapController?.dispose();
    _pickupFocusNode.dispose();
    _destinationFocusNode.dispose();
    _rideStatusTimer?.cancel();
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

    if (fieldType == 'pickup') _pickupFocusNode.unfocus();
    else _destinationFocusNode.unfocus();
    FocusScope.of(context).unfocus();

    if (prediction.placeId == null) { _showError("Could not get place details (Missing Place ID)."); setState(() => _isFetchingPlaceDetails = false); return; }
    if (_googleApiKey == 'MISSING_API_KEY') { _showError("Map search unavailable: API key missing."); setState(() => _isFetchingPlaceDetails = false); return; }

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
              } else {
                _destinationLatLng = coords;
                _destinationController.text = placeName;
                _destinationController.selection = TextSelection.fromPosition(TextPosition(offset: _destinationController.text.length));
                _updateMarkersDirectly('destination', coords, 'Destination: $placeName');
              }
              _checkShowRideOptions();
            });
            _fetchEstimatedFare();
          } else {
             print("[BookingScreen] Places Details API Error: Lat/Lng missing.");
            _showError("Failed to get location coordinates from API response.");
          }
        } else {
          final String apiErrorMsg = data['error_message'] ?? data['status'] ?? 'Unknown API error';
          print("[BookingScreen] Places Details API Error: $apiErrorMsg");
          _showError("Failed to get location details: $apiErrorMsg");
        }
      } else {
        print("[BookingScreen] Places Details HTTP Error: ${response.statusCode}");
        _showError("Failed to get location details (HTTP ${response.statusCode}).");
      }
    } on TimeoutException catch (_) {
        print("[BookingScreen] Error calling Place Details API: Timeout");
        if (mounted) _showError("Getting location details timed out.");
    } catch (e) {
        print("[BookingScreen] Error calling Place Details API: $e");
        if (mounted) _showError("Error getting location details: ${e.toString()}");
    } finally {
        if (mounted) setState(() => _isFetchingPlaceDetails = false);
    }
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
    final rideService = ref.read(rideServiceProvider);
    try {
       final fare = await rideService.getEstimatedFare(
         pickupCoords: _pickupLatLng!,
         destinationCoords: _destinationLatLng!,
       );
      print("[BookingScreen] Fare estimate received from API: $fare");
      if (mounted) setState(() { _estimatedFare = fare; });
    } catch (e) {
       print("[BookingScreen] Error fetching fare from API: $e");
       if (mounted) _showError("Could not get fare estimate: ${e.toString().replaceFirst("Exception: ", "")}");
       if (mounted) setState(() { _estimatedFare = null; });
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
     if (_estimatedFare == null) {
        _showError("Could not get fare estimate. Please try again."); return;
     }

     print("[BookingScreen] Attempting ride request...");
     // Set _isRequestingRide for button, _isSearchingForDriver for UI switch
     setState(() { _isRequestingRide = true; });

     final rideService = ref.read(rideServiceProvider);
     try {
        print("[BookingScreen] Calling createRideRequest Service...");
        final ride = await rideService.createRideRequest(
           pickupCoords: _pickupLatLng!, pickupAddress: pickupAddress,
           destinationCoords: _destinationLatLng!, destinationAddress: destinationAddress,
           estimatedFare: _estimatedFare!,
        );
        if (mounted) {
           print("[BookingScreen] Ride Requested! ID: ${ride.id}");
           // *** This setState will trigger the UI change ***
           setState(() {
             _isSearchingForDriver = true; // This is the key flag for UI switch
             _currentRideId = ride.id.toString();
             _isRequestingRide = false; // Reset button loading state
           });
           print("[BookingScreen] After setState in _requestRide: _isSearchingForDriver=$_isSearchingForDriver");
           _startRideStatusPolling(ride.id);
        }
     } catch (e) {
        print("[BookingScreen] Ride request failed: $e");
        if (mounted) {
           _showError("Failed to request ride: ${e.toString().replaceFirst("Exception: ", "")}");
           setState(() { _isRequestingRide = false; }); // Reset button loading on error
        }
     }
     // _isRequestingRide is reset above or on error
  }

  // --- Polling for Ride Status ---
  void _startRideStatusPolling(int rideId) {
    print("[BookingScreen] Starting ride status polling for ride ID: $rideId");
    _rideStatusTimer?.cancel();
    _rideStatusTimer = Timer.periodic(const Duration(seconds: 7), (timer) async {
      if (!mounted || !_isSearchingForDriver) { // Check _isSearchingForDriver
        timer.cancel();
        print("[BookingScreen] Polling stopped (unmounted or no longer searching).");
        return;
      }
      print("[BookingScreen] Polling for ride status (ID: $rideId)...");
      try {
        // TODO: Implement RideService.getRideDetails(rideId)
        // final rideDetails = await ref.read(rideServiceProvider).getRideDetails(rideId);
        if (timer.tick > 3) { // Simulate acceptance
           print("[BookingScreen] SIMULATING DRIVER ACCEPTANCE for ride $rideId");
           if (mounted) {
             setState(() { _isSearchingForDriver = false; }); // Stop searching UI
             _showError("Ride Accepted! (Simulated)"); // Replace with actual UI
             timer.cancel(); // Stop polling
             // TODO: Navigate to Ride Tracking Screen
           }
        }
      } catch (e) { print("[BookingScreen] Error polling ride status: $e"); }
    });
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
    print("[BookingScreen] Build: Init: $_isInitializingLocation, ShowOpts: $_showRideOptions, Searching: $_isSearchingForDriver");

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book a Ride'), centerTitle: true, elevation: 0,
        backgroundColor: Colors.transparent, systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      extendBodyBehindAppBar: true,
      body: GestureDetector(
         onTap: () {
            print("[BookingScreen] GestureDetector tapped - Unfocusing");
            FocusScope.of(context).unfocus();
         },
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
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height *
                      (_isSearchingForDriver
                          ? 0.25
                          : (_showRideOptions ? 0.60 : 0.40)),
                  top: 100
                ),
                onMapCreated: (GoogleMapController controller) {
                   if (!_mapControllerCompleter.isCompleted) { _mapControllerCompleter.complete(controller); }
                   _mapController = controller;
                   print("[BookingScreen] Map Created/Updated.");
                   if (_pickupLatLng != null) { _animateMapToPosition(_pickupLatLng!); }
                },
                onTap: (LatLng position) { FocusScope.of(context).unfocus(); },
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

            // --- Main Content: Booking Sheet OR Searching Overlay ---
            if (!_isInitializingLocation) // Only show after init attempt
              _isSearchingForDriver
                  ? _buildSearchingForDriverUI() // Show searching overlay
                  : DraggableScrollableSheet( // Show booking options sheet
                      initialChildSize: _showRideOptions ? 0.65 : 0.45,
                      minChildSize: 0.25,
                      maxChildSize: 0.9,
                      builder: (context, scrollController) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).canvasColor,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                            boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, spreadRadius: 2)],
                          ),
                          child: ListView(
                            controller: scrollController,
                            padding: EdgeInsets.zero,
                            children: [
                               Center(child: Container(width: 40, height: 5, margin: const EdgeInsets.only(top: 12, bottom: 12), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(3)))),
                               Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildPlacesSearchField(
                                         controller: _pickupController, labelText: 'Pickup Location',
                                         prefixIcon: Icons.my_location, focusNode: _pickupFocusNode,
                                         fieldType: 'pickup',
                                         trailing: IconButton(
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
                                      const SizedBox(height: 16),
                                      AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 300),
                                        transitionBuilder: (child, animation) => SizeTransition(sizeFactor: animation, child: child),
                                        child: _showRideOptions ? _buildRideOptionsSection() : const SizedBox.shrink(key: ValueKey('empty')),
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                  ),
                               ),
                            ],
                          ),
                        );
                      },
                    ),
            // --- End Main Content ---
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
              if (fieldType == 'pickup') _pickupFocusNode.unfocus();
              else _destinationFocusNode.unfocus();
           },
           itemBuilder: (context, index, Prediction prediction) {
              return Material(
                 color: Colors.transparent,
                 child: InkWell(
                   onTap: () {
                      _onPlaceSelected(prediction, fieldType);
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
           isCrossBtnShown: false,
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
          eta: _isFetchingFare ? "..." : "5 min",
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
          onPressed: (_isRequestingRide || _pickupLatLng == null || _destinationLatLng == null || _estimatedFare == null)
              ? null
              : _requestRide,
        ),
      ],
    );
  }
  // --- End Ride Options Section ---

  // --- *** NEW: Searching for Driver UI *** ---
  Widget _buildSearchingForDriverUI() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.75),
        child: Center(
          child: Material(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: Theme.of(context).cardColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.motorcycle, size: 60, color: ghanaGreen),
                  const SizedBox(height: 20),
                  const Text(
                    'Searching for Okadas...',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Connecting you with a nearby rider.',
                    style: TextStyle(fontSize: 14, color: textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  LinearProgressIndicator(
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(ghanaGold),
                    minHeight: 6,
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () {
                      _rideStatusTimer?.cancel();
                      setState(() {
                        _isSearchingForDriver = false;
                        _isRequestingRide = false;
                        // Optionally reset locations or just show ride options again
                        // For now, just hide searching UI and let user decide next
                        if (_pickupLatLng != null && _destinationLatLng != null) {
                           _showRideOptions = true;
                        }
                      });
                      print("Ride search cancelled by user.");
                    },
                    child: const Text('Cancel Request', style: TextStyle(color: ghanaRed, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  // --- *** END Searching For Driver UI *** ---

} // End of _BookingScreenState
