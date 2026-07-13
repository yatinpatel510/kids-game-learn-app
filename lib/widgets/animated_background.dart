import 'dart:math';
import 'package:flutter/material.dart';

class FloatingParticle {
  double x, y, size, speed, opacity;
  final String symbol;
  final Color color;
  double angle;

  FloatingParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.symbol,
    required this.color,
    required this.angle,
  });
}

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<FloatingParticle> _particles = [];
  final Random _random = Random();

  final _symbols = ['⭐', '✨', '🫧', '💫', '🎉', '🌟', '❄️', '🔵'];
  final _colors = [
    Colors.yellow,
    Colors.pinkAccent,
    Colors.lightBlueAccent,
    Colors.purpleAccent,
    Colors.greenAccent,
    Colors.orangeAccent,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    for (int i = 0; i < 18; i++) {
      _particles.add(FloatingParticle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 14 + 10,
        speed: _random.nextDouble() * 0.003 + 0.001,
        opacity: _random.nextDouble() * 0.5 + 0.3,
        symbol: _symbols[_random.nextInt(_symbols.length)],
        color: _colors[_random.nextInt(_colors.length)],
        angle: _random.nextDouble() * 2 * pi,
      ));
    }
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
      builder: (_, __) {
        for (final p in _particles) {
          p.y -= p.speed;
          p.x += sin(p.angle) * 0.002;
          p.angle += 0.02;
          if (p.y < -0.05) {
            p.y = 1.05;
            p.x = _random.nextDouble();
          }
        }
        return CustomPaint(
          painter: _ParticlePainter(_particles),
          size: Size.infinite,
        );
      },
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final List<FloatingParticle> particles;
  _ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final tp = TextPainter(
        text: TextSpan(
          text: p.symbol,
          style: TextStyle(fontSize: p.size, color: p.color.withValues(alpha: p.opacity)),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(p.x * size.width, p.y * size.height));
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => true;
}
