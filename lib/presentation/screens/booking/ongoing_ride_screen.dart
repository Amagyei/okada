
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/theme.dart';

class OngoingRideScreen extends ConsumerStatefulWidget {
  const OngoingRideScreen({super.key});

  @override
  ConsumerState<OngoingRideScreen> createState() => _OngoingRideScreenState();
}

class _OngoingRideScreenState extends ConsumerState<OngoingRideScreen> {
  String tripStatus = 'in_progress'; // driver_coming, in_progress, arrived
  double tripProgress = 0.35; // 35% completed
  
  // Mock trip data
  final Map<String, String> tripDetails = {
    'id': 'TRP001',
    'from': 'Osu Oxford Street',
    'to': 'Kwame Nkrumah Circle',
    'estimatedTime': '12 min',
    'estimatedFare': '22 GHS',
    'distance': '5.2 km',
  };

  final Map<String, dynamic> driverInfo = {
    'name': 'Isaac Owusu',
    'rating': 4.8,
    'phone': '+233 24 123 4567',
    'vehicle': 'Honda CB125',
    'plateNumber': 'GR 2486-23',
    'color': 'Red',
  };

  String _getStatusMessage() {
    switch (tripStatus) {
      case 'driver_coming':
        return 'Driver is on the way to pick you up';
      case 'in_progress':
        return 'Trip in progress';
      case 'arrived':
        return 'You have arrived at your destination';
      default:
        return 'Trip status unknown';
    }
  }

  Color _getStatusColor() {
    switch (tripStatus) {
      case 'driver_coming':
        return ghanaGold;
      case 'in_progress':
        return ghanaGreen;
      case 'arrived':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildMapSection(),
                    _buildTripProgress(),
                    _buildDriverInfo(),
                    _buildTripDetails(),
                    _buildActionButtons(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 16),
      decoration: BoxDecoration(
        color: ghanaGreen,
        boxShadow: [
          BoxShadow(
            color: ghanaGreen.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: ghanaWhite),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Okada Ride',
                  style: TextStyle(
                    fontFamily: 'Playfair Display',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ghanaWhite,
                  ),
                ),
                Text(
                  _getStatusMessage(),
                  style: TextStyle(
                    fontSize: 14,
                    color: ghanaWhite.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: ghanaWhite.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'ID: ${tripDetails['id']}',
              style: const TextStyle(
                color: ghanaWhite,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    return Container(
      height: 250,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ghanaGreen.withOpacity(0.1),
            ghanaGreen.withOpacity(0.2),
          ],
        ),
        border: Border.all(color: ghanaGreen.withOpacity(0.3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Map placeholder
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    ghanaGreen.withOpacity(0.1),
                    ghanaGreen.withOpacity(0.2),
                  ],
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 48,
                    color: ghanaGreen,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Live Map View',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ghanaGreen,
                    ),
                  ),
                  Text(
                    'Real-time tracking active',
                    style: TextStyle(
                      fontSize: 14,
                      color: ghanaGreen.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            // Status indicator
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: ghanaWhite,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      tripStatus.replaceAll('_', ' ').toUpperCase(),
                      style: const TextStyle(
                        color: ghanaWhite,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripProgress() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ghanaWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ghanaBlack.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FROM',
                    style: TextStyle(
                      fontSize: 12,
                      color: textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    tripDetails['from']!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ghanaBlack,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.arrow_forward,
                color: ghanaGreen,
                size: 24,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'TO',
                    style: TextStyle(
                      fontSize: 12,
                      color: textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    tripDetails['to']!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ghanaBlack,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Progress bar
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Trip Progress',
                    style: TextStyle(
                      fontSize: 14,
                      color: textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${(tripProgress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 14,
                      color: ghanaGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: tripProgress,
                backgroundColor: ghanaGreen.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(ghanaGreen),
                minHeight: 6,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDriverInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ghanaWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ghanaBlack.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Driver',
            style: TextStyle(
              fontFamily: 'Playfair Display',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ghanaBlack,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: ghanaGreen.withOpacity(0.2),
                child: Text(
                  driverInfo['name'].split(' ').map((n) => n[0]).join(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ghanaGreen,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driverInfo['name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ghanaBlack,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: ghanaGold,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${driverInfo['rating']} Rating',
                          style: TextStyle(
                            fontSize: 14,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${driverInfo['color']} ${driverInfo['vehicle']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: textSecondary,
                      ),
                    ),
                    Text(
                      driverInfo['plateNumber'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ghanaBlack,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTripDetails() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ghanaWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ghanaBlack.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildDetailItem(
            icon: Icons.access_time,
            label: 'Time',
            value: tripDetails['estimatedTime']!,
          ),
          _buildDetailItem(
            icon: Icons.route,
            label: 'Distance',
            value: tripDetails['distance']!,
          ),
          _buildDetailItem(
            icon: Icons.payments,
            label: 'Fare',
            value: tripDetails['estimatedFare']!,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: ghanaGreen,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: ghanaBlack,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                border: Border.all(color: ghanaGreen),
                borderRadius: BorderRadius.circular(28),
              ),
              child: TextButton.icon(
                onPressed: () {
                  // Call driver functionality
                },
                icon: const Icon(Icons.phone, color: ghanaGreen),
                label: const Text(
                  'Call Driver',
                  style: TextStyle(
                    color: ghanaGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                border: Border.all(color: ghanaGreen),
                borderRadius: BorderRadius.circular(28),
              ),
              child: TextButton.icon(
                onPressed: () {
                  // Message driver functionality
                },
                icon: const Icon(Icons.message, color: ghanaGreen),
                label: const Text(
                  'Message',
                  style: TextStyle(
                    color: ghanaGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
