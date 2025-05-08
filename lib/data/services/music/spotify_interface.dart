import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import '../../types/song.dart';

const String authUrl = 'https://accounts.spotify.com/authorize';
const String tokenUrl = 'https://accounts.spotify.com/api/token';
const String playlistsUrl = 'https://api.spotify.com/v1/me/playlists';
const String searchUrl = 'https://api.spotify.com/v1/search';
const String scope = 'playlist-read-private';

class SpotifyInterface {
  SpotifySdk spotify = SpotifySdk();
  final String clientID =
      String.fromEnvironment('SPOT_CLIENT_ID').isNotEmpty
          ? String.fromEnvironment('SPOT_CLIENT_ID')
          : dotenv.env['SPOT_CLIENT_ID'] ?? '';
  final String clientSecret =
      String.fromEnvironment('SPOT_CLIENT_SECRET').isNotEmpty
          ? String.fromEnvironment('SPOT_CLIENT_SECRET')
          : dotenv.env['SPOT_CLIENT_SECRET'] ?? '';
  final String redirectURI = "rhythmrun://callback";
  final List<String> _songQueue = [];
  bool loading = false;

  Future<void> initSpotify() async {
    try {
      await connectToSpotifySDK();
      await getAuth();
    } catch (e) {
      print('Failed to initialize Spotify');
    }
  }

  Future<void> setMusicQueue(StreamableSong song) async {
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

  Future<void> skipToPrevious() async {
  try {
    await SpotifySdk.skipPrevious();
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

  Future<void> shuffleSongs(bool shuffleStatus) async {
    print('Spotify: Shuffling songs');
    try {
      await SpotifySdk.setShuffle(shuffle: shuffleStatus);
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

  Future<void> connectToSpotifySDK() async {
    try {
      loading = true;

      var result = await SpotifySdk.connectToSpotifyRemote(
        clientId: clientID,
        redirectUrl: redirectURI,
      );
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

class SpotifyAPI extends SpotifyInterface with ChangeNotifier {
  String? _accessToken;
  String? _refreshToken;
  final _storage = FlutterSecureStorage();

  String? get accessToken => _accessToken;
  bool get isAuthenticated => _accessToken != null;

  Future<void> authenticate() async {
    final url =
        '$authUrl?client_id=$clientID&response_type=code&redirect_uri=$redirectURI&scope=$scope';
    final result = await FlutterWebAuth.authenticate(
      url: url,
      callbackUrlScheme: 'rhythmrun',
    );
    final code = Uri.parse(result).queryParameters['code']!;

    final response = await http.post(
      Uri.parse(tokenUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': redirectURI,
        'client_id': clientID,
        'client_secret': clientSecret,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _accessToken = data['access_token'];
      _refreshToken = data['refresh_token'];
      await _storage.write(key: 'access_token', value: _accessToken);
      await _storage.write(key: 'refresh_token', value: _refreshToken);
      notifyListeners();
    } else {
      throw Exception('Authentication failed');
    }
  }

  Future<void> refreshToken() async {
    final refreshToken = await _storage.read(key: 'refresh_token');
    final response = await http.post(
      Uri.parse(tokenUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken!,
        'client_id': clientID,
        'client_secret': clientSecret,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _accessToken = data['access_token'];
      await _storage.write(key: 'access_token', value: _accessToken);
      notifyListeners();
    } else {
      throw Exception('Token refresh failed');
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    _accessToken = null;
    _refreshToken = null;
    notifyListeners();
  }

  Future<void> loadTokens() async {
    _accessToken = await _storage.read(key: 'access_token');
    _refreshToken = await _storage.read(key: 'refresh_token');
    if (_accessToken != null) notifyListeners();
  }

  Future<StreamableSong?> searchSpotifyForSong(Song song) async {
    // Build the search query using song name and artist
    final query = Uri.encodeComponent('${song.name} ${song.artist}');
    final url = '$searchUrl?q=$query&type=track&limit=1';

    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 401) {
      await refreshToken();
      return searchSpotifyForSong(song);
    } else if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final tracks = data['tracks'];
      if (tracks != null &&
          tracks['items'] != null &&
          tracks['items'].isNotEmpty) {
        final item = tracks['items'][0];
        return StreamableSong.fromSpotifySearch(item, song);
      } else {
        return null;
      }
    } else {
      throw Exception('Failed to search for song');
    }
  }

  Future<List<SpotifyPlaylist>> fetchPlaylists() async {
    final response = await http.get(
      Uri.parse(playlistsUrl),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 401) {
      await refreshToken();
      return fetchPlaylists();
    } else if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final items = data['items'] as List;
      return items.map((item) => SpotifyPlaylist.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch playlists');
    }
  }

  Future<List<StreamableSong>> fetchTracks(playlistID) async {
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/playlists/$playlistID/tracks'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 401) {
      await refreshToken();
      return fetchTracks(playlistID);
    } else if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final items = data['items'] as List;
      return items.map((item) => StreamableSong.fromSpotifyJson(item)).toList();
    } else {
      throw Exception('Failed to fetch tracks');
    }
  }
}
