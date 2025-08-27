import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static const String _languageKey = 'selectedLanguage';

  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'ar': 'العربية',
    'ur': 'اردو',
  };

  static Future<void> saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }

  static Future<String> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'en';
  }

  static bool isRTL(String languageCode) {
    return ['ar', 'ur'].contains(languageCode);
  }

  static Locale getLocale(String languageCode) {
    return Locale(languageCode);
  }
}