import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../state/app_state.dart';
import '../utils/app_strings.dart';

class HandyBotChatScreen extends StatefulWidget {
  const HandyBotChatScreen({super.key});

  @override
  State<HandyBotChatScreen> createState() => _HandyBotChatScreenState();
}

class _HandyBotChatScreenState extends State<HandyBotChatScreen>
    with TickerProviderStateMixin {
  final FlutterTts _flutterTts = FlutterTts();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  bool _isSpeaking = false;
  bool _ttsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadVoiceSettings();
    _checkAssessmentCompletion();
  }

  void _checkAssessmentCompletion() {
    final appState = Provider.of<AppState>(context, listen: false);
    
    // Check if user has completed the assessment
    if (appState.risk == 0.0 || appState.iqScore == 0) {
      // Show warning dialog
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Assessment Not Complete',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
              ],
            ),
            content: Text(
              'Please complete the handwriting assessment first before consulting with HandyBot.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to previous screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1565C0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Go Back',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      });
      return;
    }
    
    _initialize();
  }

  Future<void> _initialize() async {
    await _initTts();
    _startConversation();
  }

  void _loadVoiceSettings() {
    final appState = Provider.of<AppState>(context, listen: false);
    setState(() {
      _ttsEnabled = appState.settings.voiceEnabled;
    });
  }

  Future<void> _initTts() async {
    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final language = appState.settings.language;
      
      // Configure TTS based on selected language
      String locale;
      String voiceName;
      double speechRate;
      double pitch;
      
      switch (language) {
        case 'Hindi':
          locale = "hi-IN";
          voiceName = "hi-in-x-hid-network"; // Google's high-quality Hindi voice
          speechRate = 0.45; // Slightly slower for better clarity in Hindi
          pitch = 1.0;
          break;
        case 'Kannada':
          locale = "kn-IN";
          voiceName = "kn-in-x-knm-network"; // Google's high-quality Kannada voice
          speechRate = 0.45; // Slightly slower for better clarity in Kannada
          pitch = 1.0;
          break;
        default: // English
          locale = "en-US";
          voiceName = "en-us-x-sfg-network"; // Google's high-quality English voice
          speechRate = 0.50;
          pitch = 1.0;
      }
      
      await _flutterTts.setLanguage(locale);
      
      // Try to use Google's high-quality TTS engine first (Android only)
      try {
        await _flutterTts.setEngine("com.google.android.tts");
        // Use enhanced network voice for most natural sound
        await _flutterTts.setVoice({"name": voiceName, "locale": locale});
      } catch (e) {
        // Fallback to default engine if Google TTS not available
        debugPrint('Google TTS engine not available, using default: $e');
      }
      
      // Configure speech parameters
      await _flutterTts.setSpeechRate(speechRate);
      await _flutterTts.setPitch(pitch);
      await _flutterTts.setVolume(1.0);

      _flutterTts.setCompletionHandler(() {
        if (mounted) {
          setState(() => _isSpeaking = false);
        }
      });
    } catch (e) {
      debugPrint('TTS initialization error: $e');
      // Continue without TTS if initialization fails
    }
  }

  Future<void> _speak(String text) async {
    if (_ttsEnabled && mounted) {
      try {
        setState(() => _isSpeaking = true);
        // Remove emojis and special characters from TTS
        String cleanText = _removeEmojis(text);
        await _flutterTts.speak(cleanText);
        // Wait for speech to complete
        while (_isSpeaking && mounted) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
      } catch (e) {
        debugPrint('TTS speak error: $e');
        if (mounted) {
          setState(() => _isSpeaking = false);
        }
      }
    }
  }

  Future<void> _stopSpeaking() async {
    await _flutterTts.stop();
    if (mounted) {
      setState(() => _isSpeaking = false);
    }
  }

  String _removeEmojis(String text) {
    // Remove emojis, bullets, and clean up the text for TTS
    String cleanText = text
        // Remove all emojis
        .replaceAll(RegExp(r'[\u{1F300}-\u{1F9FF}]', unicode: true), '')
        .replaceAll(RegExp(r'[\u{2600}-\u{26FF}]', unicode: true), '')
        .replaceAll(RegExp(r'[\u{2700}-\u{27BF}]', unicode: true), '')
        .replaceAll(RegExp(r'[\u{FE00}-\u{FE0F}]', unicode: true), '')
        // Remove bullet points and special characters
        .replaceAll('•', '')
        .replaceAll('→', '')
        .replaceAll('✓', '')
        .replaceAll('✔', '')
        // Clean up multiple spaces and newlines
        .replaceAll(RegExp(r'\n+'), '. ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    
    // Ensure proper sentence ending
    if (!cleanText.endsWith('.') && !cleanText.endsWith('!') && !cleanText.endsWith('?')) {
      cleanText += '.';
    }
    
    return cleanText;
  }

  void _startConversation() {
    final appState = Provider.of<AppState>(context, listen: false);
    final name = appState.profile?.name ?? 'there';
    final risk = appState.risk;
    final iq = appState.iqScore;

    List<String> botMessages = _generateMessages(name, risk, iq);

    // Send messages one by one with delays
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _sendBotMessage(botMessages, 0);
      }
    });
  }

  List<String> _generateMessages(String name, double risk, int iq) {
    final appState = Provider.of<AppState>(context, listen: false);
    final language = appState.settings.language;
    List<String> messages = [];

    // Opening message
    messages.add(AppStrings.get('bot_greeting', language).replaceAll('{name}', name));

    // Risk-based messages
    if (risk < 0.4) {
      // Low Risk - Positive
      messages.add(AppStrings.get('bot_low_risk_1', language).replaceAll('{name}', name));
      messages.add(AppStrings.get('bot_low_risk_2', language));
    } else if (risk < 0.7) {
      // Moderate Risk - Encouraging
      messages.add(AppStrings.get('bot_moderate_risk_1', language).replaceAll('{name}', name));
      messages.add(AppStrings.get('bot_moderate_risk_2', language).replaceAll('{name}', name));
    } else {
      // High Risk - Supportive & Empathetic
      messages.add(AppStrings.get('bot_high_risk_1', language).replaceAll('{name}', name));
      messages.add(AppStrings.get('bot_high_risk_2', language));
    }

    // Summary message
    String riskLevel = risk < 0.4
        ? "${AppStrings.get('low_risk', language)} 🟢"
        : risk < 0.7
            ? "${AppStrings.get('moderate_risk', language)} �"
            : "${AppStrings.get('high_risk', language)} 🔴";
    
    String focusArea = risk < 0.4 
        ? AppStrings.get('focus_low', language)
        : risk < 0.7 
            ? AppStrings.get('focus_moderate', language)
            : AppStrings.get('focus_high', language);
    
    messages.add(
        AppStrings.get('bot_summary', language)
            .replaceAll('{risk}', riskLevel)
            .replaceAll('{iq}', iq.toString())
            .replaceAll('{focus}', focusArea));

    // Closing message
    messages.add(AppStrings.get('bot_closing', language));

    return messages;
  }

  void _sendBotMessage(List<String> messages, int index) {
    if (!mounted || index >= messages.length) {
      // All messages sent, show action buttons after delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _messages.add(ChatMessage(
              text: '',
              isBot: true,
              isActionButtons: true,
            ));
          });
          _scrollToBottom();
        }
      });
      return;
    }

    // Show typing indicator
    setState(() => _isTyping = true);

    Future.delayed(const Duration(milliseconds: 1500), () async {
      if (!mounted) return;

      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(
          text: messages[index],
          isBot: true,
          timestamp: DateTime.now(),
        ));
      });

      _scrollToBottom();
      
      // Wait for speech to complete before sending next message
      await _speak(messages[index]);

      // Send next message after speech is done
      await Future.delayed(const Duration(milliseconds: 800));
      _sendBotMessage(messages, index + 1);
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleUserAction(String action) async {
    final appState = Provider.of<AppState>(context, listen: false);
    final language = appState.settings.language;
    String response = '';

    switch (action) {
      case 'tips':
        response = AppStrings.get('bot_tips', language);
        break;
      case 'practice':
        response = AppStrings.get('bot_practice', language);
        setState(() {
          _messages.add(ChatMessage(
            text: response,
            isBot: true,
            timestamp: DateTime.now(),
          ));
        });
        _scrollToBottom();
        await _speak(response);
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.pushNamed(context, '/upload');
        }
        return;
      case 'report':
        response = AppStrings.get('bot_report', language);
        setState(() {
          _messages.add(ChatMessage(
            text: response,
            isBot: true,
            timestamp: DateTime.now(),
          ));
        });
        _scrollToBottom();
        await _speak(response);
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.pushNamed(context, '/results');
        }
        return;
      case 'home':
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        return;
    }

    setState(() {
      _messages.add(ChatMessage(
        text: response,
        isBot: true,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
    await _speak(response);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pushNamedAndRemoveUntil(
              context, '/home', (route) => false);
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFE3F2FD),
                Color(0xFFB3E5FC),
                Color(0xFFE1F5FE)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _buildChatArea(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF0288D1)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF1565C0).withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Text(
              '🤖',
              style: TextStyle(fontSize: 28),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HandyBot AI Coach',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1565C0),
                  ),
                ),
                Text(
                  _isSpeaking ? '🔊 Speaking...' : 'Your personal writing guide',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              _ttsEnabled ? Icons.volume_up : Icons.volume_off,
              color: Color(0xFF1565C0),
            ),
            onPressed: () {
              setState(() => _ttsEnabled = !_ttsEnabled);
              if (!_ttsEnabled) _stopSpeaking();
              // Update global settings
              final appState = Provider.of<AppState>(context, listen: false);
              appState.updateSettings(
                appState.settings.copyWith(voiceEnabled: _ttsEnabled),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_ttsEnabled ? 'Voice enabled' : 'Voice disabled'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.home_rounded, color: Color(0xFF1565C0)),
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context, '/home', (route) => false),
          ),
        ],
      ),
    );
  }

  Widget _buildChatArea() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == _messages.length) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    if (message.isActionButtons) {
      return _buildActionButtons();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.isBot) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF0288D1)],
                ),
                shape: BoxShape.circle,
              ),
              child: Text('🤖', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: message.isBot
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: message.isBot
                        ? LinearGradient(
                            colors: [
                              Color(0xFFE3F2FD),
                              Color(0xFFBBDEFB),
                            ],
                          )
                        : LinearGradient(
                            colors: [
                              Color(0xFF1565C0),
                              Color(0xFF0288D1),
                            ],
                          ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft:
                          Radius.circular(message.isBot ? 4 : 20),
                      bottomRight:
                          Radius.circular(message.isBot ? 20 : 4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: message.isBot
                          ? Colors.grey.shade800
                          : Colors.white,
                      height: 1.5,
                    ),
                  ),
                ),
                if (message.isBot) ...[
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () => _speak(message.text),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.volume_up,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Tap to replay',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!message.isBot) const SizedBox(width: 50),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF0288D1)],
              ),
              shape: BoxShape.circle,
            ),
            child: Text('🤖', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(1),
                const SizedBox(width: 4),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        final offset = (index * 0.2);
        final animValue = ((value + offset) % 1.0);
        return Transform.translate(
          offset: Offset(0, -4 * (animValue < 0.5 ? animValue * 2 : (1 - animValue) * 2)),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Color(0xFF1565C0),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Column(
        children: [
          Text(
            'What would you like to do?',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            icon: Icons.lightbulb,
            label: '💡 Give me tips',
            color: Color(0xFFFF9800),
            onTap: () => _handleUserAction('tips'),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            icon: Icons.videogame_asset,
            label: '🎮 Practice with me',
            color: Color(0xFF4CAF50),
            onTap: () => _handleUserAction('practice'),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            icon: Icons.assessment,
            label: '📊 Show my report',
            color: Color(0xFF2196F3),
            onTap: () => _handleUserAction('report'),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF0288D1)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF1565C0).withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => _handleUserAction('home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.home_rounded, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    '🏠 Go to Dashboard',
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isBot;
  final DateTime? timestamp;
  final bool isActionButtons;

  ChatMessage({
    required this.text,
    required this.isBot,
    this.timestamp,
    this.isActionButtons = false,
  });
}
