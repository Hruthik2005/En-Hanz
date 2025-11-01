import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class LetterTracingGame extends StatefulWidget {
  const LetterTracingGame({super.key});

  @override
  State<LetterTracingGame> createState() => _LetterTracingGameState();
}

class _LetterTracingGameState extends State<LetterTracingGame> {
  final GlobalKey _canvasKey = GlobalKey();
  final List<String> _letters = ['A', 'B', 'C', 'D', 'E', 'M', 'N', 'O'];
  int _currentLetterIndex = 0;
  final List<Offset?> _drawnPoints = [];
  double? _accuracy;
  bool _showFeedback = false;
  final List<double> _scores = [];

  String get _currentLetter => _letters[_currentLetterIndex];

  void _onPanStart(DragStartDetails details) {
    setState(() {
      RenderBox? renderBox =
          _canvasKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        Offset localPosition = renderBox.globalToLocal(details.globalPosition);
        _drawnPoints.add(localPosition);
      }
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      RenderBox? renderBox =
          _canvasKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        Offset localPosition = renderBox.globalToLocal(details.globalPosition);
        _drawnPoints.add(localPosition);
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _drawnPoints.add(null); // Add null to separate strokes
      if (_drawnPoints.where((p) => p != null).length > 10) {
        _calculateAccuracy();
      }
    });
  }

  void _calculateAccuracy() {
    // Mock accuracy calculation based on points drawn
    // In real implementation, compare with letter outline path
    double coverage = math.min(_drawnPoints.length / 100, 1.0);
    double randomFactor = 0.7 + (math.Random().nextDouble() * 0.25);
    double acc = (coverage * randomFactor * 100);

    setState(() {
      _accuracy = acc;
      _showFeedback = true;
      _scores.add(acc);
    });

    // Show feedback after delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted && _showFeedback) {
        setState(() => _showFeedback = false);
      }
    });
  }

  void _nextLetter() {
    if (_accuracy == null) {
      // Show warning if user didn't draw anything
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Please trace the letter before continuing!',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_currentLetterIndex < _letters.length - 1) {
      setState(() {
        _currentLetterIndex++;
        _drawnPoints.clear();
        _accuracy = null;
        _showFeedback = false;
      });
    } else {
      _showResults();
    }
  }

  void _showResults() {
    double avgScore = _scores.isEmpty
        ? 0
        : _scores.reduce((a, b) => a + b) / _scores.length;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Text('🎉 ', style: TextStyle(fontSize: 32)),
            Text(
              'Great Job!',
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
              'Average Accuracy',
              style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              '${avgScore.toStringAsFixed(0)}%',
              style: GoogleFonts.poppins(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: avgScore > 70 ? Colors.green : Colors.orange,
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
                avgScore > 85
                    ? "Excellent tracing! 🌟"
                    : avgScore > 70
                    ? "Good work! Keep practicing! 💪"
                    : "Keep practicing, you'll get better! 🎯",
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
                _currentLetterIndex = 0;
                _drawnPoints.clear();
                _accuracy = null;
                _scores.clear();
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
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFB3E5FC)],
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
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: Color(0xFF1565C0),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Letter Tracing ✏️',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                          Text(
                            'Letter ${_currentLetterIndex + 1} of ${_letters.length}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: LinearProgressIndicator(
                  value: (_currentLetterIndex + 1) / _letters.length,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1565C0)),
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
                      Icon(Icons.info_outline, color: Color(0xFF1565C0)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Trace the letter carefully inside the lines!',
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

              // Drawing Canvas
              Expanded(
                child: Padding(
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: GestureDetector(
                        key: _canvasKey,
                        onPanStart: _onPanStart,
                        onPanUpdate: _onPanUpdate,
                        onPanEnd: _onPanEnd,
                        child: Stack(
                          children: [
                            // Letter outline
                            Center(
                              child: Text(
                                _currentLetter,
                                style: TextStyle(
                                  fontSize: 200,
                                  fontWeight: FontWeight.bold,
                                  foreground: Paint()
                                    ..style = PaintingStyle.stroke
                                    ..strokeWidth = 8
                                    ..color = Colors.grey.withOpacity(0.3),
                                ),
                              ),
                            ),

                            // User's drawing
                            CustomPaint(
                              size: Size.infinite,
                              painter: DrawingPainter(_drawnPoints),
                            ),

                            // Accuracy feedback
                            if (_showFeedback && _accuracy != null)
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _accuracy! > 70
                                        ? Colors.green
                                        : Colors.orange,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _accuracy! > 70
                                            ? '✅ Well Done!'
                                            : '👍 Keep Trying!',
                                        style: GoogleFonts.poppins(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        '${_accuracy!.toStringAsFixed(0)}% Accuracy',
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
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
                          "Stay inside the lines — you're doing great!",
                          style: GoogleFonts.inter(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Action buttons
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _drawnPoints.clear();
                            _accuracy = null;
                            _showFeedback = false;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Color(0xFF1565C0)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('Clear'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _accuracy != null ? _nextLetter : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF1565C0),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _currentLetterIndex < _letters.length - 1
                              ? 'Next Letter'
                              : 'Finish',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<Offset?> points;

  DrawingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF1565C0)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (int i = 0; i < points.length - 1; i++) {
      // Skip if current or next point is null (stroke separator)
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}
