import 'package:flutter/material.dart';

import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/booking/booking_screen.dart';
import 'presentation/screens/trips/trips_screen.dart';
import 'presentation/screens/profile/profile_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/register_screen.dart';
import 'presentation/screens/auth/otp_entry_screen.dart';
import 'presentation/screens/payment/payment_screen.dart';
import 'presentation/screens/profile/personal_info_screen.dart';
import 'presentation/screens/profile/saved_locations_screen.dart';
import 'presentation/screens/profile/rate_drivers_screen.dart';
import 'presentation/screens/profile/support_screen.dart';
import 'presentation/screens/profile/settings_screen.dart';


class UndefinedView extends StatelessWidget {
  final String? name;
  const UndefinedView({Key? key, this.name}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Route for $name is not defined')),
    );
  }
}

class AppRoutes {
  
  static const String splash = '/';
  static const String home = '/home';
  static const String book = '/book';
  static const String trips = '/trips';
  static const String profile = '/profile';
  static const String login = '/login';
  static const String register = '/register';
  static const String payment = '/payment';
  static const String personalInfo = '/profile/personal-info';
  static const String savedLocations = '/profile/saved-locations';
  static const String rateDrivers = '/profile/rate-drivers';
  static const String support = '/profile/support';
  static const String settings = '/profile/settings';
  static const String otp = '/otp_entry';

  // Define protected routes
  

  static Route<dynamic> generateRoute(RouteSettings settings) {
    

    // Using if-else statements instead of switch with pattern matching
    if (settings.name == splash) {
      return MaterialPageRoute(builder: (_) => SplashScreen());
    } else if (settings.name == home) {
      return MaterialPageRoute(builder: (_) => HomeScreen());
    } else if (settings.name == book) {
      return MaterialPageRoute(builder: (_) => BookingScreen());
    } else if (settings.name == trips) {
      return MaterialPageRoute(builder: (_) => TripsScreen());
    } else if (settings.name == profile) {
      return MaterialPageRoute(builder: (_) => ProfileScreen());
    } else if (settings.name == login) {
      return MaterialPageRoute(builder: (_) => LoginScreen());
    } else if (settings.name == register) {
      return MaterialPageRoute(builder: (_) => RegisterScreen());
    } else if (settings.name == payment) {
      return MaterialPageRoute(builder: (_) => PaymentScreen());
    } else if (settings.name == personalInfo) {
      return MaterialPageRoute(builder: (_) => PersonalInfoScreen());
    } else if (settings.name == savedLocations) {
      return MaterialPageRoute(builder: (_) => SavedLocationsScreen());
    } else if (settings.name == rateDrivers) {
      return MaterialPageRoute(builder: (_) => RateDriversScreen());
    } else if (settings.name == support) {
      return MaterialPageRoute(builder: (_) => SupportScreen());
    } else if (settings.name == settings) {
      return MaterialPageRoute(builder: (_) => SettingsScreen());
    } else if (settings.name == otp) {
      final phoneNumber = settings.arguments as String?;
      if (phoneNumber != null) {
        return MaterialPageRoute(
          builder: (_) => OtpEntryScreen(phoneNumber: phoneNumber),
        );
      } else {
        return MaterialPageRoute(builder: (_) => LoginScreen());
      }
    } else {
      return MaterialPageRoute(builder: (_) => UndefinedView(name: settings.name));
    }
  }
}
