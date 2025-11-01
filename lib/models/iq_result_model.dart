import 'package:cloud_firestore/cloud_firestore.dart';

class IQResultModel {
  final String? id;
  final String userId; // Teacher/Parent user ID
  final String? childProfileId; // Child profile ID
  final int totalScore;
  final double mentalAge;
  final double iqValue;
  final DateTime testDate;

  IQResultModel({
    this.id,
    required this.userId,
    this.childProfileId,
    required this.totalScore,
    required this.mentalAge,
    required this.iqValue,
    required this.testDate,
  });

  // Convert IQResultModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'child_profile_id': childProfileId,
      'total_score': totalScore,
      'mental_age': mentalAge,
      'iq_value': iqValue,
      'test_date': Timestamp.fromDate(testDate),
    };
  }

  // Create IQResultModel from Firestore document
  factory IQResultModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    return IQResultModel(
      id: docId,
      userId: json['user_id'] as String,
      childProfileId: json['child_profile_id'] as String?,
      totalScore: json['total_score'] as int,
      mentalAge: (json['mental_age'] as num).toDouble(),
      iqValue: (json['iq_value'] as num).toDouble(),
      testDate: (json['test_date'] as Timestamp).toDate(),
    );
  }

  // Create IQResultModel from Firestore DocumentSnapshot
  factory IQResultModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return IQResultModel.fromJson(data, docId: doc.id);
  }

  // Copy with method for updates
  IQResultModel copyWith({
    String? id,
    String? userId,
    String? childProfileId,
    int? totalScore,
    double? mentalAge,
    double? iqValue,
    DateTime? testDate,
  }) {
    return IQResultModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      childProfileId: childProfileId ?? this.childProfileId,
      totalScore: totalScore ?? this.totalScore,
      mentalAge: mentalAge ?? this.mentalAge,
      iqValue: iqValue ?? this.iqValue,
      testDate: testDate ?? this.testDate,
    );
  }
}
