//lib/presentation/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod

import '../../../core/constants/theme.dart';
import '../../../core/widgets/ghana_widgets.dart';
import '../../../routes.dart';
import 'package:okada/providers/auth_providers.dart';

import 'widgets/quick_route_card.dart';
import 'widgets/trip_card.dart';



class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends ConsumerState<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  
  // --- Logout Dialog Method ---
  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext), // Close dialog
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ghanaGreen, // Use theme color
            ),
            onPressed: () {
              Navigator.pop(dialogContext); // Close the dialog
              // Read the notifier and call the logout method using ref
              ref.read(authNotifierProvider.notifier).logout();
              // AuthWrapper will automatically handle navigating to LoginScreen
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
  // --- End Logout Dialog Method ---

  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(context, ref),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppBar(context, ref),
                _buildHeroSection(),
                _buildQuickRoutes(),
                _buildRecentTrips(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext contex, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider.select((state) => state.user));
    String initials = ((user?.firstName.isNotEmpty == true ? user!.firstName[0] : '') +
                       (user?.lastName.isNotEmpty == true ? user!.lastName[0] : '')).toUpperCase();
    if (initials.isEmpty) initials = '?';

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

  Widget _buildDrawer(BuildContext context, WidgetRef ref) {
    // Watch only the user part of the state
    final user = ref.watch(authNotifierProvider.select((state) => state.user));
    // Safely calculate initials
    String initials = ((user?.firstName.isNotEmpty == true ? user!.firstName[0] : '') +
                       (user?.lastName.isNotEmpty == true ? user!.lastName[0] : '')).toUpperCase();
    if (initials.isEmpty) initials = '?'; // Fallback

    final currentRoute = ModalRoute.of(context)?.settings.name ?? AppRoutes.home;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader( // User Info Header
            decoration: const BoxDecoration(color: ghanaGreen),
            child: Column(
               crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end,
               children: [
                 CircleAvatar(
                   radius: 30, backgroundColor: ghanaWhite,
                   backgroundImage: (user?.profilePicture != null && user!.profilePicture!.isNotEmpty) ? NetworkImage(user.profilePicture!) : null,
                   child: (user?.profilePicture == null || user!.profilePicture!.isEmpty)
                    ? Text(initials, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: ghanaGreen))
                    : null),
                 const SizedBox(height: 12),
                 Text(
                   user?.fullName ?? 'User Name', // Display full name safely
                   style: const TextStyle(color: ghanaWhite, fontSize: 18, fontWeight: FontWeight.bold),
                   maxLines: 1, overflow: TextOverflow.ellipsis
                 ),
                 const SizedBox(height: 4),
                 Text(
                   user?.phoneNumber ?? 'Phone Number', // Display phone safely
                   style: TextStyle(color: ghanaWhite.withOpacity(0.9), fontSize: 14)
                 ),
               ],
            ),
          ),
          // Drawer Menu Items
          _buildDrawerItem( context: context, title: 'Home', icon: Icons.home_outlined, route: AppRoutes.home, currentRoute: currentRoute ),
          _buildDrawerItem( context: context, title: 'Book Ride', icon: Icons.map_outlined, route: AppRoutes.book, currentRoute: currentRoute ),
          _buildDrawerItem( context: context, title: 'My Trips', icon: Icons.history_outlined, route: AppRoutes.trips, currentRoute: currentRoute ),
          _buildDrawerItem( context: context, title: 'Profile', icon: Icons.person_outline, route: AppRoutes.profile, currentRoute: currentRoute ),
          _buildDrawerItem( context: context, title: 'Payment Methods', icon: Icons.credit_card_outlined, route: AppRoutes.payment, currentRoute: currentRoute ),
          const Divider(),
          _buildDrawerItem( context: context, title: 'Settings', icon: Icons.settings_outlined, route: AppRoutes.settings, currentRoute: currentRoute ),
          _buildDrawerItem( context: context, title: 'Help Center', icon: Icons.help_outline, route: AppRoutes.support, currentRoute: currentRoute ),
          const SizedBox(height: 16),
          // Sign Out Button (Calls dialog which calls notifier)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(foregroundColor: ghanaRed, side: const BorderSide(color: ghanaRed), padding: const EdgeInsets.symmetric(vertical: 12)),
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
              // Call the logout dialog method using ref from the state class
              onPressed: () => _showLogoutDialog(context, ref),
            ),
          ),
          const SizedBox(height: 24),
          Center(child: Text('Okada © ${DateTime.now().year}', style: const TextStyle(color: textSecondary, fontSize: 12))),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
      required BuildContext context,
      required String title,
      required IconData icon,
      required String route,
      required String currentRoute,
      VoidCallback? onTap,
    }) {
      final bool isSelected = (route == currentRoute);
      return ListTile(
        leading: Icon( icon, color: isSelected ? ghanaGreen : textPrimary ),
        title: Text( title, style: TextStyle( color: isSelected ? ghanaGreen : textPrimary, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal, ), ),
        selected: isSelected,
        selectedTileColor: ghanaGreen.withOpacity(0.1),
        onTap: onTap ?? () { // Default navigation behavior
            Navigator.pop(context); // Close drawer
            if (!isSelected) {
               Navigator.pushNamed(context, route);
            }
        },
      );
    }
}
