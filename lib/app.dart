import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/video_feed/video_feed_screen.dart';

class MediaGramApp extends StatelessWidget {
  const MediaGramApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediaGram',
      theme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
      home: const VideoFeedScreen(),
    );
  }
}
