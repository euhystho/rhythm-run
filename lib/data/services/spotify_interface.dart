import 'package:flutter/services.dart';
import 'package:dotenv/dotenv.dart' as dotenv;
import 'package:spotify_sdk/spotify_sdk.dart';
import '../types/song.dart';

final env = dotenv.DotEnv()..load(['.env']);

class SpotifyInterface {
  SpotifySdk spotify = SpotifySdk();
  final String clientID =
      String.fromEnvironment('SPOT_CLIENT_ID').isNotEmpty
          ? String.fromEnvironment('SPOT_CLIENT_ID')
          : env['SPOT_CLIENT_ID'] ?? '';
  final String clientSecret =
      String.fromEnvironment('SPOT_CLIENT_SECRET').isNotEmpty
          ? String.fromEnvironment('SPOT_CLIENT_SECRET')
          : env['SPOT_CLIENT_SECRET'] ?? '';
  final String redirectURI = "rhythmrun://callback";
  final List<String> _songQueue = [];
  bool loading = false;

  Future<void> initSpotify() async {
    /// Initializes the Spotify API by connecting the Spotify,
    /// then getting the Authentication Token and throws an error if initializing fails
    try {
      await connectToSpotifySDK();
      await getAuth();
    } catch (e) {
      print('Failed to initialize Spotify');
    }
  }

  // Subsystem methods
  Future<void> setMusicQueue(StreamableSong song) async {
    /// Adds a song to the queue on Spotify based on the Spotify URI
    print('Spotify: Setting music queue for $song');
    _songQueue.add(song.streamID);
    try {
      if (_songQueue.isNotEmpty) {
        await SpotifySdk.queue(spotifyUri: _songQueue.last);
      }
    } on PlatformException catch (e) {
      print(e.code);
    } on MissingPluginException {
      print('not implemented');
    }
  }

  Future<void> addSongToLibrary(StreamableSong song) async {
    print('Spotify: Adding song to library: $song');
    try {
      await SpotifySdk.addToLibrary(spotifyUri: song.streamID);
    } on PlatformException catch (e) {
      print(e.code);
    } on MissingPluginException {
      print('not implemented');
    }
  }

  Future<void> togglePlayback() async {
    print('Spotify: Toggling playback');
    try {
      var playerState = await SpotifySdk.getPlayerState();
      if (playerState != null && playerState.isPaused) {
        await SpotifySdk.resume();
      } else if (playerState != null && !playerState.isPaused) {
        await SpotifySdk.pause();
      }
    } on PlatformException catch (e) {
      print(e.code);
    } on MissingPluginException {
      print('not implemented');
    }
  }

  Future<void> skipSong() async {
    print('Spotify: Skipping song');
    try {
      await SpotifySdk.skipNext();
    } on PlatformException catch (e) {
      print(e.code);
    } on MissingPluginException {
      print('not implemented');
    }
  }

  Future<void> shuffleSongs() async {
    print('Spotify: Shuffling songs');
    try {
      await SpotifySdk.toggleShuffle();
    } on PlatformException catch (e) {
      print(e.code);
    } on MissingPluginException {
      print('not implemented');
    }
  }

  Future<void> repeatSongs(RepeatMode repeat) async {
    print('Spotify: Repeating songs, repeatCurrent: $repeat');
    try {
      await SpotifySdk.setRepeatMode(repeatMode: repeat);
    } on PlatformException catch (e) {
      print(e.code);
    } on MissingPluginException {
      print('not implemented');
    }
  }

  /// Authentication Methods:

  Future<void> connectToSpotifySDK() async {
    try {
      loading = true;

      var result = await SpotifySdk.connectToSpotifyRemote(
        clientId: clientID,
        redirectUrl: redirectURI,
      );
      // TODO: Put this in a Popup Message :)
      print(
        result ? 'connect to spotify successful' : 'connect to spotify failed',
      );
      loading = false;
    } on PlatformException catch (e) {
      loading = false;
      print(e.code);
    } on MissingPluginException {
      loading = false;
      print('not implemented');
    }
  }

  Future<String> getAuth() async {
    try {
      var authenticationToken = await SpotifySdk.getAccessToken(
        clientId: clientID,
        redirectUrl: redirectURI,
        scope:
            'app-remote-control, '
            'user-modify-playback-state, '
            'playlist-read-private, '
            'playlist-modify-public,user-read-currently-playing',
      );
      print('Got a token: $authenticationToken');
      return authenticationToken;
    } on PlatformException catch (e) {
      print(e.code);
      return Future.error('$e.code: $e.message');
    } on MissingPluginException {
      print('not implemented');
      return Future.error('not implemented');
    }
  }
}
