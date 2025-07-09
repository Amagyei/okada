// lib/presentation/auth/login
import 'dart:async'; // Import dart:async for Timer
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/theme.dart';
import '../../../core/widgets/ghana_widgets.dart'; // Assuming GhanaButton is here
import '../../../routes.dart';

import '../../../providers/auth_providers.dart';
import '../../../state/auth_state.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();

  OverlayEntry? _overlayEntry;
  Timer? _overlayTimer;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _removeErrorOverlay(); // Clean up the overlay and timer
    super.dispose();
  }

  void _removeErrorOverlay() {
    _overlayTimer?.cancel();
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showErrorBubble(String message) {
    if (!mounted) return;
    _removeErrorOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 20.0,
        left: MediaQuery.of(context).size.width * 0.1,
        right: MediaQuery.of(context).size.width * 0.1,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(25.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 5.0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _overlayTimer = Timer(const Duration(seconds: 4), () {
      _removeErrorOverlay();
    });
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      _showErrorBubble("Please fill all fields correctly.");
      return;
    }
    String phoneNumber = _phoneController.text.trim();
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
      } else if (latestAuthState.status == AuthStatus.error && latestAuthState.errorMessage != null) {
          _showErrorBubble(latestAuthState.errorMessage!);
      }
      // If login fails and the notifier throws an exception, the catch block handles it.
      // If the notifier sets an error state without throwing, the else-if above handles it.
      
    } catch (e) {
      if (mounted) {
        _showErrorBubble(e.toString().replaceFirst("Exception: ", ""));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.status == AuthStatus.authenticating;

    // Listen to auth state for errors that might not be caught by the try-catch in _login
    // (e.g., if login succeeds but some other condition fails and sets error state in notifier)
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.error && next.errorMessage != null) {
        // Ensure we're not showing duplicate error messages if _login also caught it
        // This listener is more for errors set by the notifier outside the direct _login flow.
        // You might need to add more sophisticated logic to prevent double display if _login() also calls _showErrorBubble for the same error.
        // For now, this covers cases where an error is set in the provider asynchronously.
        // If _login always handles showing its own errors, this specific listener part might be redundant or need adjustment.
        // Consider if error is already being shown by _login's try/catch or direct status check.
      }
    });

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
                     // Updated Regex for Ghana phone numbers (starts with 0, followed by 9 digits)
                     if (!RegExp(r'^0[0-9]{9}$').hasMatch(value.trim())) {
                        return 'Enter a valid 10-digit Ghana phone number';
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
                  isLoading: isLoading,
                  onPressed: () => _login(),
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
                          color: textSecondary, // Assuming textSecondary is defined
                        ),
                        children: [
                          TextSpan(
                            text: 'Sign Up',
                            style: TextStyle(
                              color: ghanaGreen, // Assuming ghanaGreen is defined
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