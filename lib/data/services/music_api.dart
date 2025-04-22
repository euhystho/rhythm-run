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
  Future<void> setMusicQueue(Song song, Playlist songList) async {
    // Delegate to appropriate API based on auth status
    final authStatus = await _auth.getAuthStatus();
    if (authStatus == 'spotify') {
      await _spotifyAPI.setMusicQueue(song, songList);
    } else if (authStatus == 'apple') {
      await _appleMusicAPI.setMusicQueue(song, songList);
    }
  }

  Future<void> addSongToLibrary(Song song) async {
    final authStatus = await _auth.getAuthStatus();
    if (authStatus == 'spotify') {
      await _spotifyAPI.addSongToLibrary(song);
    } else if (authStatus == 'apple') {
      await _appleMusicAPI.addSongToLibrary(song);
    }
  }

  Future<void> addPlaylistToLibrary(Playlist songList) async {
    final authStatus = await _auth.getAuthStatus();
    if (authStatus == 'spotify') {
      await _spotifyAPI.addPlaylistToLibrary(songList);
    } else if (authStatus == 'apple') {
      await _appleMusicAPI.addPlaylistToLibrary(songList);
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

  Future<void> repeatSongs({bool repeatCurrent = false}) async {
    final authStatus = await _auth.getAuthStatus();
    if (authStatus == 'spotify') {
      await _spotifyAPI.repeatSongs(repeatCurrent: repeatCurrent);
    } else if (authStatus == 'apple') {
      await _appleMusicAPI.repeatSongs(repeatCurrent: repeatCurrent);
    }
  }
}