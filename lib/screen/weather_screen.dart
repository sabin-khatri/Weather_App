import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import 'package:mmamc/screen/map_screen.dart';
import 'package:provider/provider.dart';
import 'package:mmamc/model/weather.dart';
import 'package:mmamc/model/forecast.dart';
import 'package:mmamc/screen/settings_screen.dart';
import 'package:mmamc/screen/history_screen.dart';
import 'package:mmamc/service/weather_service.dart';
import 'package:mmamc/service/favorites_service.dart';
import 'package:mmamc/service/settings_service.dart';
import 'package:mmamc/service/notification_service.dart';
import 'package:mmamc/service/history_service.dart';
import 'package:mmamc/service/translation_service.dart';
import 'package:mmamc/provider/theme_provider.dart';
import 'package:mmamc/provider/language_provider.dart';
import 'package:mmamc/model/hourly_forecast.dart';
import 'package:mmamc/widget/tubelight_dock.dart';
import 'package:mmamc/widget/bioweather_card.dart';
import 'package:mmamc/widget/weather_particles.dart';
import 'package:mmamc/widget/fade_slide_in.dart';
import 'package:mmamc/widget/weather_mood_chip.dart';
import 'package:mmamc/widget/hourly_strip.dart';
import 'package:mmamc/widget/moon_phase_card.dart';
import 'package:mmamc/widget/comfort_index_card.dart';
import 'package:mmamc/util/responsive.dart';


