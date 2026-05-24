/// Minimal on-device NLP service with app-aware replies.
class NLPService {
  NLPService._();
  static final NLPService instance = NLPService._();

  /// Process input text and return a simple response object.
  /// Supports a few languages via keyword matching: English, Spanish, Hindi.
  Map<String, dynamic> processText(
    String text, {
    String? locale,
    Map<String, dynamic>? assessment,
  }) {
    final t = text.trim().toLowerCase();
    final lang = (locale ?? 'en').split('-').first;
    final appSummary = _buildAppSummary(assessment, lang);

    // Greeting intent
    final greetingsEn = ['hello', 'hi', 'hey', 'good morning', 'good evening'];
    final greetingsEs = ['hola', 'buenos', 'buenas'];
    final greetingsHi = ['namaste', 'hello', 'namaskar'];
    final greetingsKn = ['ಹಲೋ', 'ನಮಸ್ಕಾರ', 'ನಮಸ್ಕಾರೊ', 'ನಮಸ್ತೆ', 'ನಮಸ್ಕಾರ'];

    if (_containsAny(t, greetingsEn) && lang == 'en') {
      return _makeIntent('greeting', appSummary.isEmpty ? _randomGreeting('en') : '$appSummary\n\nHow can I help with your report or practice next?');
    }
    if (_containsAny(t, greetingsEs) && lang == 'es') {
      return _makeIntent('greeting', appSummary.isEmpty ? _randomGreeting('es') : '$appSummary\n\n¿Qué te gustaría revisar?');
    }
    if (_containsAny(t, greetingsHi) && lang == 'hi') {
      return _makeIntent('greeting', appSummary.isEmpty ? _randomGreeting('hi') : '$appSummary\n\nआप किस चीज़ की जानकारी चाहते हैं?');
    }
    if (_containsAny(t, greetingsKn) && lang == 'kn') {
      return _makeIntent('greeting', appSummary.isEmpty ? _randomGreeting('kn') : '$appSummary\n\nನೀವು ಯಾವ ವಿವರಗಳನ್ನು ಬೇಕಾದ್ದು ಕೇಳಬಹುದು?');
    }

    // Ask for analysis / report summary / scores
    if (_isReportQuestion(t, lang)) {
      return _makeIntent('report_summary', _buildReportReply(assessment, lang));
    }

    // Ask for handwriting analysis or next steps
    if (t.contains('analyze') || t.contains('analyse') || t.contains('check my') || t.contains('handwriting') || t.contains('writing') || t.contains('analizar') || t.contains('हाथ')) {
      return _makeIntent('analyze_request', _buildAnalysisReply(assessment, lang));
    }

    // Ask for help
    if (t.contains('help') || t.contains('ayuda') || t.contains('मदद')) {
      return _makeIntent('help', _buildHelpReply(assessment, lang));
    }

    if (t.contains('practice') || t.contains('improve') || t.contains('exercise') || t.contains('practice zone')) {
      return _makeIntent('practice', _buildPracticeReply(assessment, lang));
    }

    // Fallback
    return _makeIntent('fallback', _buildFallbackReply(assessment, lang));
  }

  Map<String, dynamic> _makeIntent(String name, dynamic reply) {
    return {'intent': name, 'response': reply};
  }

  bool _isReportQuestion(String text, String lang) {
    final reportKeywords = [
      'report',
      'summary',
      'results',
      'scores',
      'score',
      'how am i',
      'how did i do',
      'what did you find',
      'tell me about my assessment',
      'analysis',
      'feedback',
      'my iq',
      'my handwriting',
      'my risk',
      'रेपोर्ट',
      'रिपोर्ट',
      'नतीजे',
      'सारांश',
      'résumé',
      'resultado',
      'ರಿಪೋರ್ಟ್',
      'ವಿವರಣೆ',
      'ಫಲಿತಾಂಶ',
    ];
    return reportKeywords.any(text.contains) ||
        (lang == 'hi' && (text.contains('स्कोर') || text.contains('परिणाम')));
  }

