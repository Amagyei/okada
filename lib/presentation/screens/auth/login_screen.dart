import 'package:flutter/material.dart';
import '../../../core/constants/theme.dart';
import '../../../core/widgets/ghana_widgets.dart';
import '../../../routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/models/auth_response_model.dart';
import '../../../data/models/user_model.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();


  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _authService.dispose();
    super.dispose();
  }

  void _showError(String message) {
     if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
     }
    String phoneNumber = _phoneController.text.trim();
    setState(() { _isLoading = true; });


    try {
      final AuthResponse authResponse = await _authService.login(phoneNumber, _passwordController.text);
      if (!mounted) return;

      if (authResponse.user.isPhoneVerified) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.otp, arguments: phoneNumber);
      }

    } catch (e) {
       if (mounted) {
         _showError(e.toString().replaceFirst("Exception: ", ""));
       }
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
          // Wrap content in a Form
          child: Form(
            key: _formKey, // Assign form key
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
                  hint: 'e.g. 024XXXXXXX', // Updated hint
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_android,
                   validator: (value) {
                     if (value == null || value.trim().isEmpty) {
                       return 'Please enter phone number';
                     }
                     // Basic 10 digit check - adjust regex if needed for Ghana format
                     if (!RegExp(r'^[0-9]{10}$').hasMatch(value.trim())) {
                        return 'Enter a valid 10-digit phone number';
                     }
                     return null;
                   }
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
                   validator: (value) => value == null || value.isEmpty ? 'Please enter your password' : null,
                ),
                SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Navigate to forgot password screen
                    },
                    child: Text('Forgot Password?'),
                  ),
                ),
                SizedBox(height: 32),
                GhanaButton(
                  text: 'Sign In',
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : () { _login(); },
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
      ),
    );
  }
}