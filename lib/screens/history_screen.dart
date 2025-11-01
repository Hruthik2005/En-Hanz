import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/report_service.dart';
import '../services/child_profile_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  final _authService = AuthService();
  final _reportService = ReportService();
  final _childProfileService = ChildProfileService();
  Map<String, List<Map<String, dynamic>>> _assessmentsByChild = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
    _loadAssessments();
  }

  Future<void> _loadAssessments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = _authService.currentUserId;
      if (userId != null) {
        // Get all reports for this teacher (includes reports with or without childProfileId)
        final reports = await _reportService.getUserReports(userId);

        debugPrint('📊 Found ${reports.length} reports for teacher');

        // Group assessments by child name
        final Map<String, List<Map<String, dynamic>>> assessmentsByChild = {};

        for (var report in reports) {
          debugPrint(
            '📄 Processing report: ${report.id}, childProfileId: ${report.childProfileId}',
          );

          // Get child name
          String childName = 'Unknown Child';
          if (report.childProfileId != null) {
            try {
              final childProfile = await _childProfileService.getChildProfile(
                report.childProfileId!,
              );
              if (childProfile != null) {
                childName = childProfile.childName;
              }
            } catch (e) {
              debugPrint('❌ Error loading child profile: $e');
            }
          }

          // Parse risk score from label or use default
          double riskScore = 0.5;
          if (report.overallRiskLabel.toLowerCase().contains('low')) {
            riskScore = 0.3;
          } else if (report.overallRiskLabel.toLowerCase().contains(
            'moderate',
          )) {
            riskScore = 0.5;
          } else if (report.overallRiskLabel.toLowerCase().contains('high')) {
            riskScore = 0.7;
          }

          // Try to get IQ score from the linked IQ result
          int iqScore = 100; // Default
          if (report.iqResultId != null) {
            try {
              final iqResult = await _reportService.getIQResult(
                report.iqResultId!,
              );
              if (iqResult != null) {
                iqScore = iqResult.iqValue.round();
                debugPrint('✅ Got IQ score: $iqScore for $childName');
              }
            } catch (e) {
              debugPrint('❌ Error loading IQ result: $e');
            }
          }

          // Add to the child's assessment list
          if (!assessmentsByChild.containsKey(childName)) {
            assessmentsByChild[childName] = [];
          }

          assessmentsByChild[childName]!.add({
            'date': report.reportDate,
            'risk': riskScore,
            'iq': iqScore,
            'recommendation': report.overallFeedback,
            'reportId': report.id,
            'childName': childName,
          });
        }

        // Sort each child's assessments by date (most recent first)
        assessmentsByChild.forEach((childName, assessments) {
          assessments.sort(
            (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime),
          );
        });

        debugPrint(
          '✅ Loaded assessments for ${assessmentsByChild.length} children',
        );

        setState(() {
          _assessmentsByChild = assessmentsByChild;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading assessments: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Color _getRiskColor(double risk) {
    if (risk < 0.4) return Color(0xFF4CAF50);
    if (risk < 0.7) return Color(0xFFFF9800);
    return Color(0xFFF44336);
  }

  String _getRiskLabel(double risk) {
    if (risk < 0.4) return 'Low Risk';
    if (risk < 0.7) return 'Moderate';
    return 'High Risk';
  }

  IconData _getRiskIcon(double risk) {
    if (risk < 0.4) return Icons.check_circle;
    if (risk < 0.7) return Icons.warning;
    return Icons.error;
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
                _buildHeader(),

                // Content
                Expanded(
                  child: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF1565C0),
                          ),
                        )
                      : _assessmentsByChild.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(24),
                          itemCount: _assessmentsByChild.length,
                          itemBuilder: (context, index) {
                            final childName = _assessmentsByChild.keys
                                .elementAt(index);
                            final assessments = _assessmentsByChild[childName]!;
                            return _buildChildSection(
                              childName,
                              assessments,
                              index,
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Color(0xFFE3F2FD),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: Color(0xFF1565C0)),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assessment History',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1565C0),
                  ),
                ),
                Text(
                  'Track progress by child',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Color(0xFFE3F2FD),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.refresh_rounded, color: Color(0xFF1565C0)),
              onPressed: _loadAssessments,
              tooltip: 'Refresh',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Icon(
              Icons.assignment_outlined,
              color: Colors.grey.shade400,
              size: 64,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Assessments Yet',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete your first test to see\nyour progress history here',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/child_selection'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1565C0),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Start New Test',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildSection(
    String childName,
    List<Map<String, dynamic>> assessments,
    int sectionIndex,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Child name header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: EdgeInsets.only(bottom: 16, top: sectionIndex > 0 ? 24 : 0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF1565C0).withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  childName,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${assessments.length} test${assessments.length != 1 ? 's' : ''}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Assessment cards for this child
        ...assessments.asMap().entries.map((entry) {
          final index = entry.key;
          final assessment = entry.value;
          return _buildAssessmentCard(assessment, index, assessments.length);
        }),
      ],
    );
  }

  Widget _buildAssessmentCard(
    Map<String, dynamic> assessment,
    int index,
    int totalCount,
  ) {
    final date = assessment['date'] as DateTime;
    final risk = assessment['risk'] as double;
    final iq = assessment['iq'] as int;
    final recommendation = assessment['recommendation'] as String;
    final riskColor = _getRiskColor(risk);
    final riskLabel = _getRiskLabel(risk);
    final riskIcon = _getRiskIcon(risk);

    return Container(
      margin: EdgeInsets.only(bottom: index < totalCount - 1 ? 16 : 0),
      child: InkWell(
        onTap: () {
          _showDetailDialog(assessment);
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: riskColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(riskIcon, color: riskColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${date.day}/${date.month}/${date.year}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        Text(
                          _getTimeAgo(date),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: riskColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      riskLabel,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(
                      Icons.show_chart,
                      'Risk: ${(risk * 100).toInt()}%',
                      riskColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoChip(
                      Icons.psychology_rounded,
                      'IQ: $iq',
                      Color(0xFF1565C0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Colors.grey.shade400,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      recommendation,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else {
      return '${(difference.inDays / 30).floor()} months ago';
    }
  }

  void _showDetailDialog(Map<String, dynamic> assessment) {
    final date = assessment['date'] as DateTime;
    final risk = assessment['risk'] as double;
    final iq = assessment['iq'] as int;
    final recommendation = assessment['recommendation'] as String;
    final childName = assessment['childName'] as String? ?? 'Unknown Child';
    final riskColor = _getRiskColor(risk);
    final riskLabel = _getRiskLabel(risk);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Assessment Details',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1565C0),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: riskColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Icon(_getRiskIcon(risk), color: riskColor, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      riskLabel,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: riskColor,
                      ),
                    ),
                    Text(
                      '${(risk * 100).toInt()}% Risk Score',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildDetailRow('Child Name', childName),
              _buildDetailRow('Date', '${date.day}/${date.month}/${date.year}'),
              _buildDetailRow('IQ Score', '$iq'),
              const SizedBox(height: 16),
              Text(
                'Recommendation',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                recommendation,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1565C0),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade600),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
