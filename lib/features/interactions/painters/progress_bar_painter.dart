import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ProgressBarPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final double buffered; // 0.0 to 1.0
  final bool isDragging;

  const ProgressBarPainter({
    required this.progress,
    required this.buffered,
    required this.isDragging,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height;
    final w = size.width;
    final radius = Radius.circular(h / 2);

    // Track (background)
    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), radius),
      trackPaint,
    );

    // Buffered
    final bufferedPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w * buffered, h), radius),
      bufferedPaint,
    );

    // Played (gradient)
    final progressW = w * progress;
    if (progressW > 0) {
      final progressPaint = Paint()
        ..shader = const LinearGradient(
          colors: [AppColors.accent, Color(0xFFFF6B8A)],
        ).createShader(Rect.fromLTWH(0, 0, w, h))
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, progressW, h), radius),
        progressPaint,
      );
    }

    // Scrub handle (circle at current position)
    if (isDragging) {
      final handleX = w * progress;
      final handleRadius = h * 1.8;
      final handlePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(handleX, h / 2), handleRadius, handlePaint);

      // Glow
      final glowPaint = Paint()
        ..color = AppColors.accentGlow
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(
          Offset(handleX, h / 2), handleRadius + 2, glowPaint);
    }
  }

  @override
  bool shouldRepaint(ProgressBarPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.buffered != buffered ||
      oldDelegate.isDragging != isDragging;
}
