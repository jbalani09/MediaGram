import '../models/episode.dart';

class EpisodeRepository {
  static List<Episode> getEpisodes() => [
        const Episode(
          id: 'ep1',
          title: 'Shadows of Tomorrow',
          subtitle: 'A love story across lifetimes',
          videoUrl:
              'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
          isLocked: true,
          episodeNumber: 1,
          totalEpisodes: 8,
        ),
        const Episode(
          id: 'ep2',
          title: 'The Last Signal',
          subtitle: 'When silence speaks volumes',
          videoUrl:
              'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
          isLocked: true,
          episodeNumber: 2,
          totalEpisodes: 8,
        ),
        const Episode(
          id: 'ep3',
          title: 'Crimson Horizon',
          subtitle: 'Some choices burn forever',
          videoUrl:
              'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
          isLocked: true,
          episodeNumber: 3,
          totalEpisodes: 8,
        ),
      ];
}
