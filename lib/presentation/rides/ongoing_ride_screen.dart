import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:okada/core/constants/theme.dart';
import 'package:okada/core/widgets/ghana_widgets.dart';
import 'package:okada/data/models/ride_model.dart' as ride_model;
import 'package:okada/notifiers/ride_notifier.dart';
import 'package:okada/providers/ride_provider.dart';
import 'package:okada/providers/app_providers.dart';
import 'package:okada/routes.dart';
import 'package:okada/core/services/websocket_service.dart';
import 'package:okada/providers/auth_providers.dart';

class OngoingRideScreen extends ConsumerStatefulWidget {
  final int rideId;
  const OngoingRideScreen({super.key, required this.rideId});

  @override
  ConsumerState<OngoingRideScreen> createState() => _OngoingRideScreenState();
}

class _OngoingRideScreenState extends ConsumerState<OngoingRideScreen> {
  final Completer<GoogleMapController> _mapControllerCompleter = Completer<GoogleMapController>();
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  static const LatLng _defaultCenter = LatLng(5.6037, -0.1870); // Accra coordinates
  bool _isFetchingRoute = false;
  
  // WebSocket for real-time updates
  StreamSubscription? _websocketSubscription;

  @override
  void initState() {
    super.initState();
    print("[OngoingRideScreen] initState for rideId: ${widget.rideId}");
    // Fetch initial ride details and start polling for live updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final rideDetailNotifier = ref.read(rideDetailProvider(widget.rideId).notifier);
        rideDetailNotifier.startPolling(interval: const Duration(seconds: 5)); // Faster polling as fallback
        _initializeWebSocket(); // Initialize WebSocket for real-time updates
      }
    });
  }

  @override
  void dispose() {
    print("[OngoingRideScreen] dispose for rideId: ${widget.rideId}");
    // Stop polling when screen is disposed
    ref.read(rideDetailProvider(widget.rideId).notifier).stopPolling();
    _websocketSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  void _initializeWebSocket() {
    print("[OngoingRideScreen] Initializing WebSocket for real-time ride updates");
    final websocketService = ref.read(websocketServiceProvider);
    final authState = ref.read(authNotifierProvider);
    
    if (authState.user != null) {
      websocketService.connect(authState.user!.id.toString());
      _websocketSubscription = websocketService.messages.listen((data) {
        print("[OngoingRideScreen] WebSocket message received: $data");
        _handleWebSocketMessage(data);
      }, onError: (err) {
        print("[OngoingRideScreen] WebSocket error: $err");
      }, onDone: () {
        print("[OngoingRideScreen] WebSocket connection closed");
      });
    } else {
      print("[OngoingRideScreen] No user found, skipping WebSocket initialization");
    }
  }

  void _handleWebSocketMessage(Map<String, dynamic> data) {
    final type = data['type'];
    print("[OngoingRideScreen] Processing WebSocket message type: $type");
    
    switch (type) {
      case 'send.notification':
        final payload = data['payload'];
        if (payload != null) {
          _handleWebSocketMessage(payload);
        }
        break;
      case 'RIDE_ASSIGNED':
      case 'RIDE_ON_ROUTE_TO_PICKUP':
      case 'DRIVER_ARRIVED':
      case 'RIDE_STARTED':
      case 'RIDE_COMPLETED':
      case 'RIDE_CANCELLED_BY_RIDER':
      case 'RIDE_CANCELLED_BY_DRIVER':
      case 'NO_DRIVER_FOUND':
        print("[OngoingRideScreen] Ride status update received: $type");
        // Immediately fetch updated ride details
        final rideDetailNotifier = ref.read(rideDetailProvider(widget.rideId).notifier);
        rideDetailNotifier.fetchRideDetails();
        break;
      default:
        print("[OngoingRideScreen] Unknown WebSocket message type: $type");
    }
  }

  Future<void> _fetchRoutePolyline(LatLng origin, LatLng destination) async {
    if (_isFetchingRoute) return;
    setState(() => _isFetchingRoute = true);

    try {
      final directionsService = ref.read(directionsServiceProvider);
      final points = await directionsService.getRoutePolyline(origin, destination);
      
      if (!mounted) return;

      setState(() {
        _polylines.clear();
        _polylines.add(Polyline(
          polylineId: const PolylineId('route'),
          points: points,
          color: ghanaGreen,
          width: 5,
        ));
      });

      // Fit the map to show the entire route
      if (_mapController != null) {
        final bounds = LatLngBounds(
          southwest: LatLng(
            points.map((p) => p.latitude).reduce((a, b) => a < b ? a : b),
            points.map((p) => p.longitude).reduce((a, b) => a < b ? a : b),
          ),
          northeast: LatLng(
            points.map((p) => p.latitude).reduce((a, b) => a > b ? a : b),
            points.map((p) => p.longitude).reduce((a, b) => a > b ? a : b),
          ),
        );
        _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50.0));
      }
    } catch (e) {
      print("[OngoingRideScreen] Error fetching route: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load route: ${e.toString().replaceFirst("Exception: ", "")}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isFetchingRoute = false);
    }
  }

  void _updateMap(ride_model.Ride ride) {
    if (!mounted) return;

    final Set<Marker> newMarkers = {};

    // Add pickup and destination markers
    if (ride.pickupLatLng != null) {
      newMarkers.add(Marker(
        markerId: const MarkerId('pickup'),
        position: ride.pickupLatLng!,
        infoWindow: InfoWindow(title: 'Pickup', snippet: ride.pickupAddress),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ));
    }
    if (ride.destinationLatLng != null) {
      newMarkers.add(Marker(
        markerId: const MarkerId('destination'),
        position: ride.destinationLatLng!,
        infoWindow: InfoWindow(title: 'Destination', snippet: ride.destinationAddress),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ));
    }

    // TODO: Add and update driver's live location marker
    // if (ride.driver?.currentLocation != null) { ... }

    // Update state only if markers have changed to avoid unnecessary rebuilds
    if (_markers.length != newMarkers.length || !_markers.containsAll(newMarkers)) {
      setState(() {
        _markers.clear();
        _markers.addAll(newMarkers);
      });
    }

    // Fetch and draw route polyline if we have both pickup and destination
    if (ride.pickupLatLng != null && ride.destinationLatLng != null && _polylines.isEmpty) {
      _fetchRoutePolyline(ride.pickupLatLng!, ride.destinationLatLng!);
    }
  }

  void _handleCancelRide(ride_model.Ride ride) async {
    bool? confirmCancel = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Ride?'),
        content: const Text('Are you sure you want to cancel this ride?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No'),),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: ghanaRed),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, Cancel', style: TextStyle(color: ghanaWhite)),
          ),
        ],
      ),
    );

    if (confirmCancel == true && mounted) {
      final rideNotifier = ref.read(rideDetailProvider(widget.rideId).notifier);
      try {
        await rideNotifier.cancelRideAction("Cancelled by rider");
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Your ride has been cancelled.'), backgroundColor: ghanaGreen,));
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to cancel ride: ${e.toString().replaceFirst("Exception: ","")}'), backgroundColor: ghanaRed,));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rideDetailState = ref.watch(rideDetailProvider(widget.rideId));
    final ride_model.Ride? ride = rideDetailState.ride;

    if (ride != null) {
      _updateMap(ride);
    }

    // Handle loading and error states for the initial fetch
    if (rideDetailState.isLoading && ride == null) {
      return Scaffold(appBar: AppBar(title: const Text("Loading Ride...")), body: const Center(child: CircularProgressIndicator()));
    }
    if (rideDetailState.error != null && ride == null) {
      return Scaffold(appBar: AppBar(title: const Text("Error")), body: Center(child: Text("Error loading ride: ${rideDetailState.error}")));
    }
    if (ride == null) {
      return Scaffold(appBar: AppBar(title: const Text("Ride Not Found")), body: const Center(child: Text("Could not load ride details.")));
    }
    
    return Scaffold(
      backgroundColor: ghanaWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(ride),
            Expanded(
              child: _buildMap(ride),
            ),
            _buildBottomPanel(ride),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ride_model.Ride ride) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: ghanaGreen,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: ghanaWhite,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getStatusIcon(ride.status),
              color: ghanaGreen,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusText(ride.status),
                  style: const TextStyle(
                    color: ghanaWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _getStatusSubtext(ride),
                  style: TextStyle(
                    color: ghanaWhite.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              // Show trip details
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ghanaWhite.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.info_outline,
                color: ghanaWhite,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'ACCEPTED':
        return Icons.directions_bike;
      case 'ON_ROUTE_TO_PICKUP':
        return Icons.directions_bike;
      case 'ARRIVED_AT_PICKUP':
        return Icons.location_on;
      case 'ON_TRIP':
        return Icons.directions_bike;
      case 'COMPLETED':
        return Icons.check_circle;
      default:
        return Icons.schedule;
    }
  }

  String _getStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'ACCEPTED':
        return 'Driver Assigned';
      case 'ON_ROUTE_TO_PICKUP':
        return 'Driver En Route';
      case 'ARRIVED_AT_PICKUP':
        return 'Driver Arrived';
      case 'ON_TRIP':
        return 'On Trip to Destination';
      case 'COMPLETED':
        return 'Trip Completed';
      default:
        return 'Ride Status: $status';
    }
  }

  String _getStatusSubtext(ride_model.Ride ride) {
    switch (ride.status.toUpperCase()) {
      case 'ACCEPTED':
        return 'Your driver is on the way';
      case 'ON_ROUTE_TO_PICKUP':
        return 'Heading to pickup location';
      case 'ARRIVED_AT_PICKUP':
        return 'Driver is waiting for you';
      case 'ON_TRIP':
        return ride.destinationAddress ?? 'Heading to destination';
      case 'COMPLETED':
        return 'Trip completed successfully';
      default:
        return ride.pickupAddress ?? 'Ride in progress';
    }
  }

  Widget _buildMap(ride_model.Ride ride) {
    return Stack(
      children: [
        GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            target: ride.pickupLatLng ?? _defaultCenter,
            zoom: 16.5,
          ),
          markers: _markers,
          polylines: _polylines,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          onMapCreated: (GoogleMapController controller) {
            _mapControllerCompleter.complete(controller);
            _mapController = controller;
          },
        ),
        Positioned(
          top: 16,
          right: 16,
          child: Column(
            children: [
              _buildMapControlButton(
                icon: Icons.my_location,
                onTap: () {
                  // Center on user location
                },
              ),
              const SizedBox(height: 8),
              _buildMapControlButton(
                icon: Icons.directions,
                onTap: () {
                  // Refresh route
                  if (ride.pickupLatLng != null && ride.destinationLatLng != null) {
                    _fetchRoutePolyline(ride.pickupLatLng!, ride.destinationLatLng!);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMapControlButton({
    required IconData icon,
    required Function() onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: ghanaWhite,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: ghanaGreen),
      ),
    );
  }

  Widget _buildBottomPanel(ride_model.Ride ride) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ghanaWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDriverInfo(ride),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildActionButton(
                icon: Icons.phone,
                text: 'Call',
                onTap: () {
                  // Call driver
                  print("TODO: Call driver at ${ride.driver?.phoneNumber}");
                },
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                icon: Icons.message,
                text: 'Message',
                onTap: () {
                  // Send message
                },
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                icon: Icons.cancel,
                text: 'Cancel',
                onTap: () => _handleCancelRide(ride),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTripInfo(ride),
        ],
      ),
    );
  }

  Widget _buildDriverInfo(ride_model.Ride ride) {
    final driver = ride.driver;
    if (driver == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ghanaGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.schedule, color: ghanaGreen),
            SizedBox(width: 12),
            Text(
              'Waiting for driver assignment...',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: ghanaGreen,
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ghanaGreen.withOpacity(0.1),
          ),
          child: driver.profilePicture != null && driver.profilePicture!.isNotEmpty
              ? ClipOval(
                  child: Image.network(
                    driver.profilePicture!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.person,
                      color: ghanaGreen,
                      size: 30,
                    ),
                  ),
                )
              : const Center(
                  child: Icon(
                    Icons.person,
                    color: ghanaGreen,
                    size: 30,
                  ),
                ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                driver.fullName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.star,
                    color: ghanaGold,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    driver.numericRating?.toStringAsFixed(1) ?? 'N/A',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '• ${driver.vehicleModel ?? 'Okada'}',
                    style: const TextStyle(
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                driver.vehicleNumber ?? '---',
                style: const TextStyle(
                  color: textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ghanaGold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
                     child: Text(
             'GHS ${ride.fare?.toStringAsFixed(2) ?? '0.00'}',
             style: const TextStyle(
               fontWeight: FontWeight.bold,
               color: ghanaGold,
             ),
           ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required Function() onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: ghanaGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(icon, color: ghanaGreen),
              const SizedBox(height: 4),
              Text(
                text,
                style: const TextStyle(
                  color: ghanaGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripInfo(ride_model.Ride ride) {
    return Column(
      children: [
        _buildLocationRow(
          icon: Icons.my_location,
          address: ride.pickupAddress ?? "Pickup location",
          title: "Pickup",
        ),
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Container(height: 20, width: 2, color: Colors.grey.shade300),
        ),
        _buildLocationRow(
          icon: Icons.location_on,
          address: ride.destinationAddress ?? "Destination",
          title: "Destination",
        ),
      ],
    );
  }

  Widget _buildLocationRow({
    required IconData icon,
    required String address,
    required String title,
  }) {
    return Row(
      children: [
        Icon(icon, size: 24, color: textSecondary),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                address,
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
