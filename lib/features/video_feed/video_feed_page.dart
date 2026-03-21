import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/haptic_util.dart';
import '../../core/utils/video_preload_manager.dart';
import '../../data/models/episode.dart';
import '../../providers/video_feed_provider.dart';
import '../../providers/paywall_provider.dart';
import '../../providers/like_provider.dart';
import '../../widgets/gradient_overlay.dart';
import '../../widgets/episode_info_overlay.dart';
import '../interactions/widgets/double_tap_like.dart';
import '../interactions/widgets/progress_scrubber.dart';
import '../paywall/paywall_overlay.dart';
import 'widgets/video_player_widget.dart';
import 'widgets/skeleton_loader.dart';
import 'widgets/side_action_bar.dart';

class VideoFeedPage extends StatefulWidget {
  final Episode episode;
  final bool isActive;
  final int pageIndex;
  final VideoPreloadManager preloadManager;

  const VideoFeedPage({
    super.key,
    required this.episode,
    required this.isActive,
    required this.pageIndex,
    required this.preloadManager,
  });

  @override
  State<VideoFeedPage> createState() => _VideoFeedPageState();
}

class _VideoFeedPageState extends State<VideoFeedPage>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _showPlayPauseIcon = false;
  bool _paywallTriggered = false;
  bool _isLongPressed = false;
  bool _is2xSpeed = false;
  late AnimationController _playPauseAnimController;
  late Animation<double> _playPauseAnim;

  @override
  void initState() {
    super.initState();
    _playPauseAnimController = AnimationController(
      vsync: this,
      duration: AppConstants.tapFeedbackDuration,
    );
    _playPauseAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
          parent: _playPauseAnimController, curve: Curves.easeOut),
    );
    _initController();
  }

  void _initController() {
    _controller = widget.preloadManager.getController(widget.pageIndex);

    if (widget.preloadManager.isInitialized(widget.pageIndex)) {
      _isInitialized = true;
      if (widget.isActive) _controller.play();
    } else {
      _controller.addListener(_onControllerReady);
    }

    _controller.addListener(_onVideoPositionChanged);
  }


  void _onControllerReady() {
    if (_controller.value.isInitialized && !_isInitialized) {
      _controller.removeListener(_onControllerReady);
      if (!mounted) return;
      setState(() => _isInitialized = true);
      if (widget.isActive) _controller.play();
    }
  }

  void _onVideoPositionChanged() {
    if (!mounted || !_isInitialized) return;

    final position = _controller.value.position;


    context
        .read<VideoFeedProvider>()
        .savePosition(widget.episode.id, position);


    if (position >= AppConstants.paywallTrigger && !_paywallTriggered) {
      final paywallProvider = context.read<PaywallProvider>();
      if (paywallProvider.shouldTrigger(widget.episode.id)) {
        _paywallTriggered = true;
        _controller.pause();
        _resetSpeed();
        HapticUtil.heavy();
        paywallProvider.trigger(widget.episode.id);
      }
    }
  }


  void _resetSpeed() {
    if (_is2xSpeed) {
      _controller.setPlaybackSpeed(1.0);
      if (mounted) setState(() => _is2xSpeed = false);
    }
    if (_isLongPressed) {
      if (mounted) setState(() => _isLongPressed = false);
    }
  }

  @override
  void didUpdateWidget(VideoFeedPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        final paywallProvider = context.read<PaywallProvider>();
        if (!paywallProvider.isTriggered(widget.episode.id)) {
          if (_isInitialized) {
            _controller.seekTo(Duration.zero).then((_) {
              if (mounted) _controller.play();
            });
          } else {
            _controller.play();
          }
        }
      } else {
        _controller.pause();
        _resetSpeed();
      }
    }
  }

  void _togglePlayPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      final paywallProvider = context.read<PaywallProvider>();
      if (!paywallProvider.isTriggered(widget.episode.id)) {
        _controller.play();
      }
    }
    setState(() => _showPlayPauseIcon = true);
    _playPauseAnimController.forward(from: 0);
    Future.delayed(AppConstants.tapFeedbackDuration, () {
      if (mounted) setState(() => _showPlayPauseIcon = false);
    });
  }

  void _onLongPressStart(Offset position) {
    if (!_isInitialized) return;
    final size = MediaQuery.of(context).size;
    const edgeX = 88.0;
    const topGuard = 100.0;
    const bottomGuard = 160.0;

    final isHorizontalEdge =
        position.dx < edgeX || position.dx > size.width - edgeX;
    final isVerticalMiddle =
        position.dy > topGuard && position.dy < size.height - bottomGuard;

    if (isHorizontalEdge && isVerticalMiddle) {
      HapticUtil.medium();
      _controller.setPlaybackSpeed(2.0);
      setState(() => _is2xSpeed = true);
    } else {
      // Any other area → pause / hold
      HapticUtil.light();
      _controller.pause();
      setState(() => _isLongPressed = true);
    }
  }

  void _onLongPressEnd() {
    if (!_isInitialized) return;
    final wasPaused = _isLongPressed;
    _resetSpeed();
    if (wasPaused) {
      final paywallProvider = context.read<PaywallProvider>();
      if (!paywallProvider.isTriggered(widget.episode.id)) {
        _controller.play();
      }
    }
  }

  void _showHeartAtCenter() {
    final overlay = Overlay.of(context);
    final size = MediaQuery.of(context).size;
    final center = Offset(size.width / 2, size.height / 2);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => HeartOverlay(
        position: center,
        onComplete: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }

  void _onPaywallDismissed() {
    final provider = context.read<PaywallProvider>();
    provider.dismiss(widget.episode.id);
    // Resume from where they left off
    final lastPos = context
        .read<VideoFeedProvider>()
        .getLastPosition(widget.episode.id);
    _controller.seekTo(lastPos).then((_) => _controller.play());
  }

  @override
  void dispose() {
    _controller.removeListener(_onVideoPositionChanged);
    _controller.removeListener(_onControllerReady);
    _playPauseAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paywallProvider = context.watch<PaywallProvider>();
    final likeProvider = context.watch<LikeProvider>();
    final isPaywallActive = paywallProvider.isTriggered(widget.episode.id);

    final bottomSafe = MediaQuery.of(context).viewPadding.bottom;

    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: AppColors.bgDeep),

          if (!_isInitialized)
            const SkeletonLoader()
          else ...[
            VideoPlayerWidget(controller: _controller),
            const GradientOverlay(isTop: true),
            const GradientOverlay(isTop: false),

            DoubleTapLike(
              episodeId: widget.episode.id,
              onSingleTap: isPaywallActive ? null : _togglePlayPause,
              onLongPressStart: isPaywallActive ? null : _onLongPressStart,
              onLongPressEnd: isPaywallActive ? null : _onLongPressEnd,
              child: Container(color: Colors.transparent),
            ),

            if (_isLongPressed)
              IgnorePointer(
                child: Container(color: Colors.black.withValues(alpha: 0.35)),
              ),

            if (_is2xSpeed)
              Positioned(
                bottom: bottomSafe.clamp(16.0, double.infinity) + 64,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 9),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.80),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.55),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.25),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.fast_forward_rounded,
                              color: AppColors.accent, size: 18),
                          const SizedBox(width: 7),
                          const Text(
                            '2× Speed',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            if (_showPlayPauseIcon)
              Center(
                child: AnimatedBuilder(
                  animation: _playPauseAnim,
                  builder: (context, _) => Opacity(
                    opacity: _playPauseAnim.value,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _controller.value.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),

            Positioned(
              left: 16,
              bottom: bottomSafe + 64,
              right: 80,
              child: EpisodeInfoOverlay(episode: widget.episode),
            ),

            Positioned(
              right: 12,
              bottom: bottomSafe + 64,
              child: SideActionBar(
                episode: widget.episode,
                likeProvider: likeProvider,
                onLikeAdded: _showHeartAtCenter,
              ),
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: bottomSafe.clamp(16.0, double.infinity),
              child: ProgressScrubber(controller: _controller),
            ),

            if (isPaywallActive)
              PaywallOverlay(
                episode: widget.episode,
                onDismiss: _onPaywallDismissed,
              ),
          ],
        ],
      ),
    );
  }
}

