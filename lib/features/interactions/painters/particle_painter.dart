import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ParticlePainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  static const int _particleCount = 10;
  static const List<Color> _colors = [
    AppColors.like,
    AppColors.gold,
    Colors.white,
    Color(0xFFFF6B8A),
    Color(0xFFFFB347),
  ];

  const ParticlePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final random = math.Random(42); // fixed seed for consistent pattern

    for (int i = 0; i < _particleCount; i++) {
      final angle =
          (i / _particleCount) * 2 * math.pi + (random.nextDouble() * 0.5);
      final maxRadius = 45.0 + random.nextDouble() * 15;
      final radius = maxRadius * progress;
      final opacity = (1.0 - progress).clamp(0.0, 1.0);

      final particleX = center.dx + math.cos(angle) * radius;
      final particleY = center.dy + math.sin(angle) * radius;

      final paint = Paint()
        ..color = _colors[i % _colors.length].withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      final particleSize =
          (3.0 + random.nextDouble() * 4) * (1 - progress * 0.5);
      canvas.drawCircle(Offset(particleX, particleY), particleSize, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
