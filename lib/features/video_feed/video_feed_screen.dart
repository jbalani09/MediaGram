import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/video_preload_manager.dart';
import '../../providers/video_feed_provider.dart';
import '../../core/utils/haptic_util.dart';
import 'video_feed_page.dart';

class VideoFeedScreen extends StatefulWidget {
  const VideoFeedScreen({super.key});

  @override
  State<VideoFeedScreen> createState() => _VideoFeedScreenState();
}

class _VideoFeedScreenState extends State<VideoFeedScreen> {
  late final PageController _pageController;
  late final VideoPreloadManager _preloadManager;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    final episodes = context.read<VideoFeedProvider>().episodes;
    _preloadManager = VideoPreloadManager(episodes: episodes);
    // Pre-load the first page and its neighbor
    _preloadManager.onPageChanged(0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _preloadManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VideoFeedProvider>();
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        physics: const ClampingScrollPhysics(),
        itemCount: provider.episodes.length,
        onPageChanged: (index) {
          HapticUtil.light();
          provider.setCurrentIndex(index);
          _preloadManager.onPageChanged(index);
        },
        itemBuilder: (context, index) {
          return VideoFeedPage(
            episode: provider.episodes[index],
            isActive: index == provider.currentIndex,
            pageIndex: index,
            preloadManager: _preloadManager,
          );
        },
      ),
    );
  }
}
