import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../models/handwriting_analysis_model.dart';

class HandwritingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String _collection = 'handwriting_analysis';
  final String _storagePath = 'handwriting_uploads';

  // Upload handwriting image to Firebase Storage
  Future<String> uploadHandwritingImage({
    required String userId,
    required File imageFile,
  }) async {
    try {
      // Create unique filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${userId}_$timestamp.jpg';
      final storageRef = _storage.ref().child(
        '$_storagePath/$userId/$fileName',
      );

      // Upload file
      debugPrint('📤 Uploading handwriting image: $fileName');
      final uploadTask = await storageRef.putFile(imageFile);

      // Get download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      debugPrint('✅ Handwriting image uploaded: $downloadUrl');

      return downloadUrl;
    } catch (e) {
      debugPrint('❌ Error uploading handwriting image: $e');
      rethrow;
    }
  }

  // Save handwriting analysis result
  Future<String> saveAnalysisResult(HandwritingAnalysisModel analysis) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(analysis.toJson());
      debugPrint('✅ Handwriting analysis saved: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Error saving handwriting analysis: $e');
      rethrow;
    }
  }

  // Upload image and save analysis in one operation
  Future<String> uploadAndSaveAnalysis({
    required String userId,
    required File imageFile,
    required double riskScore,
    required String recommendation,
  }) async {
    try {
      // First upload the image
      final imageUrl = await uploadHandwritingImage(
        userId: userId,
        imageFile: imageFile,
      );

      // Then save the analysis result
      final analysis = HandwritingAnalysisModel(
        userId: userId,
        imageUrl: imageUrl,
        riskScore: riskScore,
        recommendation: recommendation,
        analyzedAt: DateTime.now(),
      );

      return await saveAnalysisResult(analysis);
    } catch (e) {
      debugPrint('❌ Error uploading and saving analysis: $e');
      rethrow;
    }
  }

  // Get handwriting analysis by ID
  Future<HandwritingAnalysisModel?> getAnalysis(String analysisId) async {
    try {
      final doc = await _firestore
          .collection(_collection)
          .doc(analysisId)
          .get();
      if (doc.exists) {
        return HandwritingAnalysisModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting handwriting analysis: $e');
      rethrow;
    }
  }

  // Get all handwriting analyses for a specific user
  Future<List<HandwritingAnalysisModel>> getUserAnalyses(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('user_id', isEqualTo: userId)
          .orderBy('analyzed_at', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => HandwritingAnalysisModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('❌ Error getting user handwriting analyses: $e');
      rethrow;
    }
  }

  // Stream user handwriting analyses (real-time updates)
  Stream<List<HandwritingAnalysisModel>> streamUserAnalyses(String userId) {
    return _firestore
        .collection(_collection)
        .where('user_id', isEqualTo: userId)
        .orderBy('analyzed_at', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => HandwritingAnalysisModel.fromFirestore(doc))
              .toList(),
        );
  }

  // Get latest handwriting analysis for a user
  Future<HandwritingAnalysisModel?> getLatestAnalysis(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('user_id', isEqualTo: userId)
          .orderBy('analyzed_at', descending: true)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        return HandwritingAnalysisModel.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting latest handwriting analysis: $e');
      rethrow;
    }
  }

  // Delete handwriting analysis (and optionally the image)
  Future<void> deleteAnalysis(
    String analysisId, {
    bool deleteImage = true,
  }) async {
    try {
      if (deleteImage) {
        // Get the analysis to retrieve image URL
        final analysis = await getAnalysis(analysisId);
        if (analysis != null) {
          await deleteImageFromUrl(analysis.imageUrl);
        }
      }

      await _firestore.collection(_collection).doc(analysisId).delete();
      debugPrint('✅ Handwriting analysis deleted: $analysisId');
    } catch (e) {
      debugPrint('❌ Error deleting handwriting analysis: $e');
      rethrow;
    }
  }

  // Delete image from Firebase Storage using URL
  Future<void> deleteImageFromUrl(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      debugPrint('✅ Handwriting image deleted from storage');
    } catch (e) {
      debugPrint('❌ Error deleting handwriting image: $e');
      rethrow;
    }
  }

  // Get handwriting statistics for a user
  Future<Map<String, dynamic>> getHandwritingStatistics(String userId) async {
    try {
      final analyses = await getUserAnalyses(userId);

      if (analyses.isEmpty) {
        return {
          'count': 0,
          'averageRisk': 0.0,
          'highestRisk': 0.0,
          'lowestRisk': 0.0,
          'trend': 'No data',
        };
      }

      final riskScores = analyses.map((a) => a.riskScore).toList();
      final average = riskScores.reduce((a, b) => a + b) / riskScores.length;
      final highest = riskScores.reduce((a, b) => a > b ? a : b);
      final lowest = riskScores.reduce((a, b) => a < b ? a : b);

      // Determine trend (improving/worsening)
      String trend = 'Stable';
      if (analyses.length >= 2) {
        final recent = analyses.first.riskScore;
        final previous = analyses[1].riskScore;
        if (recent < previous - 0.1) {
          trend = 'Improving';
        } else if (recent > previous + 0.1) {
          trend = 'Worsening';
        }
      }

      return {
        'count': analyses.length,
        'averageRisk': average,
        'highestRisk': highest,
        'lowestRisk': lowest,
        'trend': trend,
      };
    } catch (e) {
      debugPrint('❌ Error getting handwriting statistics: $e');
      rethrow;
    }
  }
}
