import 'package:flutter/foundation.dart';

class LikeProvider extends ChangeNotifier {
  final Map<String, bool> _liked = {};
  final Map<String, int> _counts = {};

  bool isLiked(String episodeId) => _liked[episodeId] ?? false;
  int likeCount(String episodeId) => _counts[episodeId] ?? 1247;

  void toggleLike(String episodeId) {
    final wasLiked = _liked[episodeId] ?? false;
    _liked[episodeId] = !wasLiked;
    _counts[episodeId] = (likeCount(episodeId)) + (wasLiked ? -1 : 1);
    notifyListeners();
  }

  /// Only ever adds a like — used by double-tap (never removes).
  void addLike(String episodeId) {
    if (_liked[episodeId] == true) return;
    _liked[episodeId] = true;
    _counts[episodeId] = likeCount(episodeId) + 1;
    notifyListeners();
  }
}
