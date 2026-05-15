import 'dart:ui';

class ForecastDay {
  final DateTime date;
  final double minTemp;
  final double maxTemp;
  final String description;
  final String icon;
  final int humidity;
  final double windSpeed;

  ForecastDay({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
  });
}

class AirQuality {
  final int aqi; // 1=Good, 2=Fair, 3=Moderate, 4=Poor, 5=Very Poor
  final double pm25;
  final double pm10;
  final double co;

  AirQuality({
    required this.aqi,
    required this.pm25,
    required this.pm10,
    required this.co,
  });

  String get aqiLabel {
    switch (aqi) {
      case 1: return 'Good';
      case 2: return 'Fair';
      case 3: return 'Moderate';
      case 4: return 'Poor';
      case 5: return 'Very Poor';
      default: return 'Unknown';
    }
  }

  Color get aqiColor {
    switch (aqi) {
      case 1: return const Color(0xFF22C55E);
      case 2: return const Color(0xFF84CC16);
      case 3: return const Color(0xFFFACC15);
      case 4: return const Color(0xFFF97316);
      case 5: return const Color(0xFFEF4444);
      default: return const Color(0xFF94A3B8);
    }
  }

  factory AirQuality.fromJson(Map<String, dynamic> json) {
    final components = json['list'][0]['components'];
    return AirQuality(
      aqi: json['list'][0]['main']['aqi'],
      pm25: components['pm2_5'].toDouble(),
      pm10: components['pm10'].toDouble(),
      co: components['co'].toDouble(),
    );
  }
}