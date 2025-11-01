import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../state/app_state.dart';
import '../services/report_service.dart';
import '../models/report_model.dart';
import '../models/iq_result_model.dart';
import '../models/handwriting_analysis_model.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _reportService = ReportService();
  bool _isLoading = true;

  // Report data
  ReportModel? _latestReport;
  IQResultModel? _iqResult;
  HandwritingAnalysisModel? _handwritingAnalysis;
  double _riskScore = 0.0;
  int _iqScore = 0;
  double _mentalAge = 0.0;
  String _recommendation = '';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );
    _loadReportData();
  }

  Future<void> _loadReportData() async {
    try {
      final appState = Provider.of<AppState>(context, listen: false);

      // Get the selected child profile
      final childProfile = appState.selectedChildProfile;

      if (childProfile?.id != null) {
        // Load reports for the selected child
        final reports = await _reportService.getChildProfileReports(
          childProfile!.id!,
        );

        if (reports.isNotEmpty) {
          _latestReport = reports.first;

          // Load IQ result if available
          if (_latestReport!.iqResultId != null) {
            _iqResult = await _reportService.getIQResult(
              _latestReport!.iqResultId!,
            );
            if (_iqResult != null) {
              _iqScore = _iqResult!.iqValue.round();
              _mentalAge = _iqResult!.mentalAge;
            }
          }

          // Load handwriting analysis if available
          if (_latestReport!.handwritingId != null) {
            _handwritingAnalysis = await _reportService.getHandwritingAnalysis(
              _latestReport!.handwritingId!,
            );
            if (_handwritingAnalysis != null) {
              _riskScore = _handwritingAnalysis!.riskScore;
              _recommendation = _handwritingAnalysis!.recommendation;
            }
          }

          // Use report feedback if available
          if (_latestReport!.overallFeedback.isNotEmpty) {
            _recommendation = _latestReport!.overallFeedback;
          }

          debugPrint(
            '✅ Loaded report data for child: ${childProfile.childName}',
          );
          debugPrint('   - Risk Score: $_riskScore');
          debugPrint('   - IQ Score: $_iqScore');
          debugPrint('   - Mental Age: $_mentalAge');
        } else {
          // No reports found, try to get from AppState as fallback
          debugPrint('⚠️ No reports found for child profile, using AppState');
          _riskScore = appState.risk;
          _iqScore = appState.iqScore;
          _mentalAge = appState.mentalAge;
          _recommendation = appState.recommendation;
        }
      } else {
        // No child profile selected, use AppState
        debugPrint('⚠️ No child profile selected, using AppState');
        _riskScore = appState.risk;
        _iqScore = appState.iqScore;
        _mentalAge = appState.mentalAge;
        _recommendation = appState.recommendation;
      }

      setState(() {
        _isLoading = false;
      });

      _animController.forward();
    } catch (e) {
      debugPrint('❌ Error loading report data: $e');
      // Fallback to AppState on error
      final appState = Provider.of<AppState>(context, listen: false);
      setState(() {
        _riskScore = appState.risk;
        _iqScore = appState.iqScore;
        _mentalAge = appState.mentalAge;
        _recommendation = appState.recommendation;
        _isLoading = false;
      });
      _animController.forward();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Color _colorFromRisk(double risk) {
    if (risk < 0.4) return Color(0xFF4CAF50);
    if (risk < 0.7) return Color(0xFFFF9800);
    return Color(0xFFF44336);
  }

  String _riskLabel(double risk) {
    if (risk < 0.4) return 'Low Risk';
    if (risk < 0.7) return 'Moderate Risk';
    return 'High Risk';
  }

  IconData _riskIcon(double risk) {
    if (risk < 0.4) return Icons.check_circle_rounded;
    if (risk < 0.7) return Icons.warning_rounded;
    return Icons.error_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    // Use loaded data if available, otherwise use AppState as fallback
    final risk = _isLoading ? appState.risk : _riskScore;
    final percent = (risk).clamp(0.0, 1.0);
    final iq = _isLoading ? appState.iqScore : _iqScore;
    final mentalAge = _isLoading ? appState.mentalAge : _mentalAge;
    final chronoAge =
        appState.selectedChildProfile?.age ?? appState.profile?.age ?? 0;
    final recommendation = _isLoading
        ? appState.recommendation
        : _recommendation;
    final riskColor = _colorFromRisk(risk);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        }
      },
      child: Scaffold(
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
                            Icons.home_rounded,
                            color: Color(0xFF1565C0),
                          ),
                          onPressed: () => Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/home',
                            (route) => false,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Column(
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [
                                    Color(0xFF1565C0),
                                    Color(0xFF0288D1),
                                  ],
                                ).createShader(bounds),
                                child: Text(
                                  'Assessment Results',
                                  style: GoogleFonts.poppins(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                // Main Content
                Expanded(
                  child: _isLoading
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF1565C0),
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Loading report...',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(36),
                                  topRight: Radius.circular(36),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.12),
                                    blurRadius: 30,
                                    offset: const Offset(0, -8),
                                  ),
                                ],
                              ),
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Column(
                                  children: [
                                    // Risk Score Circle
                                    Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: riskColor.withValues(
                                          alpha: 0.05,
                                        ),
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      child: Column(
                                        children: [
                                          CircularPercentIndicator(
                                            radius: 90.0,
                                            lineWidth: 14.0,
                                            percent: percent,
                                            center: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  _riskIcon(risk),
                                                  color: riskColor,
                                                  size: 48,
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  '${(percent * 100).toInt()}%',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 32,
                                                    fontWeight: FontWeight.w700,
                                                    color: riskColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            backgroundColor:
                                                Colors.grey.shade200,
                                            progressColor: riskColor,
                                            circularStrokeCap:
                                                CircularStrokeCap.round,
                                            animation: true,
                                            animationDuration: 1200,
                                          ),
                                          const SizedBox(height: 20),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              color: riskColor,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: riskColor.withValues(
                                                    alpha: 0.3,
                                                  ),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: Text(
                                              _riskLabel(risk),
                                              style: GoogleFonts.inter(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 24),

                                    // Recommendation Card
                                    _buildInfoCard(
                                      icon: Icons.lightbulb_rounded,
                                      title: 'Recommendation',
                                      content: recommendation,
                                      color: Color(0xFF0288D1),
                                    ),

                                    const SizedBox(height: 16),

                                    // Mental vs Chronological Age
                                    _buildInfoCard(
                                      icon: Icons.psychology_rounded,
                                      title: 'Cognitive Assessment',
                                      color: Color(0xFF1565C0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: _buildAgeBar(
                                              'Chronological',
                                              chronoAge.toDouble(),
                                              Color(0xFF1565C0),
                                              '$chronoAge yrs',
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          Expanded(
                                            child: _buildAgeBar(
                                              'Mental Age',
                                              mentalAge,
                                              Color(0xFF0288D1),
                                              '${mentalAge.toStringAsFixed(1)} yrs',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 16),

                                    // IQ Score Card
                                    _buildInfoCard(
                                      icon: Icons.emoji_events_rounded,
                                      title: 'IQ Score',
                                      color: Color(0xFFFF9800),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '$iq',
                                            style: GoogleFonts.poppins(
                                              fontSize: 48,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFFFF9800),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            '🧠',
                                            style: TextStyle(fontSize: 36),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 32),

                                    // Action Button
                                    TweenAnimationBuilder<double>(
                                      tween: Tween(begin: 0.95, end: 1.0),
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      curve: Curves.easeOut,
                                      builder: (context, value, child) {
                                        return Transform.scale(
                                          scale: value,
                                          child: Container(
                                            height: 56,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Color(0xFF1565C0),
                                                  Color(0xFF0288D1),
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(18),
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
                                            child: ElevatedButton(
                                              onPressed: () =>
                                                  Navigator.pushNamed(
                                                    context,
                                                    '/handybot',
                                                  ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.transparent,
                                                shadowColor: Colors.transparent,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(18),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    '🤖',
                                                    style: TextStyle(
                                                      fontSize: 24,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Text(
                                                    'Ask HandyBot',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Colors.white,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Icon(
                                                    Icons.arrow_forward_rounded,
                                                    color: Colors.white,
                                                    size: 22,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),

                                    const SizedBox(height: 20),
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
      ), // Scaffold
    ); // PopScope
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required Color color,
    String? content,
    Widget? child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          if (content != null) ...[
            const SizedBox(height: 16),
            Text(
              content,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800,
                height: 1.5,
              ),
            ),
          ],
          if (child != null) ...[const SizedBox(height: 16), child],
        ],
      ),
    );
  }

  Widget _buildAgeBar(
    String label,
    double value,
    Color color,
    String displayValue,
  ) {
    final maxHeight = 120.0;
    final height = (value * 8.0).clamp(20.0, maxHeight);

    return Column(
      children: [
        Container(
          height: maxHeight,
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            width: 60,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.6)],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                displayValue,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
