import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';

class DotJoinGame extends StatefulWidget {
  const DotJoinGame({super.key});

  @override
  State<DotJoinGame> createState() => _DotJoinGameState();
}

class _DotJoinGameState extends State<DotJoinGame> {
  late ConfettiController _confettiController;
  
  final List<Map<String, dynamic>> _patterns = [
    {'name': 'A', 'dots': [
      Offset(0.5, 0.2), Offset(0.3, 0.7), Offset(0.7, 0.7), Offset(0.4, 0.45), Offset(0.6, 0.45)
    ]},
    {'name': 'Triangle', 'dots': [
      Offset(0.5, 0.2), Offset(0.2, 0.7), Offset(0.8, 0.7)
    ]},
    {'name': 'Square', 'dots': [
      Offset(0.3, 0.3), Offset(0.7, 0.3), Offset(0.7, 0.7), Offset(0.3, 0.7)
    ]},
    {'name': 'Star', 'dots': [
      Offset(0.5, 0.15), Offset(0.6, 0.4), Offset(0.82, 0.42), Offset(0.67, 0.58), 
      Offset(0.72, 0.82), Offset(0.5, 0.68), Offset(0.28, 0.82), Offset(0.33, 0.58),
      Offset(0.18, 0.42), Offset(0.4, 0.4)
    ]},
  ];

  int _currentPatternIndex = 0;
  int _nextDotIndex = 0;
  List<Offset> _connectedDots = [];
  bool _isComplete = false;
  int _completionTime = 0;
  DateTime? _startTime;
  List<int> _times = [];

  Map<String, dynamic> get _currentPattern => _patterns[_currentPatternIndex];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _startTime = DateTime.now();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _onDotTapped(int index) {
    if (_isComplete) return;

    if (index == _nextDotIndex) {
      setState(() {
        List<Offset> dots = List<Offset>.from(_currentPattern['dots']);
        _connectedDots.add(dots[index]);
        _nextDotIndex++;

        if (_nextDotIndex >= dots.length) {
          _completePattern();
        }
      });
    } else {
      // Wrong dot - show error feedback
      _showError();
    }
  }

  void _showError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('⚠️ Follow the numbers in order!'),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _completePattern() {
    _completionTime = DateTime.now().difference(_startTime!).inSeconds;
    _times.add(_completionTime);
    
    setState(() {
      _isComplete = true;
    });
    
    _confettiController.play();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isComplete = false;
        });
      }
    });
  }

  void _nextPattern() {
    if (_currentPatternIndex < _patterns.length - 1) {
      setState(() {
        _currentPatternIndex++;
        _nextDotIndex = 0;
        _connectedDots.clear();
        _isComplete = false;
        _startTime = DateTime.now();
      });
    } else {
      _showResults();
    }
  }

  void _showResults() {
    double avgTime = _times.isEmpty ? 0 : _times.reduce((a, b) => a + b) / _times.length;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Text('⭐ ', style: TextStyle(fontSize: 32)),
            Text(
              'Dot Master!',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1565C0),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Average Time',
              style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              '${avgTime.toStringAsFixed(1)}s',
              style: GoogleFonts.poppins(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1565C0),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                avgTime < 15
                    ? "Super fast! Great motor control! 🚀"
                    : avgTime < 30
                        ? "Good coordination! Keep practicing! 💪"
                        : "You're improving! Try again! 🎯",
                style: GoogleFonts.inter(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Back to Practice Zone'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentPatternIndex = 0;
                _nextDotIndex = 0;
                _connectedDots.clear();
                _isComplete = false;
                _times.clear();
                _startTime = DateTime.now();
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1565C0),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Play Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Offset> dots = List<Offset>.from(_currentPattern['dots']);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE1F5FE), Color(0xFF81D4FA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_rounded, color: Color(0xFF0277BD)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dot-Join Game 🔵',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0277BD),
                            ),
                          ),
                          Text(
                            'Pattern ${_currentPatternIndex + 1} of ${_patterns.length}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!_isComplete)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '⏱️ ${DateTime.now().difference(_startTime!).inSeconds}s',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0277BD),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: LinearProgressIndicator(
                  value: (_currentPatternIndex + 1) / _patterns.length,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0277BD)),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),

              const SizedBox(height: 24),

              // Instruction
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.touch_app, color: Color(0xFF0277BD)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Tap the dots in order from 1 to ${dots.length}!',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Dot pattern canvas
              Expanded(
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return CustomPaint(
                              size: Size(constraints.maxWidth, constraints.maxHeight),
                              painter: DotPatternPainter(dots, _connectedDots, _isComplete),
                              child: Stack(
                                children: List.generate(dots.length, (index) {
                                  bool isConnected = index < _nextDotIndex;
                                  bool isCurrent = index == _nextDotIndex;
                                  
                                  return Positioned(
                                    left: dots[index].dx * constraints.maxWidth - 25,
                                    top: dots[index].dy * constraints.maxHeight - 25,
                                    child: GestureDetector(
                                      onTap: () => _onDotTapped(index),
                                      child: Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isConnected
                                              ? Colors.green
                                              : isCurrent
                                                  ? Color(0xFF0277BD)
                                                  : Colors.grey[300],
                                          border: Border.all(
                                            color: isCurrent ? Colors.orange : Colors.white,
                                            width: isCurrent ? 3 : 2,
                                          ),
                                          boxShadow: [
                                            if (isCurrent)
                                              BoxShadow(
                                                color: Colors.orange.withOpacity(0.5),
                                                blurRadius: 10,
                                                spreadRadius: 2,
                                              ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${index + 1}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
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
                        ),
                      ),
                    ),

                    // Confetti
                    Align(
                      alignment: Alignment.topCenter,
                      child: ConfettiWidget(
                        confettiController: _confettiController,
                        blastDirectionality: BlastDirectionality.explosive,
                        particleDrag: 0.05,
                        emissionFrequency: 0.05,
                        numberOfParticles: 50,
                        gravity: 0.1,
                        colors: [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
                      ),
                    ),

                    // Completion overlay
                    if (_isComplete)
                      Container(
                        color: Colors.black.withOpacity(0.3),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '🎉',
                                  style: TextStyle(fontSize: 64),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Perfect!',
                                  style: GoogleFonts.poppins(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0277BD),
                                  ),
                                ),
                                Text(
                                  '${_currentPattern['name']} Complete!',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Time: $_completionTime seconds',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // HandyBot tip
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Text('🤖', style: TextStyle(fontSize: 32)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Try not to skip any dot! Follow the numbers!",
                          style: GoogleFonts.inter(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Next button
              if (_isComplete)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: _nextPattern,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0277BD),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _currentPatternIndex < _patterns.length - 1
                          ? 'Next Pattern'
                          : 'Finish',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class DotPatternPainter extends CustomPainter {
  final List<Offset> dots;
  final List<Offset> connectedDots;
  final bool isComplete;

  DotPatternPainter(this.dots, this.connectedDots, this.isComplete);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isComplete ? Colors.green : Color(0xFF0277BD)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // Draw connected lines
    for (int i = 0; i < connectedDots.length - 1; i++) {
      Offset start = Offset(
        connectedDots[i].dx * size.width,
        connectedDots[i].dy * size.height,
      );
      Offset end = Offset(
        connectedDots[i + 1].dx * size.width,
        connectedDots[i + 1].dy * size.height,
      );
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(DotPatternPainter oldDelegate) => true;
}
