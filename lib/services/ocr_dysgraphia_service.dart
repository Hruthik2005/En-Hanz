import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// OCR-based dysgraphia detection service
/// Uses handwriting recognition confidence to determine dysgraphia risk
/// Low recognition confidence = Poor handwriting = High dysgraphia risk
class OCRDysgraphiaService {
  static final TextRecognizer _textRecognizer = TextRecognizer();

  /// Analyze handwriting using OCR recognition confidence
  static Future<Map<String, dynamic>> analyzeHandwriting(File imageFile) async {
    try {
      debugPrint('🔍 Starting OCR-based handwriting analysis...');

      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      if (recognizedText.text.isEmpty) {
        debugPrint('⚠️ No text recognized - very poor handwriting');
        return {
          'riskScore': 0.95,
          'riskPercentage': 95,
          'riskLevel': 'HIGH',
          'recommendation': _generateRecommendation(0.95),
          'recognizedText': '',
          'confidence': 0.05,
          'textBlocks': 0,
          'analysisDetails': {
            'textRecognized': false,
            'reason': 'No readable text detected',
          },
        };
      }

      // Analyze confidence scores from text blocks
      final analysis = _analyzeTextBlocks(recognizedText);
      final riskScore = _calculateRiskScore(analysis);
      final riskPercentage = (riskScore * 100).toInt();

      debugPrint('✅ OCR Analysis complete:');
      debugPrint('   - Recognized: ${recognizedText.text.substring(0, recognizedText.text.length > 50 ? 50 : recognizedText.text.length)}...');
      debugPrint('   - Blocks: ${analysis['blockCount']}');
      debugPrint('   - Avg Confidence: ${(analysis['avgConfidence'] * 100).toInt()}%');
      debugPrint('   - Risk Score: $riskPercentage%');

      return {
        'riskScore': riskScore,
        'riskPercentage': riskPercentage,
        'riskLevel': _getRiskLevel(riskScore),
        'recommendation': _generateRecommendation(riskScore),
        'recognizedText': recognizedText.text,
        'confidence': analysis['avgConfidence'],
        'textBlocks': analysis['blockCount'],
        'analysisDetails': analysis,
      };
    } catch (e) {
      debugPrint('❌ OCR Analysis error: $e');
      // Return moderate risk if OCR fails
      return {
        'riskScore': 0.5,
        'riskPercentage': 50,
        'riskLevel': 'MODERATE',
        'recommendation': 'Unable to analyze handwriting completely. Please try with better lighting.',
        'recognizedText': '',
        'confidence': 0.5,
        'textBlocks': 0,
        'analysisDetails': {
          'error': e.toString(),
        },
      };
    }
  }

  /// Analyze text blocks and calculate metrics
  static Map<String, dynamic> _analyzeTextBlocks(RecognizedText recognizedText) {
    final blocks = recognizedText.blocks;
    
    if (blocks.isEmpty) {
      return {
        'blockCount': 0,
        'avgConfidence': 0.0,
        'lineCount': 0,
        'wordCount': 0,
        'consistencyScore': 0.0,
      };
    }

    // Collect confidence scores (ML Kit doesn't provide direct confidence,
    // so we'll use other metrics as proxies)
    int totalWords = 0;
    int totalLines = 0;
    final List<int> wordLengths = [];
    final List<double> lineHeights = [];
    final List<double> wordSpacings = [];

    for (final block in blocks) {
      for (final line in block.lines) {
        totalLines++;
        lineHeights.add(line.boundingBox.height.toDouble());
        
        final words = line.elements;
        totalWords += words.length;
        
        for (int i = 0; i < words.length; i++) {
          wordLengths.add(words[i].text.length);
          
          // Calculate spacing between words
          if (i < words.length - 1) {
            final spacing = words[i + 1].boundingBox.left - words[i].boundingBox.right;
            wordSpacings.add(spacing.toDouble());
          }
        }
      }
    }

    // Calculate consistency metrics (good handwriting = consistent)
    final wordLengthConsistency = _calculateConsistency(wordLengths.map((e) => e.toDouble()).toList());
    final lineHeightConsistency = _calculateConsistency(lineHeights);
    final spacingConsistency = wordSpacings.isNotEmpty ? _calculateConsistency(wordSpacings) : 0.75; // More generous default

    // Estimate confidence based on consistency and structure
    final structureScore = (wordLengthConsistency + lineHeightConsistency + spacingConsistency) / 3;
    
    // Text density (more text recognized = better handwriting)
    final textDensity = totalWords / (blocks.length + 1);
    final densityScore = (textDensity / 6).clamp(0.0, 1.0); // Normalize to 6 words instead of 8 (more lenient)
    
    // Combined confidence - very generous
    // Start with higher base confidence if any text is found
    final baseConfidence = totalWords > 0 ? 0.5 : 0.0; // Start at 50% if any text found (increased)
    final avgConfidence = (baseConfidence + structureScore * 0.35 + densityScore * 0.15).clamp(0.0, 1.0);

    return {
      'blockCount': blocks.length,
      'lineCount': totalLines,
      'wordCount': totalWords,
      'avgConfidence': avgConfidence,
      'consistencyScore': structureScore,
      'densityScore': densityScore,
      'wordLengthConsistency': wordLengthConsistency,
      'lineHeightConsistency': lineHeightConsistency,
      'spacingConsistency': spacingConsistency,
    };
  }

