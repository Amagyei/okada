import 'package:flutter/material.dart';
import '../../../core/constants/theme.dart';
import '../../../core/widgets/ghana_widgets.dart';
import '../../../routes.dart';

class ProfileMenuItem {
  final String title;
  final String description;
  final IconData icon;
  final String route;

  ProfileMenuItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
  });
}

class ProfileScreen extends StatelessWidget {
  final List<ProfileMenuItem> _menuItems = [
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildProfileHeader(context),
              SizedBox(height: 24),
              ListView.separated(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _menuItems.length,
                separatorBuilder: (context, index) => SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = _menuItems[index];
                  return GhanaCard(
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
              GhanaButton(
                text: 'Log Out',
                onPressed: () => _showLogoutDialog(context),
                icon: Icons.logout,
                width: MediaQuery.of(context).size.width * 0.9,
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
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
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: ghanaWhite, width: 2),
                  color: ghanaGold.withOpacity(0.2),
                ),
                child: Center(
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: ghanaWhite,
                  ),
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kwame Mensah',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: ghanaWhite,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '024 123 4567',
                      style: TextStyle(
                        color: ghanaWhite.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: ghanaGold,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '4.8',
                          style: TextStyle(
                            color: ghanaWhite,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          '(32 rides)',
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
                _buildStatItem('32', 'Rides'),
                _buildDivider(),
                _buildStatItem('12', 'Saved Places'),
                _buildDivider(),
                _buildStatItem('GH₵ 450', 'Spent'),
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

  void _showLogoutDialog(BuildContext context) {
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
              backgroundColor: ghanaGreen,
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
            child: Text('Log Out'),
          ),
        ],
      ),
    );
  }
}
