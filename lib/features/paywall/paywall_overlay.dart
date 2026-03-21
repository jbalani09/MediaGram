import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/episode.dart';
import 'widgets/paywall_card.dart';

class PaywallOverlay extends StatefulWidget {
  final Episode episode;
  final VoidCallback onDismiss;

  const PaywallOverlay({
    super.key,
    required this.episode,
    required this.onDismiss,
  });

  @override
  State<PaywallOverlay> createState() => _PaywallOverlayState();
}

class _PaywallOverlayState extends State<PaywallOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _blurAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: AppConstants.blurAnimDuration,
    );
    _blurAnim =
        Tween<double>(begin: 0.0, end: AppConstants.backdropBlurSigma).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // Animated blur backdrop
            ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: _blurAnim.value,
                  sigmaY: _blurAnim.value,
                ),
                child: Container(
                  color: Colors.black.withValues(alpha: _fadeAnim.value * 0.45),
                ),
              ),
            ),
            // Paywall card (slides up)
            Align(
              alignment: Alignment.bottomCenter,
              child: Opacity(
                opacity: _fadeAnim.value,
                child: PaywallCard(
                  episode: widget.episode,
                  // Reverse the blur animation first, then dismiss so the
                  // blur doesn't snap away abruptly
                  onDismiss: () => _ctrl.reverse().then((_) {
                    if (mounted) widget.onDismiss();
                  }),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
