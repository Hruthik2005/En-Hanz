import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Show loading screen
  runApp(const _LoadingApp());

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('⚠️ Firebase initialization error: $e');
  }

  // Preload Google Fonts to prevent errors
  try {
    await Future.wait([
      GoogleFonts.pendingFonts([
        GoogleFonts.poppins(),
        GoogleFonts.inter(),
        GoogleFonts.dancingScript(),
      ]),
    ]);
  } catch (e) {
    // If fonts fail to load, continue anyway
    debugPrint('Font loading error: $e');
  }

  // Small delay to ensure fonts are ready
  await Future.delayed(const Duration(milliseconds: 100));

  runApp(const MyApp());
}

/// Temporary loading screen shown while fonts load
class _LoadingApp extends StatelessWidget {
  const _LoadingApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFE3F2FD), // Light blue
                Color(0xFFB3E5FC), // Sky blue
                Color(0xFFE1F5FE), // Cyan tint
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF1565C0),
              strokeWidth: 3,
            ),
          ),
        ),
      ),
    );
  }
}

/// Minimal main - app wiring lives in `lib/app.dart` and feature screens
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const App();
  }
}
