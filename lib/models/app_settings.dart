class AppSettings {
  final String language;
  final bool largeFontMode;
  final bool voiceEnabled;
  final bool notificationsEnabled;

  AppSettings({
    this.language = 'English',
    this.largeFontMode = false,
    this.voiceEnabled = true,
    this.notificationsEnabled = true,
  });

  AppSettings copyWith({
    String? language,
    bool? largeFontMode,
    bool? voiceEnabled,
    bool? notificationsEnabled,
  }) {
    return AppSettings(
      language: language ?? this.language,
      largeFontMode: largeFontMode ?? this.largeFontMode,
      voiceEnabled: voiceEnabled ?? this.voiceEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'largeFontMode': largeFontMode,
      'voiceEnabled': voiceEnabled,
      'notificationsEnabled': notificationsEnabled,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      language: json['language'] ?? 'English',
      largeFontMode: json['largeFontMode'] ?? false,
      voiceEnabled: json['voiceEnabled'] ?? true,
      notificationsEnabled: json['notificationsEnabled'] ?? true,
    );
  }

  double get fontSizeMultiplier => largeFontMode ? 1.3 : 1.0;
}
