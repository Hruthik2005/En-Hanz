import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../widgets/handybot_widget.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      CircleAvatar(radius: 28, child: Text('EH')),
                      SizedBox(width: 12),
                      Text(
                        'En-HanZ',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const HandyBot(size: 120),
                  const SizedBox(height: 16),
                  const Text(
                    'AI that understands your handwriting — for early dysgraphia detection.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),

              Column(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await appState.setOnboardingComplete(true);
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, '/profile');
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 28.0,
                        vertical: 12.0,
                      ),
                      child: Text(
                        'Get Started',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Made for Smart India Hackathon 2025',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
