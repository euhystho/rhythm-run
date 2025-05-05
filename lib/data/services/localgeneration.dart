import '../types/song.dart';
import '../services/db_gen.dart'
Future<Playlist>? generatePlaylist(double avgBPM,String expLevel,double avgPace,List<double> paceGroup) async{
  //Todo: generate list
  final SongDatabase db;
  final ranges = {
      'beginner': {
        'low': [120, 130],
        'medium': [150, 157],
        'high': [170, 177],
      },
      'intermediate': {
        'low': [130, 140],
        'medium': [157, 163],
        'high': [177, 183],
      },
      'advanced': {
        'low': [140, 150],
        'medium': [163, 170],
        'high': [183, 190],
      },
    };
}
if (_database == null) await initialize();

    // Subranges within each intensity, based on experience level
    

    final durationRanges = {
      'short': [10, 15],
      'medium': [15, 20],
      'long': [20, 25],
    };

    // Validate inputs
    if (!ranges.containsKey(xpLvl) ||
        !ranges[xpLvl]!.containsKey(intensity) ||
        !durationRanges.containsKey(duration)) {
      return null;
    }

    final seenIds = <int>{};
    const step = 2;
    var totalTime = 0.0;
    final playlist = <Map<String, dynamic>>[];

    var minBpm = ranges[xpLvl]![intensity]![0];
    var maxBpm = ranges[xpLvl]![intensity]![1];
    final minDur = durationRanges[duration]![0];
    final maxDur = durationRanges[duration]![1];

    while (totalTime < minDur) {
      final matches = await _database!.query(
        'songs',
        where: 'bpm BETWEEN ? AND ?',
        whereArgs: [minBpm, maxBpm],
      );

      // Filter out seen songs and shuffle
      final availableSongs = matches
          .where((song) => !seenIds.contains(song['id']))
          .toList()
        ..shuffle();

      for (final song in availableSongs) {
        if (totalTime + (song['length'] as double) <= maxDur) {
          playlist.add(song);
          totalTime += song['length'] as double;
          seenIds.add(song['id'] as int);
        }
        if (totalTime >= minDur) break;
      }

      minBpm -= step;
      maxBpm += step;

      // Stop expanding BPM range if outside reasonable bounds
      if (minBpm < 60 && maxBpm > 220) break;
    }

    return playlist;
  }