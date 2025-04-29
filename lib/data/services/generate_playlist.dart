import 'package:dotenv/dotenv.dart' as dotenv;
import 'package:lastfm/lastfm.dart';
import '../types/song.dart';
import 'package:xml/xml.dart' as xml;

final env = dotenv.DotEnv()..load(['.env']);

Future<Playlist> getSimilarSongs(Song song, double lowerThreshold, int limit) async {
  final tempApiKey = const String.fromEnvironment('LASTFM_API_KEY', defaultValue: '');
  final tempSharedSecret = const String.fromEnvironment('LASTFM_SHARED_SECRET', defaultValue: '');

  final apiKey = (tempApiKey.isNotEmpty ? tempApiKey : (env['LASTFM_API_KEY'] ?? ''));
  final sharedSecret = (tempSharedSecret.isNotEmpty) ? tempSharedSecret : env['LASTFM_SHARED_SECRET'];

  LastFM lastfm = LastFMUnauthorized(apiKey, sharedSecret);

  try {
    // Make the API call
    var similarSongs = await lastfm.read('track.getSimilar', {
      "artist": song.artist,
      "track": song.name,
      "limit": limit.toString(),
      "api_key": apiKey
    }).timeout(const Duration(seconds: 5));
    
    // Get all track elements directly from the LastFM response
    final trackElements = similarSongs.findAllElements('track');

    // If no tracks found, return an empty playlist
    if (trackElements.isEmpty) {
      print("No similar tracks found");
      return Playlist([Song("No similar tracks", "")]);
    }
    var tracks =
        trackElements.map((element) {
          try {
            // Extract the track name
            final name = element.findElements('name').first.innerText;

            // Extract the artist name
            final artistElement = element.findElements('artist').first;
            final artistName =
                artistElement.findElements('name').first.innerText;

            // Extract the match score and mbid:
            final match =
                double.tryParse(
                  element.findElements('match').first.innerText,
                ) ??
                0.0;
            if (match >= lowerThreshold) {
              // Create and return a SimilarSong object
              return SimilarSong(song, name, artistName, match);
            }
          } catch (e) {
            print("Error parsing track: $e");
          }
          // Return null if parsing fails or match is below threshold
          return null;
        }).whereType<Song>().toList();

    return Playlist(tracks); // Return the playlist
  } catch (e) {
    print("Error fetching similar songs: $e");
    // Return a fallback playlist with a single song
    return Playlist([Song("Nothing", "Is Here")]);
  }
}

// Example usage
void main() async {
  Song follow = Song("The Prince", "Madeon");

  // Fetch the playlist
  Playlist playlist = await getSimilarSongs(follow, 0.2, 10);

  // Print all songs in the playlist
  for (var song in playlist.tracks) {
    if (song is SimilarSong) {
      print(
        "Song: ${song.name}, Artist: ${song.artist} - Match: ${song.match}",
      );
    }
  }
}