  /// Calculate consistency score (1.0 = very consistent, 0.0 = very inconsistent)
  static double _calculateConsistency(List<double> values) {
    if (values.isEmpty || values.length < 2) return 0.7; // Default to decent if not enough data

    final mean = values.reduce((a, b) => a + b) / values.length;
    if (mean == 0) return 0.7;

    final variance = values.map((v) => (v - mean) * (v - mean)).reduce((a, b) => a + b) / values.length;
    final stdDev = variance > 0 ? variance.abs() : 0.0;
    final cv = stdDev / mean.abs(); // Coefficient of variation

    // Lower CV = higher consistency
    // Good handwriting typically has CV < 0.3
    // Poor handwriting has CV > 0.5
    final consistencyScore = (1.0 - (cv * 2.0)).clamp(0.0, 1.0);
    
    return consistencyScore;
  }

  /// Calculate dysgraphia risk score from OCR analysis
  /// High text recognition & good structure = Low risk
  /// Low text recognition & poor structure = High risk
  static double _calculateRiskScore(Map<String, dynamic> analysis) {
    final confidence = analysis['avgConfidence'] as double;
    final consistencyScore = analysis['consistencyScore'] as double;
    final blockCount = analysis['blockCount'] as int;
    final wordCount = analysis['wordCount'] as int;

    // If NO text recognized at all, high risk
    if (blockCount == 0 || wordCount == 0) {
      return 0.85; // 85% risk (reduced from 90%)
    }

    // SPECIAL CASE: For very short samples (like just a name),
    // if ML Kit recognized it successfully, assume GOOD handwriting
    if (wordCount <= 5 && blockCount >= 1) {
      // Successfully recognized a short text = good quality, low risk
      return 0.25; // 25% risk (reduced from 40%) - more lenient
    }

    // Key insight: If ML Kit successfully recognizes text,
    // the handwriting is READABLE = Lower risk

    // Generous base success score - recognizing ANY text is good
    final baseSuccess = wordCount > 0 ? 0.6 : 0.0; // 60% quality (increased from 50%)
    
    // More generous word scoring (cap at 12 words instead of 15)
    final wordScore = (wordCount / 12.0).clamp(0.0, 1.0);
    
    // Boost confidence score (make it more forgiving)
    final recognitionQuality = (confidence * 1.2).clamp(0.0, 1.0); // Boost by 20%
    
    // Boost structure quality (make it more forgiving)
    final structureQuality = (consistencyScore * 1.15).clamp(0.0, 1.0); // Boost by 15%

    // Calculate QUALITY score (higher = better handwriting)
    // Give even more weight to successfully recognizing text
    final overallQuality = (
      baseSuccess * 0.35 +           // 35% just for recognizing anything (increased)
      recognitionQuality * 0.35 +    // 35% for confidence (increased)
      structureQuality * 0.15 +      // 15% for structure (decreased)
      wordScore * 0.15               // 15% for word count (decreased)
    ).clamp(0.0, 1.0);

    // Convert quality to risk (invert: high quality = low risk)
    // Apply a reduction factor to make it even more lenient
    final riskScore = ((1.0 - overallQuality) * 0.85).clamp(0.0, 1.0); // Reduce risk by 15%

    return riskScore;
  }

  /// Get risk level category
  static String _getRiskLevel(double riskScore) {
    if (riskScore < 0.3) return 'LOW';
    if (riskScore < 0.5) return 'MILD';
    if (riskScore < 0.7) return 'MODERATE';
    return 'HIGH';
  }

  /// Generate recommendation based on risk score
  static String _generateRecommendation(double riskScore) {
    if (riskScore < 0.3) {
      return '✅ Excellent! Your handwriting is clear and easy to read.\n\n'
          '• Text recognition: Excellent\n'
          '• Legibility: Very Good\n'
          '• Keep up the great work!\n'
          '• Continue daily practice to maintain quality';
    }

    if (riskScore < 0.5) {
      return '📝 Good Progress! Minor improvements needed.\n\n'
          '• Text recognition: Good\n'
          '• Legibility: Acceptable\n'
          '• Focus on letter spacing\n'
          '• Practice consistent letter sizes\n'
          '• Try our tracing games for 10 min/day';
    }

    if (riskScore < 0.7) {
      return '⚠️ Moderate Difficulties Detected\n\n'
          '• Text recognition: Fair\n'
          '• Legibility: Needs improvement\n'
          '• Recommendations:\n'
          '  - Practice letter formation daily (15 min)\n'
          '  - Use lined paper with guides\n'
          '  - Slow down your writing pace\n'
          '  - Try our guided practice modules\n'
          '  - Focus on one letter at a time';
    }

    return '🚨 Significant Challenges Detected\n\n'
        '• Text recognition: Poor\n'
        '• Legibility: Difficult to read\n'
        '• Action Plan:\n'
        '  - Consider occupational therapy consultation\n'
        '  - Daily guided practice (20 min minimum)\n'
        '  - Use adaptive writing tools\n'
        '  - Break writing into short sessions\n'
        '  - Practice basic strokes before letters\n'
        '  - Focus on grip and posture\n\n'
        '💡 Early intervention makes a big difference!';
  }

  /// Dispose resources
  static void dispose() {
    _textRecognizer.close();
    debugPrint('🗑️ OCR Text Recognizer disposed');
  }
}
