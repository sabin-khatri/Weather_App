import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:mmamc/provider/theme_provider.dart';
import 'package:mmamc/provider/language_provider.dart';

class MapScreen extends StatefulWidget {
  final double lat;
  final double lon;
  final String cityName;

  const MapScreen({
    super.key,
    required this.lat,
    required this.lon,
    required this.cityName,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  static const String _apiKey = 'cdd7176a047c94a0c3436198b8cd1e05';

  final List<Map<String, String>> _layers = [
    {'id': 'temp_new', 'label': '🌡 Temperature'},
    {'id': 'precipitation_new', 'label': '🌧 Precipitation'},
    {'id': 'clouds_new', 'label': '☁️ Clouds'},
    {'id': 'wind_new', 'label': '💨 Wind Speed'},
    {'id': 'pressure_new', 'label': '📊 Pressure'},
  ];

  String _selectedLayer = 'temp_new';

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    context.watch<LanguageProvider>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF1B2A4A), const Color(0xFF0F1C3A)]
                : [const Color(0xFF4A90D9), const Color(0xFF87CEEB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🗺️ Weather Map',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.cityName,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _layers.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final layer = _layers[index];
                    final isSelected = _selectedLayer == layer['id'];
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedLayer = layer['id']!),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.lightBlueAccent.withOpacity(0.3)
                              : Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? Colors.lightBlueAccent
                                : Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          layer['label']!,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.lightBlueAccent
                                : Colors.white70,
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: LatLng(widget.lat, widget.lon),
                      initialZoom: 7,
                      minZoom: 2,
                      maxZoom: 15,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: isDark
                            ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                            : 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                        subdomains: const ['a', 'b', 'c', 'd'],
                        userAgentPackageName: 'com.mmamc.app',
                      ),
                      Opacity(
                        opacity: 0.8,
                        child: TileLayer(
                          urlTemplate:
                              'http://tile.openweathermap.org/map/$_selectedLayer/{z}/{x}/{y}.png?appid=$_apiKey',
                          userAgentPackageName: 'com.mmamc.app',
                        ),
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(widget.lat, widget.lon),
                            width: 80,
                            height: 70,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.black.withOpacity(0.3),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    widget.cityName,
                                    style: const TextStyle(
                                      color: Color(0xFF1B2A4A),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(
                                  Icons.location_pin,
                                  color: Colors.red,
                                  size: 28,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              _buildLegend(),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: 'zoom_in',
            backgroundColor: Colors.white.withOpacity(0.2),
            onPressed: () {
              final zoom = _mapController.camera.zoom;
              _mapController.move(
                _mapController.camera.center,
                zoom + 1,
              );
            },
            child: const Icon(Icons.add, color: Colors.white),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'zoom_out',
            backgroundColor: Colors.white.withOpacity(0.2),
            onPressed: () {
              final zoom = _mapController.camera.zoom;
              _mapController.move(
                _mapController.camera.center,
                zoom - 1,
              );
            },
            child: const Icon(Icons.remove, color: Colors.white),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'center',
            backgroundColor: Colors.lightBlueAccent.withOpacity(0.8),
            onPressed: () {
              _mapController.move(
                LatLng(widget.lat, widget.lon),
                7,
              );
            },
            child: const Icon(Icons.my_location, color: Colors.white),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    final Map<String, List<Map<String, Object>>> legends = {
      'temp_new': [
        {'color': const Color(0xFF0000FF), 'label': '-40°'},
        {'color': const Color(0xFF00FFFF), 'label': '0°'},
        {'color': const Color(0xFF00FF00), 'label': '20°'},
        {'color': const Color(0xFFFFFF00), 'label': '30°'},
        {'color': const Color(0xFFFF0000), 'label': '40°+'},
      ],
      'precipitation_new': [
        {'color': const Color(0xFFE0F7FA), 'label': 'Low'},
        {'color': const Color(0xFF4FC3F7), 'label': 'Mid'},
        {'color': const Color(0xFF0D47A1), 'label': 'High'},
      ],
      'clouds_new': [
        {'color': const Color(0xFFFFFFFF), 'label': '0%'},
        {'color': const Color(0xFF9E9E9E), 'label': '50%'},
        {'color': const Color(0xFF212121), 'label': '100%'},
      ],
      'wind_new': [
        {'color': const Color(0xFF80CBC4), 'label': 'Calm'},
        {'color': const Color(0xFF4DB6AC), 'label': 'Moderate'},
        {'color': const Color(0xFF00695C), 'label': 'Strong'},
      ],
      'pressure_new': [
        {'color': const Color(0xFFE1BEE7), 'label': 'Low'},
        {'color': const Color(0xFF9C27B0), 'label': 'Normal'},
        {'color': const Color(0xFF4A148C), 'label': 'High'},
      ],
    };

    final currentLegend = legends[_selectedLayer] ?? [];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: Colors.black.withOpacity(0.3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: currentLegend.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: item['color'] as Color,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Colors.white24,
                      width: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  item['label'] as String,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}