  String _buildAppSummary(Map<String, dynamic>? assessment, String lang) {
    if (assessment == null) return '';
    final name = (assessment['name'] ?? 'your child').toString();
    final iqScore = assessment['iqScore'] as int?;
    final mentalAge = assessment['mentalAge'] as num?;
    final riskScore = assessment['riskScore'] as num?;
    final riskPercent = riskScore != null ? (riskScore.toDouble() * 100).toInt() : null;
    final riskLabel = _riskLabel(riskScore?.toDouble() ?? 0.0);

    switch (lang) {
      case 'hi':
        return 'अभी का सारांश: $name का IQ ${iqScore ?? 'N/A'} है, मानसिक आयु ${mentalAge?.toStringAsFixed(1) ?? 'N/A'} है, और हस्तलेखन जोखिम ${riskPercent ?? 'N/A'}% ($riskLabel) है.';
      case 'kn':
        return 'ಪ್ರಸ್ತುತ ಸಾರಾಂಶ: $name ರ IQ ${iqScore ?? 'N/A'}, ಮಾನಸಿಕ ವಯಸ್ಸು ${mentalAge?.toStringAsFixed(1) ?? 'N/A'}, ಮತ್ತು ಬರವಣಿಗೆಯ ಅಪಾಯ ${riskPercent ?? 'N/A'}% ($riskLabel).';
      case 'es':
        return 'Resumen actual: $name tiene un CI de ${iqScore ?? 'N/A'}, edad mental ${mentalAge?.toStringAsFixed(1) ?? 'N/A'} y riesgo de escritura ${riskPercent ?? 'N/A'}% ($riskLabel).';
      default:
        return 'Current summary for $name: IQ ${iqScore ?? 'N/A'}, mental age ${mentalAge?.toStringAsFixed(1) ?? 'N/A'}, handwriting risk ${riskPercent ?? 'N/A'}% ($riskLabel).';
    }
  }

  String _buildReportReply(Map<String, dynamic>? assessment, String lang) {
    if (assessment == null) {
      return _localized(
        en: 'I do not have a saved assessment yet. Please complete the IQ and handwriting tests first.',
        es: 'Aún no tengo una evaluación guardada. Completa primero las pruebas de CI y escritura.',
        hi: 'मेरे पास अभी कोई सहेजा हुआ मूल्यांकन नहीं है। पहले IQ और handwriting test पूरा करें।',
        kn: 'ನನ್ನ ಬಳಿ ಯಾವುದೇ ಸನ್‌ರಕ್ಷಿತ ಮೌಲ್ಯಮಾಪನ ಇಲ್ಲ. ದಯವಿಟ್ಟು ಮೊದಲು IQ ಮತ್ತು ಬರವಣಿಗೆ ಪರೀಕ್ಷೆಗಳನ್ನು ಪೂರ್ಣಗೊಳಿಸಿ.',
        lang: lang,
      );
    }

    final name = (assessment['name'] ?? 'your child').toString();
    final iqScore = (assessment['iqScore'] as int?) ?? 0;
    final mentalAge = (assessment['mentalAge'] as num?)?.toStringAsFixed(1) ?? 'N/A';
    final riskScore = (assessment['riskScore'] as num?)?.toDouble() ?? 0.0;
    final riskPercent = (riskScore * 100).toInt();
    final recommendation = (assessment['recommendation'] ?? '').toString();
    final riskLabel = _riskLabel(riskScore);

    final feedback = _localized(
      en: 'Here is the latest report for $name:\n• IQ score: $iqScore\n• Mental age: $mentalAge\n• Handwriting risk: $riskPercent% ($riskLabel)\n• Next step: ${_nextStepFromRisk(riskScore)}',
      es: 'Este es el último informe de $name:\n• CI: $iqScore\n• Edad mental: $mentalAge\n• Riesgo de escritura: $riskPercent% ($riskLabel)\n• Siguiente paso: ${_nextStepFromRisk(riskScore, lang: 'es')}',
      hi: '$name के लिए नवीनतम रिपोर्ट:\n• IQ स्कोर: $iqScore\n• मानसिक आयु: $mentalAge\n• handwriting risk: $riskPercent% ($riskLabel)\n• अगला कदम: ${_nextStepFromRisk(riskScore, lang: 'hi')}',
      kn: '$name ರ ಇತ್ತೀಚಿನ ವರದಿ:\n• IQ: $iqScore\n• ಮಾನಸಿಕ ವಯಸ್ಸು: $mentalAge\n• ಬರವಣಿಗೆಯ ಅಪಾಯ: $riskPercent% ($riskLabel)\n• ಮುಂದಿನ ಹಂತ: ${_nextStepFromRisk(riskScore, lang: 'kn')}',
      lang: lang,
    );

    if (recommendation.isNotEmpty) {
      return '$feedback\n\nKey recommendation: ${_shorten(recommendation)}';
    }
    return feedback;
  }

