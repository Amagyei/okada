// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'routes.dart';
import 'core/constants/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/widgets/auth_wrapper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(
    ProviderScope(child: OkadaApp())
  );
}

class OkadaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Okada',
      debugShowCheckedModeBanner: false,
      theme: okadaTheme,
      home: AuthWrapper(), // Make AuthWrapper the root
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
} 