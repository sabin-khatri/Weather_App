import 'dart:math';
import 'package:flutter/material.dart';

enum ParticleWeather { clear, cloudy, rainy, snowy, stormy, defaultSky }

class WeatherParticles extends StatefulWidget {
  final String weatherDescription;

  const WeatherParticles({super.key, required this.weatherDescription});

  @override
  State<WeatherParticles> createState() => _WeatherParticlesState();
}

class _WeatherParticlesState extends State<WeatherParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  late ParticleWeather _type;

  @override
  void initState() {
    super.initState();
    _type = _resolveType(widget.weatherDescription);
    _particles = _generateParticles(_type);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void didUpdateWidget(WeatherParticles oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.weatherDescription != widget.weatherDescription) {
      _type = _resolveType(widget.weatherDescription);
      _particles = _generateParticles(_type);
    }
  }

  ParticleWeather _resolveType(String desc) {
    final d = desc.toLowerCase();
    if (d.contains('thunder')) return ParticleWeather.stormy;
    if (d.contains('snow')) return ParticleWeather.snowy;
    if (d.contains('rain') || d.contains('drizzle')) {
      return ParticleWeather.rainy;
    }
    if (d.contains('cloud') || d.contains('mist') || d.contains('fog')) {
      return ParticleWeather.cloudy;
    }
    if (d.contains('clear')) return ParticleWeather.clear;
    return ParticleWeather.defaultSky;
  }

  List<_Particle> _generateParticles(ParticleWeather type) {
    final rng = Random(42);
    final count = switch (type) {
      ParticleWeather.rainy => 80,
      ParticleWeather.snowy => 50,
      ParticleWeather.stormy => 60,
      ParticleWeather.cloudy => 12,
      ParticleWeather.clear => 8,
      _ => 6,
    };

    return List.generate(count, (i) {
      return _Particle(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        size: rng.nextDouble() * 3 + 1,
        speed: rng.nextDouble() * 0.4 + 0.15,
        opacity: rng.nextDouble() * 0.5 + 0.2,
        drift: (rng.nextDouble() - 0.5) * 0.02,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _ParticlePainter(
            progress: _controller.value,
            particles: _particles,
            type: _type,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Particle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;
  final double drift;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.drift,
  });
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  final List<_Particle> particles;
  final ParticleWeather type;

  _ParticlePainter({
    required this.progress,
    required this.particles,
    required this.type,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      var py = (p.y + progress * p.speed) % 1.0;
      var px = (p.x + progress * p.drift) % 1.0;
      final x = px * size.width;
      final y = py * size.height;

      switch (type) {
        case ParticleWeather.rainy:
        case ParticleWeather.stormy:
          _drawRain(canvas, x, y, p);
        case ParticleWeather.snowy:
          _drawSnow(canvas, x, y, p);
        case ParticleWeather.cloudy:
          _drawCloud(canvas, x, y, p);
        case ParticleWeather.clear:
          _drawSunRay(canvas, size, x, y, p);
        default:
          _drawStar(canvas, x, y, p);
      }
    }
  }

  void _drawRain(Canvas canvas, double x, double y, _Particle p) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(p.opacity * 0.7)
      ..strokeWidth = p.size * 0.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(x, y), Offset(x - 2, y + 12 * p.size), paint);
  }

  void _drawSnow(Canvas canvas, double x, double y, _Particle p) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(p.opacity)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(x, y), p.size, paint);
  }

  void _drawCloud(Canvas canvas, double x, double y, _Particle p) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(p.opacity * 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(x, y),
        width: 60 + p.size * 20,
        height: 30 + p.size * 10,
      ),
      paint,
    );
  }

  void _drawSunRay(Canvas canvas, Size size, double x, double y, _Particle p) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.amber.withOpacity(p.opacity * 0.15),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset(x, y), radius: 40));
    canvas.drawCircle(Offset(x, y), 40, paint);
  }

  void _drawStar(Canvas canvas, double x, double y, _Particle p) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(p.opacity * 0.4);
    canvas.drawCircle(Offset(x, y), p.size * 0.8, paint);
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) =>
      old.progress != progress || old.type != type;
}
