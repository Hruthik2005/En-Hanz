import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/app_state.dart';
import 'screens/onboarding_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/iq_test_screen.dart';
import 'screens/upload_screen.dart';
import 'screens/drawing_screen.dart';
import 'screens/processing_screen.dart';
import 'screens/results_screen.dart';
import 'screens/coach_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/handybot_chat_screen.dart';
import 'screens/practice_zone_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/about_screen.dart';
import 'screens/letter_tracing_game.dart';
import 'screens/dot_join_game.dart';
import 'screens/copy_word_game.dart';
import 'utils/modern_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'En-HanZ',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: ModernTheme.primaryBlue,
            primary: ModernTheme.primaryBlue,
            secondary: ModernTheme.secondaryPurple,
          ),
          scaffoldBackgroundColor: ModernTheme.backgroundLight,
          useMaterial3: true,
          fontFamily: 'Inter',
        ),
        builder: (context, widget) {
          // Error handling to prevent red screen flashes
          ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
            return Container(
              decoration: BoxDecoration(
                gradient: ModernTheme.backgroundGradient,
              ),
              child: Center(
                child: CircularProgressIndicator(
                  color: ModernTheme.primaryBlue,
                ),
              ),
            );
          };
          return widget ?? const SizedBox.shrink();
        },
        initialRoute: '/splash',
        routes: {
          '/splash': (_) => const SplashScreen(),
          '/': (_) => const OnboardingScreen(),
          '/profile': (_) => const ProfileScreen(),
          '/iq': (_) => const IQTestScreen(),
          '/upload': (_) => const UploadScreen(),
          '/drawing': (_) => const DrawingScreen(),
          '/processing': (_) => const ProcessingScreen(),
          '/results': (_) => const ResultsScreen(),
          '/coach': (_) => const CoachScreen(),
          '/home': (_) => const HomeScreen(),
          '/handybot': (_) => const HandyBotChatScreen(),
          '/practice': (_) => const PracticeZoneScreen(),
          '/practice/tracing': (_) => const LetterTracingGame(),
          '/practice/dots': (_) => const DotJoinGame(),
          '/practice/copy': (_) => const CopyWordGame(),
          '/history': (_) => const HistoryScreen(),
          '/settings': (_) => const SettingsScreen(),
          '/about': (_) => const AboutScreen(),
        },
      ),
    );
  }
}
