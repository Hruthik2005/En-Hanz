import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a child profile in the system
/// Each teacher (userId) can have multiple child profiles
class ChildProfileModel {
  final String? id; // Document ID in Firestore
  final String teacherId; // The teacher/parent userId who created this profile
  final String childName;
  final int age;
  final String schoolClass;
  final String gender;
  final List<String> disabilities;
  final String handedness;
  final DateTime createdAt;
  final DateTime? lastAssessmentDate;

  ChildProfileModel({
    this.id,
    required this.teacherId,
    required this.childName,
    required this.age,
    required this.schoolClass,
    required this.gender,
    required this.disabilities,
    required this.handedness,
    required this.createdAt,
    this.lastAssessmentDate,
  });

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'teacher_id': teacherId,
      'child_name': childName,
      'age': age,
      'school_class': schoolClass,
      'gender': gender,
      'disabilities': disabilities,
      'handedness': handedness,
      'created_at': Timestamp.fromDate(createdAt),
      'last_assessment_date': lastAssessmentDate != null
          ? Timestamp.fromDate(lastAssessmentDate!)
          : null,
    };
  }

  // Create from JSON
  factory ChildProfileModel.fromJson(Map<String, dynamic> json, String docId) {
    return ChildProfileModel(
      id: docId,
      teacherId: json['teacher_id'] as String,
      childName: json['child_name'] as String,
      age: json['age'] as int,
      schoolClass: json['school_class'] as String,
      gender: json['gender'] as String,
      disabilities: List<String>.from(json['disabilities'] ?? []),
      handedness: json['handedness'] as String,
      createdAt: (json['created_at'] as Timestamp).toDate(),
      lastAssessmentDate: json['last_assessment_date'] != null
          ? (json['last_assessment_date'] as Timestamp).toDate()
          : null,
    );
  }

  // Create from Firestore DocumentSnapshot
  factory ChildProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChildProfileModel.fromJson(data, doc.id);
  }

  // Copy with method for updates
  ChildProfileModel copyWith({
    String? id,
    String? teacherId,
    String? childName,
    int? age,
    String? schoolClass,
    String? gender,
    List<String>? disabilities,
    String? handedness,
    DateTime? createdAt,
    DateTime? lastAssessmentDate,
  }) {
    return ChildProfileModel(
      id: id ?? this.id,
      teacherId: teacherId ?? this.teacherId,
      childName: childName ?? this.childName,
      age: age ?? this.age,
      schoolClass: schoolClass ?? this.schoolClass,
      gender: gender ?? this.gender,
      disabilities: disabilities ?? this.disabilities,
      handedness: handedness ?? this.handedness,
      createdAt: createdAt ?? this.createdAt,
      lastAssessmentDate: lastAssessmentDate ?? this.lastAssessmentDate,
    );
  }
}
