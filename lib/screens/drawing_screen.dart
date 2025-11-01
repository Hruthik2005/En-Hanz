import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DrawingScreen extends StatefulWidget {
  const DrawingScreen({super.key});

  @override
  State<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen>
    with SingleTickerProviderStateMixin {
  final List<DrawingPoint> _points = [];
  Color _selectedColor = Colors.black;
  double _strokeWidth = 3.0;
  final GlobalKey _canvasKey = GlobalKey();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _clearCanvas() {
    setState(() {
      _points.clear();
    });
  }

  void _undoLastStroke() {
    setState(() {
      // Remove points until we hit a null (which marks end of stroke)
      while (_points.isNotEmpty && _points.last.offset != null) {
        _points.removeLast();
      }
      // Remove the null marker
      if (_points.isNotEmpty) {
        _points.removeLast();
      }
    });
  }

  Future<void> _saveAndContinue() async {
    if (_points.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please draw something first!'),
          backgroundColor: Colors.red.shade400,
        ),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFF1565C0)),
              const SizedBox(height: 20),
              Text(
                'Processing your drawing...',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Simulate processing
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;
    Navigator.pop(context); // Close loading dialog
    Navigator.pushReplacementNamed(context, '/processing');
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
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back_rounded,
                            color: Color(0xFF1565C0),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Draw with Stylus',
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            Text(
                              'Write naturally on the canvas',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Drawing Canvas
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        children: [
                          // Grid pattern background
                          CustomPaint(
                            painter: GridPainter(),
                            size: Size.infinite,
                          ),
                          // Drawing area
                          RepaintBoundary(
                            key: _canvasKey,
                            child: GestureDetector(
                              onPanStart: (details) {
                                setState(() {
                                  _points.add(
                                    DrawingPoint(
                                      offset: details.localPosition,
                                      paint: Paint()
                                        ..color = _selectedColor
                                        ..strokeWidth = _strokeWidth
                                        ..strokeCap = StrokeCap.round
                                        ..strokeJoin = StrokeJoin.round,
                                    ),
                                  );
                                });
                              },
                              onPanUpdate: (details) {
                                setState(() {
                                  _points.add(
                                    DrawingPoint(
                                      offset: details.localPosition,
                                      paint: Paint()
                                        ..color = _selectedColor
                                        ..strokeWidth = _strokeWidth
                                        ..strokeCap = StrokeCap.round
                                        ..strokeJoin = StrokeJoin.round,
                                    ),
                                  );
                                });
                              },
                              onPanEnd: (details) {
                                setState(() {
                                  _points.add(
                                    DrawingPoint(offset: null, paint: Paint()),
                                  );
                                });
                              },
                              child: CustomPaint(
                                painter: DrawingPainter(points: _points),
                                size: Size.infinite,
                              ),
                            ),
                          ),
                          // Instructions overlay (shows when empty)
                          if (_points.isEmpty)
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: Color(
                                        0xFF1565C0,
                                      ).withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.gesture,
                                      size: 64,
                                      color: Color(
                                        0xFF1565C0,
                                      ).withValues(alpha: 0.5),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'Start drawing with your finger or stylus',
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Write words, sentences, or draw shapes',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Tools Panel
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Stroke width slider
                      Row(
                        children: [
                          Icon(
                            Icons.line_weight,
                            color: Color(0xFF1565C0),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SliderTheme(
                              data: SliderThemeData(
                                activeTrackColor: Color(0xFF1565C0),
                                inactiveTrackColor: Colors.grey.shade300,
                                thumbColor: Color(0xFF1565C0),
                                overlayColor: Color(
                                  0xFF1565C0,
                                ).withValues(alpha: 0.2),
                              ),
                              child: Slider(
                                value: _strokeWidth,
                                min: 1.0,
                                max: 10.0,
                                onChanged: (value) {
                                  setState(() {
                                    _strokeWidth = value;
                                  });
                                },
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFF1565C0).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${_strokeWidth.toInt()}px',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1565C0),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Color and action buttons
                      Row(
                        children: [
                          // Color picker
                          Expanded(
                            child: Wrap(
                              spacing: 8,
                              children: [
                                _buildColorButton(Colors.black),
                                _buildColorButton(Color(0xFF1565C0)),
                                _buildColorButton(Colors.red.shade600),
                                _buildColorButton(Colors.green.shade600),
                                _buildColorButton(Colors.orange.shade600),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Undo button
                          _buildToolButton(
                            icon: Icons.undo_rounded,
                            onPressed: _points.isNotEmpty
                                ? _undoLastStroke
                                : null,
                            color: Colors.orange.shade600,
                          ),
                          const SizedBox(width: 8),
                          // Clear button
                          _buildToolButton(
                            icon: Icons.delete_outline_rounded,
                            onPressed: _points.isNotEmpty ? _clearCanvas : null,
                            color: Colors.red.shade600,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Continue button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _saveAndContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF1565C0),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.analytics_rounded, size: 22),
                              const SizedBox(width: 12),
                              Text(
                                'Analyze Drawing',
                                style: GoogleFonts.inter(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
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
      ),
    );
  }

  Widget _buildColorButton(Color color) {
    final isSelected = _selectedColor == color;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = color;
        });
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: isSelected
            ? Icon(Icons.check, color: Colors.white, size: 20)
            : null,
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: onPressed != null
            ? color.withValues(alpha: 0.1)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: onPressed != null ? color : Colors.grey.shade400,
        ),
        onPressed: onPressed,
      ),
    );
  }
}

// Drawing point data model
class DrawingPoint {
  final Offset? offset;
  final Paint paint;

  DrawingPoint({this.offset, required this.paint});
}

// Custom painter for drawing
class DrawingPainter extends CustomPainter {
  final List<DrawingPoint> points;

  DrawingPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i].offset != null && points[i + 1].offset != null) {
        canvas.drawLine(
          points[i].offset!,
          points[i + 1].offset!,
          points[i].paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}

// Grid background painter
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 1;

    const spacing = 30.0;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) => false;
}
