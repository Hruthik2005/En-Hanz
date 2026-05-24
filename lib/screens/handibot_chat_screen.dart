import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../services/speech_service.dart';
import '../services/nlp_service.dart';

class HandibotChatScreen extends StatefulWidget {
  const HandibotChatScreen({super.key});

  @override
  State<HandibotChatScreen> createState() => _HandibotChatScreenState();
}

class _HandibotChatScreenState extends State<HandibotChatScreen> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final VoidCallback _speechListener;
  bool _listening = false;
  bool _speechReady = false;
  String _selectedLanguage = 'en'; // en | hi | kn

  @override
  void initState() {
    super.initState();
    _speechListener = () {
      if (mounted) setState(() {});
    };
    SpeechService.instance.recognizedText.addListener(_speechListener);
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    await SpeechService.instance.init();
    if (!mounted) return;
    setState(() {
      _speechReady = true;
    });
    _addWelcomeMessage();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ensure UI uses locale if no explicit selection
    final locale = Localizations.maybeLocaleOf(context);
    if (locale != null && _selectedLanguage == 'en') {
      if (locale.languageCode == 'hi') _selectedLanguage = 'hi';
      if (locale.languageCode == 'kn') _selectedLanguage = 'kn';
    }
  }

  @override
  void dispose() {
    SpeechService.instance.recognizedText.removeListener(_speechListener);
    SpeechService.instance.cancelListening();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendText(String text) async {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.insert(0, {'from': 'user', 'text': text});
    });
    _controller.clear();

    final result = NLPService.instance.processText(
      text,
      locale: _nlpLocale(),
      assessment: _assessmentContext(),
    );
    final response = result['response'] is String
        ? result['response'] as String
        : (result['response']?.toString() ?? '');

    setState(() {
      _messages.insert(0, {'from': 'bot', 'text': response});
    });

    _scrollToTop();

    // Speak response
    await SpeechService.instance.speak(response, language: _ttsLanguageTag());
  }

  void _scrollToTop() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Future<void> _toggleListening() async {
    if (!_speechReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preparing microphone... try again in a moment.')),
      );
      return;
    }

    if (_listening) {
      final recognized = await SpeechService.instance.stopListening();
      setState(() => _listening = false);
      if (recognized.isNotEmpty) _sendText(recognized);
      return;
    }

    final previousTranscript = SpeechService.instance.recognizedText.value;
    setState(() => _listening = true);
    try {
      await SpeechService.instance.startListening(
        localeId: _localeForLanguage(),
      );
    } catch (e) {
      debugPrint('Speech start error: $e');
      if (!mounted) return;
      setState(() => _listening = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not start microphone: $e')),
      );
      SpeechService.instance.resetTranscript();
      if (previousTranscript.isNotEmpty) {
        SpeechService.instance.recognizedText.value = previousTranscript;
      }
    }
  }

  String? _localeForLanguage() {
    switch (_selectedLanguage) {
      case 'hi':
        return 'hi_IN';
      case 'kn':
        return 'kn_IN';
      default:
        return 'en_US';
    }
  }

  /// Language tag for TTS (BCP-47 style)
  String _ttsLanguageTag() {
    switch (_selectedLanguage) {
      case 'hi':
        return 'hi-IN';
      case 'kn':
        return 'kn-IN';
      default:
        return 'en-US';
    }
  }

  /// Short language code for NLP ('en', 'hi', 'kn')
  String _nlpLocale() {
    switch (_selectedLanguage) {
      case 'hi':
        return 'hi';
      case 'kn':
        return 'kn';
      default:
        return 'en';
    }
  }

  Map<String, dynamic> _assessmentContext() {
    final appState = Provider.of<AppState>(context, listen: false);
    final name = appState.selectedChildProfile?.childName ?? appState.profile?.name ?? 'your child';
    return {
      'name': name,
      'iqScore': appState.iqScore,
      'mentalAge': appState.mentalAge,
      'riskScore': appState.risk,
      'recommendation': appState.recommendation,
      'handwritingImagePath': appState.handwritingImagePath,
    };
  }

  void _addWelcomeMessage() {
    if (!mounted) return;
    final summary = NLPService.instance.processText(
      'report summary',
      locale: _nlpLocale(),
      assessment: _assessmentContext(),
    );
    final welcome = summary['response']?.toString() ?? '';
    if (welcome.isEmpty) return;
    if (_messages.isNotEmpty && _messages.first['from'] == 'bot') return;
    setState(() {
      _messages.insert(0, {'from': 'bot', 'text': welcome});
    });
    // Speak welcome in selected language
    SpeechService.instance.speak(welcome, language: _ttsLanguageTag());
  }

  @override
  Widget build(BuildContext context) {
    final liveTranscript = SpeechService.instance.recognizedText.value;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEAF2FF), Color(0xFFF8FBFF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildSpeechStatusBar(),
              _buildTopBar(),
              Expanded(
                child: _messages.isEmpty ? _buildEmptyState() : _buildMessages(),
              ),
              _buildComposer(liveTranscript),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Handibot Voice Chat',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                Text(
                  _listening ? 'Listening...' : 'Tap mic and speak',
                  style: TextStyle(
                    color: _listening ? Colors.redAccent : Colors.blueGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _listening ? const Color(0xFFFFE7E7) : const Color(0xFFE7F3FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _listening ? 'Mic On' : 'Mic Off',
              style: TextStyle(
                color: _listening ? const Color(0xFFC62828) : const Color(0xFF1565C0),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Language selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedLanguage,
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'hi', child: Text('हिन्दी')),
                  DropdownMenuItem(value: 'kn', child: Text('ಕನ್ನಡ')),
                ],
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _selectedLanguage = v);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.record_voice_over_rounded, size: 56, color: Color(0xFF4F79D7)),
            const SizedBox(height: 12),
            const Text(
              'Voice and chat in one place',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Press the mic button below and talk to Handibot, or type your message.\n\nThe bot can summarize your latest IQ and handwriting scores.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessages() {
    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        final isUser = msg['from'] == 'user';
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            constraints: const BoxConstraints(maxWidth: 320),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isUser ? const Color(0xFF2E73E8) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              msg['text'] ?? '',
              style: TextStyle(
                height: 1.35,
                color: isUser ? Colors.white : const Color(0xFF1E2430),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildComposer(String liveTranscript) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _listening ? const Color(0xFFFFF1F1) : const Color(0xFFF3F7FC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    _listening ? Icons.graphic_eq_rounded : Icons.mic_none_rounded,
                    color: _listening ? Colors.redAccent : const Color(0xFF607D9A),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _listening
                          ? (liveTranscript.isEmpty ? 'Listening... start speaking' : liveTranscript)
                          : 'Voice transcript will appear here',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _listening ? const Color(0xFFC62828) : const Color(0xFF607D9A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Material(
                  color: _listening
                      ? const Color(0xFFD32F2F)
                      : (!_speechReady ? const Color(0xFF90A4AE) : const Color(0xFF2E73E8)),
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: _toggleListening,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        _listening ? Icons.mic_off_rounded : Icons.mic_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: _sendText,
                    decoration: InputDecoration(
                      hintText: 'Type message',
                      filled: true,
                      fillColor: const Color(0xFFF3F7FC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Material(
                  color: const Color(0xFF1B5E20),
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => _sendText(_controller.text.trim()),
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(Icons.send_rounded, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeechStatusBar() {
    if (_speechReady) return const SizedBox.shrink();
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: LinearProgressIndicator(minHeight: 2),
    );
  }
}
