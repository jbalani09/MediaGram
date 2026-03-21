import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Backgrounds
  static const Color bgDeep = Color(0xFF020203);
  static const Color bgBase = Color(0xFF0A0A0F);
  static const Color bgElevated = Color(0xFF0A0A0C);
  static const Color surface = Color(0x0DFFFFFF); // rgba(255,255,255,0.05)
  static const Color surfaceHigh = Color(0x1AFFFFFF); // rgba(255,255,255,0.10)

  // Borders
  static const Color border = Color(0x14FFFFFF); // rgba(255,255,255,0.08)

  // Accent
  static const Color accent = Color(0xFFE94560); // Vibrant red
  static const Color accentGlow = Color(0x33E94560); // accent 20% opacity
  static const Color gold = Color(0xFFFFD700); // Shimmer sweep
  static const Color goldGlow = Color(0x33FFD700);

  // Text
  static const Color textPrimary = Color(0xFFEDEDEF);
  static const Color textSecondary = Color(0xFF8A8F98);
  static const Color textMuted = Color(0xFF4A4F58);

  // Semantic
  static const Color like = Color(0xFFFF375F); // Heart color
  static const Color buffered = Color(0x4DFFFFFF); // Progress buffered

  // Gradients
  static const LinearGradient videoTopGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xBF000000), Color(0x00000000)],
    stops: [0.0, 1.0],
  );

  static const LinearGradient videoBottomGradient = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [Color(0xCC000000), Color(0x00000000)],
    stops: [0.0, 0.65],
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFE94560), Color(0xFFFF6B8A)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
