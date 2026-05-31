import 'package:flutter/material.dart';
import 'package:mmamc/model/weather.dart';
import 'package:mmamc/service/translation_service.dart';

class WeatherMoodChip extends StatelessWidget {
  final Weather weather;

  const WeatherMoodChip({super.key, required this.weather});

  String get _moodKey {
    final desc = weather.description.toLowerCase();
    final temp = weather.temperature;

    if (desc.contains('thunder')) return 'moodStorm';
    if (desc.contains('rain') || desc.contains('drizzle')) return 'moodRain';
    if (desc.contains('snow')) return 'moodSnow';
    if (desc.contains('fog') || desc.contains('mist')) return 'moodFog';
    if (desc.contains('cloud')) {
      if (temp > 25) return 'moodWarmCloud';
      return 'moodCloudy';
    }
    if (desc.contains('clear')) {
      if (temp > 32) return 'moodHot';
      if (temp > 22) return 'moodSunny';
      if (temp < 10) return 'moodColdClear';
      return 'moodPerfect';
    }
    return 'moodDefault';
  }

  IconData get _icon {
    switch (_moodKey) {
      case 'moodStorm':
        return Icons.thunderstorm;
      case 'moodRain':
        return Icons.beach_access;
      case 'moodSnow':
        return Icons.ac_unit;
      case 'moodFog':
        return Icons.cloud_queue;
      case 'moodHot':
        return Icons.local_fire_department;
      case 'moodSunny':
      case 'moodPerfect':
        return Icons.emoji_emotions;
      case 'moodColdClear':
        return Icons.ac_unit_outlined;
      default:
        return Icons.wb_cloudy;
    }
  }

  Color get _glowColor {
    switch (_moodKey) {
      case 'moodStorm':
        return const Color(0xFF818CF8);
      case 'moodRain':
        return const Color(0xFF38BDF8);
      case 'moodSnow':
        return const Color(0xFFE0F2FE);
      case 'moodHot':
        return const Color(0xFFF97316);
      case 'moodPerfect':
      case 'moodSunny':
        return const Color(0xFFFBBF24);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.85, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _glowColor.withOpacity(0.25),
              _glowColor.withOpacity(0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _glowColor.withOpacity(0.4)),
          boxShadow: [
            BoxShadow(
              color: _glowColor.withOpacity(0.2),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icon, color: _glowColor, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                TranslationService.get(_moodKey),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
