import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import '../../../core/constants/theme.dart';
import '../../../core/widgets/ghana_widgets.dart';
import '../../../routes.dart';
// Import Notifier and Provider if using Riverpod for registration
import '../../../providers/auth_providers.dart';
import '../../../state/auth_state.dart';
// Remove direct AuthService import if using Riverpod Notifier
// import '../../../core/services/auth_service.dart';

// Convert to ConsumerStatefulWidget
class RegisterScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

// Convert to ConsumerState
class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // Remove local AuthService instance if using Riverpod Notifier
  // final AuthService _authService = AuthService();
  // Use local loading state for button, notifier handles app-wide state
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _acceptedTerms = false;
  // Define the Form Key
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

   void _showError(String message) {
     if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: ghanaRed),
    );
  }

  Future<void> _handleSignUp() async {
    print("[RegisterScreen] _handleSignUp called.");

    // --- Validate Form ---
    // Use the _formKey to validate
    final isFormValid = _formKey.currentState?.validate() ?? false;
    print("[RegisterScreen] Form validation result: $isFormValid");
    if (!isFormValid) {
      print("[RegisterScreen] Form validation failed. Returning.");
      return; // Don't proceed if form is invalid
    }

    // --- Check Terms ---
    print("[RegisterScreen] Accepted Terms: $_acceptedTerms");
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please accept the terms and conditions to continue'),
          backgroundColor: ghanaRed,
        ),
      );
      print("[RegisterScreen] Terms not accepted. Returning.");
      return;
    }

    // --- Start Loading ---
    // Use local isLoading for the button state during the async operation
    setState(() { _isLoading = true; });
    print("[RegisterScreen] Starting registration API call...");

    String phoneNumber = _phoneController.text.trim();
    String email = _emailController.text.trim();
    // Get the notifier instance using ref.read
    final authNotifier = ref.read(authNotifierProvider.notifier);

    try {
      // Call register on the notifier
      await authNotifier.register(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: phoneNumber,
        email: email.isEmpty ? null : email, // Handle optional email
        password: _passwordController.text,
        userType: 'rider', // Assuming default 'rider'
      );
      print("[RegisterScreen] Registration API successful.");

      // Check state AFTER await if needed, though navigation usually happens next
      final latestAuthState = ref.read(authNotifierProvider);

      if (mounted) {
        print("[RegisterScreen] Navigating to OTP screen.");
        // Navigate to OTP screen after successful registration
        // The AuthWrapper will handle showing HomeScreen later if OTP is successful
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.otp,
          arguments: phoneNumber,
        );
      }
    } catch (e) {
      print("[RegisterScreen] Registration API failed with error: $e");
      if (mounted) {
         _showError(e.toString().replaceFirst("Exception: ", ""));
      }
      // No return needed here, finally block will execute
    } finally {
      print("[RegisterScreen] Finally block reached.");
      // Only update local isLoading state if the widget is still mounted
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
         print("[RegisterScreen] isLoading set to false.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the notifier ONLY if you need its status for UI elements other than button loading
    // final authState = ref.watch(authNotifierProvider);
    // final isAuthLoading = authState.status == AuthStatus.authenticating;
    // Using local _isLoading is simpler for just the button state here

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24),
          // --- Wrap Column in Form Widget ---
          child: Form(
            key: _formKey, // Assign the key
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Playfair Display',
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign up to start riding with Okada',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 32),
                GhanaTextField(
                  label: 'First Name',
                  hint: 'Enter your first name',
                  controller: _firstNameController,
                  prefixIcon: Icons.person_outline,
                  // --- Added Validator ---
                  validator: (value) => value == null || value.trim().isEmpty ? 'Please enter first name' : null,
                ),
                const SizedBox(height: 24),
                GhanaTextField(
                  label: 'Last Name',
                  hint: 'Enter your Last name',
                  controller: _lastNameController,
                  prefixIcon: Icons.person_outline,
                   // --- Added Validator ---
                   validator: (value) => value == null || value.trim().isEmpty ? 'Please enter last name' : null,
                ),
                const SizedBox(height: 24),
                GhanaTextField(
                  label: 'Phone Number',
                  hint: 'e.g. 024XXXXXXX',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_android,
                   // --- Added Validator ---
                   validator: (value) {
                     if (value == null || value.trim().isEmpty) return 'Please enter phone number';
                     // Basic Ghana phone number check (adjust regex if needed)
                     if (!RegExp(r'^(02[034567]|05[045679])[0-9]{7}$').hasMatch(value.trim())) return 'Enter a valid 10-digit Ghana number';
                     return null;
                   }
                ),
                const SizedBox(height: 24),
                GhanaTextField(
                  label: 'Email (Optional)',
                  hint: 'Enter your email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                   // --- Added Validator (optional field, but validate format if entered) ---
                   validator: (value) {
                      if (value != null && value.isNotEmpty && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                         return 'Enter a valid email address';
                      }
                      return null; // Return null if empty or valid
                   }
                ),
                const SizedBox(height: 24),
                GhanaTextField(
                  label: 'Password',
                  hint: 'Create a password (min 8 chars)',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_outline,
                  suffix: IconButton(
                    icon: Icon(
                      // Corrected icon logic
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                   // --- Added Validator ---
                   validator: (value) => value == null || value.length < 8 ? 'Password must be at least 8 characters' : null,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Checkbox(
                      value: _acceptedTerms,
                      // Disable checkbox while loading
                      onChanged: _isLoading ? null : (value) {
                        setState(() {
                          _acceptedTerms = value ?? false;
                        });
                      },
                      activeColor: ghanaGreen,
                    ),
                    Expanded(
                      child: Text.rich( // Consider adding GestureDetector for links
                        const TextSpan(
                          text: 'I agree to the ',
                          style: TextStyle(fontSize: 14, color: textPrimary), // Set default color
                          children: [
                            TextSpan(
                              text: 'Terms of Service',
                              style: TextStyle(color: ghanaGreen, fontWeight: FontWeight.bold),
                              // recognizer: TapGestureRecognizer()..onTap = () { /* Open Terms URL */ },
                            ),
                            TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(color: ghanaGreen, fontWeight: FontWeight.bold),
                               // recognizer: TapGestureRecognizer()..onTap = () { /* Open Privacy URL */ },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Opacity(
                  opacity: _acceptedTerms ? 1.0 : 0.5,
                  child: GhanaButton(
                    text: 'Sign Up',
                    isLoading: _isLoading, // Use local loading state
                    // --- Added Debug Print to onPressed ---
                    onPressed: _isLoading // Disable button if loading
                      ? null
                      : _acceptedTerms
                          ? () {
                              print("[RegisterScreen] GhanaButton onPressed: _handleSignUp assigned and called!");
                              _handleSignUp();
                            }
                          : () {
                              print("[RegisterScreen] GhanaButton onPressed: SnackBar function called (Terms not accepted?)");
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please accept the terms and conditions to continue'),
                                  backgroundColor: ghanaRed,
                                ),
                              );
                            },
                    // --- End Debug Print ---
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    // Disable button if loading
                    onPressed: _isLoading ? null : () {
                      Navigator.pushReplacementNamed(context, AppRoutes.login);
                    },
                    child: RichText(
                      text: const TextSpan(
                        text: "Already have an account? ",
                         style: TextStyle(color: textSecondary), // Set default color
                        children: [
                          TextSpan(
                            text: 'Sign In',
                            style: TextStyle(
                              color: ghanaGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // --- End Form Widget ---
        ),
      ),
    );
  }
}