  String _buildAnalysisReply(Map<String, dynamic>? assessment, String lang) {
    if (assessment == null) {
      return _localized(
        en: 'Upload or complete an assessment and I will analyze the result in detail.',
        es: 'Carga o completa una evaluación y la analizaré en detalle.',
        hi: 'एक assessment पूरा करें या अपलोड करें, मैं उसका विस्तार से विश्लेषण करूँगा।',
        kn: 'ಮೌಲ್ಯಮಾಪನವನ್ನು ಅಪ್‌ಲೋಡ್ ಅಥವಾ ಪೂರ್ಣಗೊಳಿಸಿ, ನಾನು ವಿವರವಾಗಿ ವಿಶ್ಲೇಷಣೆ ಮಾಡುತ್ತೇನೆ.',
        lang: lang,
      );
    }
    final riskScore = (assessment['riskScore'] as num?)?.toDouble() ?? 0.0;
    final recommendation = (assessment['recommendation'] ?? '').toString();
    final riskPercent = (riskScore * 100).toInt();

    return _localized(
      en: 'Based on the last assessment, handwriting risk is $riskPercent%. ${_nextStepFromRisk(riskScore)} ${recommendation.isNotEmpty ? 'Recommendation: ${_shorten(recommendation)}' : ''}',
      es: 'Según la última evaluación, el riesgo de escritura es $riskPercent%. ${_nextStepFromRisk(riskScore, lang: 'es')} ${recommendation.isNotEmpty ? 'Recomendación: ${_shorten(recommendation)}' : ''}',
      hi: 'पिछले assessment के आधार पर handwriting risk $riskPercent% है। ${_nextStepFromRisk(riskScore, lang: 'hi')} ${recommendation.isNotEmpty ? 'सुझाव: ${_shorten(recommendation)}' : ''}',
      kn: 'ಕೊನೆಯ ಮೌಲ್ಯಮಾಪನದ ಆಧಾರದ ಮೇಲೆ, ಬರವಣಿಗೆಯ ಅಪಾಯ $riskPercent% ಅಂದಿದೆ. ${_nextStepFromRisk(riskScore, lang: 'kn')} ${recommendation.isNotEmpty ? 'ಶಿಫಾರಸು: ${_shorten(recommendation)}' : ''}',
      lang: lang,
    );
  }

  String _buildHelpReply(Map<String, dynamic>? assessment, String lang) {
    final next = assessment == null
        ? _localized(
            en: 'Start with IQ test and handwriting analysis. Then I can summarize your report and suggest practice.',
            es: 'Empieza con la prueba de CI y el análisis de escritura. Luego puedo resumir tu informe y sugerir práctica.',
            hi: 'IQ test और handwriting analysis से शुरू करें। फिर मैं report summarize करके practice suggest कर सकता हूँ।',
            kn: 'IQ ಪರೀಕ್ಷೆ ಮತ್ತು ಬರವಣಿಗೆ ವಿಶ್ಲೇಷಣೆಯಿಂದ ಪ್ರಾರಂಭಿಸಿ. ಬಳಿಕ ನಾನು ನಿಮ್ಮ ವರದಿಯನ್ನು ಸಾರಾಂಶಗೊಳಿಸಿ ಅಭ್ಯಾಸವನ್ನು ಸೂಚಿಸಬಹುದು.',
            lang: lang,
          )
        : _localized(
            en: 'You can ask me to explain the IQ score, handwriting risk, report summary, or practice next steps.',
            es: 'Puedes pedirme que explique el CI, el riesgo de escritura, el resumen del informe o los siguientes pasos.',
            hi: 'आप मुझसे IQ score, handwriting risk, report summary या next steps पूछ सकते हैं।',
            kn: 'ನೀವು ನನ್ನನ್ನು IQ ಅಂಕೆ, ಬರವಣಿಗೆ ಅಪಾಯ, ವರದಿ ಸಾರಾಂಶ ಅಥವಾ ಅಭ್ಯಾಸದ ಮುಂದಿನ ಹಂತಗಳ ಬಗ್ಗೆ ಕೇಳಬಹುದು.',
            lang: lang,
          );
    return '$next\n\nAvailable commands: report summary, analyze handwriting, practice tips, or go to dashboard.';
  }

