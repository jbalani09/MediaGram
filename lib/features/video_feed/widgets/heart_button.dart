import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Heart button for the side action bar.
/// - Tapping to LIKE: plays a center heart overlay (via [onTap] callback) + press pop.
/// - Tapping to UN-LIKE: the filled heart vanishes with a scale+fade animation,
///   then snaps back to the outline icon.
class HeartButton extends StatefulWidget {
  final bool isLiked;
  final String count;
  final VoidCallback onTap;

  const HeartButton({
    super.key,
    required this.isLiked,
    required this.count,
    required this.onTap,
  });

  @override
  State<HeartButton> createState() => _HeartButtonState();
}

class _HeartButtonState extends State<HeartButton>
    with TickerProviderStateMixin {
  // Press-down scale feedback
  late AnimationController _pressCtrl;
  late Animation<double> _pressScale;

  // Vanish animation for un-like (liked → not liked)
  late AnimationController _vanishCtrl;
  late Animation<double> _vanishScale;
  late Animation<double> _vanishOpacity;
  bool _isVanishing = false;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _pressScale = Tween<double>(begin: 1.0, end: 0.82).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut),
    );

    _vanishCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    // Scale: hold → pop up → shrink to nothing
    _vanishScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.3)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.3, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 75,
      ),
    ]).animate(_vanishCtrl);
    // Fade: stays opaque during pop, then fades out
    _vanishOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 30),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 70,
      ),
    ]).animate(_vanishCtrl);
  }

  @override
  void didUpdateWidget(HeartButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLiked && !widget.isLiked) {
      // Liked → un-liked: play vanish
      setState(() => _isVanishing = true);
      _vanishCtrl.forward(from: 0).then((_) {
        if (mounted) setState(() => _isVanishing = false);
      });
    }
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    _vanishCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showLiked = widget.isLiked || _isVanishing;
    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressCtrl.reverse(),
      // Press scale wraps the whole button (icon + label) — feels natural
      child: ScaleTransition(
        scale: _pressScale,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Vanish animation is ONLY applied to the icon
            AnimatedBuilder(
              animation: _vanishCtrl,
              builder: (context, _) {
                return Opacity(
                  opacity: _isVanishing ? _vanishOpacity.value : 1.0,
                  child: Transform.scale(
                    scale: _isVanishing ? _vanishScale.value : 1.0,
                    child: Icon(
                      showLiked
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color:
                          showLiked ? AppColors.like : AppColors.textPrimary,
                      size: 28,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 4),
            // Count label stays visible and steady throughout
            Text(
              widget.count,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
