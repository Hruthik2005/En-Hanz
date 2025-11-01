import '../models/profile.dart';

class ApiService {
  /// Mock predict - in real app this would POST to your backend endpoint.
  static Future<Map<String, dynamic>> predict({
    required Profile profile,
    required int iqScore,
    required double mentalAge,
    String? imagePath,
  }) async {
    // simulate network latency and some processing time
    await Future.delayed(const Duration(seconds: 3));

    // Create a deterministic-ish mock risk based on name hash and iq
    final seed = profile.name.hashCode.abs() % 100;
    final base = (100 - iqScore) / 100; // higher IQ => lower base risk
    final randomFactor = (seed % 30) / 100; // 0.0 - 0.29
    final risk = (base * 0.6 + randomFactor * 0.4).clamp(0.0, 1.0);

    return {
      'risk': double.parse((risk).toStringAsFixed(2)),
      'iq_score': iqScore,
      'mental_age': mentalAge,
      'recommendation': risk > 0.7
          ? 'Consider targeted motor control exercises and professional evaluation.'
          : (risk > 0.4
                ? 'Mild motor pattern irregularity — practice spacing and tracing.'
                : 'No immediate concern — encourage daily handwriting practice.'),
    };
  }
}
