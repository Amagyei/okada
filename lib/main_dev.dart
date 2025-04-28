import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:okada_app/main.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load the DEV environment file
  try {
    await dotenv.load(fileName: "../.env.dev"); // Load dev config
     print("[main_dev] .env.dev loaded successfully.");
  } catch (e) {
     print("[main_dev] ERROR loading .env.dev: $e");
     // Fallback or error handling if needed
     await dotenv.load(fileName: "../.env"); 
  }
  // Run the main app widget
  runApp( ProviderScope(child: OkadaApp()) ); 
}