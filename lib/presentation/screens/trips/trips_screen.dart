
import 'package:flutter/material.dart';
import '../../../core/constants/theme.dart';
import '../../../core/widgets/ghana_widgets.dart';
import 'widgets/trip_item.dart';
import 'widgets/active_trip_card.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  _TripsScreenState createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _hasActiveTrip = true; // For demo purposes

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Trips'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: ghanaGreen,
          labelColor: ghanaGreen,
          unselectedLabelColor: textSecondary,
          tabs: [
            Tab(text: 'Current'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCurrentTripsTab(),
          _buildHistoryTripsTab(),
        ],
      ),
    );
  }

  Widget _buildCurrentTripsTab() {
    return _hasActiveTrip
        ? Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ActiveTripCard(
                  from: 'East Legon',
                  to: 'Accra Mall',
                  driverName: 'Isaac Owusu',
                  driverRating: 4.8,
                  eta: '10 min',
                  onCancel: () {
                    // Show cancel confirmation dialog
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Cancel Trip'),
                        content: Text('Are you sure you want to cancel this trip? Cancellation fees may apply.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('No, Keep Trip'),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: ghanaRed,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              setState(() {
                                _hasActiveTrip = false;
                              });
                            },
                            child: Text('Yes, Cancel Trip'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          )
        : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.motorcycle_outlined,
                  size: 72,
                  color: textSecondary,
                ),
                SizedBox(height: 16),
                Text(
                  'No Active Trips',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Book a ride to get started!',
                  style: TextStyle(
                    color: textSecondary,
                  ),
                ),
                SizedBox(height: 24),
                GhanaButton(
                  text: 'Book a Ride',
                  width: 200,
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/book');
                  },
                ),
              ],
            ),
          );
  }

  Widget _buildHistoryTripsTab() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        TripItem(
          from: 'Osu',
          to: 'Kwame Nkrumah Circle',
          date: 'Today, 10:30 AM',
          price: '22 GHS',
          status: 'Completed',
          driverName: 'Isaac Owusu',
          driverRating: 4.8,
        ),
        TripItem(
          from: 'Achimota',
          to: 'Accra Mall',
          date: 'Yesterday, 2:15 PM',
          price: '30 GHS',
          status: 'Completed',
          driverName: 'Kofi Mensah',
          driverRating: 4.5,
        ),
        TripItem(
          from: 'University of Ghana',
          to: 'Madina Market',
          date: '23 May, 9:45 AM',
          price: '18 GHS',
          status: 'Cancelled',
          driverName: 'Abena Pokuaa',
          driverRating: 4.7,
        ),
        TripItem(
          from: 'Accra Central',
          to: 'Tema Station',
          date: '20 May, 4:30 PM',
          price: '25 GHS',
          status: 'Completed',
          driverName: 'Kwame Asante',
          driverRating: 4.6,
        ),
        TripItem(
          from: 'Labone',
          to: 'Airport City',
          date: '18 May, 11:20 AM',
          price: '28 GHS',
          status: 'Completed',
          driverName: 'Isaac Owusu',
          driverRating: 4.8,
        ),
      ],
    );
  }
}
