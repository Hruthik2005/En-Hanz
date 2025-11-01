import 'dart:convert';

import 'package:flutter/foundation.dart';
import '../models/profile.dart';
import '../models/app_settings.dart';
import '../services/storage_service.dart';

class AppState extends ChangeNotifier {
  Profile? profile;
  int iqScore = 0;
  double mentalAge = 0;
  double risk = 0.0;
  String recommendation = '';
  bool onboardingComplete = false;
  String? handwritingImagePath;
  AppSettings settings = AppSettings();

  AppState() {
    _init();
  }

  Future<void> _init() async {
    onboardingComplete = await StorageService.getOnboardingFlag();
    final json = await StorageService.loadProfileJson();
    if (json != null) {
      try {
        profile = Profile.fromJson(jsonDecode(json));
      } catch (_) {}
    }
    
    // Load settings
    final settingsJson = await StorageService.loadSettingsJson();
    if (settingsJson != null) {
      try {
        settings = AppSettings.fromJson(jsonDecode(settingsJson));
      } catch (_) {}
    }
    
    notifyListeners();
  }

  Future<void> setOnboardingComplete(bool v) async {
    onboardingComplete = v;
    await StorageService.setOnboardingFlag(v);
    notifyListeners();
  }

  Future<void> saveProfile(Profile p) async {
    profile = p;
    await StorageService.saveProfileJson(jsonEncode(p.toJson()));
    notifyListeners();
  }

  void saveIQ(int score, double mAge) {
    iqScore = score;
    mentalAge = mAge;
    notifyListeners();
  }

  void saveHandwritingPath(String path) {
    handwritingImagePath = path;
    notifyListeners();
  }

  void saveResult(double riskScore, String rec) {
    risk = riskScore;
    recommendation = rec;
    notifyListeners();
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    settings = newSettings;
    await StorageService.saveSettingsJson(jsonEncode(newSettings.toJson()));
    notifyListeners();
  }

  Future<void> clearAllData() async {
    profile = null;
    iqScore = 0;
    mentalAge = 0;
    risk = 0.0;
    recommendation = '';
    handwritingImagePath = null;
    await StorageService.saveProfileJson('');
    notifyListeners();
  }
}
