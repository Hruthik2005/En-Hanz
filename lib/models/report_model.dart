import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String? id;
  final String userId; // Teacher/Parent user ID
  final String? childProfileId; // Child profile ID
  final String? iqResultId;
  final String? handwritingId;
  final String overallRiskLabel;
  final String overallFeedback;
  final DateTime reportDate;

  ReportModel({
    this.id,
    required this.userId,
    this.childProfileId,
    this.iqResultId,
    this.handwritingId,
    required this.overallRiskLabel,
    required this.overallFeedback,
    required this.reportDate,
  });

  // Convert ReportModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'child_profile_id': childProfileId,
      'iq_result_id': iqResultId,
      'handwriting_id': handwritingId,
      'overall_risk_label': overallRiskLabel,
      'overall_feedback': overallFeedback,
      'report_date': Timestamp.fromDate(reportDate),
    };
  }

  // Create ReportModel from Firestore document
  factory ReportModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    return ReportModel(
      id: docId,
      userId: json['user_id'] as String,
      childProfileId: json['child_profile_id'] as String?,
      iqResultId: json['iq_result_id'] as String?,
      handwritingId: json['handwriting_id'] as String?,
      overallRiskLabel: json['overall_risk_label'] as String,
      overallFeedback: json['overall_feedback'] as String,
      reportDate: (json['report_date'] as Timestamp).toDate(),
    );
  }

  // Create ReportModel from Firestore DocumentSnapshot
  factory ReportModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReportModel.fromJson(data, docId: doc.id);
  }

  // Copy with method for updates
  ReportModel copyWith({
    String? id,
    String? userId,
    String? childProfileId,
    String? iqResultId,
    String? handwritingId,
    String? overallRiskLabel,
    String? overallFeedback,
    DateTime? reportDate,
  }) {
    return ReportModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      childProfileId: childProfileId ?? this.childProfileId,
      iqResultId: iqResultId ?? this.iqResultId,
      handwritingId: handwritingId ?? this.handwritingId,
      overallRiskLabel: overallRiskLabel ?? this.overallRiskLabel,
      overallFeedback: overallFeedback ?? this.overallFeedback,
      reportDate: reportDate ?? this.reportDate,
    );
  }
}
