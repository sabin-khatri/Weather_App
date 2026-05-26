import 'package:shared_preferences/shared_preferences.dart';

class HistoryService {
  static const String _key = 'search_history';
  static const int _maxHistory = 10;

  static Future<List<String>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  static Future<void> addHistory(String city) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    list.remove(city);
    list.insert(0, city);
    if (list.length > _maxHistory) list.removeLast();
    await prefs.setStringList(_key, list);
  }

  static Future<void> removeHistory(String city) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    list.remove(city);
    await prefs.setStringList(_key, list);
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}