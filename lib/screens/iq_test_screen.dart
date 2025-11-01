import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../state/app_state.dart';

class IQTestScreen extends StatefulWidget {
  const IQTestScreen({super.key});

  @override
  State<IQTestScreen> createState() => _IQTestScreenState();
}

class _IQTestScreenState extends State<IQTestScreen>
    with SingleTickerProviderStateMixin {
  int _currentQuestion = 0;
  int _score = 0;
  String? _selectedAnswer;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'What comes next in the pattern?',
      'pattern': '🟦 🔴 🟩 🟦 🔴 🟩 🟦 ❓',
      'options': ['🟨', '🔴', '🟩', '🟦'],
      'correct': '🔴',
      'explanation':
          'The pattern repeats every three symbols (blue, red, green).',
    },
    {
      'question': 'What number comes next?',
      'pattern': '2, 4, 8, 16, ❓',
      'options': ['18', '24', '32', '34'],
      'correct': '32',
      'explanation': 'Each number doubles the previous one (×2 pattern).',
    },
    {
      'question': 'Which one doesn\'t belong?',
      'pattern': 'Square  Circle  Triangle  Car',
      'options': ['Square', 'Circle', 'Triangle', 'Car'],
      'correct': 'Car',
      'explanation': 'The first three are geometric shapes; "Car" is not.',
    },
    {
      'question': 'Complete the analogy',
      'pattern': 'Sun : Day :: Moon : ❓',
      'options': ['Light', 'Night', 'Star', 'Dark'],
      'correct': 'Night',
      'explanation': 'The sun appears during day, the moon during night.',
    },
    {
      'question': 'What comes next in the pattern?',
      'pattern': '🔺 ⬛ ⬟ ❓',
      'options': ['🔶', '⬣', '⚫', '🔵'],
      'correct': '⬣',
      'explanation':
          'The pattern increases the number of sides in each shape — Triangle (3) → Square (4) → Pentagon (5) → Hexagon (6).',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOutCubic),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.15, 0), end: Offset.zero).animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _nextQuestion() {
    if (_selectedAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select an answer', style: GoogleFonts.inter()),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(milliseconds: 1500),
        ),
      );
      return;
    }

    // Check if answer is correct
    if (_selectedAnswer == _questions[_currentQuestion]['correct']) {
      _score += 10;
    }

    if (_currentQuestion < _questions.length - 1) {
      setState(() {
        _currentQuestion++;
        _selectedAnswer = null;
      });
      _animController.reset();
      Future.delayed(const Duration(milliseconds: 100), () {
        _animController.forward();
      });
    } else {
      _showResults();
    }
  }

  void _showResults() {
    final iq = (_score * 2) + 60; // Formula: (TotalScore × 2) + 60
    final appState = Provider.of<AppState>(context, listen: false);
    final age = appState.profile?.age ?? 8;
    final mentalAge = (iq / 100) * age;
    appState.saveIQ(iq, mentalAge);

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (context) => ScaleTransition(
        scale: CurvedAnimation(
          parent: _animController,
          curve: Curves.easeOutBack,
        ),
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE3F2FD), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1565C0), Color(0xFF0288D1)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF1565C0).withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.emoji_events_rounded,
                    color: Colors.white,
                    size: 56,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Great Job! 🎉',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1565C0),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'IQ Score: ',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          Text(
                            '$iq',
                            style: GoogleFonts.poppins(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('🧠', style: TextStyle(fontSize: 24)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Mental Age: ${mentalAge.toStringAsFixed(1)} years',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '"You did great! Let\'s check your\nhandwriting next!"',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/upload');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1565C0),
                      elevation: 8,
                      shadowColor: Color(0xFF1565C0).withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Continue',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 20,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestion];
    final progress = (_currentQuestion + 1) / _questions.length;

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
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
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
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [Color(0xFF1565C0), Color(0xFF0288D1)],
                          ).createShader(bounds),
                          child: Text(
                            'En-HanZ',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'IQ Assessment',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1565C0),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Question ${_currentQuestion + 1} of ${_questions.length}',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Progress bar
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade100,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF1565C0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Question Card
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(32),
                            topRight: Radius.circular(32),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 20,
                              offset: const Offset(0, -5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF1565C0),
                                        Color(0xFF0288D1),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Question ${_currentQuestion + 1}',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              question['question'],
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                                letterSpacing: 0.3,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 28),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFE3F2FD),
                                    Color(0xFFBBDEFB),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(
                                      0xFF1565C0,
                                    ).withValues(alpha: 0.1),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  question['pattern'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1565C0),
                                    letterSpacing: 3,
                                    height: 1.4,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF1565C0),
                                        Color(0xFF0288D1),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Choose your answer:',
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey.shade800,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Column(
                              children: List.generate(
                                question['options'].length,
                                (index) {
                                  final option = question['options'][index];
                                  final isSelected = _selectedAnswer == option;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: InkWell(
                                      onTap: () => setState(
                                        () => _selectedAnswer = option,
                                      ),
                                      borderRadius: BorderRadius.circular(18),
                                      splashColor: Color(
                                        0xFF1565C0,
                                      ).withValues(alpha: 0.2),
                                      highlightColor: Color(
                                        0xFF1565C0,
                                      ).withValues(alpha: 0.08),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 150,
                                        ),
                                        curve: Curves.easeOut,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 18,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: isSelected
                                              ? LinearGradient(
                                                  colors: [
                                                    Color(0xFF1565C0),
                                                    Color(0xFF0288D1),
                                                  ],
                                                )
                                              : null,
                                          color: isSelected
                                              ? null
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                          border: Border.all(
                                            color: isSelected
                                                ? Color(0xFF1565C0)
                                                : Colors.grey.shade300,
                                            width: 2,
                                          ),
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                    color: Color(
                                                      0xFF1565C0,
                                                    ).withValues(alpha: 0.5),
                                                    blurRadius: 20,
                                                    offset: const Offset(0, 8),
                                                    spreadRadius: 2,
                                                  ),
                                                ]
                                              : [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withValues(
                                                          alpha: 0.04,
                                                        ),
                                                    blurRadius: 6,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                        ),
                                        child: Row(
                                          children: [
                                            AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 150,
                                              ),
                                              curve: Curves.easeOut,
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: isSelected
                                                    ? Colors.white
                                                    : Color(0xFFE3F2FD),
                                                border: Border.all(
                                                  color: isSelected
                                                      ? Colors.white
                                                      : Color(0xFF1565C0),
                                                  width: 2,
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  String.fromCharCode(
                                                    65 + index,
                                                  ), // A, B, C, D
                                                  style: GoogleFonts.inter(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w800,
                                                    color: isSelected
                                                        ? Color(0xFF1565C0)
                                                        : Color(0xFF1565C0),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: AnimatedDefaultTextStyle(
                                                duration: const Duration(
                                                  milliseconds: 150,
                                                ),
                                                curve: Curves.easeOut,
                                                style: GoogleFonts.inter(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w600,
                                                  color: isSelected
                                                      ? Colors.white
                                                      : Colors.grey.shade800,
                                                  letterSpacing: 0.3,
                                                ),
                                                child: Text(option),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            if (isSelected)
                                              TweenAnimationBuilder<double>(
                                                tween: Tween(
                                                  begin: 0.0,
                                                  end: 1.0,
                                                ),
                                                duration: const Duration(
                                                  milliseconds: 200,
                                                ),
                                                curve: Curves.easeOutBack,
                                                builder: (context, value, child) {
                                                  return Transform.scale(
                                                    scale: value,
                                                    child: Icon(
                                                      Icons
                                                          .check_circle_rounded,
                                                      color: Colors.white,
                                                      size: 24,
                                                    ),
                                                  );
                                                },
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.95, end: 1.0),
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOut,
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF1565C0),
                                          Color(0xFF0288D1),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(18),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(
                                            0xFF1565C0,
                                          ).withValues(alpha: 0.5),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: 56,
                                      child: ElevatedButton(
                                        onPressed: _nextQuestion,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              _currentQuestion <
                                                      _questions.length - 1
                                                  ? 'Next Question'
                                                  : 'See Results',
                                              style: GoogleFonts.inter(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Icon(
                                              _currentQuestion <
                                                      _questions.length - 1
                                                  ? Icons.arrow_forward_rounded
                                                  : Icons.emoji_events_rounded,
                                              color: Colors.white,
                                              size: 22,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
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
