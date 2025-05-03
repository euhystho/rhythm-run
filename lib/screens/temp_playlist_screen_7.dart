import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rhythmrun/utils/theme.dart';
import '../data/services/generate_playlist.dart';
import '../data/types/song.dart';
import 'final_playlist_screen_8.dart';

class TempPlaylistPage extends StatefulWidget {
  const TempPlaylistPage({super.key});

  @override
  State<TempPlaylistPage> createState() => TempPlaylistPageState();
}

class TempPlaylistPageState extends State<TempPlaylistPage> {
  // PLEASE DELETE THE SAMPLES LATER THEY ARE FOR TESTING
  Playlist songList = Playlist([
    Song('Everything In Its Right Place', 'Radiohead'),
    // Song('Elf', 'Ado'),
    Song('Simmer', 'Hayley Williams')
  ]);

  Playlist suggestedSongs = Playlist([]);

  double threshold = 0.2;
  double limit = 1;
  Timer? debounce;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchSuggestions();
  }

  void onSliderUpdate() {
    debounce?.cancel();

    debounce = Timer(
      const Duration(milliseconds: 500),
      () {
        fetchSuggestions();
      },
    );
  }

  Future<void> fetchSuggestions() async {
    final currentSongList = List<Song>.from(songList.tracks);
    final localThreshold = threshold;
    final localLimit = limit.toInt();

    setState(() {
      isLoading = true;
    });

    try {
      List<Future<Playlist>> futures = currentSongList.map((song) async {
        try {
          return await getSimilarSongs(song, localThreshold, localLimit).timeout(const Duration(seconds: 5));
        } catch (e) {
          print("Timeout or error for song ${song.name}: $e");
          return Playlist([]);
        }
      }).toList();

      final playlists = await Future.wait(futures);

      List<Song> newSuggestions = [];
      for (var playlist in playlists) {
        newSuggestions.addAll(playlist.tracks);
      }

      final existingSongs = {
        ...currentSongList.map((s) => '${s.name}-${s.artist}')
      };
      newSuggestions = newSuggestions.where((s) => !existingSongs.contains('${s.name}-${s.artist}')).toList();

      if (mounted) {
        setState(() {
          suggestedSongs.tracks = newSuggestions;
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


  void addSongToPlaylist(Song song) {
    setState(() {
      songList.tracks.add(song);
      suggestedSongs.tracks.removeWhere((s) => s.name == song.name && s.artist == song.artist);
    });
  }

  void removeSongFromPlaylist(Song song) {
    setState(() {
      songList.tracks.removeWhere((s) => s.name == song.name && s.artist == song.artist);
      suggestedSongs.tracks.add(song);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Tentative Playlist',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 16.0),
                    child: Text(
                      'Playlist',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ReorderableListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: songList.tracks.length,
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (oldIndex < newIndex) {
                              newIndex -= 1;
                            }
                            final item = songList.tracks.removeAt(oldIndex);
                            songList.tracks.insert(newIndex, item);
                          });
                        },
                        itemBuilder: (context, index) {
                          final fileName = songList.tracks[index].toString();
                          return Material(
                            key: Key('$index'),
                            color: Colors.transparent,
                            child: ListTile(
                              title: Text(
                                fileName,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Theme.of(context).colorScheme.error,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        removeSongFromPlaylist(songList.tracks[index]);
                                      });
                                    },
                                  ),
                                  ReorderableDragStartListener(
                                    index: index,
                                    child: Icon(
                                      Icons.drag_handle,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 16.0),
                    child: Text(
                      'Suggested Songs',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : suggestedSongs.tracks.isEmpty
                              ? const Center(child: Text('No suggestions found.'))
                              : ListView.builder(
                                  itemCount: suggestedSongs.tracks.length,
                                  itemBuilder: (context, index) {
                                    final song = suggestedSongs.tracks[index];
                                    return ListTile(
                                      title: Text('${song.name} - ${song.artist}'),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.add_circle),
                                        onPressed: () => addSongToPlaylist(song),
                                      ),
                                    );
                                  },
                                ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Suggested song similarity (least to most similar)',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Slider(
                    value: threshold,
                    min: 0.2,
                    max: 1.0,
                    inactiveColor: Theme.of(context).colorScheme.onSurface,
                    onChanged: (double value) {
                      setState(() {
                        threshold = value;
                        onSliderUpdate();
                      });
                    },
                  ),
                  Text(
                    'Number of suggestions per song (1-20)',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Slider(
                    value: limit,
                    min: 1,
                    max: 20,
                    inactiveColor: Theme.of(context).colorScheme.onSurface,
                    onChanged: (double value) {
                      setState(() {
                        limit = value;
                        onSliderUpdate();
                      });
                    },
                  ),
                ],
              ),
            ),
            if (songList.tracks.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 4,
                        color: Color(0x20000000),
                        offset: Offset(0, -2),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${songList.tracks.length} Songs',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Ready to finalize',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: RhythmRunTheme.secondaryText,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => FinalPlaylistPage()),
                            );
                          },
                          icon: FaIcon(FontAwesomeIcons.check),
                          label: Text(
                            'Finalize Playlist',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.tertiary,
                            minimumSize: const Size(150, 40),
                            padding: const EdgeInsets.all(8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

Future main() async {
  await dotenv.load(fileName: "assets/.env"); 
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //Toggle the Debug Banner on the side :)
      debugShowCheckedModeBanner: false,
      title: 'RhythmRun',
      theme: RhythmRunTheme.lightTheme,
      darkTheme: RhythmRunTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const TempPlaylistPage(),
    );
  }
}