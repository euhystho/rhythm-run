import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spotify Playlist Importer',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SpotifyPlaylistScreen(),
    );
  }
}

class SpotifyPlaylistScreen extends StatefulWidget {
  const SpotifyPlaylistScreen({Key? key}) : super(key: key);

  @override
  _SpotifyPlaylistScreenState createState() => _SpotifyPlaylistScreenState();
}

class _SpotifyPlaylistScreenState extends State<SpotifyPlaylistScreen> {
  final String clientId = String.fromEnvironment('SPOT_CLIENT_ID'); // Replace with your Spotify Client ID
  final String redirectUri = 'rhythmrun://callback'; // Your registered redirect URI
  String? accessToken;
  List<Playlist> playlists = [];
  List<Track> tracks = [];
  bool isLoading = false;
  String selectedPlaylistName = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tracks.isEmpty ? 'Spotify Playlists' : selectedPlaylistName),
        actions: [
          if (tracks.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                setState(() {
                  tracks = [];
                });
              },
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : accessToken == null
              ? _buildLoginView()
              : tracks.isNotEmpty
                  ? _buildTrackList()
                  : _buildPlaylistsView(),
      floatingActionButton: accessToken == null
          ? null
          : FloatingActionButton(
              child: const Icon(Icons.refresh),
              onPressed: () {
                if (tracks.isEmpty) {
                  _fetchPlaylists();
                } else {
                  _fetchPlaylistTracks(tracks[0].playlistId);
                }
              },
            ),
    );
  }

  Widget _buildLoginView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            'https://storage.googleapis.com/pr-newsroom-wp/1/2018/11/Spotify_Logo_RGB_Green.png',
            height: 80,
          ),
          const SizedBox(height: 30),
          const Text(
            'Import your Spotify playlists',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Connect your Spotify account to access your playlists',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            icon: const Icon(Icons.login),
            label: const Text('Connect with Spotify'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: _authenticate,
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistsView() {
    return playlists.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'No playlists found',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _fetchPlaylists,
                  child: const Text('Refresh Playlists'),
                ),
              ],
            ),
          )
        : ListView.builder(
            itemCount: playlists.length,
            itemBuilder: (context, index) {
              final playlist = playlists[index];
              return ListTile(
                leading: playlist.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          playlist.imageUrl!,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Container(
                        width: 56,
                        height: 56,
                        color: Colors.grey[300],
                        child: const Icon(Icons.music_note),
                      ),
                title: Text(playlist.name),
                subtitle: Text('${playlist.trackCount} tracks'),
                onTap: () => _fetchPlaylistTracks(playlist.id),
              );
            },
          );
  }

  Widget _buildTrackList() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: tracks.length,
            itemBuilder: (context, index) {
              final track = tracks[index];
              return ListTile(
                leading: track.albumImageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          track.albumImageUrl!,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Container(
                        width: 56,
                        height: 56,
                        color: Colors.grey[300],
                        child: const Icon(Icons.music_note),
                      ),
                title: Text(
                  track.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  track.artists.join(', '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  _formatDuration(track.durationMs),
                  style: TextStyle(color: Colors.grey[600]),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[100],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${tracks.length} songs',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Total time: ${_formatTotalDuration()}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _authenticate() async {
    setState(() {
      isLoading = true;
    });

    final authorizeUrl = Uri.https('accounts.spotify.com', '/authorize', {
      'client_id': clientId,
      'response_type': 'token',
      'redirect_uri': redirectUri,
      'scope': 'playlist-read-private playlist-read-collaborative',
    });

    try {
      final result = await FlutterWebAuth.authenticate(
        url: authorizeUrl.toString(),
        callbackUrlScheme: 'myapp',
      );

      final Uri resultUri = Uri.parse(result);
      final fragment = resultUri.fragment;
      final params = Uri.splitQueryString(fragment);
      final token = params['access_token'];

      setState(() {
        accessToken = token;
        isLoading = false;
      });

      _fetchPlaylists();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showError('Authentication failed');
    }
  }

  Future<void> _fetchPlaylists() async {
    if (accessToken == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/me/playlists?limit=50'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final items = data['items'] as List;

        setState(() {
          playlists = items.map((item) {
            String? imageUrl;
            if (item['images'] != null && (item['images'] as List).isNotEmpty) {
              imageUrl = item['images'][0]['url'];
            }

            return Playlist(
              id: item['id'],
              name: item['name'],
              trackCount: item['tracks']['total'],
              imageUrl: imageUrl,
            );
          }).toList();
          isLoading = false;
        });
      } else if (response.statusCode == 401) {
        // Token expired
        setState(() {
          accessToken = null;
          isLoading = false;
        });
        _showError('Session expired. Please login again.');
      } else {
        setState(() {
          isLoading = false;
        });
        _showError('Failed to load playlists');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showError('Network error');
    }
  }

  Future<void> _fetchPlaylistTracks(String playlistId) async {
    if (accessToken == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      // First, get the playlist name
      final playlistResponse = await http.get(
        Uri.parse('https://api.spotify.com/v1/playlists/$playlistId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );
      
      if (playlistResponse.statusCode == 200) {
        final playlistData = jsonDecode(playlistResponse.body);
        selectedPlaylistName = playlistData['name'];
      }

      // Then get the tracks
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/playlists/$playlistId/tracks'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final items = data['items'] as List;

        setState(() {
          tracks = items.map((item) {
            final track = item['track'];
            if (track == null) {
              // Some items might be null or missing track data
              return Track(
                id: 'unknown',
                name: 'Unknown Track',
                artists: ['Unknown Artist'],
                durationMs: 0,
                albumImageUrl: null,
                playlistId: playlistId,
              );
            }

            String? albumImageUrl;
            if (track['album'] != null && 
                track['album']['images'] != null && 
                (track['album']['images'] as List).isNotEmpty) {
              albumImageUrl = track['album']['images'][0]['url'];
            }

            final artistsList = (track['artists'] as List)
                .map((artist) => artist['name'] as String)
                .toList();

            return Track(
              id: track['id'],
              name: track['name'],
              artists: artistsList,
              durationMs: track['duration_ms'],
              albumImageUrl: albumImageUrl,
              playlistId: playlistId,
            );
          }).toList();
          isLoading = false;
        });
      } else if (response.statusCode == 401) {
        // Token expired
        setState(() {
          accessToken = null;
          isLoading = false;
        });
        _showError('Session expired. Please login again.');
      } else {
        setState(() {
          isLoading = false;
        });
        _showError('Failed to load tracks');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showError('Network error');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  String _formatDuration(int milliseconds) {
    final int seconds = (milliseconds / 1000).floor();
    final int minutes = (seconds / 60).floor();
    final int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatTotalDuration() {
    final int totalMs = tracks.fold(0, (sum, track) => sum + track.durationMs);
    final int totalSeconds = (totalMs / 1000).floor();
    final int hours = (totalSeconds / 3600).floor();
    final int minutes = ((totalSeconds % 3600) / 60).floor();
    
    if (hours > 0) {
      return '$hours hr ${minutes.toString()} min';
    } else {
      return '$minutes min';
    }
  }
}

class Playlist {
  final String id;
  final String name;
  final int trackCount;
  final String? imageUrl;

  Playlist({
    required this.id,
    required this.name,
    required this.trackCount,
    this.imageUrl,
  });
}

class Track {
  final String id;
  final String name;
  final List<String> artists;
  final int durationMs;
  final String? albumImageUrl;
  final String playlistId;

  Track({
    required this.id,
    required this.name,
    required this.artists,
    required this.durationMs,
    this.albumImageUrl,
    required this.playlistId,
  });
}