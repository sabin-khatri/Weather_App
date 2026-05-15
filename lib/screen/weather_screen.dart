import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import 'package:mmamc/model/weather.dart';
import 'package:mmamc/model/forecast.dart';
import 'package:mmamc/service/weather_service.dart';
import 'package:mmamc/service/favorites_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final searchController = TextEditingController();
  Weather? weather;
  List<ForecastDay> forecast = [];
  AirQuality? airQuality;
  bool isLoading = false;
  bool isLocationLoading = false;
  String? errorMessage;
  bool isFavorite = false;
  List<String> favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favs = await FavoritesService.getFavorites();
    setState(() => favorites = favs);
  }

  Future<void> fetchWeather({String? city}) async {
    final query = city ?? searchController.text.trim();
    if (query.isEmpty) {
      setState(() => errorMessage = "Please enter a city name");
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await WeatherService.getWeather(query);
      final forecastResult = await WeatherService.getForecast(result.lat, result.lon);
      final aqiResult = await WeatherService.getAirQuality(result.lat, result.lon);
      final fav = await FavoritesService.isFavorite(result.cityName);

      setState(() {
        weather = result;
        forecast = forecastResult;
        airQuality = aqiResult;
        isFavorite = fav;
        isLoading = false;
      });

      searchController.clear();
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceAll('Exception: ', '');
        isLoading = false;
      });
    }
  }

  Future<void> fetchByLocation() async {
    setState(() {
      isLocationLoading = true;
      errorMessage = null;
    });

    try {
      final position = await WeatherService.getCurrentLocation();
      final result = await WeatherService.getWeatherByLocation(
        position.latitude,
        position.longitude,
      );
      final forecastResult = await WeatherService.getForecast(result.lat, result.lon);
      final aqiResult = await WeatherService.getAirQuality(result.lat, result.lon);
      final fav = await FavoritesService.isFavorite(result.cityName);

      setState(() {
        weather = result;
        forecast = forecastResult;
        airQuality = aqiResult;
        isFavorite = fav;
        isLocationLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceAll('Exception: ', '');
        isLocationLoading = false;
      });
    }
  }

  Future<void> toggleFavorite() async {
    if (weather == null) return;
    if (isFavorite) {
      await FavoritesService.removeFavorite(weather!.cityName);
    } else {
      await FavoritesService.addFavorite(weather!.cityName);
    }
    await _loadFavorites();
    setState(() => isFavorite = !isFavorite);
  }

  // Lottie animation URL by weather condition
  String getLottieUrl(String description) {
    final desc = description.toLowerCase();
    if (desc.contains('clear')) {
      return 'https://assets10.lottiefiles.com/packages/lf20_xlmz9xwm.json';
    } else if (desc.contains('cloud')) {
      return 'https://assets10.lottiefiles.com/packages/lf20_kd7kbf6m.json';
    } else if (desc.contains('rain') || desc.contains('drizzle')) {
      return 'https://assets10.lottiefiles.com/packages/lf20_bbsvqqq2.json';
    } else if (desc.contains('thunder')) {
      return 'https://assets10.lottiefiles.com/packages/lf20_jm7mv1ib.json';
    } else if (desc.contains('snow')) {
      return 'https://assets10.lottiefiles.com/packages/lf20_2glqweqs.json';
    } else {
      return 'https://assets10.lottiefiles.com/packages/lf20_xlmz9xwm.json';
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
    final desc = weather!.description.toLowerCase();
    if (desc.contains('clear')) {
      return const LinearGradient(colors: [Color(0xFF1E3A8A), Color(0xFF60A5FA)]);
    } else if (desc.contains('cloud')) {
      return const LinearGradient(colors: [Color(0xFF334155), Color(0xFF64748B)]);
    } else if (desc.contains('rain') || desc.contains('drizzle')) {
      return const LinearGradient(colors: [Color(0xFF1E2937), Color(0xFF334155)]);
    } else if (desc.contains('thunder')) {
      return const LinearGradient(colors: [Color(0xFF1E1B4B), Color(0xFF312E81)]);
    } else {
      return const LinearGradient(colors: [Color(0xFF1B2A4A), Color(0xFF0F1C3A)]);
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
                _buildHeader(),
                const SizedBox(height: 16),
                _buildSearchBar(),
                const SizedBox(height: 16),
                if (favorites.isNotEmpty) _buildFavoritesRow(),
                const SizedBox(height: 16),
                if (isLoading || isLocationLoading)
                  const CircularProgressIndicator(color: Colors.white),
                if (errorMessage != null) _buildErrorCard(),
                if (weather != null) ...[
                  const SizedBox(height: 10),
                  _buildMainCard(),
                  const SizedBox(height: 20),
                  _buildSunriseSunset(),
                  const SizedBox(height: 20),
                  _buildDetailsGrid(),
                  if (airQuality != null) ...[
                    const SizedBox(height: 20),
                    _buildAQICard(),
                  ],
                  if (forecast.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildForecastSection(),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Weather",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Row(
          children: [
            if (weather != null)
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.star : Icons.star_border,
                  color: isFavorite ? Colors.amber : Colors.white70,
                  size: 28,
                ),
                onPressed: toggleFavorite,
              ),
            IconButton(
              icon: isLocationLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location, color: Colors.white70, size: 28),
              onPressed: fetchByLocation,
            ),
          ],
        ),
      ],
    );
  }

  // ── Search Bar ──────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: TextField(
        controller: searchController,
        style: const TextStyle(color: Colors.white),
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => fetchWeather(),
        decoration: InputDecoration(
          hintText: 'Search city name...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          suffixIcon: IconButton(
            icon: const Icon(Icons.search, color: Colors.white70),
            onPressed: fetchWeather,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  // ── Favorites Row ───────────────────────────────────────
  Widget _buildFavoritesRow() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: favorites.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final city = favorites[index];
          return GestureDetector(
            onTap: () => fetchWeather(city: city),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 14),
                  const SizedBox(width: 6),
                  Text(city, style: const TextStyle(color: Colors.white, fontSize: 14)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Error Card ──────────────────────────────────────────
  Widget _buildErrorCard() {
    return Container(
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
    );
  }

  // ── Main Weather Card ───────────────────────────────────
  Widget _buildMainCard() {
    return Container(
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
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('EEEE, dd MMMM').format(DateTime.now()),
            style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.7)),
          ),
          const SizedBox(height: 16),

          // Lottie Animation
          SizedBox(
            height: 150,
            width: 150,
            child: Lottie.network(
              getLottieUrl(weather!.description),
              fit: BoxFit.contain,
              errorBuilder: (context, error, _) => Image.network(
                'https://openweathermap.org/img/wn/${weather!.icon}@4x.png',
                width: 130,
                height: 130,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.cloud_off, size: 100, color: Colors.white54),
              ),
            ),
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
            style: const TextStyle(fontSize: 18, letterSpacing: 3, color: Colors.white70),
          ),
          const SizedBox(height: 12),
          Text(
            'Feels like ${weather!.feelsLike.toStringAsFixed(1)}°C',
            style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  // ── Sunrise / Sunset ────────────────────────────────────
  Widget _buildSunriseSunset() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _sunItem(Icons.wb_sunny, "Sunrise", DateFormat('hh:mm a').format(weather!.sunrise)),
          Container(height: 50, width: 1, color: Colors.white24),
          _sunItem(Icons.nights_stay, "Sunset", DateFormat('hh:mm a').format(weather!.sunset)),
        ],
      ),
    );
  }

  Widget _sunItem(IconData icon, String label, String time) {
    return Column(
      children: [
        Icon(icon, color: Colors.amber, size: 28),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
        const SizedBox(height: 4),
        Text(time, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
      ],
    );
  }

  // ── Details Grid ────────────────────────────────────────
  Widget _buildDetailsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.65,
      children: [
        _detailCard(Icons.water_drop, "${weather!.humidity}%", "Humidity"),
        _detailCard(Icons.air, "${weather!.windSpeed} m/s", "Wind Speed"),
        _detailCard(Icons.compress, "${weather!.pressure} hPa", "Pressure"),
        _detailCard(Icons.visibility, "${(weather!.visibility / 1000).toStringAsFixed(1)} km", "Visibility"),
      ],
    );
  }

  Widget _detailCard(IconData icon, String value, String label) {
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
          Icon(icon, color: Colors.lightBlueAccent, size: 28),
          const Spacer(),
          Text(value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(label,
              style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.6))),
        ],
      ),
    );
  }

  // ── AQI Card ─────────────────────────────────────────────
  Widget _buildAQICard() {
    final aqi = airQuality!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.air, color: Colors.lightBlueAccent, size: 24),
              const SizedBox(width: 8),
              const Text("Air Quality",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: aqi.aqiColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: aqi.aqiColor),
                ),
                child: Text(aqi.aqiLabel,
                    style: TextStyle(color: aqi.aqiColor, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _aqiItem("PM2.5", "${aqi.pm25.toStringAsFixed(1)} µg"),
              _aqiItem("PM10", "${aqi.pm10.toStringAsFixed(1)} µg"),
              _aqiItem("CO", "${aqi.co.toStringAsFixed(1)} µg"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _aqiItem(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
      ],
    );
  }

  // ── 5-Day Forecast ───────────────────────────────────────
  Widget _buildForecastSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("5-Day Forecast",
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ...forecast.map((day) => _forecastTile(day)),
      ],
    );
  }

  Widget _forecastTile(ForecastDay day) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              DateFormat('EEE, MMM d').format(day.date),
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
            ),
          ),
          Image.network(
            'https://openweathermap.org/img/wn/${day.icon}@2x.png',
            width: 40,
            height: 40,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.cloud, color: Colors.white54, size: 30),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              day.description,
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${day.minTemp.toStringAsFixed(0)}° / ${day.maxTemp.toStringAsFixed(0)}°',
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}