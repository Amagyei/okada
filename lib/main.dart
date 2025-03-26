
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'routes.dart';
import 'core/constants/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(OkadaApp());
}

class OkadaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Okada',
      debugShowCheckedModeBanner: false,
      theme: okadaTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}