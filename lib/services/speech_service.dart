import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

/// Simple wrapper around `speech_to_text` and `flutter_tts`.
class SpeechService {
  SpeechService._();
  static final SpeechService instance = SpeechService._();

  final stt.SpeechToText _stt = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _initialized = false;
  bool _initializing = false;
  bool _disposed = false;
  bool get isInitialized => _initialized;

  /// Latest recognized text
  final ValueNotifier<String> recognizedText = ValueNotifier('');

  /// Initialize STT and TTS engines. Safe to call multiple times.
  Future<void> init() async {
    if (_initialized || _initializing) return;
    _initializing = true;
    try {
      final available = await _stt.initialize(
        onStatus: (status) {
          debugPrint('SpeechService status: $status');
        },
        onError: (error) {
          debugPrint('SpeechService error: ${error.errorMsg}');
        },
      );
      if (!available) {
        debugPrint('SpeechService: STT not available');
      }
      // Set some TTS defaults
      await _tts.setSpeechRate(0.5);
      await _tts.setPitch(1.0);
      _initialized = true;
      debugPrint('SpeechService: initialized');
    } catch (e) {
      debugPrint('SpeechService init error: $e');
    } finally {
      _initializing = false;
    }
  }

  /// Start listening. Provide an optional localeId like 'en_US' or 'es_ES'.
  Future<void> startListening({String? localeId}) async {
    if (_disposed) {
      _disposed = false;
    }
    if (!_initialized) await init();
    recognizedText.value = '';

    await _stt.listen(
      onResult: (result) {
        recognizedText.value = result.recognizedWords;
      },
      localeId: localeId,
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
        listenMode: stt.ListenMode.dictation,
      ),
    );
    debugPrint('SpeechService: started listening (locale=$localeId)');
  }

  /// Stop listening and return last recognized text.
  Future<String> stopListening() async {
    await _stt.stop();
    debugPrint('SpeechService: stopped listening -> "${recognizedText.value}"');
    return recognizedText.value;
  }

  Future<void> cancelListening() async {
    await _stt.cancel();
    debugPrint('SpeechService: canceled listening');
  }

  /// Speak some text using TTS. Optional `language` like 'en-US' or 'es-ES'.
  Future<void> speak(String text, {String? language}) async {
    if (!_initialized) await init();
    if (language != null) await _tts.setLanguage(language);
    await _tts.stop();
    await _tts.speak(text);
  }

  /// Get available locales (from speech_to_text)
  Future<List<stt.LocaleName>> getAvailableLocales() async {
    if (!_initialized) await init();
    return await _stt.locales();
  }

  void dispose() {
    _disposed = true;
    _tts.stop();
    _stt.cancel();
  }

  void resetTranscript() {
    recognizedText.value = '';
  }
}
