import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class GradientOverlay extends StatelessWidget {
  final bool isTop;

  const GradientOverlay({super.key, required this.isTop});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: isTop
              ? AppColors.videoTopGradient
              : AppColors.videoBottomGradient,
        ),
      ),
    );
  }
}
