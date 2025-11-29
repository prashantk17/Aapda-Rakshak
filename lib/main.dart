// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Try to initialize Firebase, but continue if it fails on unsupported platforms (e.g., Windows
  // if you haven't configured Firebase for that platform). We log the error for debugging.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, st) {
    // Not fatal for development on platforms where Firebase isn't configured.
    // Keep the app running and print the error so you can see what's wrong.
    // Remove or reduce logging in production if desired.
    debugPrint('Firebase initialization skipped or failed: $e');
    debugPrint('$st');
  }

  runApp(const AapdaRakshakApp());
}

class AapdaRakshakApp extends StatelessWidget {
  const AapdaRakshakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aapda Rakshak',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD32F2F),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Color(0xFFD32F2F),
          foregroundColor: Colors.white,
        ),
      ),
      home: const HomeScreen(),
      routes: {'/home': (context) => const HomeScreen()},
    );
  }
}
