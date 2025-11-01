import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/child_profile_model.dart';

/// Service for managing child profiles
/// Each teacher can create and manage multiple child profiles
class ChildProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'child_profiles';

  // Create a new child profile
  Future<String> createChildProfile(ChildProfileModel profile) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(profile.toJson());
      debugPrint(
        '✅ Child profile created: ${docRef.id} for ${profile.childName}',
      );
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Error creating child profile: $e');
      rethrow;
    }
  }

  // Get a specific child profile by ID
  Future<ChildProfileModel?> getChildProfile(String profileId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(profileId).get();
      if (doc.exists) {
        return ChildProfileModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting child profile: $e');
      rethrow;
    }
  }

  // Get all child profiles for a teacher
  Future<List<ChildProfileModel>> getTeacherChildProfiles(
    String teacherId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('teacher_id', isEqualTo: teacherId)
          .get();

      final profiles = snapshot.docs
          .map((doc) => ChildProfileModel.fromFirestore(doc))
          .toList();

      // Sort in memory to avoid requiring a composite index
      profiles.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      debugPrint(
        '✅ Found ${profiles.length} child profiles for teacher $teacherId',
      );
      return profiles;
    } catch (e) {
      debugPrint('❌ Error getting teacher child profiles: $e');
      rethrow;
    }
  }

  // Stream child profiles for real-time updates
  Stream<List<ChildProfileModel>> streamTeacherChildProfiles(String teacherId) {
    return _firestore
        .collection(_collection)
        .where('teacher_id', isEqualTo: teacherId)
        .snapshots()
        .map((snapshot) {
          final profiles = snapshot.docs
              .map((doc) => ChildProfileModel.fromFirestore(doc))
              .toList();

          // Sort in memory to avoid requiring a composite index
          profiles.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return profiles;
        });
  }

  // Update a child profile
  Future<void> updateChildProfile(
    String profileId,
    ChildProfileModel profile,
  ) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(profileId)
          .update(profile.toJson());
      debugPrint('✅ Child profile updated: $profileId');
    } catch (e) {
      debugPrint('❌ Error updating child profile: $e');
      rethrow;
    }
  }

  // Update last assessment date
  Future<void> updateLastAssessmentDate(String profileId, DateTime date) async {
    try {
      await _firestore.collection(_collection).doc(profileId).update({
        'last_assessment_date': Timestamp.fromDate(date),
      });
      debugPrint('✅ Updated last assessment date for profile: $profileId');
    } catch (e) {
      debugPrint('❌ Error updating last assessment date: $e');
      rethrow;
    }
  }

  // Delete a child profile
  Future<void> deleteChildProfile(String profileId) async {
    try {
      await _firestore.collection(_collection).doc(profileId).delete();
      debugPrint('✅ Child profile deleted: $profileId');
    } catch (e) {
      debugPrint('❌ Error deleting child profile: $e');
      rethrow;
    }
  }

  // Search child profiles by name
  Future<List<ChildProfileModel>> searchChildProfiles(
    String teacherId,
    String searchQuery,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('teacher_id', isEqualTo: teacherId)
          .get();

      final profiles = snapshot.docs
          .map((doc) => ChildProfileModel.fromFirestore(doc))
          .where(
            (profile) => profile.childName.toLowerCase().contains(
              searchQuery.toLowerCase(),
            ),
          )
          .toList();

      return profiles;
    } catch (e) {
      debugPrint('❌ Error searching child profiles: $e');
      rethrow;
    }
  }

  // Get statistics for a teacher
  Future<Map<String, dynamic>> getTeacherStatistics(String teacherId) async {
    try {
      final profiles = await getTeacherChildProfiles(teacherId);

      int totalChildren = profiles.length;
      int assessedChildren = profiles
          .where((p) => p.lastAssessmentDate != null)
          .length;

      // Age distribution
      Map<String, int> ageGroups = {'3-5': 0, '6-8': 0, '9-12': 0, '13+': 0};

      for (var profile in profiles) {
        if (profile.age <= 5) {
          ageGroups['3-5'] = (ageGroups['3-5'] ?? 0) + 1;
        } else if (profile.age <= 8) {
          ageGroups['6-8'] = (ageGroups['6-8'] ?? 0) + 1;
        } else if (profile.age <= 12) {
          ageGroups['9-12'] = (ageGroups['9-12'] ?? 0) + 1;
        } else {
          ageGroups['13+'] = (ageGroups['13+'] ?? 0) + 1;
        }
      }

      return {
        'total_children': totalChildren,
        'assessed_children': assessedChildren,
        'pending_assessments': totalChildren - assessedChildren,
        'age_distribution': ageGroups,
      };
    } catch (e) {
      debugPrint('❌ Error getting teacher statistics: $e');
      rethrow;
    }
  }
}
