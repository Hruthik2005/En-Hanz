import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _onboardingKey = 'onboarding_complete';
  static const _profileJsonKey = 'profile_json';
  static const _settingsJsonKey = 'settings_json';

  static Future<bool> getOnboardingFlag() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_onboardingKey) ?? false;
  }

  static Future<void> setOnboardingFlag(bool v) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_onboardingKey, v);
  }

  static Future<void> saveProfileJson(String json) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_profileJsonKey, json);
  }

  static Future<String?> loadProfileJson() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_profileJsonKey);
  }

  static Future<void> saveSettingsJson(String json) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_settingsJsonKey, json);
  }

  static Future<String?> loadSettingsJson() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_settingsJsonKey);
  }
}
