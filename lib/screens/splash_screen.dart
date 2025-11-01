import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
  bool _fontsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadFontsAndAnimate();
  }

  Future<void> _loadFontsAndAnimate() async {
    // Ensure fonts are loaded before starting animations
    await Future.wait([
      GoogleFonts.pendingFonts([
        GoogleFonts.dancingScript(),
        GoogleFonts.poppins(),
        GoogleFonts.inter(),
      ]),
    ]);

    // Small delay to ensure fonts are rendered
    await Future.delayed(const Duration(milliseconds: 150));

    if (!mounted) return;

    setState(() {
      _fontsLoaded = true;
    });

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeInOutCubicEmphasized),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 60.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
    Future.delayed(const Duration(milliseconds: 3000), _waitAndNavigate);
  }

  @override
  void dispose() {
    if (_fontsLoaded) {
      _controller.dispose();
    }
    super.dispose();
  }

  Future<void> _waitAndNavigate() async {
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/profile');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE3F2FD), // Light blue
              Color(0xFFB3E5FC), // Sky blue
              Color(0xFFE1F5FE), // Cyan tint
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: !_fontsLoaded
                ? const CircularProgressIndicator(
                    color: Color(0xFF1565C0),
                    strokeWidth: 3,
                  )
                : AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Animated "hello" text
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: ScaleTransition(
                              scale: _scaleAnimation,
                              child: _AnimatedHelloText(
                                controller: _controller,
                              ),
                            ),
                          ),

                          const SizedBox(height: 48),

                          // App name with slide animation
                          Transform.translate(
                            offset: Offset(0, _slideAnimation.value),
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.95,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(
                                            0xFF1976D2,
                                          ).withValues(alpha: 0.2),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: ShaderMask(
                                      shaderCallback: (bounds) =>
                                          LinearGradient(
                                            colors: [
                                              Color(0xFF1565C0), // Deep blue
                                              Color(0xFF0288D1), // Vibrant blue
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ).createShader(bounds),
                                      child: Text(
                                        'En-HanZ',
                                        style: GoogleFonts.poppins(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.5,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'AI that understands your handwriting',
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      color: Color(0xFF1565C0),
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.3,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color(
                                        0xFF1976D2,
                                      ).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'for early dysgraphia detection',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: Color(0xFF0D47A1),
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 60),

                          // Pulsing loading indicator
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: _PulsingDots(),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedHelloText extends StatelessWidget {
  final AnimationController controller;

  const _AnimatedHelloText({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final text = 'hello';
        final progress = (controller.value * 1.3).clamp(0.0, 1.0);
        final visibleChars = (progress * text.length).floor();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(text.length, (index) {
              final isVisible = index < visibleChars;
              final charProgress = isVisible
                  ? 1.0
                  : (progress * text.length - index).clamp(0.0, 1.0);

              // Smooth bounce effect only
              final bounce = (1 - charProgress) * 20.0;

              return Transform.translate(
                offset: Offset(0, bounce),
                child: Opacity(
                  opacity: charProgress,
                  child: Transform.scale(
                    scale: 0.5 + (charProgress * 0.5),
                    child: ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          Color(0xFF1565C0), // Deep blue
                          Color(0xFF0288D1), // Vibrant blue
                          Color(0xFF00ACC1), // Cyan
                        ],
                      ).createShader(bounds),
                      child: Text(
                        text[index],
                        style: GoogleFonts.dancingScript(
                          fontSize: 96,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.0,
                          letterSpacing: -2,
                          shadows: [
                            Shadow(
                              color: Color(0xFF1976D2).withValues(alpha: 0.5),
                              offset: const Offset(0, 6),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

class _PulsingDots extends StatefulWidget {
  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final progress = ((_pulseController.value - delay).clamp(0.0, 1.0));
            final scale = 0.7 + (progress * 0.3);
            final opacity = progress;

            return Transform.scale(
              scale: scale,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(
                    0xFF0288D1,
                  ).withValues(alpha: 0.2 + opacity * 0.8),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF1976D2).withValues(alpha: 0.5 * opacity),
                      blurRadius: 12 + (opacity * 8),
                      spreadRadius: 2 + (opacity * 2),
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
