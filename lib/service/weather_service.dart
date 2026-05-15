import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:mmamc/model/weather.dart';
import 'package:mmamc/model/forecast.dart';

class WeatherService {
  static const String _apiKey = 'cdd7176a047c94a0c3436198b8cd1e05';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  // Current weather by city name
  static Future<Weather> getWeather(String city) async {
    final url = Uri.parse('$_baseUrl/weather?q=$city&appid=$_apiKey&units=metric');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('City not found');
    } else {
      throw Exception('Failed to fetch weather');
    }
  }

  // Current weather by GPS coordinates
  static Future<Weather> getWeatherByLocation(double lat, double lon) async {
    final url = Uri.parse('$_baseUrl/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch weather for your location');
    }
  }

  // 5-Day Forecast
  static Future<List<ForecastDay>> getForecast(double lat, double lon) async {
    final url = Uri.parse('$_baseUrl/forecast?lat=$lat&lon=$lon&appid=$_apiKey&units=metric');
    final response = await http.get(url);

    if (response.statusCode != 200) throw Exception('Failed to fetch forecast');

    final data = jsonDecode(response.body);
    final List items = data['list'];

    // Group by day, take one entry per day (noon time)
    Map<String, List<dynamic>> grouped = {};
    for (var item in items) {
      final date = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
      final key = '${date.year}-${date.month}-${date.day}';
      grouped.putIfAbsent(key, () => []).add(item);
    }

    return grouped.entries.skip(1).take(5).map((entry) {
      final dayItems = entry.value;
      final temps = dayItems.map((e) => e['main']['temp'].toDouble()).toList();
      final midItem = dayItems[dayItems.length ~/ 2];

      return ForecastDay(
        date: DateTime.fromMillisecondsSinceEpoch(dayItems[0]['dt'] * 1000),
        minTemp: temps.reduce((a, b) => a < b ? a : b),
        maxTemp: temps.reduce((a, b) => a > b ? a : b),
        description: midItem['weather'][0]['description'],
        icon: midItem['weather'][0]['icon'],
        humidity: midItem['main']['humidity'],
        windSpeed: midItem['wind']['speed'].toDouble(),
      );
    }).toList();
  }

  // Air Quality Index
  static Future<AirQuality> getAirQuality(double lat, double lon) async {
    final url = Uri.parse('http://api.openweathermap.org/data/2.5/air_pollution?lat=$lat&lon=$lon&appid=$_apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return AirQuality.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch air quality');
    }
  }

  // Get current GPS location
  static Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('Location services are disabled');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}