import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String name;
  final int age;
  final String? gender;
  final String? disabilityType;
  final DateTime createdAt;

  UserModel({
    required this.userId,
    required this.name,
    required this.age,
    this.gender,
    this.disabilityType,
    required this.createdAt,
  });

  // Convert UserModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'age': age,
      'gender': gender,
      'disability_type': disabilityType,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  // Create UserModel from Firestore document
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] as String,
      name: json['name'] as String,
      age: json['age'] as int,
      gender: json['gender'] as String?,
      disabilityType: json['disability_type'] as String?,
      createdAt: (json['created_at'] as Timestamp).toDate(),
    );
  }

  // Create UserModel from Firestore DocumentSnapshot
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  // Copy with method for updates
  UserModel copyWith({
    String? userId,
    String? name,
    int? age,
    String? gender,
    String? disabilityType,
    DateTime? createdAt,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      disabilityType: disabilityType ?? this.disabilityType,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