  String _buildPracticeReply(Map<String, dynamic>? assessment, String lang) {
    final riskScore = (assessment?['riskScore'] as num?)?.toDouble() ?? 0.0;
    final riskPercent = (riskScore * 100).toInt();
    final focus = riskScore < 0.3
      ? _localized(en: 'maintaining spacing and neatness', es: 'mantener el espaciado y la limpieza', hi: 'spacing और neatness बनाए रखने पर', kn: 'ಅಂತರ ಮತ್ತು ಸ್ವಚ್ಛತೆಯನ್ನು ಕಾಯ್ದುಕೊಳ್ಳುವುದು', lang: lang)
      : riskScore < 0.7
        ? _localized(en: 'letter formation, spacing, and line alignment', es: 'formación de letras, espaciado y alineación', hi: 'letter formation, spacing और line alignment पर', kn: 'ಅಕ್ಷರ ರೂಪರೇಖೆ, ಅಂತರ ಮತ್ತು ಸಾಲದ ರೇಖೆಯ ಸರಿಹೊಂದಿಕೆ', lang: lang)
        : _localized(en: 'basic strokes, grip, and slow writing', es: 'trazos básicos, agarre y escritura lenta', hi: 'basic strokes, grip और slow writing पर', kn: 'ಆಧಾರಭೂತ ಹಂತಗಳು, ಹಿಡಿಯುವ ವಿಧಾನ ಮತ್ತು ನಿಧಾನವಾಗಿ ಬರೆಯುವುದು', lang: lang);

    return _localized(
      en: 'For your latest score ($riskPercent% handwriting risk), I recommend focusing on $focus. I can open practice games or give a 5-minute daily plan.',
      es: 'Para tu última puntuación ($riskPercent% de riesgo), te recomiendo centrarte en $focus. Puedo abrir juegos de práctica o darte un plan diario de 5 minutos.',
      hi: 'आपके पिछले score ($riskPercent% handwriting risk) के लिए, ध्यान $focus पर देना चाहिए। मैं practice games खोल सकता हूँ या 5-minute daily plan दे सकता हूँ।',
      kn: 'ನಿಮ್ಮ ಇತ್ತೀಚಿನ ಅಂಕೆ ($riskPercent% ಬರವಣಿಗೆ ಅಪಾಯ)ಗಾಗಿ, ನಾನು ಸೂಚಿಸುವುದು: $focus. ನಾನು ಅಭ್ಯಾಸ ಆಟಗಳನ್ನು ತೆರೆಯಬಹುದು ಅಥವಾ 5 ನಿಮಿಷದ ದಿನನಿತ್ಯ ಯೋಜನೆಯನ್ನು ಕೊಡಬಹುದಾಗಿದೆ.',
      lang: lang,
    );
  }

  bool _containsAny(String text, List<String> candidates) {
    for (final c in candidates) {
      if (text.contains(c)) return true;
    }
    return false;
  }

  String _randomGreeting(String lang) {
    switch (lang) {
      case 'es':
        return '¡Hola! ¿Cómo puedo ayudarte hoy?';
      case 'hi':
        return 'नमस्ते! मैं आपकी कैसे मदद कर सकता/सकती हूँ?';
      case 'kn':
        return 'ನಮಸ್ಕಾರ! ನಾನು ನಿಮ್ಮಗೆ ಹೇಗೆ ಸಹಾಯ ಮಾಡಬೇಕು?';
      default:
        return 'Hi — how can I help you today?';
    }
  }

