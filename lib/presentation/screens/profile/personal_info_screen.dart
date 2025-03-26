
import 'package:flutter/material.dart';
import '../../../core/constants/theme.dart';
import '../../../core/widgets/ghana_widgets.dart';

class PersonalInfoScreen extends StatefulWidget {
  @override
  _PersonalInfoScreenState createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final TextEditingController _nameController = TextEditingController(text: 'Kwame Mensah');
  final TextEditingController _phoneController = TextEditingController(text: '024 123 4567');
  final TextEditingController _emailController = TextEditingController(text: 'kwame@example.com');
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveChanges() {
    setState(() {
      _isLoading = true;
    });

    // Simulate saving
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Personal information updated successfully'),
          backgroundColor: ghanaGreen,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personal Information'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: _toggleEdit,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ghanaGold.withOpacity(0.2),
                      border: Border.all(color: ghanaGold, width: 2),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: ghanaGold,
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  if (_isEditing)
                    TextButton.icon(
                      icon: Icon(Icons.photo_camera),
                      label: Text('Change Photo'),
                      onPressed: () {
                        // Implement photo change
                      },
                    ),
                ],
              ),
            ),
            SizedBox(height: 30),
            GhanaTextField(
              label: 'Full Name',
              controller: _nameController,
              prefixIcon: Icons.person_outline,
              hint: 'Enter your full name',
            ),
            SizedBox(height: 20),
            GhanaTextField(
              label: 'Phone Number',
              controller: _phoneController,
              prefixIcon: Icons.phone_android,
              hint: 'Enter your phone number',
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),
            GhanaTextField(
              label: 'Email',
              controller: _emailController,
              prefixIcon: Icons.email_outlined,
              hint: 'Enter your email address',
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 40),
            if (_isEditing)
              GhanaButton(
                text: 'Save Changes',
                isLoading: _isLoading,
                onPressed: _saveChanges,
              ),
          ],
        ),
      ),
    );
  }
}
