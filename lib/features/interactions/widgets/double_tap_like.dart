import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/haptic_util.dart';
import '../../../providers/like_provider.dart';
import '../painters/particle_painter.dart';

class DoubleTapLike extends StatefulWidget {
  final String episodeId;
  final Widget child;
  final VoidCallback? onSingleTap;
  final void Function(Offset position)? onLongPressStart;
  final VoidCallback? onLongPressEnd;

  const DoubleTapLike({
    super.key,
    required this.episodeId,
    required this.child,
    this.onSingleTap,
    this.onLongPressStart,
    this.onLongPressEnd,
  });

  @override
  State<DoubleTapLike> createState() => _DoubleTapLikeState();
}

class _DoubleTapLikeState extends State<DoubleTapLike> {
  Offset? _tapPosition;

  void _onDoubleTapDown(TapDownDetails details) {
    _tapPosition = details.localPosition;
  }

  void _onDoubleTap() {
    if (_tapPosition == null) return;
    HapticUtil.medium();
    context.read<LikeProvider>().addLike(widget.episodeId);
    _showHeartAtPosition(_tapPosition!);
  }

  void _showHeartAtPosition(Offset position) {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final globalPosition = renderBox.localToGlobal(position);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => HeartOverlay(
        position: globalPosition,
        onComplete: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onSingleTap,
      onDoubleTapDown: _onDoubleTapDown,
      onDoubleTap: _onDoubleTap,
      onLongPressStart: (d) => widget.onLongPressStart?.call(d.localPosition),
      onLongPressEnd: (_) => widget.onLongPressEnd?.call(),
      child: widget.child,
    );
  }
}

/// Public so VideoFeedPage can insert it for the side-bar like button.
class HeartOverlay extends StatefulWidget {
  final Offset position;
  final VoidCallback onComplete;

  const HeartOverlay({super.key, required this.position, required this.onComplete});

  @override
  State<HeartOverlay> createState() => _HeartOverlayState();
}

class _HeartOverlayState extends State<HeartOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _particleAnim;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // Scale: pop → settle → rest → hold
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.3)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.3, end: 0.95)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 18,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.95, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 12,
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: 35,
      ),
    ]).animate(_ctrl);

    _fadeAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.70, 1.0, curve: Curves.easeIn),
      ),
    );

    _particleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );

    _ctrl.forward().then((_) {
      if (mounted) widget.onComplete();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx - 50,
      top: widget.position.dy - 50,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            return Opacity(
              opacity: _fadeAnim.value,
              child: SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Particle burst
                    CustomPaint(
                      size: const Size(100, 100),
                      painter:
                          ParticlePainter(progress: _particleAnim.value),
                    ),
                    // Heart with TweenSequence-driven scale bounce
                    Transform.scale(
                      scale: _scaleAnim.value,
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: AppColors.like,
                        size: 70,
                        shadows: [
                          Shadow(
                            color: AppColors.accentGlow,
                            blurRadius: 24,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
