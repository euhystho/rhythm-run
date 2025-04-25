import 'package:spotify_sdk/enums/repeat_mode_enum.dart';

import 'spotify_api.dart';
import 'apple_music.dart';
import '../types/song.dart';

enum MusicService { spotify, appleMusic }


class MusicAPI {
  final SpotifyAPI _spotifyAPI;
  final AppleMusicAPI _appleMusicAPI;
  MusicService service;
  String _authToken = "";

  MusicAPI(this._spotifyAPI, this._appleMusicAPI, this.service);

  Future<String> getAuth() async {
    // Delegate to appropriate API for subscription check
    if (service == MusicService.spotify) {
      _authToken = await _spotifyAPI.getAuth();
    } else if (service == MusicService.appleMusic) {
      _authToken = await _appleMusicAPI.checkSubscription();
    }
    print('Authentication Token: $_authToken');
    return _authToken;
  }

  // Facade methods to simplify music operations
  Future<void> setMusicQueue(StreamableSong song) async {
    if (service == MusicService.spotify) {
      await _spotifyAPI.setMusicQueue(song);
    } else if (service == MusicService.appleMusic) {
      await _appleMusicAPI.setMusicQueue(song);
    }
  }

  Future<void> addSongToLibrary(StreamableSong song) async {
    if (service == MusicService.spotify) {
      await _spotifyAPI.addSongToLibrary(song);
    } else if (service == MusicService.appleMusic) {
      await _appleMusicAPI.addSongToLibrary(song);
    }
  }

  Future<void> togglePlayback() async {
    if (service == MusicService.spotify) {
      await _spotifyAPI.togglePlayback();
    } else if (service == MusicService.appleMusic) {
      await _appleMusicAPI.togglePlayback();
    }
  }

  Future<void> skipSong() async {
    if (service == MusicService.spotify) {
      await _spotifyAPI.skipSong();
    } else if (service == MusicService.appleMusic) {
      await _appleMusicAPI.skipSong();
    }
  }

  Future<void> shuffleSongs() async {
    if (service == MusicService.spotify) {
      await _spotifyAPI.shuffleSongs();
    } else if (service == MusicService.appleMusic) {
      await _appleMusicAPI.shuffleSongs();
    }
  }

  Future<void> repeatSongs(bool repeat) async {
    if (service == MusicService.spotify) {
      await _spotifyAPI.repeatSongs(repeat as RepeatMode);
    } else if (service == MusicService.appleMusic) {
      await _appleMusicAPI.repeatSongs(repeat);
    }
  }
}
