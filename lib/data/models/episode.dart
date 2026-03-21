class Episode {
  final String id;
  final String title;
  final String subtitle;
  final String videoUrl;
  final bool isLocked;
  final int episodeNumber;
  final int totalEpisodes;

  const Episode({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.videoUrl,
    this.isLocked = false,
    required this.episodeNumber,
    required this.totalEpisodes,
  });
}