  String _buildFallbackReply(Map<String, dynamic>? assessment, String lang) {
    if (assessment != null) {
      final riskScore = (assessment['riskScore'] as num?)?.toDouble() ?? 0.0;
      final riskPercent = (riskScore * 100).toInt();
      return _localized(
        en: 'I can help with that. Your latest handwriting risk is $riskPercent%. Ask for the report summary, practice tips, or what the IQ score means.',
        es: 'Puedo ayudarte con eso. Tu último riesgo de escritura es $riskPercent%. Pide el resumen del informe, consejos de práctica o qué significa el CI.',
        hi: 'मैं इसमें मदद कर सकता हूँ। आपका latest handwriting risk $riskPercent% है। आप report summary, practice tips या IQ score meaning पूछ सकते हैं।',
        kn: 'ನಾನು ಸಹಾಯ ಮಾಡಬಹುದು. ನಿಮ್ಮ ಇತ್ತೀಚಿನ ಬರವಣಿಗೆಯ ಅಪಾಯ $riskPercent%. ವರದಿ ಸಾರಾಂಶ, ಅಭ್ಯಾಸ ಸಲಹೆಗಳು ಅಥವಾ IQ ಅಂಕೆ ಅರ್ಥವನ್ನು ಕೇಳಿ.',
        lang: lang,
      );
    }

    switch (lang) {
      case 'es':
        return 'Lo siento, no entendí. ¿Puedes repetirlo?';
      case 'hi':
        return 'माफ़ कीजिए, मैं समझ नहीं पाया। क्या आप दोहरा सकते हैं?';
      case 'kn':
        return 'ಕ್ಷಮಿಸಿ, ನಾನು ಹಿಡಿದಿಲ್ಲ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಹೇಳಬಹುದು?';
      default:
        return 'Sorry, I didn\'t catch that. Could you rephrase?';
    }
  }

  String _localized({
    required String en,
    required String es,
    required String hi,
    required String kn,
    required String lang,
  }) {
    switch (lang) {
      case 'es':
        return es;
      case 'hi':
        return hi;
      case 'kn':
        return kn;
      default:
        return en;
    }
  }

  String _riskLabel(double riskScore) {
    if (riskScore < 0.3) return 'Low';
    if (riskScore < 0.7) return 'Moderate';
    return 'High';
  }

  String _nextStepFromRisk(double riskScore, {String lang = 'en'}) {
    if (riskScore < 0.3) {
      return _localized(
        en: 'Great readability. Keep practicing neat spacing and consistency.',
        es: 'Excelente legibilidad. Sigue practicando el espaciado y la consistencia.',
        hi: 'बहुत अच्छी readability. spacing और consistency बनाए रखें।',
        kn: 'ಉತ್ತമ ಓದುವಾಸOr; ಸ್ವಚ್ಛ ಅಂತರ ಮತ್ತು ಸ್ಥಿರತೆಯನ್ನು ಅಭ್ಯಾಸ ಮಾಡಿ.',
          lang: lang,
      );
    }
    if (riskScore < 0.7) {
      return _localized(
        en: 'Focus on letter spacing, size consistency, and slower writing.',
        es: 'Concéntrate en el espaciado, el tamaño consistente y escribir más lento.',
        hi: 'letter spacing, size consistency और slower writing पर ध्यान दें।',
        kn: 'ಅಕ್ಷರಗಳ ಅಂತರ, ಗಾತ್ರದ ಸ್ಥಿರತೆ ಮತ್ತು ನಿಧಾನವಾದ ಬರವಣಿಗೆಯ ಮೇಲೆ ಗಮನ ಹರಿಸಿ.',
          lang: lang,
      );
    }
    return _localized(
        en: 'Start with basic strokes, grip correction, and short practice sessions.',
        es: 'Empieza con trazos básicos, agarre correcto y sesiones cortas de práctica.',
        hi: 'basic strokes, grip correction और short practice sessions से शुरू करें।',
        kn: 'ಮೂಲಭೂತ ರೇಖಾಚಿತ್ರಗಳು, ಹಿಡಿತ ಸರಿಪಡಿಸುವಿಕೆ ಮತ್ತು ಚೊಚ್ಚಲ ಅಭ್ಯಾಸ ಅವಧಿಗಳಿಂದ ಪ್ರಾರಂಭಿಸಿ.',
        lang: lang,
    );
  }

  String _shorten(String text) {
    final cleaned = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (cleaned.length <= 180) return cleaned;
    return '${cleaned.substring(0, 177)}...';
  }
}
