import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import '../../../core/constants/theme.dart';
import '../../../core/widgets/ghana_widgets.dart';
import '../../../routes.dart';
import '../../../providers/auth_providers.dart'; // Import your providers
import '../../../data/models/user_model.dart'; // Import User model

class ProfileMenuItem {
  final String title;
  final String description;
  final IconData icon;
  final String route;

  const ProfileMenuItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
  });
}

// Change StatelessWidget to ConsumerWidget
class ProfileScreen extends ConsumerWidget {
  static const List<ProfileMenuItem> _menuItems = [
    ProfileMenuItem(
      title: 'Personal Information',
      description: 'Manage your personal details',
      icon: Icons.person_outline,
      route: AppRoutes.personalInfo,
    ),
    ProfileMenuItem(
      title: 'Saved Locations',
      description: 'Manage your saved places',
      icon: Icons.place_outlined,
      route: AppRoutes.savedLocations,
    ),
    ProfileMenuItem(
      title: 'Rate Drivers',
      description: 'Rate your previous rides',
      icon: Icons.star_outline,
      route: AppRoutes.rateDrivers,
    ),
    ProfileMenuItem(
      title: 'Payment Methods',
      description: 'Manage your payment options',
      icon: Icons.payment_outlined,
      route: AppRoutes.payment,
    ),
    ProfileMenuItem(
      title: 'Support',
      description: 'Get help and support',
      icon: Icons.headset_mic_outlined,
      route: AppRoutes.support,
    ),
    ProfileMenuItem(
      title: 'Settings',
      description: 'App preferences and account settings',
      icon: Icons.settings_outlined,
      route: AppRoutes.settings,
    ),
  ];

  const ProfileScreen({super.key});

  @override
  // Add WidgetRef ref to the build method
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the auth state
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user; // Get the user object

    // Handle case where user might somehow be null even if authenticated
    // Although AuthWrapper should prevent this screen from being shown if not authenticated
    if (user == null) {
      // Optionally show a loading indicator or an error, or trigger logout
      // For simplicity, show a basic loading/error state
      return Scaffold(
        body: Center(
          child: Text('Error: User data not available. Please log in again.'),
        ),
      );
      // Consider calling ref.read(authNotifierProvider.notifier).logout(); ?
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Pass the user data to the header builder
              _buildProfileHeader(context, user),
              SizedBox(height: 24),
              ListView.separated(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _menuItems.length,
                separatorBuilder: (context, index) => SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = _menuItems[index];
                  // Ensure GhanaCard is implemented or replace with standard Card/InkWell
                  return GhanaCard( // Assuming GhanaCard takes onTap
                    elevation: 0.5,
                    onTap: () {
                      Navigator.pushNamed(context, item.route);
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: ghanaGold.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            item.icon,
                            color: ghanaGold,
                            size: 28,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                item.description,
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: textSecondary,
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: 40),
              GhanaButton( // Assuming GhanaButton can take an icon
                text: 'Log Out',
                // Pass ref to the dialog function or read inside onPressed
                onPressed: () => _showLogoutDialog(context, ref),
                icon: Icons.logout,
                width: MediaQuery.of(context).size.width * 0.9,
                // Add style if needed, e.g., red color for logout
                // style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Update header to accept User object
  Widget _buildProfileHeader(BuildContext context, User user) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ghanaGreen,
            ghanaGreenDark,
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Display profile picture or fallback icon/initials
              CircleAvatar(
                radius: 40,
                backgroundColor: ghanaGold.withOpacity(0.2),
                 // Add border using foregroundDecoration if needed or wrap with Container
                backgroundImage: (user.profilePicture != null && user.profilePicture!.isNotEmpty)
                  ? NetworkImage(user.profilePicture!) // Assumes URL
                  : null, // No background image if no URL
                 child: (user.profilePicture == null || user.profilePicture!.isEmpty)
                   ? Icon( // Fallback icon
                       Icons.person,
                       size: 50,
                       color: ghanaWhite,
                     )
                   : null, // No child needed if backgroundImage is set
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display user's full name
                    Text(
                      user.fullName, // Use getter from User model
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: ghanaWhite,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    // Display user's phone number
                    Text(
                      user.phoneNumber,
                      style: TextStyle(
                        color: ghanaWhite.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    // Display user's rating and ride count
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: ghanaGold,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          // Display rating or 'N/A'
                          user.rating?.isNotEmpty == true ? user.rating! : 'N/A',
                          style: TextStyle(
                            color: ghanaWhite,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          // Display total trips or '0'
                          '(${user.totalTrips ?? 0} rides)',
                          style: TextStyle(
                            color: ghanaWhite.withOpacity(0.9),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.edit,
                  color: ghanaWhite,
                ),
                onPressed: () {
                  // Ensure this route exists and PersonalInfoScreen is implemented
                  Navigator.pushNamed(context, AppRoutes.personalInfo);
                },
              ),
            ],
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ghanaWhite.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ghanaWhite.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Display total trips stat
                _buildStatItem((user.totalTrips ?? 0).toString(), 'Rides'),
                // You can add other relevant stats from the User model if available
                // e.g., User Type if needed, but less of a "stat"
                // _buildDivider(),
                // _buildStatItem('12', 'Saved Places'), // Placeholder or remove
                // _buildDivider(),
                // _buildStatItem('GH₵ 450', 'Spent'), // Placeholder or remove
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: ghanaWhite,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: ghanaWhite.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: ghanaWhite.withOpacity(0.3),
    );
  }

  // Update logout dialog to use ref
  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Log Out'),
        content: Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ghanaGreen, // Or Colors.red
            ),
            onPressed: () {
              Navigator.pop(context); // Close the dialog first
              // Call logout on the notifier using ref.read
              ref.read(authNotifierProvider.notifier).logout();
              // No need for Navigator.pushReplacementNamed here,
              // AuthWrapper will handle navigating to LoginScreen
              // when the authState status changes to unauthenticated.
            },
            child: Text('Log Out'),
          ),
        ],
      ),
    );
  }
}