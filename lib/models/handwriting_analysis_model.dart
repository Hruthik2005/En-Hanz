import 'package:cloud_firestore/cloud_firestore.dart';

class HandwritingAnalysisModel {
  final String? id;
  final String userId; // Teacher/Parent user ID
  final String? childProfileId; // Child profile ID
  final String imageUrl;
  final double riskScore;
  final String recommendation;
  final DateTime analyzedAt;

  HandwritingAnalysisModel({
    this.id,
    required this.userId,
    this.childProfileId,
    required this.imageUrl,
    required this.riskScore,
    required this.recommendation,
    required this.analyzedAt,
  });

  // Convert HandwritingAnalysisModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'child_profile_id': childProfileId,
      'image_url': imageUrl,
      'risk_score': riskScore,
      'recommendation': recommendation,
      'analyzed_at': Timestamp.fromDate(analyzedAt),
    };
  }

  // Create HandwritingAnalysisModel from Firestore document
  factory HandwritingAnalysisModel.fromJson(
    Map<String, dynamic> json, {
    String? docId,
  }) {
    return HandwritingAnalysisModel(
      id: docId,
      userId: json['user_id'] as String,
      childProfileId: json['child_profile_id'] as String?,
      imageUrl: json['image_url'] as String,
      riskScore: (json['risk_score'] as num).toDouble(),
      recommendation: json['recommendation'] as String,
      analyzedAt: (json['analyzed_at'] as Timestamp).toDate(),
    );
  }

  // Create HandwritingAnalysisModel from Firestore DocumentSnapshot
  factory HandwritingAnalysisModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HandwritingAnalysisModel.fromJson(data, docId: doc.id);
  }

  // Get risk level label
  String get riskLabel {
    if (riskScore < 0.3) return 'Low';
    if (riskScore < 0.7) return 'Moderate';
    return 'High';
  }

  // Copy with method for updates
  HandwritingAnalysisModel copyWith({
    String? id,
    String? userId,
    String? childProfileId,
    String? imageUrl,
    double? riskScore,
    String? recommendation,
    DateTime? analyzedAt,
  }) {
    return HandwritingAnalysisModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      childProfileId: childProfileId ?? this.childProfileId,
      imageUrl: imageUrl ?? this.imageUrl,
      riskScore: riskScore ?? this.riskScore,
      recommendation: recommendation ?? this.recommendation,
      analyzedAt: analyzedAt ?? this.analyzedAt,
    );
  }
}
