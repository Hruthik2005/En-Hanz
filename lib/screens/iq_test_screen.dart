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
  int? _selectedAnswerIndex;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  List<Map<String, dynamic>> _questions = [];
  int _childAge = 8; // Default, will be loaded from profile

  // Age Group 1: 5-7 Years (Beginner Level)
  final List<Map<String, dynamic>> _questions_5_7 = [
    {
      'question': 'What comes next in the pattern?',
      'pattern': '🔴 🟡 🔴 🟡 ❓',
      'options': ['🔴', '🟡', '🟢', '🔵'],
      'correct': '🟡',
      'explanation': 'Alternating color pattern (red, yellow, red, yellow).',
    },
    {
      'question': 'What comes next?',
      'pattern': '🐶🐶🐱🐶🐶🐱🐶🐶❓',
      'options': ['🐱', '🐶', '🐰', '🐭'],
      'correct': '🐱',
      'explanation': 'Every 3rd animal is a cat.',
    },
    {
      'question': 'What comes next in the pattern?',
      'pattern': '🔺 ⬛ 🔺 ⬛ ❓',
      'options': ['🔺', '⬛', '⚪', '🟢'],
      'correct': '🔺',
      'explanation': 'Alternates triangle and square.',
    },
    {
      'question': 'What comes next?',
      'pattern': '🔵 ⚫ ⚫ 🔵 ⚫ ⚫ ❓',
      'options': ['🔵', '⚫', '🟤', '🟢'],
      'correct': '🔵',
      'explanation': 'Every third circle is blue.',
    },
    {
      'question': 'Complete the analogy',
      'pattern': 'Sun : Day :: Moon : ❓',
      'options': ['Light', 'Cold', 'Night', 'Star'],
      'correct': 'Night',
      'explanation': 'Moon comes in night, just like sun comes in day.',
    },
  ];

  // Age Group 2: 8-10 Years (Intermediate Level)
  final List<Map<String, dynamic>> _questions_8_10 = [
    {
      'question': 'What number comes next?',
      'pattern': '3, 6, 9, 12, ❓',
      'options': ['13', '14', '15', '16'],
      'correct': '15',
      'explanation': 'Increases by 3 each time.',
    },
    {
      'question': 'Which one doesn\'t belong?',
      'pattern': 'Car  Bike  Bus  Apple',
      'options': ['Car', 'Bike', 'Bus', 'Apple'],
      'correct': 'Apple',
      'explanation': 'Car, Bike, and Bus are vehicles. Apple is not.',
    },
    {
      'question': 'What comes next in the pattern?',
      'pattern': '🔺 ⬛ ⬟ ❓',
      'options': ['⬣', '🔵', '⬢', '⚫'],
      'correct': '⬣',
      'explanation':
          'Shape sides increase — Triangle (3) → Square (4) → Pentagon (5) → Hexagon (6).',
    },
    {
      'question': 'Complete the analogy',
      'pattern': 'Bird : Fly :: Fish : ❓',
      'options': ['Swim', 'Walk', 'Float', 'Jump'],
      'correct': 'Swim',
      'explanation': 'Birds fly, fish swim.',
    },
    {
      'question': 'What comes next in the pattern?',
      'pattern': '🟦 🔴 🟩 🟦 🔴 🟩 🟦 ❓',
      'options': ['🟩', '🔴', '🟨', '🔵'],
      'correct': '🔴',
      'explanation': 'Repeats every 3 colors (blue, red, green).',
    },
  ];

  // Age Group 3: 11-13 Years (Advanced Level)
  final List<Map<String, dynamic>> _questions_11_13 = [
    {
      'question': 'What number comes next?',
      'pattern': '2, 6, 12, 20, 30, ❓',
      'options': ['36', '40', '42', '44'],
      'correct': '42',
      'explanation':
          'Difference increases by +2 each time (+4, +6, +8, +10, +12).',
    },
    {
      'question': 'What comes next in the pattern?',
      'pattern': '🔺🔵 🔺🔵 🔺🔵 🔺❓',
      'options': ['🟩', '🔺', '⬛', '🔵'],
      'correct': '🔵',
      'explanation': 'Pattern repeats every pair (triangle + blue circle).',
    },
    {
      'question': 'Complete the analogy',
      'pattern': 'Teacher : School :: Doctor : ❓',
      'options': ['Hospital', 'Patient', 'Nurse', 'Clinic'],
      'correct': 'Hospital',
      'explanation': 'Teachers work in schools, doctors work in hospitals.',
    },
    {
      'question': 'What is the result?',
      'pattern': '5 → 25, 6 → 36, 7 → ❓',
      'options': ['48', '49', '50', '54'],
      'correct': '49',
      'explanation': 'Each number is squared (5×5=25, 6×6=36, 7×7=49).',
    },
    {
      'question': 'What comes next in the pattern?',
      'pattern': '🔵 ⚫ 🔵 ⚫ ⚫ 🔵 ⚫ ❓',
      'options': ['🔵', '⚫', '🔴', '🟣'],
      'correct': '🔵',
      'explanation':
          'Hidden 3-2-2 repetition pattern (blue-black-blue-black-black).',
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

    // Load age from profile and select appropriate questions
    _loadAgeAndQuestions();

    _animController.forward();
  }

  void _loadAgeAndQuestions() {
    final appState = Provider.of<AppState>(context, listen: false);
    _childAge = appState.profile?.age ?? 8;

    // Select questions based on age group
    if (_childAge >= 5 && _childAge <= 7) {
      _questions = List.from(_questions_5_7);
      debugPrint('✅ Selected age group: 5-7 years (Beginner)');
    } else if (_childAge >= 8 && _childAge <= 10) {
      _questions = List.from(_questions_8_10);
      debugPrint('✅ Selected age group: 8-10 years (Intermediate)');
    } else if (_childAge >= 11 && _childAge <= 13) {
      _questions = List.from(_questions_11_13);
      debugPrint('✅ Selected age group: 11-13 years (Advanced)');
    } else {
      // Default to intermediate for ages outside range
      _questions = List.from(_questions_8_10);
      debugPrint(
        '⚠️ Age $_childAge outside range, using intermediate questions',
      );
    }

    debugPrint('📊 Loaded ${_questions.length} questions for age $_childAge');
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _nextQuestion() {
    if (_selectedAnswerIndex == null) {
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
    final selectedOption = _questions[_currentQuestion]['options'][_selectedAnswerIndex!];
    if (selectedOption == _questions[_currentQuestion]['correct']) {
      _score += 10;
    }

    if (_currentQuestion < _questions.length - 1) {
      setState(() {
        _currentQuestion++;
        _selectedAnswerIndex = null;
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
    // Calculate IQ using accurate formula
    final maxScore = _questions.length * 10; // Each correct answer = 10 points
    final iq = (60 + ((_score / maxScore) * 70)).round();

    // Calculate mental age
    final mentalAge = (iq / 100) * _childAge;

    // Determine IQ category
    String iqCategory;
    String iqDescription;
    if (iq >= 130) {
      iqCategory = 'Exceptional';
      iqDescription = 'Advanced analytical ability';
    } else if (iq >= 115) {
      iqCategory = 'High';
      iqDescription = 'Excellent logical ability';
    } else if (iq >= 100) {
      iqCategory = 'Above Average';
      iqDescription = 'Good reasoning skills';
    } else if (iq >= 85) {
      iqCategory = 'Average';
      iqDescription = 'Normal range';
    } else {
      iqCategory = 'Below Average';
      iqDescription = 'Needs learning support';
    }

    // Save to app state
    final appState = Provider.of<AppState>(context, listen: false);
    appState.saveIQ(iq, mentalAge);

    // Log results for debugging
    debugPrint('📊 IQ Test Results:');
    debugPrint('   Age: $_childAge years');
    debugPrint('   Score: $_score / $maxScore');
    debugPrint('   IQ: $iq ($iqCategory)');
    debugPrint('   Mental Age: ${mentalAge.toStringAsFixed(1)} years');

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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF1565C0), Color(0xFF0288D1)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          iqCategory,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        iqDescription,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Divider(color: Colors.grey.shade300),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Text(
                                'Your Age',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              Text(
                                '$_childAge yrs',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 24),
                          Container(
                            width: 1,
                            height: 30,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(width: 24),
                          Column(
                            children: [
                              Text(
                                'Mental Age',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              Text(
                                '${mentalAge.toStringAsFixed(1)} yrs',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1565C0),
                                ),
                              ),
                            ],
                          ),
                        ],
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
                                  final isSelected = _selectedAnswerIndex == index;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: InkWell(
                                      onTap: () => setState(
                                        () => _selectedAnswerIndex = index,
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
