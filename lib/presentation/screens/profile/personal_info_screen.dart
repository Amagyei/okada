import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import '../../../core/constants/theme.dart';
import '../../../core/widgets/ghana_widgets.dart';
import '../../../providers/auth_providers.dart'; // Import providers
import '../../../state/auth_state.dart'; // Import state for status check


class PersonalInfoScreen extends ConsumerStatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  ConsumerState<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends ConsumerState<PersonalInfoScreen> {
  // Separate controllers for first and last name
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  final _formKey = GlobalKey<FormState>(); // Add form key for validation
  bool _isEditing = false;
  bool _isLoading = false; 

  @override
  void initState() {
    super.initState();
    final user = ref.read(authNotifierProvider).user;

    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
         final user = ref.read(authNotifierProvider).user;
         _firstNameController.text = user?.firstName ?? '';
         _lastNameController.text = user?.lastName ?? '';
         _phoneController.text = user?.phoneNumber ?? '';
         _emailController.text = user?.email ?? '';
      }
    });
  }

  Future<void> _saveChanges() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() { _isLoading = true; });

    final notifier = ref.read(authNotifierProvider.notifier);
    final updatedFirstName = _firstNameController.text.trim();
    final updatedLastName = _lastNameController.text.trim();
    final updatedEmail = _emailController.text.trim();
    

    try {
     
      print("Simulating successful profile update...");
      await Future.delayed(Duration(seconds: 1));
      // TODO: Replace simulation with actual call to notifier.updateUserProfile
      
      if (mounted) {
        setState(() {
          _isEditing = false; 
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Personal information updated successfully'),
            backgroundColor: ghanaGreen, // Use your theme color
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString().replaceFirst("Exception: ", "");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Update failed: $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  // TODO: Implement image picking and upload logic
  void _changePhoto() async {
     
     print("TODO: Implement change photo");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Change photo feature not implemented yet.')),
      );
  }


  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    
    if (user == null) {
      return Scaffold(appBar: AppBar(title: Text('Personal Information')), body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Personal Information'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            tooltip: _isEditing ? 'Cancel Edit' : 'Edit Profile',
            onPressed: _toggleEdit,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        // Use Form widget
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    // Profile Picture display logic
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: ghanaGold.withOpacity(0.2),
                      backgroundImage: (user.profilePicture != null && user.profilePicture!.isNotEmpty)
                        ? NetworkImage(user.profilePicture!)
                        : null,
                      child: (user.profilePicture == null || user.profilePicture!.isEmpty)
                        ? Icon(Icons.person, size: 50, color: ghanaGold,)
                        : null,
                    ),
                    SizedBox(height: 12),
                    if (_isEditing)
                      TextButton.icon(
                        icon: Icon(Icons.photo_camera),
                        label: Text('Change Photo'),
                        onPressed: _changePhoto, // Call change photo function
                      ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              // Separate First and Last Name Fields
              GhanaTextField(
                label: 'First Name',
                controller: _firstNameController,
                prefixIcon: Icons.person_outline,
                hint: 'Enter your first name',
                readOnly: !_isEditing, // Make read-only when not editing
                validator: (value) => value == null || value.trim().isEmpty ? 'First name cannot be empty' : null,
              ),
              SizedBox(height: 20),
              GhanaTextField(
                label: 'Last Name',
                controller: _lastNameController,
                prefixIcon: Icons.person_outline,
                hint: 'Enter your last name',
                readOnly: !_isEditing, // Make read-only when not editing
                 validator: (value) => value == null || value.trim().isEmpty ? 'Last name cannot be empty' : null,
              ),
              SizedBox(height: 20),
              GhanaTextField(
                label: 'Phone Number',
                controller: _phoneController,
                prefixIcon: Icons.phone_android,
                hint: 'Enter your phone number',
                keyboardType: TextInputType.phone,
                 // Phone number is typically not directly editable or requires re-verification
                readOnly: true, // Usually make phone number read-only
                enabled: false, // Visually indicate it's disabled
                 validator: (value) { // Keep validation even if read-only
                     if (value == null || value.trim().isEmpty) return 'Phone number required';
                     if (!RegExp(r'^[0-9]{10}$').hasMatch(value.trim())) return 'Invalid phone number format';
                     return null;
                   }
              ),
              SizedBox(height: 20),
              GhanaTextField(
                label: 'Email',
                controller: _emailController,
                prefixIcon: Icons.email_outlined,
                hint: 'Enter your email address',
                keyboardType: TextInputType.emailAddress,
                readOnly: !_isEditing, // Make read-only when not editing
                 validator: (value) {
                    // Email can be optional, but if entered, must be valid
                    if (value != null && value.isNotEmpty && !value.contains('@')) {
                       return 'Enter a valid email address';
                    }
                    return null;
                 }
              ),
              SizedBox(height: 40),
              if (_isEditing)
                Center( // Center the button
                  child: GhanaButton(
                    text: 'Save Changes',
                    isLoading: _isLoading, // Use local loading state for save button
                    onPressed: _isLoading ? null : _saveChanges,
                     width: MediaQuery.of(context).size.width * 0.8, // Example width
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}