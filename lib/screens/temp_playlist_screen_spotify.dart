import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rhythmrun/data/services/generate_playlist.dart';
import 'package:rhythmrun/data/services/music/spotify_interface.dart';
import 'package:rhythmrun/data/types/song.dart';
import 'spotify_playback_screen.dart';

class TempPlaylistSpotifyPage extends StatefulWidget {
  final List<StreamableSong> importedSongs;
  final SpotifyAPI spotifyApi;

  const TempPlaylistSpotifyPage({
    super.key,
    required this.importedSongs,
    required this.spotifyApi,
  });

  @override
  State<TempPlaylistSpotifyPage> createState() => TempPlaylistSpotifyPageState();
}

class TempPlaylistSpotifyPageState extends State<TempPlaylistSpotifyPage> {
  late Playlist songList;
  Set<Song> suggestedSongs = {};
  double threshold = 0.2;
  double limit = 1;
  Timer? debounce;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    songList = Playlist(widget.importedSongs);
    fetchSuggestions();
  }

  Future<void> fetchSuggestions() async {
    final currentSongList = List<StreamableSong>.from(songList.tracks);
    final localThreshold = threshold;
    final localLimit = limit.toInt();

    setState(() {
      isLoading = true;
    });

    try {
      Set<Song> newSuggestions = {};
      for (final song in currentSongList) {
        try {
          final playlist = await getSimilarSongs(song, localThreshold, localLimit).timeout(const Duration(seconds: 5));
          final existingSongs = {
            ...currentSongList.map((s) => '${s.name}-${s.artist}')
          };
          final filtered = playlist.tracks
              .where((s) =>
                  s.name.trim().isNotEmpty &&
                  s.artist.trim().isNotEmpty &&
                  !existingSongs.contains('${s.name}-${s.artist}'))
              .toList();
          newSuggestions.addAll(filtered);
        } catch (e) {
          print("Timeout or error for song " + song.name + ": $e");
        }
      }
      if (mounted) {
        setState(() {
          suggestedSongs = newSuggestions;
        });
      }
    } catch (e) {
      print("fetchSuggestions error: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> addSongToPlaylist(Song song) async {
    setState(() {
      isLoading = true;
    });
    try {
      final streamableSong = await widget.spotifyApi.searchSpotifyForSong(
        Song(song.name, song.artist),
      );
      if (streamableSong != null) {
        setState(() {
          songList = Playlist([...songList.tracks, streamableSong]); // Create new playlist instance
          suggestedSongs = Set<Song>.from(suggestedSongs)..removeWhere(
            (s) => s.name == song.name && s.artist == song.artist
          );
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not find this song on Spotify.')),
        );
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding song: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final suggestionsList = suggestedSongs.toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: Text(
          'Customize Playlist',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        elevation: 0,
      ),
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 8,
                        color: Colors.black.withOpacity(0.08),
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Songs',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSecondaryContainer,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: ListView.builder(
                            itemCount: songList.trackCount,
                            itemBuilder: (context, index) {
                              if (index >= songList.tracks.length) return const SizedBox.shrink();
                              final song = songList.tracks[index] as StreamableSong;
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ListTile(
                                  title: Text(
                                    song.name,
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                  subtitle: Text(
                                    song.artist,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  dense: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 8,
                        color: Colors.black.withOpacity(0.08),
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Suggested Songs',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSecondaryContainer,
                              ),
                            ),
                            const Spacer(),
                            if (isLoading)
                              const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: suggestionsList.isEmpty
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 24),
                                    child: Text('No suggestions found.'),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: suggestionsList.length,
                                  itemBuilder: (context, index) {
                                    final s = suggestionsList[index];
                                    return Card(
                                      margin: const EdgeInsets.symmetric(vertical: 6),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: ListTile(
                                        title: Text(
                                          s.name,
                                          style: theme.textTheme.bodyLarge,
                                        ),
                                        subtitle: Text(
                                          s.artist,
                                          style: theme.textTheme.bodySmall,
                                        ),
                                        trailing: IconButton(
                                          icon: Icon(Icons.add_circle, color: colorScheme.primary),
                                          onPressed: () => addSongToPlaylist(s),
                                        ),
                                        dense: true,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SpotifyPlaybackScreen(
                          playlist: songList,
                          spotifyApi: widget.spotifyApi,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Continue to Playback',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}