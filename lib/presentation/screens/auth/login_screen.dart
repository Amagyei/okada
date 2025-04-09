import 'package:flutter/material.dart';
import '../../../core/constants/theme.dart';
import '../../../core/widgets/ghana_widgets.dart';
import '../../../routes.dart';
// Import the AuthService from your core services
import '../../../core/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  final AuthService _authService = AuthService(); // Create an instance of AuthService

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _authService.dispose(); // Dispose the auth service if needed
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Attempt to login using the AuthService
      await _authService.login(_phoneController.text, _passwordController.text);
      // Navigator.pushReplacementNamed(context, AppRoutes.home);
      await _authService.requestOtp();
    } catch (e) {
      // On error, show an error message
      _showError(e.toString());
    } finally {
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
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 60),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: ghanaGold,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          'O',
                          style: TextStyle(
                            fontFamily: 'Playfair Display',
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: ghanaBlack,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Okada',
                      style: TextStyle(
                        fontFamily: 'Playfair Display',
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Quick & Reliable Rides',
                      style: TextStyle(
                        fontSize: 16,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 60),
              Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Sign in to continue using Okada',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 32),
              GhanaTextField(
                label: 'Phone Number',
                hint: '024XXXXXXX',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_android,
              ),
              SizedBox(height: 24),
              GhanaTextField(
                label: 'Password',
                hint: 'Enter your password',
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
              SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Navigate to forgot password screen
                  },
                  child: Text('Forgot Password?'),
                ),
              ),
              SizedBox(height: 32),
              GhanaButton(
                text: 'Sign In',
                isLoading: _isLoading,
                onPressed: _login,
              ),
              SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.register);
                  },
                  child: RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: TextStyle(
                        color: textSecondary,
                      ),
                      children: [
                        TextSpan(
                          text: 'Sign Up',
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