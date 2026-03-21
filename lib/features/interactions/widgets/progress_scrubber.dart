import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/duration_formatter.dart';
import '../painters/progress_bar_painter.dart';

class ProgressScrubber extends StatefulWidget {
  final VideoPlayerController controller;

  const ProgressScrubber({super.key, required this.controller});

  @override
  State<ProgressScrubber> createState() => _ProgressScrubberState();
}

class _ProgressScrubberState extends State<ProgressScrubber>
    with SingleTickerProviderStateMixin {
  bool _isDragging = false;
  double _dragProgress = 0.0;
  double _tooltipX = 0.0;
  late AnimationController _expandController;
  late Animation<double> _heightAnim;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: AppConstants.progressExpandDuration,
    );
    _heightAnim = Tween<double>(
      begin: AppConstants.progressBarNormalHeight,
      end: AppConstants.progressBarExpandedHeight,
    ).animate(CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeOut,
    ));
    widget.controller.addListener(_onVideoUpdate);
  }

  void _onVideoUpdate() {
    if (!_isDragging && mounted) setState(() {});
  }

  void _onDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
      _dragProgress = _getProgressFromX(details.localPosition.dx);
      _tooltipX = details.localPosition.dx;
    });
    _expandController.forward();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final width = context.size?.width ?? 1;
    final clampedX = details.localPosition.dx.clamp(0.0, width);
    setState(() {
      _dragProgress = _getProgressFromX(clampedX);
      _tooltipX = clampedX;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    final duration = widget.controller.value.duration;
    final seekTo = duration * _dragProgress;
    widget.controller.seekTo(seekTo);
    setState(() => _isDragging = false);
    _expandController.reverse();
  }

  double _getProgressFromX(double x) {
    final width = context.size?.width ?? 1;
    return (x / width).clamp(0.0, 1.0);
  }

  Duration get _currentPosition {
    if (_isDragging) {
      return widget.controller.value.duration * _dragProgress;
    }
    return widget.controller.value.position;
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onVideoUpdate);
    _expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.controller.value;
    final duration = value.duration;
    final position = _currentPosition;
    final screenWidth = MediaQuery.of(context).size.width;
    final progress = duration.inMilliseconds > 0
        ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;
    final buffered = value.buffered.isNotEmpty
        ? (value.buffered.last.end.inMilliseconds / duration.inMilliseconds)
            .clamp(0.0, 1.0)
        : 0.0;

    // Tooltip dimensions for clamping
    const tooltipWidth = 96.0;
    final tooltipLeft =
        (_tooltipX - tooltipWidth / 2).clamp(8.0, screenWidth - tooltipWidth - 8.0);

    return GestureDetector(
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 48,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            AnimatedBuilder(
              animation: _heightAnim,
              builder: (context, _) {
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: RepaintBoundary(
                    child: CustomPaint(
                      size: Size(screenWidth, _heightAnim.value),
                      painter: ProgressBarPainter(
                        progress: progress,
                        buffered: buffered,
                        isDragging: _isDragging,
                      ),
                    ),
                  ),
                );
              },
            ),

            if (_isDragging)
              Positioned(
                left: tooltipLeft,
                bottom: 52, // above the 48px touch zone
                child: _TimeTooltip(
                  position: position,
                  duration: duration,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TimeTooltip extends StatelessWidget {
  final Duration position;
  final Duration duration;

  const _TimeTooltip({required this.position, required this.duration});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xE6000000), // 90% black
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Text(
        DurationFormatter.formatProgress(position, duration),
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
