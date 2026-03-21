import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/haptic_util.dart';

class ShimmerCtaButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const ShimmerCtaButton({super.key, required this.label, required this.onTap});

  @override
  State<ShimmerCtaButton> createState() => _ShimmerCtaButtonState();
}

class _ShimmerCtaButtonState extends State<ShimmerCtaButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  // 0.0 → 1.0 over 3 seconds, then repeats
  late Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: AppConstants.shimmerSweepDuration,
    )..repeat();
    _shimmerAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticUtil.medium();
        widget.onTap();
      },
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: AppColors.accentGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.45),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Button label — always on top
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),

              // Shimmer sweep painted OVER the label so it brightens everything
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _shimmerAnim,
                    builder: (_, __) => CustomPaint(
                      painter: _ShimmerBandPainter(
                        progress: _shimmerAnim.value,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Paints a white semi-transparent diagonal band that sweeps left → right.
class _ShimmerBandPainter extends CustomPainter {
  final double progress; // 0.0 → 1.0

  const _ShimmerBandPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // Band center starts 80px off the left edge and exits 80px past the right.
    final bandCenter = -80.0 + (size.width + 160) * progress;
    const bandHalfWidth = 55.0;

    final bandRect = Rect.fromLTRB(
      bandCenter - bandHalfWidth,
      0,
      bandCenter + bandHalfWidth,
      size.height,
    );

    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          Colors.white.withValues(alpha: 0.55),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(bandRect);

    // Draw the full canvas; the gradient shader is transparent outside bandRect.
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(_ShimmerBandPainter old) => old.progress != progress;
}
