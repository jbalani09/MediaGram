import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/episode.dart';
import 'shimmer_cta_button.dart';

class PaywallCard extends StatefulWidget {
  final Episode episode;
  final VoidCallback onDismiss;

  const PaywallCard({super.key, required this.episode, required this.onDismiss});

  @override
  State<PaywallCard> createState() => _PaywallCardState();
}

class _PaywallCardState extends State<PaywallCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController.unbounded(vsync: this);
    _slideAnim = _ctrl.drive(
      Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero),
    );

    final spring = SpringDescription(mass: 1, stiffness: 200, damping: 15);
    final simulation = SpringSimulation(spring, 0, 1, 0);
    _ctrl.animateWith(simulation);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnim,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF12121A),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          border: Border(
            top: BorderSide(color: AppColors.border, width: 0.5),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Lock icon + badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.accentGlow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.lock_rounded,
                          color: AppColors.accent,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppColors.accent.withValues(alpha: 0.3)),
                        ),
                        child: const Text(
                          'PREMIUM',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Title
                  const Text(
                    'Keep Watching',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.episode.title} has ${widget.episode.totalEpisodes - widget.episode.episodeNumber} more episodes. Unlock all to continue your binge.',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Feature bullets
                  ...[
                    (
                      'All 8 episodes, ad-free',
                      Icons.play_circle_outline_rounded
                    ),
                    ('Offline downloads', Icons.download_rounded),
                    (
                      'New episodes weekly',
                      Icons.notifications_active_rounded
                    ),
                  ].map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Icon(item.$2, color: AppColors.accent, size: 16),
                            const SizedBox(width: 10),
                            Text(
                              item.$1,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 24),

                  // CTA button
                  ShimmerCtaButton(
                    label: 'Unlock Episode',
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),

                  // Dismiss
                  Center(
                    child: TextButton(
                      onPressed: widget.onDismiss,
                      child: const Text(
                        'Maybe Later',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            // Safe area bottom
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}
