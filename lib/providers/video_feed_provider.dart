import 'package:flutter/foundation.dart';
import '../data/models/episode.dart';
import '../data/repositories/episode_repository.dart';

class VideoFeedProvider extends ChangeNotifier {
  int _currentIndex = 0;
  final List<Episode> _episodes = EpisodeRepository.getEpisodes();
  final Map<String, Duration> _lastPositions = {};

  int get currentIndex => _currentIndex;
  List<Episode> get episodes => _episodes;

  void setCurrentIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void savePosition(String episodeId, Duration position) {
    _lastPositions[episodeId] = position;
  }

  Duration getLastPosition(String episodeId) {
    return _lastPositions[episodeId] ?? Duration.zero;
  }
}
