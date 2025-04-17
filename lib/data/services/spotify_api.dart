import 'package:spotify_sdk/spotify_sdk.dart';

class SpotifyAPI {
  SpotifySdk spotify = SpotifySdk();
  final String clientID = String.fromEnvironment('SPOT_CLIENT_ID');
  final String redirectURI = String.fromEnvironment('REDIRECT_URL');

  SpotifyAPI();

  // Subsystem methods
  Future<void> setMusicQueue(String song, List<String> songList) async {
    print('Spotify: Setting music queue for $song, list: $songList');
    // Implement Spotify API call
  }

  Future<void> addSongToLibrary(String song) async {
    print('Spotify: Adding song to library: $song');
    // Implement Spotify API call
  }

  Future<void> addPlaylistToLibrary(List<String> songList) async {
    print('Spotify: Adding playlist to library: $songList');
    // Implement Spotify API call
  }

  Future<void> togglePlayback() async {
    print('Spotify: Toggling playback');
    // Implement Spotify API call
  }

  Future<void> skipSong() async {
    print('Spotify: Skipping song');
    //TODO: Add more error catching here :)
    await SpotifySdk.skipNext();
    // Implement Spotify API call
  }

  Future<void> shuffleSongs() async {
    print('Spotify: Shuffling songs');
    // Implement Spotify API call
  }

  Future<void> repeatSongs({bool repeatCurrent = false}) async {
    print('Spotify: Repeating songs, repeatCurrent: $repeatCurrent');
    // Implement Spotify API call
  }

  Future<bool> checkSubscription() async {
    // Placeholder for subscription check
    return true; // Implement actual logic
  }
}