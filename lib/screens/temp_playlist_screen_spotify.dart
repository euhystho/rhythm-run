import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rhythmrun/data/services/generate_playlist.dart';
import 'package:rhythmrun/data/types/song.dart';

class TempPlaylistSpotifyPage extends StatefulWidget {
  final List<StreamableSong> importedSongs;
  const TempPlaylistSpotifyPage({super.key, required this.importedSongs});

  @override
  State<TempPlaylistSpotifyPage> createState() => TempPlaylistSpotifyPageState();
}

class TempPlaylistSpotifyPageState extends State<TempPlaylistSpotifyPage> {
  late Playlist songList;
  Map<StreamableSong, List<Song>> suggestedSongsMap = {};
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
      Map<StreamableSong, List<Song>> newSuggestionsMap = {};
      for (final song in currentSongList) {
        try {
          final playlist = await getSimilarSongs(song, localThreshold, localLimit).timeout(const Duration(seconds: 5));
          final existingSongs = {
            ...currentSongList.map((s) => '${s.name}-${s.artist}')
          };
          final filtered = playlist.tracks.where((s) => !existingSongs.contains('${s.name}-${s.artist}')).toList();
          newSuggestionsMap[song] = filtered;
        } catch (e) {
          print("Timeout or error for song " + song.name + ": $e");
          newSuggestionsMap[song] = [];
        }
      }
      if (mounted) {
        setState(() {
          suggestedSongsMap = newSuggestionsMap;
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

  void addSongToPlaylist(StreamableSong song) {
    setState(() {
      songList.addSong(song);
      for (final suggestions in suggestedSongsMap.values) {
        suggestions.removeWhere((s) => s.name == song.name && s.artist == song.artist);
      }
    });
    fetchSuggestions();
  }

  void removeSongFromPlaylist(StreamableSong song) {
    setState(() {
      songList.removeSong(song);
    });
    fetchSuggestions();
  }

  @override
  Widget build(BuildContext context) {
    // Flatten all suggestions into a single list, removing duplicates
    final allSuggestions = <Song>{};
    for (final suggestions in suggestedSongsMap.values) {
      allSuggestions.addAll(suggestions);
    }
    final suggestionsList = allSuggestions.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Temp Playlist Spotify'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: songList.trackCount,
              itemBuilder: (context, index) {
                if (index >= songList.tracks.length) return SizedBox.shrink();
                final song = songList.tracks[index] as StreamableSong;
                return ListTile(
                  title: Text(song.name),
                  subtitle: Text(song.artist),
                  trailing: IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: () => removeSongFromPlaylist(song),
                  ),
                );
              },
            ),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            )
          else ...[
            Expanded(
              child: suggestionsList.isEmpty
                  ? const Center(child: Text('No suggestions found.'))
                  : ListView.builder(
                      itemCount: suggestionsList.length,
                      itemBuilder: (context, index) {
                        final s = suggestionsList[index];
                        return ListTile(
                          title: Text('${s.name} - ${s.artist}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.add_circle),
                            onPressed: () => addSongToPlaylist(s as StreamableSong),
                          ),
                        );
                      },
                    ),
            ),
          ],
          ElevatedButton(
            onPressed: () {
              // Logic for adding a song
            },
            child: Text('Add Song'),
          ),
        ],
      ),
    );
  }
}