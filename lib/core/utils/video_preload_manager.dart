import 'package:video_player/video_player.dart';
import '../../data/models/episode.dart';

// Keeps a sliding window of controllers: [current-1, current, current+1].
// Controllers outside the window are disposed to free memory.
class VideoPreloadManager {
  final List<Episode> episodes;
  final Map<int, VideoPlayerController> _controllers = {};
  final Map<int, bool> _initialized = {};
  final Map<int, bool> _errors = {};

  VideoPreloadManager({required this.episodes});

  VideoPlayerController getController(int index) {
    if (!_controllers.containsKey(index)) _createController(index);
    return _controllers[index]!;
  }

  bool isInitialized(int index) => _initialized[index] ?? false;
  bool hasError(int index) => _errors[index] ?? false;

  void onPageChanged(int currentIndex) {
    final windowStart = (currentIndex - 1).clamp(0, episodes.length - 1);
    final windowEnd = (currentIndex + 1).clamp(0, episodes.length - 1);

    for (int i = windowStart; i <= windowEnd; i++) {
      if (!_controllers.containsKey(i)) _createController(i);
    }

    final toRemove = _controllers.keys
        .where((idx) => idx < windowStart || idx > windowEnd)
        .toList();
    for (final idx in toRemove) {
      _controllers[idx]?.dispose();
      _controllers.remove(idx);
      _initialized.remove(idx);
      _errors.remove(idx);
    }
  }

  void retryController(int index) {
    _controllers[index]?.dispose();
    _controllers.remove(index);
    _initialized.remove(index);
    _errors.remove(index);
    _createController(index);
  }

  void _createController(int index) {
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(episodes[index].videoUrl),
    );
    _controllers[index] = controller;
    _initialized[index] = false;
    _errors[index] = false;
    controller.initialize().then((_) {
      _initialized[index] = true;
      controller.setLooping(true);
    }).catchError((_) {
      _errors[index] = true;
    });
  }

  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    _initialized.clear();
    _errors.clear();
  }
}
