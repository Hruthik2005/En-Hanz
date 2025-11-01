import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../services/api_service.dart';
import '../state/app_state.dart';

class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({super.key});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen>
    with TickerProviderStateMixin {
  double _progress = 0.0;
  Timer? _timer;
  String _currentTask = 'Initializing analysis...';
  int _currentQuoteIndex = 0;
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _typingController;

  final List<String> _tasks = [
    'Analyzing letter formation...',
    'Measuring spacing patterns...',
    'Detecting slant consistency...',
    'Evaluating pressure variance...',
    'Processing stroke characteristics...',
    'Calculating dysgraphia indicators...',
    'Finalizing assessment...',
  ];

  final List<String> _quotes = [
    "Analyzing your unique handwriting patterns",
    "AI is detecting subtle writing characteristics",
    "Every stroke reveals important insights",
    "Technology meeting compassionate care",
    "Precision analysis for early detection",
    "Understanding the story behind each letter",
    "Smart detection for brighter futures",
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _typingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _start();
    _startQuoteRotation();
  }

  void _startQuoteRotation() {
    Timer.periodic(const Duration(milliseconds: 4000), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _currentQuoteIndex = (_currentQuoteIndex + 1) % _quotes.length;
      });
    });
  }

  void _start() async {
    int taskIndex = 0;

    // fake progress with task updates
    _timer = Timer.periodic(const Duration(milliseconds: 600), (t) {
      setState(() {
        _progress = (_progress + 0.08).clamp(0.0, 0.98);
        if (_progress > taskIndex * 0.14 && taskIndex < _tasks.length) {
          _currentTask = _tasks[taskIndex];
          taskIndex++;
        }
      });
    });

    final appState = Provider.of<AppState>(context, listen: false);
    final profile = appState.profile ?? (throw Exception('Missing profile'));
    final iq = appState.iqScore;
    final mentalAge = appState.mentalAge;

    final result = await ApiService.predict(
      profile: profile,
      iqScore: iq,
      mentalAge: mentalAge,
      imagePath: appState.handwritingImagePath,
    );

    _timer?.cancel();
    setState(() {
      _progress = 1.0;
      _currentTask = 'Analysis complete! ✓';
    });
    // Save to state and navigate
    appState.saveResult(
      (result['risk'] as num).toDouble(),
      result['recommendation'] ?? '',
    );
    // small delay so user sees 100%
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/results');
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _rotateController.dispose();
    _typingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFB3E5FC), Color(0xFFE1F5FE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  // Animated White Robot
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final breathe = _pulseController.value;
                      return Transform.scale(
                        scale: 1.0 + (breathe * 0.05),
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF1565C0), Color(0xFF0288D1)],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(
                                  0xFF1565C0,
                                ).withValues(alpha: 0.3 + (breathe * 0.2)),
                                blurRadius: 30 + (breathe * 20),
                                spreadRadius: 5 + (breathe * 5),
                              ),
                            ],
                          ),
                          child: Center(
                            child: _AnimatedRobot(
                              animation: _pulseController,
                              rotateAnimation: _rotateController,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 48),

                  // Smooth Quote Display
                  Container(
                    height: 90,
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Color(0xFF1565C0).withValues(alpha: 0.15),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF1565C0).withValues(alpha: 0.12),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 800),
                        switchInCurve: Curves.easeInOutCubic,
                        switchOutCurve: Curves.easeInOutCubic,
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: Tween<double>(begin: 0.92, end: 1.0)
                                  .animate(
                                    CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOutBack,
                                    ),
                                  ),
                              child: child,
                            ),
                          );
                        },
                        child: Row(
                          key: ValueKey<int>(_currentQuoteIndex),
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              color: Color(0xFF0288D1),
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                _quotes[_currentQuoteIndex],
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1565C0),
                                  height: 1.5,
                                  letterSpacing: 0.2,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.auto_awesome,
                              color: Color(0xFF0288D1),
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Progress Circle
                  CircularPercentIndicator(
                    radius: 90.0,
                    lineWidth: 10.0,
                    percent: _progress,
                    center: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${(_progress * 100).toInt()}%',
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1565C0),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Processing',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.white.withValues(alpha: 0.4),
                    progressColor: Color(0xFF0288D1),
                    circularStrokeCap: CircularStrokeCap.round,
                    animation: false,
                  ),

                  const SizedBox(height: 40),

                  // Task Description Card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF1565C0).withValues(alpha: 0.2),
                                Color(0xFF0288D1).withValues(alpha: 0.2),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.psychology_rounded,
                            color: Color(0xFF1565C0),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Flexible(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.3),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            child: Text(
                              _currentTask,
                              key: ValueKey<String>(_currentTask),
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Processing Indicators (Animated Dots)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      return AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          final delay = index * 0.2;
                          final progress = ((_pulseController.value - delay)
                              .clamp(0.0, 1.0));
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(
                                0xFF0288D1,
                              ).withValues(alpha: 0.3 + (progress * 0.7)),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(
                                    0xFF1565C0,
                                  ).withValues(alpha: 0.4 * progress),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Animated Robot Widget - Inspired by cute robot design
class _AnimatedRobot extends StatelessWidget {
  final Animation<double> animation;
  final Animation<double> rotateAnimation;

  const _AnimatedRobot({
    required this.animation,
    required this.rotateAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final blink = animation.value > 0.95 ? 0.0 : 1.0;
    final float = animation.value * 6;

    return Transform.translate(
      offset: Offset(0, float),
      child: SizedBox(
        width: 140,
        height: 140,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Robot Body (egg-shaped like the reference)
            Positioned(
              bottom: 8,
              child: Container(
                width: 75,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(38),
                    topRight: Radius.circular(38),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Body accent lines
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        children: [
                          Container(
                            width: 40,
                            height: 2.5,
                            decoration: BoxDecoration(
                              color: Color(0xFF0288D1).withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 35,
                            height: 2.5,
                            decoration: BoxDecoration(
                              color: Color(0xFF0288D1).withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Robot Head (rounded white shape)
            Positioned(
              top: 0,
              child: Container(
                width: 85,
                height: 85,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(42),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Black visor/screen (like the reference image)
                    Positioned(
                      top: 20,
                      left: 10,
                      right: 10,
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF1a1a2e), Color(0xFF0f0f1e)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Left Eye
                            Positioned(
                              top: 10,
                              left: 15,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                width: 14,
                                height: blink == 1.0 ? 14 : 2,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: blink == 1.0
                                      ? [
                                          BoxShadow(
                                            color: Color(
                                              0xFF0288D1,
                                            ).withValues(alpha: 0.6),
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                          ),
                                        ]
                                      : [],
                                ),
                                child: blink == 1.0
                                    ? Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: RadialGradient(
                                            colors: [
                                              Color(0xFF0288D1),
                                              Color(0xFF1565C0),
                                            ],
                                          ),
                                        ),
                                        child: Center(
                                          child: Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                            // Right Eye
                            Positioned(
                              top: 10,
                              right: 15,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                width: 14,
                                height: blink == 1.0 ? 14 : 2,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: blink == 1.0
                                      ? [
                                          BoxShadow(
                                            color: Color(
                                              0xFF0288D1,
                                            ).withValues(alpha: 0.6),
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                          ),
                                        ]
                                      : [],
                                ),
                                child: blink == 1.0
                                    ? Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: RadialGradient(
                                            colors: [
                                              Color(0xFF0288D1),
                                              Color(0xFF1565C0),
                                            ],
                                          ),
                                        ),
                                        child: Center(
                                          child: Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Antenna
                    Positioned(
                      top: -8,
                      left: 36,
                      child: Column(
                        children: [
                          Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF1565C0), Color(0xFF0288D1)],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(
                                    0xFF0288D1,
                                  ).withValues(alpha: 0.7),
                                  blurRadius: 12,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 2.5,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Left arm
            Positioned(
              top: 55,
              left: -8,
              child: Transform.rotate(
                angle: 0.4 + (animation.value * 0.15),
                child: Container(
                  width: 28,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Color(0xFF0288D1).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                ),
              ),
            ),
            // Right arm
            Positioned(
              top: 55,
              right: -8,
              child: Transform.rotate(
                angle: -0.4 - (animation.value * 0.15),
                child: Container(
                  width: 28,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Color(0xFF0288D1).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                ),
              ),
            ),

            // Wheels/Base (circular like the reference)
            Positioned(
              bottom: 0,
              left: 20,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Color(0xFF0288D1).withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1565C0), Color(0xFF0288D1)],
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 20,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Color(0xFF0288D1).withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1565C0), Color(0xFF0288D1)],
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
