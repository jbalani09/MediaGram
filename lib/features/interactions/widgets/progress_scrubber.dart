import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/duration_formatter.dart';
import '../../../core/utils/haptic_util.dart';
import '../painters/progress_bar_painter.dart';

class _ScrubState {
  final bool isDragging;
  final double dragProgress;
  final double tooltipX;

  const _ScrubState({
    this.isDragging = false,
    this.dragProgress = 0.0,
    this.tooltipX = 0.0,
  });

  _ScrubState copyWith({
    bool? isDragging,
    double? dragProgress,
    double? tooltipX,
  }) {
    return _ScrubState(
      isDragging: isDragging ?? this.isDragging,
      dragProgress: dragProgress ?? this.dragProgress,
      tooltipX: tooltipX ?? this.tooltipX,
    );
  }
}

class ProgressScrubber extends StatefulWidget {
  final VideoPlayerController controller;

  const ProgressScrubber({super.key, required this.controller});

  @override
  State<ProgressScrubber> createState() => _ProgressScrubberState();
}

class _ProgressScrubberState extends State<ProgressScrubber>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<_ScrubState> _scrubNotifier =
      ValueNotifier(const _ScrubState());
  late AnimationController _expandController;
  late Animation<double> _heightAnim;
  DateTime _lastHapticTime = DateTime(0);

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
  }

  void _onDragStart(DragStartDetails details) {
    _scrubNotifier.value = _scrubNotifier.value.copyWith(
      isDragging: true,
      dragProgress: _getProgressFromX(details.localPosition.dx),
      tooltipX: details.localPosition.dx,
    );
    _expandController.forward();
    HapticUtil.light();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final width = context.size?.width ?? 1;
    final clampedX = details.localPosition.dx.clamp(0.0, width);
    _scrubNotifier.value = _scrubNotifier.value.copyWith(
      dragProgress: _getProgressFromX(clampedX),
      tooltipX: clampedX,
    );
    final now = DateTime.now();
    if (now.difference(_lastHapticTime).inMilliseconds >= 50) {
      HapticUtil.selection();
      _lastHapticTime = now;
    }
  }

  void _onDragEnd(DragEndDetails details) {
    final duration = widget.controller.value.duration;
    final seekTo = duration * _scrubNotifier.value.dragProgress;
    widget.controller.seekTo(seekTo);
    _scrubNotifier.value = _scrubNotifier.value.copyWith(isDragging: false);
    _expandController.reverse();
    HapticUtil.light();
  }

  double _getProgressFromX(double x) {
    final width = context.size?.width ?? 1;
    return (x / width).clamp(0.0, 1.0);
  }

  @override
  void dispose() {
    _scrubNotifier.dispose();
    _expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

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
            ListenableBuilder(
              listenable: Listenable.merge([
                _scrubNotifier,
                _heightAnim,
                widget.controller,
              ]),
              builder: (context, _) {
                final scrub = _scrubNotifier.value;
                final value = widget.controller.value;
                final duration = value.duration;
                final position = scrub.isDragging
                    ? duration * scrub.dragProgress
                    : value.position;
                final progress = duration.inMilliseconds > 0
                    ? (position.inMilliseconds / duration.inMilliseconds)
                        .clamp(0.0, 1.0)
                    : 0.0;
                final buffered = value.buffered.isNotEmpty
                    ? (value.buffered.last.end.inMilliseconds /
                            duration.inMilliseconds)
                        .clamp(0.0, 1.0)
                    : 0.0;

                return Align(
                  alignment: Alignment.bottomCenter,
                  child: RepaintBoundary(
                    child: CustomPaint(
                      size: Size(screenWidth, _heightAnim.value),
                      painter: ProgressBarPainter(
                        progress: progress,
                        buffered: buffered,
                        isDragging: scrub.isDragging,
                      ),
                    ),
                  ),
                );
              },
            ),
            ValueListenableBuilder<_ScrubState>(
              valueListenable: _scrubNotifier,
              builder: (context, scrub, _) {
                if (!scrub.isDragging) return const SizedBox.shrink();

                const tooltipWidth = 96.0;
                final tooltipLeft = (scrub.tooltipX - tooltipWidth / 2)
                    .clamp(8.0, screenWidth - tooltipWidth - 8.0);
                final duration = widget.controller.value.duration;
                final position = duration * scrub.dragProgress;

                return Positioned(
                  left: tooltipLeft,
                  bottom: 52,
                  child: _TimeTooltip(
                    position: position,
                    duration: duration,
                  ),
                );
              },
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
