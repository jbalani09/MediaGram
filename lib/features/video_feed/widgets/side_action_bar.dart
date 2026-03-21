import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/haptic_util.dart';
import '../../../data/models/episode.dart';
import '../../../providers/like_provider.dart';
import 'heart_button.dart';
import 'action_button.dart';

class SideActionBar extends StatelessWidget {
  final Episode episode;
  final LikeProvider likeProvider;
  final VoidCallback onLikeAdded;

  const SideActionBar({
    super.key,
    required this.episode,
    required this.likeProvider,
    required this.onLikeAdded,
  });

  @override
  Widget build(BuildContext context) {
    final isLiked = likeProvider.isLiked(episode.id);
    final count = likeProvider.likeCount(episode.id);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        HeartButton(
          isLiked: isLiked,
          count: _formatCount(count),
          onTap: () {
            HapticUtil.medium();
            final wasLiked = likeProvider.isLiked(episode.id);
            likeProvider.toggleLike(episode.id);
            if (!wasLiked) onLikeAdded();
          },
        ),
        const SizedBox(height: 20),
        ActionButton(
          icon: Icons.chat_bubble_rounded,
          label: '342',
          color: AppColors.textPrimary,
          onTap: () {
            HapticUtil.light();
            ScaffoldMessenger.of(context)
              ..clearSnackBars()
              ..showSnackBar(
                const SnackBar(
                  content: Text('Comments coming soon'),
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
          },
        ),
        const SizedBox(height: 20),
        ActionButton(
          icon: Icons.share_rounded,
          label: 'Share',
          color: AppColors.textPrimary,
          onTap: () {
            HapticUtil.light();
            ScaffoldMessenger.of(context)
              ..clearSnackBars()
              ..showSnackBar(
                const SnackBar(
                  content: Text('Share coming soon'),
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
          },
        ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}
