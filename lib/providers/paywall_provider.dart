import 'package:flutter/foundation.dart';

class PaywallProvider extends ChangeNotifier {
  final Map<String, bool> _triggered = {};
  final Map<String, bool> _dismissed = {};

  bool isTriggered(String episodeId) => _triggered[episodeId] ?? false;
  bool isDismissed(String episodeId) => _dismissed[episodeId] ?? false;

  void trigger(String episodeId) {
    if (!(_dismissed[episodeId] ?? false) &&
        !(_triggered[episodeId] ?? false)) {
      _triggered[episodeId] = true;
      notifyListeners();
    }
  }

  void dismiss(String episodeId) {
    _triggered[episodeId] = false;
    _dismissed[episodeId] = true;
    notifyListeners();
  }

  bool shouldTrigger(String episodeId) {
    return !(_dismissed[episodeId] ?? false) &&
        !(_triggered[episodeId] ?? false);
  }
}