class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final searchController = TextEditingController();
  Weather? weather;
  List<ForecastDay> forecast = [];
  List<HourlyForecast> hourly = [];
  AirQuality? airQuality;
  bool isLoading = false;
  bool isLocationLoading = false;
  String? errorMessage;
  bool isFavorite = false;
  List<String> favorites = [];
  String _tempUnit = '°C';

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _loadDefaultCity();
    _loadUnit();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUnit() async {
    final unit = await SettingsService.getUnit();
    setState(() => _tempUnit = unit == 'metric' ? '°C' : '°F');
  }

  Future<void> _loadFavorites() async {
    final favs = await FavoritesService.getFavorites();
    setState(() => favorites = favs);
  }

  Future<void> _loadDefaultCity() async {
    final city = await SettingsService.getDefaultCity();
    if (city != null && city.isNotEmpty) {
      fetchWeather(city: city);
    }
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
      final forecastResult = await WeatherService.getForecast(
        result.lat,
        result.lon,
      );
      final hourlyResult = await WeatherService.getHourlyForecast(
        result.lat,
        result.lon,
      );
      final aqiResult = await WeatherService.getAirQuality(
        result.lat,
        result.lon,
      );
      final fav = await FavoritesService.isFavorite(result.cityName);

      await HistoryService.addHistory(result.cityName);

      final rainAlert = await SettingsService.getRainAlert();
      if (rainAlert) {
        final desc = result.description.toLowerCase();
        if (desc.contains('rain') ||
            desc.contains('drizzle') ||
            desc.contains('thunder')) {
          await NotificationService.showRainWarning(result.cityName);
        }
      }

      final unit = await SettingsService.getUnit();

      setState(() {
        weather = result;
        forecast = forecastResult;
        hourly = hourlyResult;
        airQuality = aqiResult;
        isFavorite = fav;
        isLoading = false;
        _tempUnit = unit == 'metric' ? '°C' : '°F';
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
      final forecastResult = await WeatherService.getForecast(
        result.lat,
        result.lon,
      );
      final hourlyResult = await WeatherService.getHourlyForecast(
        result.lat,
        result.lon,
      );
      final aqiResult = await WeatherService.getAirQuality(
        result.lat,
        result.lon,
      );
      final fav = await FavoritesService.isFavorite(result.cityName);

      await HistoryService.addHistory(result.cityName);

      final rainAlert = await SettingsService.getRainAlert();
      if (rainAlert) {
        final desc = result.description.toLowerCase();
        if (desc.contains('rain') ||
            desc.contains('drizzle') ||
            desc.contains('thunder')) {
          await NotificationService.showRainWarning(result.cityName);
        }
      }

      final unit = await SettingsService.getUnit();

      setState(() {
        weather = result;
        forecast = forecastResult;
        hourly = hourlyResult;
        airQuality = aqiResult;
        isFavorite = fav;
        isLocationLoading = false;
        _tempUnit = unit == 'metric' ? '°C' : '°F';
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceAll('Exception: ', '');
        isLocationLoading = false;
      });
    }
  }

  Future<void> _refreshWeather() async {
    if (weather != null) {
      await fetchWeather(city: weather!.cityName);
    } else {
      await fetchByLocation();
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

  LinearGradient getBackgroundGradient(bool isDark) {
    if (weather == null) {
      return LinearGradient(
        colors: isDark
            ? [const Color(0xFF1B2A4A), const Color(0xFF0F1C3A)]
            : [const Color(0xFF4A90D9), const Color(0xFF87CEEB)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    }
    final desc = weather!.description.toLowerCase();
    if (desc.contains('clear')) {
      return LinearGradient(
        colors: isDark
            ? [const Color(0xFF1E3A8A), const Color(0xFF60A5FA)]
            : [const Color(0xFF3B82F6), const Color(0xFFBAE6FD)],
      );
    } else if (desc.contains('cloud')) {
      return LinearGradient(
        colors: isDark
            ? [const Color(0xFF334155), const Color(0xFF64748B)]
            : [const Color(0xFF94A3B8), const Color(0xFFCBD5E1)],
      );
    } else if (desc.contains('rain') || desc.contains('drizzle')) {
      return LinearGradient(
        colors: isDark
            ? [const Color(0xFF1E2937), const Color(0xFF334155)]
            : [const Color(0xFF475569), const Color(0xFF94A3B8)],
      );
    } else if (desc.contains('thunder')) {
      return LinearGradient(
        colors: isDark
            ? [const Color(0xFF1E1B4B), const Color(0xFF312E81)]
            : [const Color(0xFF4338CA), const Color(0xFF818CF8)],
      );
    } else {
      return LinearGradient(
        colors: isDark
            ? [const Color(0xFF1B2A4A), const Color(0xFF0F1C3A)]
            : [const Color(0xFF4A90D9), const Color(0xFF87CEEB)],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    context.watch<LanguageProvider>(); // ← language change हुँदा rebuild

    final particleDesc = weather?.description ?? 'clear sky';
    final hPad = Responsive.horizontalPadding(context);
    final bottomInset = Responsive.scrollBottomInset(context);
    final gap = Responsive.isCompact(context) ? 14.0 : 20.0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        decoration:
            BoxDecoration(gradient: getBackgroundGradient(isDark)),
        child: SizedBox.expand(
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: WeatherParticles(weatherDescription: particleDesc),
                ),
              ),
              SafeArea(
                child: RefreshIndicator(
                  onRefresh: _refreshWeather,
                  color: Colors.white,
                  backgroundColor: Colors.white24,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.only(
                      left: hPad,
                      right: hPad,
                      top: 16,
                      bottom: bottomInset,
                    ),
                    child: Column(
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 16),
                        _buildSearchBar(),
                        const SizedBox(height: 16),
                        if (favorites.isNotEmpty) _buildFavoritesRow(),
                        const SizedBox(height: 16),
                        if (isLoading || isLocationLoading)
                          const Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        if (errorMessage != null) _buildErrorCard(),

                      if (weather == null && !isLoading && !isLocationLoading && errorMessage == null) ...[
                        const SizedBox(height: 50),
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.06),
                            border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.lightBlueAccent.withOpacity(0.15),
                                blurRadius: 30,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Lottie.network(
                              'https://assets10.lottiefiles.com/packages/lf20_kd7kbf6m.json', // Cloud & Sun animation
                              height: 100,
                              width: 100,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.wb_sunny_outlined,
                                size: 70,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          TranslationService.get('welcomeTitle'),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            TranslationService.get('welcomeSubtitle'),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.7),
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
  
                      if (weather != null) ...[
                        const SizedBox(height: 10),
                        FadeSlideIn(
                          delayMs: 0,
                          child: Center(
                            child: WeatherMoodChip(weather: weather!),
                          ),
                        ),
                        const SizedBox(height: 16),
                        FadeSlideIn(delayMs: 80, child: _buildMainCard()),
                        SizedBox(height: gap),
                        FadeSlideIn(delayMs: 160, child: _buildSunriseSunset()),
                        FadeSlideIn(
                          delayMs: 240,
                          child: ComfortIndexCard(weather: weather!),
                        ),
                        SizedBox(height: gap),
                        if (hourly.isNotEmpty)
                          FadeSlideIn(
                            delayMs: 320,
                            child: HourlyStrip(
                              hourly: hourly,
                              tempUnit: _tempUnit,
                            ),
                          ),
                        if (hourly.isNotEmpty) SizedBox(height: gap),
                        FadeSlideIn(
                          delayMs: 400,
                          child: MoonPhaseCard(weather: weather!),
                        ),
                        SizedBox(height: gap),
                        FadeSlideIn(
                          delayMs: 480,
                          child: BioweatherCard(
                            weather: weather!,
                            airQuality: airQuality,
                          ),
                        ),
                        SizedBox(height: gap),
                        FadeSlideIn(
                          delayMs: 560,
                          child: LayoutBuilder(
                            builder: (context, _) => _buildDetailsGrid(),
                          ),
                        ),
                        if (airQuality != null) ...[
                          SizedBox(height: gap),
                          FadeSlideIn(delayMs: 640, child: _buildAQICard()),
                        ],
                        if (forecast.isNotEmpty) ...[
                          SizedBox(height: gap),
                          FadeSlideIn(
                            delayMs: 720,
                            child: _buildForecastSection(),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            ),
              Positioned(
                left: hPad,
                right: hPad,
                bottom: 0,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: TubelightDock(
                    hasWeather: weather != null,
                    isFavorite: isFavorite,
                    isLocationLoading: isLocationLoading,
                    onMapPressed: weather == null
                        ? null
                        : () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MapScreen(
                                  lat: weather!.lat,
                                  lon: weather!.lon,
                                  cityName: weather!.cityName,
                                ),
                              ),
                            ),
                    onFavoritePressed: weather == null ? null : toggleFavorite,
                    onLocationPressed: fetchByLocation,
                    onHistoryPressed: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (_) => HistoryScreen(
                          onCitySelected: (city) => fetchWeather(city: city),
                        ),
                      );
                    },
                    onSettingsPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                      _loadFavorites();
                      _loadDefaultCity();
                      _loadUnit();
                    },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final titleSize = Responsive.sp(context, 26);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            TranslationService.get('appTitle'),
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Text(
            DateFormat('h:mm a').format(DateTime.now()),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

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
          hintText: TranslationService.get('search'),
          hintStyle:
              TextStyle(color: Colors.white.withOpacity(0.7)),
          prefixIcon:
              const Icon(Icons.search, color: Colors.white70),
          suffixIcon: IconButton(
            icon: const Icon(Icons.search, color: Colors.white70),
            onPressed: fetchWeather,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

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
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: Colors.white.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star,
                      color: Colors.amber, size: 14),
                  const SizedBox(width: 6),
                  Text(city,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 14)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

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

  Widget _buildMainCard() {
    final pad = Responsive.cardPadding(context);
    final lottieSize = Responsive.mainLottieSize(context);
    final tempSize = Responsive.mainTempFontSize(context);
    final citySize = Responsive.sp(context, 36);

    return Hero(
      tag: 'weather_main_card',
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(pad),
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
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: citySize,
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
              const SizedBox(height: 16),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.85, end: 1),
                duration: const Duration(milliseconds: 700),
                curve: Curves.elasticOut,
                builder: (_, scale, child) =>
                    Transform.scale(scale: scale, child: child),
                child: SizedBox(
                  height: lottieSize,
                  width: lottieSize,
                  child: Lottie.network(
                    getLottieUrl(weather!.description),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, _) => Image.network(
                      'https://openweathermap.org/img/wn/${weather!.icon}@4x.png',
                      width: 130,
                      height: 130,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.cloud_off,
                        size: 100,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                ),
              ),
              TweenAnimationBuilder<double>(
                key: ValueKey('${weather!.cityName}_${weather!.temperature}'),
                tween: Tween(begin: 0, end: weather!.temperature),
                duration: const Duration(milliseconds: 1200),
                curve: Curves.easeOutCubic,
                builder: (_, value, __) => FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${value.toStringAsFixed(1)}$_tempUnit',
                    style: TextStyle(
                      fontSize: tempSize,
                      fontWeight: FontWeight.w200,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
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
                '${TranslationService.get('feelsLike')} ${weather!.feelsLike.toStringAsFixed(1)}$_tempUnit',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSunriseSunset() {
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _sunItem(
            Icons.wb_sunny,
            TranslationService.get('sunrise'),
            DateFormat('hh:mm a').format(weather!.sunrise),
          ),
          Container(height: 50, width: 1, color: Colors.white24),
          _sunItem(
            Icons.nights_stay,
            TranslationService.get('sunset'),
            DateFormat('hh:mm a').format(weather!.sunset),
          ),
        ],
      ),
    );
  }

  Widget _sunItem(IconData icon, String label, String time) {
    return Column(
      children: [
        Icon(icon, color: Colors.amber, size: 28),
        const SizedBox(height: 6),
        Text(label,
            style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 13)),
        const SizedBox(height: 4),
        Text(time,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildDetailsGrid() {
    final cardHeight = Responsive.detailCardHeight(context);
    final spacing = Responsive.isCompact(context) ? 12.0 : 16.0;
    final iconSize = Responsive.sp(context, 22);
    final valueSize = Responsive.sp(context, 18);
    final labelSize = Responsive.sp(context, 11);
    final cardPad = Responsive.sp(context, 12);

    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        mainAxisExtent: cardHeight,
      ),
      children: [
        _detailCard(Icons.water_drop,
            "${weather!.humidity}%",
            TranslationService.get('humidity'),
            iconSize: iconSize,
            valueSize: valueSize,
            labelSize: labelSize,
            padding: cardPad),
        _detailCard(Icons.air,
            "${weather!.windSpeed} m/s",
            TranslationService.get('windSpeed'),
            iconSize: iconSize,
            valueSize: valueSize,
            labelSize: labelSize,
            padding: cardPad),
        _detailCard(Icons.compress,
            "${weather!.pressure} hPa",
            TranslationService.get('pressure'),
            iconSize: iconSize,
            valueSize: valueSize,
            labelSize: labelSize,
            padding: cardPad),
        _detailCard(
          Icons.visibility,
          "${(weather!.visibility / 1000).toStringAsFixed(1)} km",
          TranslationService.get('visibility'),
          iconSize: iconSize,
          valueSize: valueSize,
          labelSize: labelSize,
          padding: cardPad,
        ),
      ],
    );
  }

  Widget _detailCard(
    IconData icon,
    String value,
    String label, {
    required double iconSize,
    required double valueSize,
    required double labelSize,
    required double padding,
  }) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Icon(icon, color: Colors.lightBlueAccent, size: iconSize),
          const Spacer(flex: 1),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: valueSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: labelSize,
              height: 1.2,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

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
              const Icon(Icons.air,
                  color: Colors.lightBlueAccent, size: 24),
              const SizedBox(width: 8),
              Text(TranslationService.get('airQuality'),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: aqi.aqiColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: aqi.aqiColor),
                ),
                child: Text(aqi.aqiLabel,
                    style: TextStyle(
                        color: aqi.aqiColor,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _aqiItem("PM2.5",
                  "${aqi.pm25.toStringAsFixed(1)} µg"),
              _aqiItem("PM10",
                  "${aqi.pm10.toStringAsFixed(1)} µg"),
              _aqiItem(
                  "CO", "${aqi.co.toStringAsFixed(1)} µg"),
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
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 13)),
      ],
    );
  }

  Widget _buildForecastSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TranslationService.get('fiveDayForecast'),
          style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ...forecast.map((day) => _forecastTile(day)),
      ],
    );
  }

  Widget _forecastTile(ForecastDay day) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(
          horizontal: 20, vertical: 14),
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
              style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14),
            ),
          ),
          Image.network(
            'https://openweathermap.org/img/wn/${day.icon}@2x.png',
            width: 40,
            height: 40,
            errorBuilder: (_, __, ___) => const Icon(
                Icons.cloud,
                color: Colors.white54,
                size: 30),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              day.description,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${day.minTemp.toStringAsFixed(0)}° / ${day.maxTemp.toStringAsFixed(0)}°',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}