# MediaGram

A high-fidelity vertical video player built for the Rusk Media Frontend Engineer assignment. Demonstrates senior-level Flutter UI/UX with custom animations, spring physics, and a retention paywall.

---

## Getting Started

```bash
flutter pub get
flutter run
```

Requires Flutter 3.10+ / Dart 3.0+. Tested on Flutter 3.41.5 / Dart 3.11.3.


## Architecture

```
lib/
├── core/
│   ├── theme/          app_colors.dart, app_theme.dart
│   ├── constants/      app_constants.dart
│   └── utils/          duration_formatter.dart, haptic_util.dart, video_preload_manager.dart
├── data/
│   ├── models/         episode.dart
│   └── repositories/   episode_repository.dart
├── providers/          video_feed_provider.dart, like_provider.dart, paywall_provider.dart
├── features/
│   ├── video_feed/     video_feed_screen.dart, video_feed_page.dart
│   │   └── widgets/    video_player_widget.dart, skeleton_loader.dart,
│   │                   side_action_bar.dart, heart_button.dart, action_button.dart
│   ├── interactions/
│   │   ├── widgets/    double_tap_like.dart, progress_scrubber.dart
│   │   └── painters/   particle_painter.dart, progress_bar_painter.dart
│   └── paywall/        paywall_overlay.dart
│       └── widgets/    paywall_card.dart, shimmer_cta_button.dart
└── widgets/            gradient_overlay.dart, episode_info_overlay.dart
```

**State management:** Provider (`ChangeNotifier`) 

---

## Design Tokens

| Token | Value |
|---|---|
| Background | `#0A0A0F` |
| Accent / CTA | `#E94560` |
| Gold shimmer | `#FFD700` |
| Primary text | `#EDEDEF` |
| Secondary text | `#8A8F98` |
| Typography | Poppins (Google Fonts) |

# MediaGram
