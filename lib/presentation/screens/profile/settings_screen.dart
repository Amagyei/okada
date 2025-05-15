
import 'package:flutter/material.dart';
import '../../../core/constants/theme.dart';
import '../../../core/widgets/ghana_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _locationTracking = true;
  bool _darkMode = false;
  String _language = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Application Settings'),
          SwitchListTile(
            title: Text('Enable Notifications'),
            subtitle: Text('Receive alerts about your trips and promotions'),
            value: _notificationsEnabled,
            activeColor: ghanaGreen,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: textHint.withOpacity(0.3)),
            ),
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          SizedBox(height: 12),
          SwitchListTile(
            title: Text('Location Tracking'),
            subtitle: Text('Allow app to track your location'),
            value: _locationTracking,
            activeColor: ghanaGreen,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: textHint.withOpacity(0.3)),
            ),
            onChanged: (value) {
              setState(() {
                _locationTracking = value;
              });
            },
          ),
          SizedBox(height: 12),
          SwitchListTile(
            title: Text('Dark Mode'),
            subtitle: Text('Use dark theme for the app'),
            value: _darkMode,
            activeColor: ghanaGreen,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: textHint.withOpacity(0.3)),
            ),
            onChanged: (value) {
              setState(() {
                _darkMode = value;
              });
              // Implement theme change
            },
          ),
          SizedBox(height: 16),
          GhanaCard(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text('Language'),
              subtitle: Text(_language),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _showLanguageDialog,
            ),
          ),
          SizedBox(height: 24),
          _buildSectionTitle('Account Settings'),
          GhanaCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.lock_outline, color: ghanaGreen),
                  title: Text('Change Password'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navigate to change password screen
                  },
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.notifications_outlined, color: ghanaGreen),
                  title: Text('Notification Preferences'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navigate to notification preferences screen
                  },
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.privacy_tip_outlined, color: ghanaGreen),
                  title: Text('Privacy Settings'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navigate to privacy settings screen
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          _buildSectionTitle('About & Legal'),
          GhanaCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info_outline, color: ghanaGreen),
                  title: Text('About Okada'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navigate to about screen
                  },
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.description_outlined, color: ghanaGreen),
                  title: Text('Terms of Service'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navigate to terms screen
                  },
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.policy_outlined, color: ghanaGreen),
                  title: Text('Privacy Policy'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navigate to privacy policy screen
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          GhanaButton(
            text: 'Log Out',
            onPressed: _showLogoutDialog,
            icon: Icons.logout,
          ),
          SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: _showDeleteAccountDialog,
              child: Text(
                'Delete Account',
                style: TextStyle(
                  color: ghanaRed,
                ),
              ),
            ),
          ),
          SizedBox(height: 24),
          Center(
            child: Text(
              'Okada v1.0.0',
              style: TextStyle(
                color: textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: ghanaGreen,
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('English'),
            _buildLanguageOption('Twi'),
            _buildLanguageOption('Ga'),
            _buildLanguageOption('Ewe'),
            _buildLanguageOption('Hausa'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String language) {
    return ListTile(
      title: Text(language),
      trailing: _language == language
          ? Icon(Icons.check, color: ghanaGreen)
          : null,
      onTap: () {
        setState(() {
          _language = language;
        });
        Navigator.pop(context);
      },
    );
  }

  void _showLogoutDialog() {
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
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: Text('Log Out'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Account'),
        content: Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ghanaRed,
            ),
            onPressed: () {
              Navigator.pop(context);
              // Implement account deletion
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: Text('Delete Account'),
          ),
        ],
      ),
    );
  }
}
