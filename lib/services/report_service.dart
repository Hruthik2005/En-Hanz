import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/report_model.dart';
import '../models/iq_result_model.dart';
import '../models/handwriting_analysis_model.dart';
import 'iq_service.dart';
import 'handwriting_service.dart';

class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'reports';
  final IQService _iqService = IQService();
  final HandwritingService _handwritingService = HandwritingService();

  // Generate comprehensive report combining IQ and handwriting analysis
  Future<String> generateReport({
    required String userId,
    String? childProfileId,
    String? iqResultId,
    String? handwritingId,
  }) async {
    try {
      // Fetch latest IQ result if not provided
      IQResultModel? iqResult;
      if (iqResultId != null) {
        iqResult = await _iqService.getIQResult(iqResultId);
      } else {
        iqResult = await _iqService.getLatestIQResult(userId);
      }

      // Fetch latest handwriting analysis if not provided
      HandwritingAnalysisModel? handwritingAnalysis;
      if (handwritingId != null) {
        handwritingAnalysis = await _handwritingService.getAnalysis(
          handwritingId,
        );
      } else {
        handwritingAnalysis = await _handwritingService.getLatestAnalysis(
          userId,
        );
      }

      // Determine overall risk label
      String overallRiskLabel = 'Low';
      String overallFeedback = '';

      if (iqResult != null && handwritingAnalysis != null) {
        // Combine IQ and handwriting risk
        final iqRisk = _getIQRiskLevel(iqResult.iqValue);
        final handwritingRisk = handwritingAnalysis.riskLabel;

        // Determine overall risk
        if (iqRisk == 'High' || handwritingRisk == 'High') {
          overallRiskLabel = 'High';
        } else if (iqRisk == 'Moderate' || handwritingRisk == 'Moderate') {
          overallRiskLabel = 'Moderate';
        } else {
          overallRiskLabel = 'Low';
        }

        // Generate feedback
        overallFeedback = _generateFeedback(
          iqValue: iqResult.iqValue,
          riskScore: handwritingAnalysis.riskScore,
          overallRiskLabel: overallRiskLabel,
        );
      } else if (iqResult != null) {
        // Only IQ result available
        final iqRisk = _getIQRiskLevel(iqResult.iqValue);
        overallRiskLabel = iqRisk;
        overallFeedback =
            'IQ Score: ${iqResult.iqValue.toStringAsFixed(1)}. '
            'Please complete handwriting analysis for a comprehensive assessment.';
      } else if (handwritingAnalysis != null) {
        // Only handwriting analysis available
        overallRiskLabel = handwritingAnalysis.riskLabel;
        overallFeedback =
            'Handwriting Risk: ${handwritingAnalysis.riskLabel}. '
            'Please complete IQ test for a comprehensive assessment.';
      } else {
        // No data available
        overallFeedback =
            'No assessment data available. Please complete IQ test and handwriting analysis.';
      }

      // Create and save report
      final report = ReportModel(
        userId: userId,
        childProfileId: childProfileId,
        iqResultId: iqResult?.id,
        handwritingId: handwritingAnalysis?.id,
        overallRiskLabel: overallRiskLabel,
        overallFeedback: overallFeedback,
        reportDate: DateTime.now(),
      );

      final docRef = await _firestore
          .collection(_collection)
          .add(report.toJson());
      debugPrint('✅ Report generated: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Error generating report: $e');
      rethrow;
    }
  }

  // Get report by ID
  Future<ReportModel?> getReport(String reportId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(reportId).get();
      if (doc.exists) {
        return ReportModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting report: $e');
      rethrow;
    }
  }

  // Get all reports for a specific user
  Future<List<ReportModel>> getUserReports(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('user_id', isEqualTo: userId)
          .get();

      // Sort in memory to avoid needing a composite index
      final reports = snapshot.docs
          .map((doc) => ReportModel.fromFirestore(doc))
          .toList();
      reports.sort((a, b) => b.reportDate.compareTo(a.reportDate));

      return reports;
    } catch (e) {
      debugPrint('❌ Error getting user reports: $e');
      rethrow;
    }
  }

  // Get all reports for a specific child profile
  Future<List<ReportModel>> getChildProfileReports(
    String childProfileId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('child_profile_id', isEqualTo: childProfileId)
          .get();

      // Sort in memory to avoid needing a composite index
      final reports = snapshot.docs
          .map((doc) => ReportModel.fromFirestore(doc))
          .toList();
      reports.sort((a, b) => b.reportDate.compareTo(a.reportDate));

      return reports;
    } catch (e) {
      debugPrint('❌ Error getting child profile reports: $e');
      rethrow;
    }
  }

  // Stream user reports (real-time updates)
  // Note: Results are not sorted to avoid composite index requirement
  // Sort the list manually after receiving it if needed
  Stream<List<ReportModel>> streamUserReports(String userId) {
    return _firestore
        .collection(_collection)
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final reports = snapshot.docs
              .map((doc) => ReportModel.fromFirestore(doc))
              .toList();
          // Sort in memory
          reports.sort((a, b) => b.reportDate.compareTo(a.reportDate));
          return reports;
        });
  }

  // Get latest report for a user
  Future<ReportModel?> getLatestReport(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('user_id', isEqualTo: userId)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      // Sort in memory to avoid needing a composite index
      final reports = snapshot.docs
          .map((doc) => ReportModel.fromFirestore(doc))
          .toList();
      reports.sort((a, b) => b.reportDate.compareTo(a.reportDate));

      return reports.first;
    } catch (e) {
      debugPrint('❌ Error getting latest report: $e');
      rethrow;
    }
  }

  // Delete report
  Future<void> deleteReport(String reportId) async {
    try {
      await _firestore.collection(_collection).doc(reportId).delete();
      debugPrint('✅ Report deleted: $reportId');
    } catch (e) {
      debugPrint('❌ Error deleting report: $e');
      rethrow;
    }
  }

  // Helper: Get IQ risk level
  String _getIQRiskLevel(double iqValue) {
    if (iqValue >= 90) return 'Low';
    if (iqValue >= 70) return 'Moderate';
    return 'High';
  }

  // Helper: Generate detailed feedback
  String _generateFeedback({
    required double iqValue,
    required double riskScore,
    required String overallRiskLabel,
  }) {
    final StringBuffer feedback = StringBuffer();

    // IQ feedback
    feedback.writeln('IQ Assessment: ${iqValue.toStringAsFixed(1)}');
    if (iqValue >= 90) {
      feedback.writeln('Cognitive abilities are within normal range.');
    } else if (iqValue >= 70) {
      feedback.writeln('Some cognitive support may be beneficial.');
    } else {
      feedback.writeln('Additional cognitive intervention recommended.');
    }

    feedback.writeln();

    // Handwriting feedback
    feedback.writeln(
      'Handwriting Risk Score: ${(riskScore * 100).toStringAsFixed(0)}%',
    );
    if (riskScore < 0.3) {
      feedback.writeln('Handwriting shows typical development patterns.');
    } else if (riskScore < 0.7) {
      feedback.writeln('Handwriting shows some signs that warrant monitoring.');
    } else {
      feedback.writeln(
        'Handwriting patterns suggest professional evaluation may be helpful.',
      );
    }

    feedback.writeln();

    // Overall recommendation
    feedback.writeln('Overall Assessment: $overallRiskLabel Risk');
    switch (overallRiskLabel) {
      case 'Low':
        feedback.writeln(
          'Continue regular developmental monitoring and practice activities.',
        );
        break;
      case 'Moderate':
        feedback.writeln(
          'Consider additional support through practice games and exercises. '
          'Regular progress monitoring recommended.',
        );
        break;
      case 'High':
        feedback.writeln(
          'Professional consultation recommended. '
          'Use practice activities consistently and track progress closely.',
        );
        break;
    }

    return feedback.toString();
  }

  // Get report statistics
  Future<Map<String, dynamic>> getReportStatistics(String userId) async {
    try {
      final reports = await getUserReports(userId);

      if (reports.isEmpty) {
        return {
          'count': 0,
          'lowRisk': 0,
          'moderateRisk': 0,
          'highRisk': 0,
          'trend': 'No data',
        };
      }

      int lowCount = 0, moderateCount = 0, highCount = 0;
      for (final report in reports) {
        switch (report.overallRiskLabel) {
          case 'Low':
            lowCount++;
            break;
          case 'Moderate':
            moderateCount++;
            break;
          case 'High':
            highCount++;
            break;
        }
      }

      return {
        'count': reports.length,
        'lowRisk': lowCount,
        'moderateRisk': moderateCount,
        'highRisk': highCount,
        'latestRisk': reports.first.overallRiskLabel,
      };
    } catch (e) {
      debugPrint('❌ Error getting report statistics: $e');
      rethrow;
    }
  }

  // Helper method to get IQ result (exposed for history screen)
  Future<IQResultModel?> getIQResult(String iqResultId) async {
    return await _iqService.getIQResult(iqResultId);
  }

  // Helper method to get handwriting analysis (exposed for history screen)
  Future<HandwritingAnalysisModel?> getHandwritingAnalysis(
    String handwritingId,
  ) async {
    return await _handwritingService.getAnalysis(handwritingId);
  }
}
