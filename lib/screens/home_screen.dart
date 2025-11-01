import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../models/profile.dart';
import '../utils/app_strings.dart';
import '../utils/modern_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final profile = appState.profile;
    final riskScore = appState.risk;
    final iqScore = appState.iqScore;
    final language = appState.settings.language;

    // Determine risk level
    String riskLevel;
    Color riskColor;
    IconData riskIcon;

    if (riskScore < 0.4) {
      riskLevel = AppStrings.get('low_risk', language);
      riskColor = Colors.green;
      riskIcon = Icons.check_circle;
    } else if (riskScore < 0.7) {
      riskLevel = AppStrings.get('moderate_risk', language);
      riskColor = Colors.orange;
      riskIcon = Icons.info;
    } else {
      riskLevel = AppStrings.get('high_risk', language);
      riskColor = Colors.red;
      riskIcon = Icons.warning;
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: ModernTheme.blueBackgroundGradient,
          ),
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with Profile
                      _buildHeader(profile),

                      const SizedBox(height: 24),

                      // Motivational Quote Box
                      _buildMotivationalQuote(),

                      const SizedBox(height: 24),

                      // 3 Big Action Cards
                      Text(
                        'What would you like to do?',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade800,
                        ),
                      ),

                      const SizedBox(height: 16),

                      _buildBigActionCard(
                        icon: Icons.rocket_launch_rounded,
                        title: AppStrings.get('start_new_test', language),
                        subtitle: 'Begin fresh handwriting assessment',
                        emoji: '🧠',
                        gradient: [ModernTheme.primaryBlue, ModernTheme.infoCyan],
                        onTap: () => Navigator.pushNamed(context, '/profile'),
                      ),

                      const SizedBox(height: 16),

                      if (riskScore > 0)
                        _buildBigActionCard(
                          icon: Icons.bar_chart_rounded,
                          title: AppStrings.get('view_report', language),
                          subtitle: 'See your assessment results',
                          emoji: '📊',
                          gradient: [ModernTheme.infoCyan, ModernTheme.successGreen],
                          onTap: () => Navigator.pushNamed(context, '/results'),
                        ),

                      if (riskScore > 0) const SizedBox(height: 16),

                      _buildBigActionCard(
                        icon: Icons.games_rounded,
                        title: AppStrings.get('practice_zone', language),
                        subtitle: 'Fun games to improve writing',
                        emoji: '🎮',
                        gradient: [ModernTheme.accentAmber, Color(0xFFF97316)],
                        onTap: () => Navigator.pushNamed(context, '/practice'),
                      ),

                      const SizedBox(height: 32),

                      // Latest Assessment Card
                      if (riskScore > 0) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.history_rounded,
                              color: ModernTheme.primaryBlue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Recent Activity',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: ModernTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildAssessmentCard(
                          riskLevel,
                          riskColor,
                          riskIcon,
                          riskScore,
                          iqScore,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Quick Actions
                      Row(
                        children: [
                          Icon(
                            Icons.grid_view_rounded,
                            color: ModernTheme.primaryBlue,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'More Options',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: ModernTheme.textDark,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Action Cards Grid
                      Row(
                        children: [
                          Expanded(
                            child: _buildSmallActionCard(
                              icon: Icons.history_edu_rounded,
                              title: AppStrings.get('history', language),
                              gradient: [ModernTheme.primaryBlue, ModernTheme.secondaryPurple],
                              onTap: () =>
                                  Navigator.pushNamed(context, '/history'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSmallActionCard(
                              icon: Icons.chat_bubble_rounded,
                              title: AppStrings.get('handybot', language),
                              gradient: [ModernTheme.secondaryPurple, Color(0xFF9333EA)],
                              onTap: () =>
                                  Navigator.pushNamed(context, '/handybot'),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _buildSmallActionCard(
                              icon: Icons.settings_rounded,
                              title: AppStrings.get('settings', language),
                              gradient: [ModernTheme.textMedium, ModernTheme.textLight],
                              onTap: () =>
                                  Navigator.pushNamed(context, '/settings'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSmallActionCard(
                              icon: Icons.info_outline_rounded,
                              title: AppStrings.get('about', language),
                              gradient: [ModernTheme.infoCyan, ModernTheme.primaryBlue],
                              onTap: () => Navigator.pushNamed(context, '/about'),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Footer
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'En-HanZ',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: ModernTheme.primaryBlue,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'AI-Powered Dysgraphia Detection',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: ModernTheme.textMedium,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Profile? profile) {
    final childName = profile?.name ?? 'Student';
    final age = profile?.age ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: ModernTheme.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: ModernTheme.coloredShadow(
                ModernTheme.primaryBlue,
                opacity: 0.3,
              ),
            ),
            child: Center(
              child: Text(
                childName.isNotEmpty ? childName[0].toUpperCase() : 'S',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back!',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: ModernTheme.textMedium,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  childName,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: ModernTheme.textDark,
                  ),
                ),
                if (age > 0)
                  Text(
                    'Age: $age years',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: ModernTheme.textMedium,
                    ),
                  ),
              ],
            ),
          ),
          Icon(Icons.waving_hand, color: ModernTheme.accentAmber, size: 28),
        ],
      ),
    );
  }

  Widget _buildAssessmentCard(
    String riskLevel,
    Color riskColor,
    IconData riskIcon,
    double riskScore,
    int iqScore,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: ModernTheme.resultsGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: ModernTheme.elevation3(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                'Latest Assessment',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(riskIcon, color: Colors.white, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        riskLevel,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${riskScore.toInt()}% Risk',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.psychology_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'IQ Score',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '$iqScore',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationalQuote() {
    final appState = Provider.of<AppState>(context, listen: false);
    final language = appState.settings.language;
    final quoteText = AppStrings.get('motivational_quote', language);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ModernTheme.accentAmber.withValues(alpha: 0.1),
            ModernTheme.accentAmber.withValues(alpha: 0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: ModernTheme.coloredShadow(
          ModernTheme.accentAmber,
          opacity: 0.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ModernTheme.accentAmber,
                  ModernTheme.accentAmberDark,
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: ModernTheme.coloredShadow(
                ModernTheme.accentAmber,
                opacity: 0.3,
              ),
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Motivation',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: ModernTheme.accentAmberDark,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  quoteText,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: ModernTheme.textDark,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBigActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String emoji,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(24),
          boxShadow: ModernTheme.coloredShadow(
            gradient[0],
            opacity: 0.4,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(emoji, style: TextStyle(fontSize: 32)),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallActionCard({
    required IconData icon,
    required String title,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(20),
          boxShadow: ModernTheme.coloredShadow(
            gradient[0],
            opacity: 0.3,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
