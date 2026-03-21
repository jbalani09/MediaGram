class AppConstants {
  AppConstants._();

  static const Duration paywallTrigger = Duration(seconds: 10);
  static const Duration heartAnimDuration = Duration(milliseconds: 800);
  static const Duration paywallAnimDuration = Duration(milliseconds: 600);
  static const Duration blurAnimDuration = Duration(milliseconds: 300);
  static const Duration shimmerSweepDuration = Duration(seconds: 3);
  static const Duration progressExpandDuration = Duration(milliseconds: 150);
  static const Duration tapFeedbackDuration = Duration(milliseconds: 500);

  // Progress bar heights
  static const double progressBarNormalHeight = 3.0;
  static const double progressBarExpandedHeight = 8.0;

  // Blur
  static const double backdropBlurSigma = 15.0;
}
