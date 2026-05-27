import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _unitKey = 'temp_unit';
  static const _defaultCityKey = 'default_city';
  static const _notifEnabledKey = 'notif_enabled';
  static const _notifHourKey = 'notif_hour';
  static const _notifMinuteKey = 'notif_minute';
  static const _rainAlertKey = 'rain_alert';

  static Future<String> getUnit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_unitKey) ?? 'metric';
  }

  static Future<void> setUnit(String unit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_unitKey, unit);
  }

  static Future<String?> getDefaultCity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_defaultCityKey);
  }

  static Future<void> setDefaultCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_defaultCityKey, city);
  }

  static Future<bool> getNotifEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notifEnabledKey) ?? false;
  }

  static Future<void> setNotifEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notifEnabledKey, value);
  }

  static Future<int> getNotifHour() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_notifHourKey) ?? 7;
  }

  static Future<int> getNotifMinute() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_notifMinuteKey) ?? 0;
  }

  static Future<void> setNotifTime(int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_notifHourKey, hour);
    await prefs.setInt(_notifMinuteKey, minute);
  }

  static Future<bool> getRainAlert() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rainAlertKey) ?? true;
  }

  static Future<void> setRainAlert(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rainAlertKey, value);
  }
}