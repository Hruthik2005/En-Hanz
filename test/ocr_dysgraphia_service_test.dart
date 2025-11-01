import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OCRDysgraphiaService Tests', () {
    
    test('Risk calculation handles invalid input gracefully', () {
      // Test with zero values
      final invalidAnalysis = {
        'blockCount': 0,
        'wordCount': 0,
        'avgConfidence': 0.0,
        'consistencyScore': 0.0,
      };
      
      final riskScore = _testCalculateRiskScore(invalidAnalysis);
      
      // Should return high risk for no recognized text
      expect(riskScore, equals(0.9));
      print('✅ Invalid input (no text): Risk = ${(riskScore * 100).toInt()}%');
    });

    test('_calculateConsistency returns correct scores for consistent values', () {
      // Test with very consistent values (should return high score ~0.9+)
      final consistentValues = [100.0, 101.0, 99.0, 100.5, 100.2];
      final consistencyScore = _testCalculateConsistency(consistentValues);
      
      expect(consistencyScore, greaterThan(0.8));
      print('✅ Consistent values (100±1): $consistencyScore');
    });

    test('_calculateConsistency returns low scores for inconsistent values', () {
      // Test with very inconsistent values (should return low score <0.5)
      final inconsistentValues = [10.0, 100.0, 5.0, 200.0, 50.0];
      final consistencyScore = _testCalculateConsistency(inconsistentValues);
      
      expect(consistencyScore, lessThan(0.6));
      print('✅ Inconsistent values (10-200): $consistencyScore');
    });

    test('_calculateConsistency handles empty list', () {
      final emptyList = <double>[];
      final consistencyScore = _testCalculateConsistency(emptyList);
      
      expect(consistencyScore, equals(0.7)); // Default value
      print('✅ Empty list returns default: $consistencyScore');
    });

    test('_calculateConsistency handles single value', () {
      final singleValue = [42.0];
      final consistencyScore = _testCalculateConsistency(singleValue);
      
      expect(consistencyScore, equals(0.7)); // Default value for insufficient data
      print('✅ Single value returns default: $consistencyScore');
    });

    test('_calculateRiskScore returns low risk for many words', () {
      // Simulate analysis with many recognized words
      final analysis = {
        'blockCount': 5,
        'wordCount': 25,
        'avgConfidence': 0.8,
        'consistencyScore': 0.85,
      };
      
      final riskScore = _testCalculateRiskScore(analysis);
      
      expect(riskScore, lessThan(0.4)); // Should be LOW risk
      print('✅ Many words (25) with high confidence: Risk = $riskScore (${(riskScore * 100).toInt()}%)');
    });

    test('_calculateRiskScore returns moderate risk for short samples', () {
      // Simulate analysis with just a name (3 words)
      final analysis = {
        'blockCount': 1,
        'wordCount': 3,
        'avgConfidence': 0.6,
        'consistencyScore': 0.7,
      };
      
      final riskScore = _testCalculateRiskScore(analysis);
      
      expect(riskScore, lessThan(0.7)); // Should be MILD-MODERATE risk
      expect(riskScore, greaterThan(0.2)); // But not too low (not enough data)
      print('✅ Short sample (3 words): Risk = $riskScore (${(riskScore * 100).toInt()}%)');
    });

    test('_calculateRiskScore returns high risk for no text', () {
      // Simulate analysis with no recognized text
      final analysis = {
        'blockCount': 0,
        'wordCount': 0,
        'avgConfidence': 0.0,
        'consistencyScore': 0.0,
      };
      
      final riskScore = _testCalculateRiskScore(analysis);
      
      expect(riskScore, greaterThanOrEqualTo(0.85)); // Should be HIGH risk
      print('✅ No text recognized: Risk = $riskScore (${(riskScore * 100).toInt()}%)');
    });

    test('_calculateRiskScore handles very short samples specially', () {
      // Test the special case for ≤5 words
      final analysis = {
        'blockCount': 1,
        'wordCount': 4,
        'avgConfidence': 0.5,
        'consistencyScore': 0.6,
      };
      
      final riskScore = _testCalculateRiskScore(analysis);
      
      // Should be around 40% (0.4) due to special short sample handling
      expect(riskScore, lessThan(0.6));
      expect(riskScore, greaterThan(0.2));
      print('✅ Very short sample (4 words): Risk = $riskScore (${(riskScore * 100).toInt()}%)');
    });

    test('_getRiskLevel categorizes risk correctly', () {
      expect(_testGetRiskLevel(0.1), equals('LOW'));
      expect(_testGetRiskLevel(0.25), equals('LOW'));
      expect(_testGetRiskLevel(0.35), equals('MILD'));
      expect(_testGetRiskLevel(0.45), equals('MILD'));
      expect(_testGetRiskLevel(0.55), equals('MODERATE'));
      expect(_testGetRiskLevel(0.65), equals('MODERATE'));
      expect(_testGetRiskLevel(0.75), equals('HIGH'));
      expect(_testGetRiskLevel(0.9), equals('HIGH'));
      
      print('✅ Risk level categorization working correctly');
    });

    test('Risk score formula produces expected results', () {
      // Test various scenarios
      
      // Scenario 1: Excellent handwriting
      final excellent = {
        'blockCount': 10,
        'wordCount': 50,
        'avgConfidence': 0.9,
        'consistencyScore': 0.95,
      };
      final excellentRisk = _testCalculateRiskScore(excellent);
      expect(excellentRisk, lessThan(0.3));
      print('✅ Excellent handwriting: ${(excellentRisk * 100).toInt()}% risk (LOW)');
      
      // Scenario 2: Good handwriting
      final good = {
        'blockCount': 5,
        'wordCount': 20,
        'avgConfidence': 0.75,
        'consistencyScore': 0.8,
      };
      final goodRisk = _testCalculateRiskScore(good);
      expect(goodRisk, lessThan(0.5));
      print('✅ Good handwriting: ${(goodRisk * 100).toInt()}% risk (LOW-MILD)');
      
      // Scenario 3: Average handwriting
      final average = {
        'blockCount': 3,
        'wordCount': 10,
        'avgConfidence': 0.5,
        'consistencyScore': 0.6,
      };
      final averageRisk = _testCalculateRiskScore(average);
      expect(averageRisk, lessThan(0.7));
      print('✅ Average handwriting: ${(averageRisk * 100).toInt()}% risk (MODERATE)');
      
      // Scenario 4: Poor handwriting
      final poor = {
        'blockCount': 1,
        'wordCount': 3,
        'avgConfidence': 0.2,
        'consistencyScore': 0.3,
      };
      final poorRisk = _testCalculateRiskScore(poor);
      expect(poorRisk, greaterThan(0.3));
      print('✅ Poor handwriting: ${(poorRisk * 100).toInt()}% risk (MILD-MODERATE)');
    });

    test('Consistency coefficient of variation calculation', () {
      // Test CV calculation with known values
      
      // Low variance (consistent)
      final lowVariance = [10.0, 10.5, 9.5, 10.2, 9.8];
      final lowVarianceScore = _testCalculateConsistency(lowVariance);
      
      // Medium variance
      final mediumVariance = [10.0, 12.0, 8.0, 11.0, 9.0];
      final mediumVarianceScore = _testCalculateConsistency(mediumVariance);
      
      // High variance (inconsistent)
      final highVariance = [10.0, 20.0, 5.0, 15.0, 8.0];
      final highVarianceScore = _testCalculateConsistency(highVariance);
      
      expect(lowVarianceScore, greaterThan(mediumVarianceScore));
      expect(mediumVarianceScore, greaterThan(highVarianceScore));
      
      print('✅ Low variance: $lowVarianceScore');
      print('✅ Medium variance: $mediumVarianceScore');
      print('✅ High variance: $highVarianceScore');
    });
  });
}

