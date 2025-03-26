
import 'package:flutter/material.dart';
import 'dart:async';
import '../../../core/constants/theme.dart';
import '../../../core/widgets/ghana_widgets.dart';
import '../../../routes.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate loading time
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ghanaGreen,
              ghanaGreen.withOpacity(0.8),
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
              decoration: BoxDecoration(
                color: ghanaGold,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  'O',
                  style: TextStyle(
                    fontFamily: 'Playfair Display',
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    color: ghanaBlack,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Okada',
              style: TextStyle(
                fontFamily: 'Playfair Display',
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: ghanaWhite,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Quick & Reliable Rides',
              style: TextStyle(
                fontSize: 16,
                color: ghanaWhite.withOpacity(0.9),
              ),
            ),
            SizedBox(height: 48),
            LoadingBike(
              color: ghanaGold,
              size: 80,
            ),
          ],
        ),
      ),
    );
  }
}
