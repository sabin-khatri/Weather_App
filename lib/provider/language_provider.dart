import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mmamc/service/translation_service.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _key = 'language_code';
  String _langCode = 'en';

  String get langCode => _langCode;

  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _langCode = prefs.getString(_key) ?? 'en';
    TranslationService.setLanguage(_langCode);
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    _langCode = code;
    TranslationService.setLanguage(code);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, code);
    notifyListeners();
  }

  String get languageName {
    switch (_langCode) {
      case 'ne': return 'नेपाली';
      case 'hi': return 'हिन्दी';
      default: return 'English';
    }
  }
}