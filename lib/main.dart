// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'routes.dart';
import 'core/constants/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/widgets/auth_wrapper.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// only added because the app does not request local network permission on iOS
import 'package:multicast_dns/multicast_dns.dart';

void triggerLocalNetworkAccess() async {
  final MDnsClient client = MDnsClient();
  await client.start();
  await for (final PtrResourceRecord ptr in client.lookup<PtrResourceRecord>(
      ResourceRecordQuery.serverPointer('_googlecast._tcp.local'))) {
    print('Discovered service: ${ptr.domainName}');
  }
  client.stop();
}
const String kFlavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');


Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  triggerLocalNetworkAccess();
  runApp(
    ProviderScope(child: OkadaApp())
  );
}

class OkadaApp extends StatelessWidget {
  const OkadaApp({super.key});

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