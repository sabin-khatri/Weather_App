import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mmamc/model/weather.dart';
import 'package:mmamc/service/translation_service.dart';
import 'package:mmamc/util/moon_phase_util.dart';

class MoonPhaseCard extends StatelessWidget {
  final Weather weather;

  const MoonPhaseCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final moon = MoonPhaseUtil.getPhase();
    final goldenAm = MoonPhaseUtil.goldenHourMorning(weather.sunrise);
    final goldenPm = MoonPhaseUtil.goldenHourEvening(weather.sunset);
    final blueAm = MoonPhaseUtil.blueHourMorning(weather.sunrise);
    final bluePm = MoonPhaseUtil.blueHourEvening(weather.sunset);

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
          Row(
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutBack,
                builder: (_, v, child) => Transform.scale(scale: v, child: child),
                child: Text(moon.emoji, style: const TextStyle(fontSize: 36)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      TranslationService.get('moonPhase'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      TranslationService.get(moon.phaseName),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              _illuminationRing(moon.illumination),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 14),
          Text(
            TranslationService.get('goldenBlueHour'),
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _timeChip(
                  Icons.wb_twilight,
                  TranslationService.get('goldenHour'),
                  '${DateFormat('h:mm a').format(goldenAm)} · ${DateFormat('h:mm a').format(goldenPm)}',
                  const Color(0xFFFBBF24),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _timeChip(
                  Icons.nightlight_round,
                  TranslationService.get('blueHour'),
                  '${DateFormat('h:mm a').format(blueAm)} · ${DateFormat('h:mm a').format(bluePm)}',
                  const Color(0xFF818CF8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _illuminationRing(double illumination) {
    return SizedBox(
      width: 48,
      height: 48,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: illumination),
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeOutCubic,
        builder: (_, value, __) => Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: value,
              strokeWidth: 3,
              backgroundColor: Colors.white12,
              color: Colors.white70,
            ),
            Text(
              '${(value * 100).round()}%',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeChip(
    IconData icon,
    String label,
    String times,
    Color accent,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 18),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: accent,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            times,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
