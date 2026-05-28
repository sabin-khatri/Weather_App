import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;


class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);

    await _plugin.initialize(settings);
  }

  // Daily morning weather notification
  static Future<void> scheduleDailyNotification({
    required String city,
    required String weather,
    required int hour,
    required int minute,
  }) async {
    await _plugin.cancel(1);
  }

  // Rain warning notification
  static Future<void> showRainWarning(String city) async {
    await _plugin.show(
      1,
      '🌧 Rain Alert!',
      'Rain expected in $city today. Don\'t forget your umbrella!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'rain_alert',
          'Rain Alert',
          channelDescription: 'Rain warning notifications',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

}