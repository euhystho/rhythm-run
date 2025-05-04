import 'package:flutter_test/flutter_test.dart';
import 'package:rhythmrun/data/types/song.dart';
import 'package:rhythmrun/data/services/generate_playlist.dart';

void main() {
  group('getSimilarSongs integration tests (real API)', () {
    test('returns at least one song above the match threshold', () async {
      final input = Song("Everything In Its Right Place", "Radiohead");
      final result = await getSimilarSongs(input, 0.1, 5);

      expect(result.tracks.isNotEmpty, true);
      for (var song in result.tracks) {
        expect(song.name.isNotEmpty, true);
        expect(song.artist.isNotEmpty, true);
        expect(song, isA<SimilarSong>());
        expect((song as SimilarSong).match >= 0.1, true);
      }
    });

    test('returns empty playlist if song is not valid', () async {
      final nonsense = Song("asdfghjkl", "qwertyuiop");
      final result = await getSimilarSongs(nonsense, 0.1, 5);

      expect(result.tracks.length, 1);
      expect(result.tracks.first.name, '');
      expect(result.tracks.first.artist, '');
    });

    test('only returns songs above threshold', () async {
      final input = Song("Everything In Its Right Place", "Radiohead");
      final result = await getSimilarSongs(input, 0.9, 10); 

      for (var song in result.tracks) {
        expect(song, isA<SimilarSong>());
        expect((song as SimilarSong).match >= 0.9, true);
      }
    });
  });
}