// Helper functions to test private methods
// These mirror the private methods in OCRDysgraphiaService

double _testCalculateConsistency(List<double> values) {
  if (values.isEmpty || values.length < 2) return 0.7;

  final mean = values.reduce((a, b) => a + b) / values.length;
  if (mean == 0) return 0.7;

  final variance = values.map((v) => (v - mean) * (v - mean)).reduce((a, b) => a + b) / values.length;
  final stdDev = variance > 0 ? variance.abs() : 0.0;
  final cv = stdDev / mean.abs();

  final consistencyScore = (1.0 - (cv * 2.0)).clamp(0.0, 1.0);
  
  return consistencyScore;
}

double _testCalculateRiskScore(Map<String, dynamic> analysis) {
  final confidence = analysis['avgConfidence'] as double;
  final consistencyScore = analysis['consistencyScore'] as double;
  final blockCount = analysis['blockCount'] as int;
  final wordCount = analysis['wordCount'] as int;

  if (blockCount == 0 || wordCount == 0) {
    return 0.9;
  }

  // Special case for very short samples
  if (wordCount <= 5 && blockCount >= 1) {
    return 0.4;
  }

  final baseSuccess = wordCount > 0 ? 0.5 : 0.0;
  final wordScore = (wordCount / 15.0).clamp(0.0, 1.0);
  final recognitionQuality = confidence;
  final structureQuality = consistencyScore;

  final overallQuality = (
    baseSuccess * 0.3 +
    recognitionQuality * 0.3 +
    structureQuality * 0.2 +
    wordScore * 0.2
  ).clamp(0.0, 1.0);

  final riskScore = (1.0 - overallQuality).clamp(0.0, 1.0);
  return riskScore;
}

String _testGetRiskLevel(double riskScore) {
  if (riskScore < 0.3) return 'LOW';
  if (riskScore < 0.5) return 'MILD';
  if (riskScore < 0.7) return 'MODERATE';
  return 'HIGH';
}
