import 'package:flutter/material.dart';
import 'package:mmamc/model/weather.dart';
import 'package:mmamc/service/translation_service.dart';

class ComfortIndexCard extends StatelessWidget {
  final Weather weather;

  const ComfortIndexCard({super.key, required this.weather});

  int get _comfortScore {
    var score = 100.0;
    final temp = weather.temperature;
    final humidity = weather.humidity;
    final wind = weather.windSpeed;

    final tempDiff = (temp - 22).abs();
    score -= tempDiff * 2.5;

    if (humidity > 80) score -= 15;
    if (humidity < 25) score -= 8;
    if (wind > 8) score -= 12;

    final desc = weather.description.toLowerCase();
    if (desc.contains('rain') || desc.contains('thunder')) score -= 25;
    if (desc.contains('snow')) score -= 20;

    return score.clamp(0, 100).round();
  }

  Color get _scoreColor {
    final s = _comfortScore;
    if (s >= 75) return const Color(0xFF22C55E);
    if (s >= 50) return const Color(0xFFFACC15);
    return const Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context) {
    final score = _comfortScore;
    final color = _scoreColor;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: score / 100),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (_, value, __) => SizedBox(
              width: 64,
              height: 64,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: value,
                    strokeWidth: 5,
                    backgroundColor: Colors.white12,
                    color: color,
                  ),
                  Text(
                    '$score',
                    style: TextStyle(
                      color: color,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  TranslationService.get('comfortIndex'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _comfortLabel(score),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _comfortLabel(int score) {
    if (score >= 80) return TranslationService.get('comfortGreat');
    if (score >= 60) return TranslationService.get('comfortGood');
    if (score >= 40) return TranslationService.get('comfortFair');
    return TranslationService.get('comfortPoor');
  }
}
