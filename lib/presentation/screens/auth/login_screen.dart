// lib/presentation/auth/login
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import '../../../core/constants/theme.dart';
import '../../../core/widgets/ghana_widgets.dart';
import '../../../routes.dart';

import '../../../providers/auth_providers.dart'; // Import provider definition
import '../../../state/auth_state.dart';      // Import state definition

class LoginScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
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
    // Get the notifier instance using ref.read (for calling methods)
    final authNotifier = ref.read(authNotifierProvider.notifier);

    try {
      
      await authNotifier.login(phoneNumber, _passwordController.text);

      final latestAuthState = ref.read(authNotifierProvider);

      if (!mounted) return;

      if (latestAuthState.status == AuthStatus.authenticated) {
        if (latestAuthState.user?.isPhoneVerified ?? false) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.otp, arguments: phoneNumber);
        }
      }
      
    } catch (e) {
      if (mounted) {
        _showError(e.toString().replaceFirst("Exception: ", ""));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.status == AuthStatus.authenticating;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
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
                  hint: 'e.g. 024XXXXXXX',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_android,
                   validator: (value) {
                     if (value == null || value.trim().isEmpty) {
                       return 'Please enter phone number';
                     }
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
                      // Use local setState ONLY for local UI state like password visibility
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
                  // Use isLoading from the watched notifier state
                  isLoading: isLoading,
                  // Pass the _login method directly or wrapped if needed
                  onPressed: isLoading ? null : _login,
                ),
                SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: isLoading ? null : () {
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