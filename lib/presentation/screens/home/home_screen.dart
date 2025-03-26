
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/theme.dart';
import '../../../core/widgets/ghana_widgets.dart';
import '../../../routes.dart';
import 'widgets/quick_route_card.dart';
import 'widgets/trip_card.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppBar(),
                _buildHeroSection(),
                _buildQuickRoutes(),
                _buildRecentTrips(),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Menu button and logo
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.menu, size: 24),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              SizedBox(width: 8),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: ghanaGold,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        'O',
                        style: TextStyle(
                          fontFamily: 'Playfair Display',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: ghanaBlack,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Okada',
                    style: TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: ghanaBlack,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Notification and profile icons
          Row(
            children: [
              Stack(
                children: [
                  IconButton(
                    icon: Icon(Icons.notifications_outlined, size: 24),
                    onPressed: () {},
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: ghanaRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.profile);
                },
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: ghanaGreen.withOpacity(0.2),
                  child: Icon(
                    Icons.person_outline,
                    color: ghanaGreen,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      margin: EdgeInsets.all(16),
      height: 380,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: ghanaGreen,
        boxShadow: [
          BoxShadow(
            color: ghanaGreen.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background image with overlay
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              decoration: BoxDecoration(
                color: ghanaGreen,
                // Image would go here - using placeholder comment
                // Image.asset('assets/images/accra_market.jpg', fit: BoxFit.cover)
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      ghanaGreen.withOpacity(0.7),
                      ghanaGreen.withOpacity(0.9),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Content
          Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick & Reliable\nOkada Rides',
                  style: TextStyle(
                    fontFamily: 'Playfair Display',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: ghanaWhite,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Beat the traffic with our trusted motorbike taxis. Fast, safe, and affordable rides across Ghana.',
                  style: TextStyle(
                    fontSize: 16,
                    color: ghanaWhite.withOpacity(0.9),
                  ),
                ),
                SizedBox(height: 24),
                GhanaButton(
                  text: 'Book a Ride Now',
                  width: 200,
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.book);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickRoutes() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quick Routes',
                style: TextStyle(
                  fontFamily: 'Playfair Display',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ghanaBlack,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Row(
                  children: [
                    Text(
                      'View All',
                      style: TextStyle(
                        color: ghanaGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: ghanaGreen,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.9,
            children: [
              QuickRouteCard(
                from: 'Accra Central',
                to: 'Makola Market',
                price: '15 GHS',
                time: '10 min',
                popularity: 'Popular',
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.book);
                },
              ),
              QuickRouteCard(
                from: 'East Legon',
                to: 'Airport City',
                price: '25 GHS',
                time: '15 min',
                popularity: 'High Demand',
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.book);
                },
              ),
              QuickRouteCard(
                from: 'Madina',
                to: 'University of Ghana',
                price: '20 GHS',
                time: '12 min',
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.book);
                },
              ),
              QuickRouteCard(
                from: 'Osu',
                to: 'Labadi Beach',
                price: '18 GHS',
                time: '8 min',
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.book);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTrips() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Trips',
                style: TextStyle(
                  fontFamily: 'Playfair Display',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ghanaBlack,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.trips);
                },
                child: Row(
                  children: [
                    Text(
                      'View All',
                      style: TextStyle(
                        color: ghanaGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: ghanaGreen,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          TripCard(
            from: 'Osu',
            to: 'Kwame Nkrumah Circle',
            date: 'Today, 10:30 AM',
            price: '22 GHS',
            status: 'Completed',
            driverName: 'Isaac Owusu',
            driverRating: 4.8,
          ),
          SizedBox(height: 16),
          TripCard(
            from: 'Achimota',
            to: 'Accra Mall',
            date: 'Yesterday, 2:15 PM',
            price: '30 GHS',
            status: 'Completed',
            driverName: 'Kofi Mensah',
            driverRating: 4.5,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: ghanaGreen,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: ghanaWhite,
                  child: Text(
                    'KM',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: ghanaGreen,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Kofi Mensah',
                  style: TextStyle(
                    color: ghanaWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '+233 55 123 4567',
                  style: TextStyle(
                    color: ghanaWhite.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            icon: Icons.home_outlined,
            title: 'Home',
            onTap: () {
              Navigator.pop(context);
            },
            isSelected: true,
          ),
          _buildDrawerItem(
            icon: Icons.map_outlined,
            title: 'Book Ride',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.book);
            },
          ),
          _buildDrawerItem(
            icon: Icons.history_outlined,
            title: 'My Trips',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.trips);
            },
          ),
          _buildDrawerItem(
            icon: Icons.person_outline,
            title: 'Profile',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.profile);
            },
          ),
          _buildDrawerItem(
            icon: Icons.credit_card_outlined,
            title: 'Payment Methods',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.payment);
            },
          ),
          Divider(),
          _buildDrawerItem(
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: () {},
          ),
          _buildDrawerItem(
            icon: Icons.help_outline,
            title: 'Help Center',
            onTap: () {},
          ),
          SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: ghanaRed,
                side: BorderSide(color: ghanaRed),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              icon: Icon(Icons.logout),
              label: Text('Sign Out'),
              onPressed: () {},
            ),
          ),
          SizedBox(height: 24),
          Center(
            child: Text(
              'Okada © 2023',
              style: TextStyle(
                color: textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? ghanaGreen : textPrimary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? ghanaGreen : textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: ghanaGreen.withOpacity(0.1),
      onTap: onTap,
    );
  }
}
