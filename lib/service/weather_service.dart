import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mmamc/model/weather.dart';


class WeatherService {
  static const String _apiKey = 'cdd7176a047c94a0c3436198b8cd1e05';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  static Future<Weather> getWeather(String cityName) async {
    final url = Uri.parse(
      '$_baseUrl?q=$cityName&appid=$_apiKey&units=metric',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('City not found');
    } else {
      throw Exception('Failed to fetch weather');
    }
  }
}