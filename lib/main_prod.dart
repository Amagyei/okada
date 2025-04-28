import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:okada_app/main.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: "../.env.prod");
     print("[main_prod] .env.prod loaded successfully.");
  } catch (e) {
     print("[main_prod] ERROR loading .env.prod: $e");
  }
  runApp( ProviderScope(child: OkadaApp()) ); 
}