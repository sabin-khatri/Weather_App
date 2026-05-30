import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mmamc/model/hourly_forecast.dart';
import 'package:mmamc/service/translation_service.dart';
import 'package:mmamc/util/responsive.dart';

class HourlyStrip extends StatelessWidget {
  final List<HourlyForecast> hourly;
  final String tempUnit;

  const HourlyStrip({
    super.key,
    required this.hourly,
    required this.tempUnit,
  });

  @override
  Widget build(BuildContext context) {
    if (hourly.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TranslationService.get('hourlyForecast'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: Responsive.isCompact(context) ? 118 : 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: hourly.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final item = hourly[index];
              final isNow = index == 0;
              return _HourlyTile(
                item: item,
                tempUnit: tempUnit,
                isNow: isNow,
                delayMs: index * 60,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HourlyTile extends StatefulWidget {
  final HourlyForecast item;
  final String tempUnit;
  final bool isNow;
  final int delayMs;

  const _HourlyTile({
    required this.item,
    required this.tempUnit,
    required this.isNow,
    required this.delayMs,
  });

  @override
  State<_HourlyTile> createState() => _HourlyTileState();
}

class _HourlyTileState extends State<_HourlyTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scale = Tween<double>(begin: 0.7, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeLabel = widget.isNow
        ? TranslationService.get('now')
        : DateFormat('ha').format(widget.item.time);

    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: Responsive.isCompact(context) ? 64 : 72,
        padding: EdgeInsets.symmetric(
          vertical: Responsive.isCompact(context) ? 10 : 14,
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          gradient: widget.isNow
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.22),
                    Colors.white.withOpacity(0.08),
                  ],
                )
              : null,
          color: widget.isNow ? null : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.isNow
                ? Colors.white.withOpacity(0.4)
                : Colors.white.withOpacity(0.15),
          ),
          boxShadow: widget.isNow
              ? [
                  BoxShadow(
                    color: Colors.lightBlueAccent.withOpacity(0.2),
                    blurRadius: 12,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              timeLabel,
              style: TextStyle(
                color: widget.isNow ? Colors.white : Colors.white70,
                fontSize: 12,
                fontWeight: widget.isNow ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            Image.network(
              'https://openweathermap.org/img/wn/${widget.item.icon}@2x.png',
              width: 36,
              height: 36,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.cloud,
                color: Colors.white54,
                size: 28,
              ),
            ),
            Text(
              '${widget.item.temp.toStringAsFixed(0)}${widget.tempUnit.replaceAll('°C', '°').replaceAll('°F', '°')}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
