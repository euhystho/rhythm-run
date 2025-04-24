import 'package:spotify_sdk/enums/repeat_mode_enum.dart';

import 'music_auth.dart';
import 'spotify_api.dart';
import 'apple_music.dart';
import '../types/song.dart';

class MusicAPI {
  final MusicAuth _auth;
  final SpotifyAPI _spotifyAPI;
  final AppleMusicAPI _appleMusicAPI;

  MusicAPI(this._auth, this._spotifyAPI, this._appleMusicAPI);

  // Facade methods to simplify music operations
  Future<void> setMusicQueue(StreamableSong song) async {
    // Delegate to appropriate API based on auth status
    final authStatus = await _auth.getAuthStatus();
    if (authStatus == 'spotify') {
      await _spotifyAPI.setMusicQueue(song);
    } else if (authStatus == 'apple') {
      await _appleMusicAPI.setMusicQueue(song);
    }
  }

  Future<void> addSongToLibrary(StreamableSong song) async {
    final authStatus = await _auth.getAuthStatus();
    if (authStatus == 'spotify') {
      await _spotifyAPI.addSongToLibrary(song);
    } else if (authStatus == 'apple') {
      await _appleMusicAPI.addSongToLibrary(song);
    }
  }

  Future<void> togglePlayback() async {
    final authStatus = await _auth.getAuthStatus();
    if (authStatus == 'spotify') {
      await _spotifyAPI.togglePlayback();
    } else if (authStatus == 'apple') {
      await _appleMusicAPI.togglePlayback();
    }
  }

  Future<void> skipSong() async {
    final authStatus = await _auth.getAuthStatus();
    if (authStatus == 'spotify') {
      await _spotifyAPI.skipSong();
    } else if (authStatus == 'apple') {
      await _appleMusicAPI.skipSong();
    }
  }

  Future<void> shuffleSongs() async {
    final authStatus = await _auth.getAuthStatus();
    if (authStatus == 'spotify') {
      await _spotifyAPI.shuffleSongs();
    } else if (authStatus == 'apple') {
      await _appleMusicAPI.shuffleSongs();
    }
  }

  Future<void> repeatSongs(bool repeat) async {
    final authStatus = await _auth.getAuthStatus();
    if (authStatus == 'spotify') {
      await _spotifyAPI.repeatSongs(repeat as RepeatMode);
    } else if (authStatus == 'apple') {
      await _appleMusicAPI.repeatSongs(repeat);
    }
  }
}