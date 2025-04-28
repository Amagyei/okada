import 'package:flutter/material.dart';
import 'dart:async';
// Adjust import paths as needed
import 'package:okada_app/core/constants/theme.dart';
import 'package:okada_app/core/widgets/ghana_widgets.dart'; // Assuming LoadingBike is here
import 'package:okada_app/routes.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer; // Store the timer to potentially cancel it in dispose

  @override
  void initState() {
    super.initState();
    print("[SplashScreen] initState called.");
    // Start timer after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) => _startTimer());
  }

  void _startTimer() {
    // Cancel any existing timer before starting a new one
    _timer?.cancel();
    print("[SplashScreen] Starting 3-second timer...");
    _timer = Timer(const Duration(seconds: 3), () {
      print("[SplashScreen] Timer finished.");
      // --- Add mounted check ---
      if (mounted) {
        // Only navigate if the widget is still part of the tree
        print("[SplashScreen] Widget is mounted. Navigating...");
        // IMPORTANT: In a real app with AuthWrapper, this explicit navigation
        // is usually NOT needed here. AuthWrapper should handle the transition
        // based on the authentication state determined by AuthNotifier.
        // Leaving it commented out as the primary navigation should come from AuthWrapper.
        // If you *do* need navigation here (e.g., always go to login first),
        // ensure it doesn't conflict with AuthWrapper's logic.
        // Navigator.pushReplacementNamed(context, AppRoutes.login); // Example: Go to login
      } else {
         print("[SplashScreen] Timer finished, but widget was unmounted. Navigation skipped.");
      }
      // --- End mounted check ---
    });
  }

  @override
  void dispose() {
    print("[SplashScreen] dispose called. Cancelling timer.");
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
     print("[SplashScreen] build called.");
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity, // Ensure container fills height
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ghanaGreen,
              ghanaGreen.withOpacity(0.8), // Use theme colors
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo placeholder
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: ghanaGold, // Use theme color
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'O',
                  style: TextStyle(
                    fontFamily: 'Playfair Display',
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    color: ghanaBlack, // Use theme color
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Okada',
              style: TextStyle(
                fontFamily: 'Playfair Display',
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: ghanaWhite, // Use theme color
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Quick & Reliable Rides',
              style: TextStyle(
                fontSize: 16,
                color: ghanaWhite.withOpacity(0.9), // Use theme color
              ),
            ),
            const SizedBox(height: 48),
            // Ensure LoadingBike widget exists and is imported
            LoadingBike(
              color: ghanaGold, // Use theme color
              size: 80,
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder for LoadingBike if not defined elsewhere
class LoadingBike extends StatelessWidget {
  final Color color;
  final double size;
  const LoadingBike({Key? key, required this.color, required this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Replace with your actual loading animation
    return Icon(Icons.motorcycle, color: color, size: size);
  }
}