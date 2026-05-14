import 'package:flutter/material.dart';
import 'package:mmamc/model/weather.dart';
import 'package:mmamc/service/weather_service.dart';
import 'package:intl/intl.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final searchcontroller = TextEditingController();
  Weather? weather;
  bool isLoading = false;
  String? errorMessage;

  
  Future<void> fetchWeather() async {
    final city = searchcontroller.text.trim();

    if (city.isEmpty) {
      setState(() {
        errorMessage = "Please enter a city name";
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await WeatherService.getWeather(city);
      setState(() {
        weather = result;
        isLoading = false;
        errorMessage = null;
      });

      
      searchcontroller.clear();

    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceAll('Exception: ', '');
        isLoading = false;
      });
    }
  }

  
  LinearGradient getBackgroundGradient() {
    if (weather == null) {
      return const LinearGradient(
        colors: [Color(0xFF1B2A4A), Color(0xFF0F1C3A)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    }

    String desc = weather!.description.toLowerCase();

    if (desc.contains('clear')) {
      return const LinearGradient(colors: [Color(0xFF1E3A8A), Color(0xFF60A5FA)]);
    } else if (desc.contains('cloud')) {
      return const LinearGradient(colors: [Color(0xFF334155), Color(0xFF64748B)]);
    } else if (desc.contains('rain') || desc.contains('drizzle')) {
      return const LinearGradient(colors: [Color(0xFF1E2937), Color(0xFF334155)]);
    } else if (desc.contains('thunder')) {
      return const LinearGradient(colors: [Color(0xFF1E1B4B), Color(0xFF312E81)]);
    } else {
      return const LinearGradient(
        colors: [Color(0xFF1B2A4A), Color(0xFF0F1C3A)],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: getBackgroundGradient()),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Weather",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                   
                  ],
                ),

                const SizedBox(height: 20),

                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.25)),
                  ),
                  child: TextField(
                    controller: searchcontroller,
                    style: const TextStyle(color: Colors.white),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => fetchWeather(),
                    decoration: InputDecoration(
                      hintText: 'Search city name...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                      prefixIcon: const Icon(Icons.search, color: Colors.white70),
                      suffixIcon: searchcontroller.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.white70),
                              onPressed: () => searchcontroller.clear(),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                if (isLoading)
                  const CircularProgressIndicator(color: Colors.white),

                if (errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.red.withOpacity(0.4)),
                    ),
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                  ),

                if (weather != null) ...[
                  const SizedBox(height: 20),

                  // Main Weather Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Colors.white.withOpacity(0.25)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 25,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          weather!.cityName,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat('EEEE, dd MMMM').format(DateTime.now()),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Image.network(
                          'https://openweathermap.org/img/wn/${weather!.icon}@4x.png',
                          width: 160,
                          height: 160,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.cloud_off, size: 100, color: Colors.white54),
                        ),
                        Text(
                          '${weather!.temperature.toStringAsFixed(1)}°C',
                          style: const TextStyle(
                            fontSize: 78,
                            fontWeight: FontWeight.w200,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                        Text(
                          weather!.description.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 18,
                            letterSpacing: 3,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Feels like ${weather!.feelsLike.toStringAsFixed(1)}°C',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Details Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.65,
                    children: [
                      detailCard(Icons.water_drop, "${weather!.humidity}%", "Humidity"),
                      detailCard(Icons.air, "${weather!.windSpeed} m/s", "Wind Speed"),
                      detailCard(Icons.compress, "${weather!.pressure} hPa", "Pressure"),
                      detailCard(Icons.visibility, "${(weather!.visibility / 1000).toStringAsFixed(1)} km", "Visibility"),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget detailCard(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.lightBlueAccent, size: 32),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}