import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class CopyWordGame extends StatefulWidget {
  const CopyWordGame({super.key});

  @override
  State<CopyWordGame> createState() => _CopyWordGameState();
}

class _CopyWordGameState extends State<CopyWordGame> {
  final GlobalKey _canvasKey = GlobalKey();
  final List<String> _words = ['APPLE', 'DOG', 'SUN', 'BOOK', 'BALL', 'CAT', 'TREE', 'STAR'];
  int _currentWordIndex = 0;
  List<Offset?> _drawnPoints = [];
  int? _score;
  bool _showFeedback = false;
  List<int> _scores = [];
  String _feedbackMessage = '';

  String get _currentWord => _words[_currentWordIndex];

  void _onPanStart(DragStartDetails details) {
    setState(() {
      RenderBox? renderBox = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        _drawnPoints.add(renderBox.globalToLocal(details.globalPosition));
      }
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      RenderBox? renderBox = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        _drawnPoints.add(renderBox.globalToLocal(details.globalPosition));
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _drawnPoints.add(null); // Add null to separate strokes
    });
  }

  void _clearDrawing() {
    setState(() {
      _drawnPoints.clear();
      _score = null;
      _showFeedback = false;
      _feedbackMessage = '';
    });
  }

  void _checkWriting() {
    if (_drawnPoints.where((p) => p != null).length < 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '⚠️ Please write the word first!',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    // Mock evaluation based on stroke count and coverage
    double coverage = math.min(_drawnPoints.length / 300, 1.0);
    double randomFactor = 0.65 + (math.Random().nextDouble() * 0.30);
    int calculatedScore = ((coverage * randomFactor) * 100).toInt();

    // Generate feedback
    List<String> feedbacks = [
      "Good spacing! 📏",
      "Nice letter formation! ✍️",
      "Try keeping letters aligned 📐",
      "Excellent consistency! 🌟",
      "Work on letter size 📊",
      "Great effort! Keep practicing! 💪",
    ];

    setState(() {
      _score = calculatedScore;
      _feedbackMessage = feedbacks[math.Random().nextInt(feedbacks.length)];
      _showFeedback = true;
      _scores.add(calculatedScore);
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _showFeedback) {
        setState(() => _showFeedback = false);
      }
    });
  }

  void _nextWord() {
    if (_currentWordIndex < _words.length - 1) {
      setState(() {
        _currentWordIndex++;
        _drawnPoints.clear();
        _score = null;
        _showFeedback = false;
        _feedbackMessage = '';
      });
    } else {
      _showResults();
    }
  }

  void _showResults() {
    double avgScore = _scores.isEmpty ? 0 : _scores.reduce((a, b) => a + b) / _scores.length;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Text('📝 ', style: TextStyle(fontSize: 32)),
            Text(
              'Word Wizard!',
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
              'Average Neatness Score',
              style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              '${avgScore.toStringAsFixed(0)}/100',
              style: GoogleFonts.poppins(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: avgScore > 80
                    ? Colors.green
                    : avgScore > 60
                        ? Colors.orange
                        : Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    avgScore > 85
                        ? "Excellent handwriting! 🏆"
                        : avgScore > 70
                            ? "Good neatness! Keep it up! 📈"
                            : "Practice makes perfect! 💪",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Words completed: ${_scores.length}',
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
                _currentWordIndex = 0;
                _drawnPoints.clear();
                _score = null;
                _scores.clear();
                _showFeedback = false;
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
            colors: [Color(0xFFFCE4EC), Color(0xFFF8BBD0)],
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
                      icon: Icon(Icons.arrow_back_rounded, color: Color(0xFFC2185B)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Copy the Word 📝',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFC2185B),
                            ),
                          ),
                          Text(
                            'Word ${_currentWordIndex + 1} of ${_words.length}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.grey[700],
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
                  value: (_currentWordIndex + 1) / _words.length,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC2185B)),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),

              const SizedBox(height: 24),

              // Reference word display
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Color(0xFFC2185B), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Copy this word:',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currentWord,
                      style: GoogleFonts.poppins(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFC2185B),
                        letterSpacing: 4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Writing canvas with guidelines
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
                            // Ruled lines (like notebook paper)
                            CustomPaint(
                              size: Size.infinite,
                              painter: RuledLinesPainter(),
                            ),

                            // User's writing
                            CustomPaint(
                              size: Size.infinite,
                              painter: WritingPainter(_drawnPoints),
                            ),

                            // Hint text
                            if (_drawnPoints.isEmpty)
                              Center(
                                child: Text(
                                  'Write the word here ✍️',
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ),

                            // Feedback overlay
                            if (_showFeedback && _score != null)
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _score! > 75
                                        ? Colors.green
                                        : _score! > 50
                                            ? Colors.orange
                                            : Colors.red,
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
                                        _feedbackMessage,
                                        style: GoogleFonts.poppins(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Score: $_score/100',
                                        style: GoogleFonts.inter(
                                          fontSize: 18,
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
                          "Try to copy the word neatly in your box!",
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
                        onPressed: _clearDrawing,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Color(0xFFC2185B)),
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
                        onPressed: _score == null ? _checkWriting : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFC2185B),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('Check'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _score != null ? _nextWord : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _currentWordIndex < _words.length - 1 ? 'Next' : 'Finish',
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

class WritingPainter extends CustomPainter {
  final List<Offset?> points;

  WritingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFFC2185B)
      ..strokeWidth = 5
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
  bool shouldRepaint(WritingPainter oldDelegate) => true;
}

class RuledLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1;

    // Draw horizontal lines like ruled paper
    double lineSpacing = size.height / 8;
    for (int i = 1; i < 8; i++) {
      double y = i * lineSpacing;
      canvas.drawLine(
        Offset(20, y),
        Offset(size.width - 20, y),
        paint,
      );
    }

    // Draw dotted middle line for letter height guide
    final dottedPaint = Paint()
      ..color = Colors.blue[200]!
      ..strokeWidth = 1;
    
    for (int i = 0; i < 7; i++) {
      double y = (i + 0.5) * lineSpacing;
      for (double x = 20; x < size.width - 20; x += 10) {
        canvas.drawCircle(Offset(x, y), 1, dottedPaint);
      }
    }
  }

  @override
  bool shouldRepaint(RuledLinesPainter oldDelegate) => false;
}
