import 'package:flutter/services.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import '../types/song.dart';


class SpotifyAPI {
  SpotifySdk spotify = SpotifySdk();
  final String clientID = String.fromEnvironment('SPOT_CLIENT_ID');
  final String redirectURI = String.fromEnvironment('REDIRECT_URL');
  final List<String> _playerQueue = [];

  SpotifyAPI();

  // Subsystem methods
  Future<void> setMusicQueue(StreamableSong song) async {
    print('Spotify: Setting music queue for $song');
    // Implement Spotify API call
    _playerQueue.add(song.streamID);
    try {
      if (_playerQueue.isNotEmpty) {
        await SpotifySdk.queue(spotifyUri: _playerQueue.last);
      }
    } on PlatformException catch (e) {
      print(e.code);
    } on MissingPluginException {
      print('not implemented');
    }
  }

  Future<void> addSongToLibrary(StreamableSong song) async {
    print('Spotify: Adding song to library: $song');
    // Implement Spotify API call
    try {
      await SpotifySdk.addToLibrary(
          spotifyUri: song.streamID);
    } on PlatformException catch (e) {
      print(e.code);
    } on MissingPluginException {
      print('not implemented');
    }
  }

  Future<void> togglePlayback() async {
    print('Spotify: Toggling playback');
    // Implement Spotify API call
    try {
      await SpotifySdk.pause();
    } on PlatformException catch (e) {
      print(e.code);
    } on MissingPluginException {
      print('not implemented');
    }
  }

  Future<void> skipSong() async {
    print('Spotify: Skipping song');
    // Implement Spotify API call
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
    // Implement Spotify API call
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
    // Implement Spotify API call
    try {
      await SpotifySdk.setRepeatMode(
        repeatMode: repeat,
      );
    } on PlatformException catch (e) {
      print(e.code);
    } on MissingPluginException {
      print('not implemented');
    }
  }

  Future<String> checkSubscription() async {
    // Placeholder for subscription check
    try {
      var authenticationToken = await SpotifySdk.getAccessToken(
          clientId: const String.fromEnvironment('SPOT_CLIENT_ID'),
          redirectUrl: const String.fromEnvironment('REDIRECT_URL'),
          scope: 'app-remote-control, '
              'user-modify-playback-state, '
              'playlist-read-private, '
              'playlist-modify-public,user-read-currently-playing');
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
