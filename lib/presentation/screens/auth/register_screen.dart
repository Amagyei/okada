import 'package:flutter/material.dart';
import '../../../core/constants/theme.dart';
import '../../../core/widgets/ghana_widgets.dart';
import '../../../routes.dart';
// Import the AuthService from your core services
import '../../../core/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _acceptedTerms = false;
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

  void _handleSignUp() async {
  // Validate the form first
  if (!(_formKey.currentState?.validate() ?? false)) {
    print("Form validation failed.");
    return;
  }
  // Check if terms are accepted
  if (!_acceptedTerms) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Please accept the terms and conditions to continue'),
        backgroundColor: ghanaRed,
      ),
    );
    print("Terms not accepted.");
    return;
  }

  // Update UI to show loading
  setState(() { _isLoading = true; });
  print("Starting registration...");

  // Define variables from controllers
  String phoneNumber = _phoneController.text.trim();
  String email = _emailController.text.trim();

  try {
    // Register the new user
    await _authService.register(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      phoneNumber: phoneNumber,
      email: email,
      password: _passwordController.text,
      userType: 'rider',
    );
    print("Registration successful, navigating to OTP page.");
    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.otp,
        arguments: phoneNumber,
      );
    }
  } catch (e) {
    print("Registration failed with error: $e");
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      // Display error using SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: $e'),
          backgroundColor: ghanaRed,
        ),
      );
    }
    return;
  } finally {
    // Always update the loading state after the operation
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Playfair Display',
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Sign up to start riding with Okada',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 32),
              GhanaTextField(
                label: 'First Name',
                hint: 'Enter your first name',
                controller: _firstNameController,
                prefixIcon: Icons.person_outline,
              ),
              SizedBox(height: 24),
              GhanaTextField(
                label: 'Last Name',
                hint: 'Enter your Last name',
                controller: _lastNameController,
                prefixIcon: Icons.person_outline,
              ),
              SizedBox(height: 24),
              GhanaTextField(
                label: 'Phone Number',
                hint: '024 XXX XXXX',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_android,
              ),
              SizedBox(height: 24),
              GhanaTextField(
                label: 'Email (Optional)',
                hint: 'Enter your email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
              ),
              SizedBox(height: 24),
              GhanaTextField(
                label: 'Password',
                hint: 'Create a password',
                controller: _passwordController,
                obscureText: _obscurePassword,
                prefixIcon: Icons.lock_outline,
                suffix: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: textSecondary,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Checkbox(
                    value: _acceptedTerms,
                    onChanged: (value) {
                      setState(() {
                        _acceptedTerms = value ?? false;
                      });
                    },
                    activeColor: ghanaGreen,
                  ),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: 'I agree to the ',
                        children: [
                          TextSpan(
                            text: 'Terms of Service',
                            style: TextStyle(
                              color: ghanaGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                              color: ghanaGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),
              Opacity(
                opacity: _acceptedTerms ? 1.0 : 0.5,
                child: GhanaButton(
                  text: 'Sign Up',
                  isLoading: _isLoading,
                  onPressed: _acceptedTerms ? _handleSignUp : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please accept the terms and conditions to continue'),
                        backgroundColor: ghanaRed,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  },
                  child: RichText(
                    text: TextSpan(
                      text: "Already have an account? ",
                      style: TextStyle(
                        color: textSecondary,
                      ),
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
      ),
    );
  }
}
