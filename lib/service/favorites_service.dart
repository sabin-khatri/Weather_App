import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const String _key = 'favorite_cities';

  static Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  static Future<void> addFavorite(String city) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    if (!list.contains(city)) {
      list.add(city);
      await prefs.setStringList(_key, list);
    }
  }

  static Future<void> removeFavorite(String city) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    list.remove(city);
    await prefs.setStringList(_key, list);
  }

  static Future<bool> isFavorite(String city) async {
    final list = await getFavorites();
    return list.contains(city);
  }
}