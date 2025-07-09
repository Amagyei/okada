import 'dart:io'; // For File type
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart'; // For picking images
// Adjust import paths
import 'package:okada/core/constants/theme.dart';
import 'package:okada/core/widgets/ghana_widgets.dart';
import 'package:okada/providers/auth_providers.dart';
// Ensure User model is imported

class PersonalInfoScreen extends ConsumerStatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  ConsumerState<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends ConsumerState<PersonalInfoScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _emergencyContactController;
  late TextEditingController _emergencyContactNameController;
  late TextEditingController _ghanaCardNumberController;
  // Add more controllers for other driver-specific fields if they are editable by the user

  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isLoading = false;

  // State variables for picked images
  File? _pickedProfilePicture;
  File? _pickedGhanaCardImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = ref.read(authNotifierProvider).user;

    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _emergencyContactController = TextEditingController(text: user?.emergencyContact ?? '');
    _emergencyContactNameController = TextEditingController(text: user?.emergencyContactName ?? '');
    _ghanaCardNumberController = TextEditingController(text: user?.ghanaCardNumber ?? '');
    // Initialize other controllers
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _emergencyContactController.dispose();
    _emergencyContactNameController.dispose();
    _ghanaCardNumberController.dispose();
    // Dispose other controllers
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) { // If cancelling edit, reset fields to original values
        final user = ref.read(authNotifierProvider).user;     
        _firstNameController.text = user?.firstName ?? '';
        _lastNameController.text = user?.lastName ?? '';
        _emailController.text = user?.email ?? '';
        _emergencyContactController.text = user?.emergencyContact ?? '';
        _emergencyContactNameController.text = user?.emergencyContactName ?? '';
        _ghanaCardNumberController.text = user?.ghanaCardNumber ?? '';
        // Reset picked images
        _pickedProfilePicture = null;
        _pickedGhanaCardImage = null;
        // Reset other controllers
      }
    });
  }

  Future<void> _pickImage(ImageSource source, Function(File) onImagePicked) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        onImagePicked(File(pickedFile.path));
      }
    } catch (e) {
      print("Error picking image: $e");
      _showError("Could not pick image: $e");
    }
  }

  void _showImageSourceActionSheet(BuildContext context, Function(File) onImagePicked) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Photo Library'),
                  onTap: () {
                    _pickImage(ImageSource.gallery, onImagePicked);
                    Navigator.of(context).pop();
                  }),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera, onImagePicked);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      }
    );
  }


  Future<void> _saveChanges() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() { _isLoading = true; });

    final notifier = ref.read(authNotifierProvider.notifier);
    final currentUserId = ref.read(authNotifierProvider).user?.id;

    if (currentUserId == null) {
      _showError("User not identified. Cannot save changes.");
      setState(() { _isLoading = false; });
      return;
    }

    // Prepare data to send
    // Note: AuthService will need to handle multipart request if images are included
    try {
      // This method needs to be implemented in AuthStateNotifier and AuthService
      // to handle both text data and potential file uploads.
      await notifier.updateUserProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        emergencyContact: _emergencyContactController.text.trim().isEmpty ? null : _emergencyContactController.text.trim(),
        emergencyContactName: _emergencyContactNameController.text.trim().isEmpty ? null : _emergencyContactNameController.text.trim(),
        ghanaCardNumber: _ghanaCardNumberController.text.trim().isEmpty ? null : _ghanaCardNumberController.text.trim(),
        profilePictureFile: _pickedProfilePicture,
        ghanaCardImageFile: _pickedGhanaCardImage,
      );

      if (mounted) {
        setState(() { _isEditing = false; _pickedProfilePicture = null; _pickedGhanaCardImage = null; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Profile updated successfully'), backgroundColor: ghanaGreen),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError("Update failed: ${e.toString().replaceFirst("Exception: ", "")}");
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  void _showError(String message) {
     if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    if (user == null) {
      // This should ideally be handled by AuthWrapper redirecting to login
      return Scaffold(appBar: AppBar(title: const Text('Personal Information')), body: const Center(child: CircularProgressIndicator()));
    }

    // Determine which image to show for profile picture
    ImageProvider profileImage;
    if (_pickedProfilePicture != null) {
      profileImage = FileImage(_pickedProfilePicture!);
    } else if (user.profilePicture != null && user.profilePicture!.isNotEmpty) {
      profileImage = NetworkImage(user.profilePicture!);
    } else {
      profileImage = const AssetImage('assets/images/default_avatar.png'); // Add a default avatar
    }

    // Determine which image to show for Ghana card
    ImageProvider? ghanaCardDisplayImage; // Nullable
    if (_pickedGhanaCardImage != null) {
      ghanaCardDisplayImage = FileImage(_pickedGhanaCardImage!);
    } else if (user.ghanaCardImage != null && user.ghanaCardImage!.isNotEmpty) {
      ghanaCardDisplayImage = NetworkImage(user.ghanaCardImage!);
    }


    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Information'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            tooltip: _isEditing ? 'Cancel Edit' : 'Edit Profile',
            onPressed: _toggleEdit,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _isEditing ? () => _showImageSourceActionSheet(context, (file) => setState(() => _pickedProfilePicture = file)) : null,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: ghanaGold.withAlpha((255 * 0.2).round()),
                            backgroundImage: profileImage,
                            onBackgroundImageError: _pickedProfilePicture == null ? (dynamic exception, StackTrace? stackTrace) {
                                print("Error loading network profile image: $exception");
                                // Optionally show placeholder again on network error
                            } : null,
                            child: (profileImage is AssetImage && _pickedProfilePicture == null) // Show icon only if it's the default asset and no new one picked
                                ? Icon(Icons.person, size: 50, color: ghanaGold)
                                : null,
                          ),
                          if (_isEditing)
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Theme.of(context).canvasColor, width: 2)
                              ),
                              child: const Icon(Icons.edit, color: Colors.white, size: 16),
                            )
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_isEditing)
                      TextButton.icon(
                        icon: const Icon(Icons.photo_camera),
                        label: const Text('Change Profile Photo'),
                        onPressed: () => _showImageSourceActionSheet(context, (file) => setState(() => _pickedProfilePicture = file)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              GhanaTextField(
                label: 'First Name', controller: _firstNameController,
                prefixIcon: Icons.person_outline, hint: 'Enter your first name',
                readOnly: !_isEditing, enabled: _isEditing,
                validator: (value) => value == null || value.trim().isEmpty ? 'First name cannot be empty' : null,
              ),
              const SizedBox(height: 20),
              GhanaTextField(
                label: 'Last Name', controller: _lastNameController,
                prefixIcon: Icons.person_outline, hint: 'Enter your last name',
                readOnly: !_isEditing, enabled: _isEditing,
                 validator: (value) => value == null || value.trim().isEmpty ? 'Last name cannot be empty' : null,
              ),
              const SizedBox(height: 20),
              GhanaTextField(
                label: 'Phone Number', controller: _phoneController,
                prefixIcon: Icons.phone_android, hint: 'Enter your phone number',
                keyboardType: TextInputType.phone,
                readOnly: true, // Phone number typically not directly editable
                enabled: false, // Visually indicate it's disabled
                 validator: (value) {
                     if (value == null || value.trim().isEmpty) return 'Phone number required';
                     if (!RegExp(r'^(02[034567]|05[045679])[0-9]{7}$').hasMatch(value.trim())) return 'Invalid Ghana phone number';
                     return null;
                   }
              ),
              const SizedBox(height: 20),
              GhanaTextField(
                label: 'Email', controller: _emailController,
                prefixIcon: Icons.email_outlined, hint: 'Enter your email address',
                keyboardType: TextInputType.emailAddress,
                readOnly: !_isEditing, enabled: _isEditing,
                 validator: (value) {
                    if (value != null && value.isNotEmpty && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                       return 'Enter a valid email address';
                    }
                    return null;
                 }
              ),
              const SizedBox(height: 20),
              GhanaTextField(
                label: 'Emergency Contact Name', controller: _emergencyContactNameController,
                prefixIcon: Icons.contact_emergency_outlined, hint: 'e.g., Maame Yaa',
                readOnly: !_isEditing, enabled: _isEditing,
              ),
              const SizedBox(height: 20),
              GhanaTextField(
                label: 'Emergency Contact Number', controller: _emergencyContactController,
                prefixIcon: Icons.phone_forwarded_outlined, hint: 'e.g., 024XXXXXXX',
                keyboardType: TextInputType.phone,
                readOnly: !_isEditing, enabled: _isEditing,
                validator: (value) {
                    if (value != null && value.isNotEmpty && !RegExp(r'^(02[034567]|05[045679])[0-9]{7}$').hasMatch(value.trim())) {
                       return 'Enter a valid Ghana phone number';
                    }
                    return null;
                 }
              ),
              const SizedBox(height: 20),
              GhanaTextField(
                label: 'Ghana Card Number', controller: _ghanaCardNumberController,
                prefixIcon: Icons.badge_outlined, hint: 'e.g., GHA-XXXXXXXXX-X',
                readOnly: !_isEditing, enabled: _isEditing,
                // TODO: Add specific validator for Ghana Card format
              ),
              const SizedBox(height: 20),
              Text("Ghana Card Image", style: TextStyle(fontWeight: FontWeight.w500, color: _isEditing ? textPrimary : textSecondary.withOpacity(0.6))),
              const SizedBox(height: 8),
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300)
                ),
                child: InkWell(
                  onTap: _isEditing ? () => _showImageSourceActionSheet(context, (file) => setState(() => _pickedGhanaCardImage = file)) : null,
                  child: ghanaCardDisplayImage != null
                    ? Image(image: ghanaCardDisplayImage, fit: BoxFit.contain)
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_outlined, size: 40, color: textSecondary.withOpacity(_isEditing ? 1.0 : 0.5)),
                            if(_isEditing) const Text("Tap to add/change image", style: TextStyle(color: textSecondary)),
                            if(!_isEditing && user.ghanaCardImage == null) const Text("No Ghana Card image uploaded", style: TextStyle(color: textSecondary)),
                          ],
                        ),
                      ),
                ),
              ),
              const SizedBox(height: 40),
              if (_isEditing)
                Center(
                  child: GhanaButton(
                    text: 'Save Changes',
                    isLoading: _isLoading,
                    onPressed: () => _saveChanges(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
