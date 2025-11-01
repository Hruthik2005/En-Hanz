import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/iq_result_model.dart';

class IQService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'iq_results';

  // Save IQ test result
  Future<String> saveIQResult(IQResultModel result) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(result.toJson());
      debugPrint('✅ IQ result saved: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Error saving IQ result: $e');
      rethrow;
    }
  }

  // Get IQ result by ID
  Future<IQResultModel?> getIQResult(String resultId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(resultId).get();
      if (doc.exists) {
        return IQResultModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting IQ result: $e');
      rethrow;
    }
  }

  // Get all IQ results for a specific user
  Future<List<IQResultModel>> getUserIQResults(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('user_id', isEqualTo: userId)
          .orderBy('test_date', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => IQResultModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('❌ Error getting user IQ results: $e');
      rethrow;
    }
  }

  // Stream user IQ results (real-time updates)
  Stream<List<IQResultModel>> streamUserIQResults(String userId) {
    return _firestore
        .collection(_collection)
        .where('user_id', isEqualTo: userId)
        .orderBy('test_date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => IQResultModel.fromFirestore(doc))
              .toList(),
        );
  }

  // Get latest IQ result for a user
  Future<IQResultModel?> getLatestIQResult(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('user_id', isEqualTo: userId)
          .orderBy('test_date', descending: true)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        return IQResultModel.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting latest IQ result: $e');
      rethrow;
    }
  }

  // Calculate and save IQ score
  Future<String> calculateAndSaveIQ({
    required String userId,
    required int totalScore,
    required int userAge,
    required int totalQuestions,
  }) async {
    try {
      // Calculate mental age based on score
      // Assuming each correct answer = 1 year of mental development
      final mentalAge = (totalScore / totalQuestions) * 18.0; // Max 18 years

      // Calculate IQ: (Mental Age / Chronological Age) × 100
      final iqValue = (mentalAge / userAge) * 100;

      final result = IQResultModel(
        userId: userId,
        totalScore: totalScore,
        mentalAge: mentalAge,
        iqValue: iqValue,
        testDate: DateTime.now(),
      );

      return await saveIQResult(result);
    } catch (e) {
      debugPrint('❌ Error calculating and saving IQ: $e');
      rethrow;
    }
  }

  // Delete IQ result
  Future<void> deleteIQResult(String resultId) async {
    try {
      await _firestore.collection(_collection).doc(resultId).delete();
      debugPrint('✅ IQ result deleted: $resultId');
    } catch (e) {
      debugPrint('❌ Error deleting IQ result: $e');
      rethrow;
    }
  }

  // Get IQ statistics for a user
  Future<Map<String, dynamic>> getIQStatistics(String userId) async {
    try {
      final results = await getUserIQResults(userId);

      if (results.isEmpty) {
        return {
          'count': 0,
          'averageIQ': 0.0,
          'highestIQ': 0.0,
          'lowestIQ': 0.0,
          'trend': 'No data',
        };
      }

      final iqValues = results.map((r) => r.iqValue).toList();
      final average = iqValues.reduce((a, b) => a + b) / iqValues.length;
      final highest = iqValues.reduce((a, b) => a > b ? a : b);
      final lowest = iqValues.reduce((a, b) => a < b ? a : b);

      // Determine trend (improving/declining)
      String trend = 'Stable';
      if (results.length >= 2) {
        final recent = results.first.iqValue;
        final previous = results[1].iqValue;
        if (recent > previous + 5) {
          trend = 'Improving';
        } else if (recent < previous - 5) {
          trend = 'Declining';
        }
      }

      return {
        'count': results.length,
        'averageIQ': average,
        'highestIQ': highest,
        'lowestIQ': lowest,
        'trend': trend,
      };
    } catch (e) {
      debugPrint('❌ Error getting IQ statistics: $e');
      rethrow;
    }
  }
}
