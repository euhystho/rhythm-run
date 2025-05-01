import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../data/types/song.dart';

class FinalPlaylistPage extends StatefulWidget {
  const FinalPlaylistPage({super.key});

  @override
  State<FinalPlaylistPage> createState() => FinalPlaylistPageState();
}

class FinalPlaylistPageState extends State<FinalPlaylistPage> {
  // PLEASE DELETE THE SAMPLES LATER THEY ARE FOR TESTING
  Playlist songList = Playlist([
    Song('Simmer', 'Hayley Williams'),
    Song('Everything In Its Right Place', 'Radiohead'),
    Song('Elf', 'Ado'),
    Song('Go With The Flow', 'Queens of the Stone Age'),
    Song('The Strokes', 'Reptilia'),
    Song('Value', 'Ado'),
    Song('Inhaler', 'My Honest Face'),
    Song('Muse', 'The Small Print'),
  ]);

  AudioPlayer? player;
  bool isPlaying = false;
  bool isShuffling = false;
  bool isLooping = false;
  int currentSongIndex = 0;

  @override
  void initState() {
    super.initState();
    player = AudioPlayer();

    player!.onPlayerComplete.listen((event) {
      if (isLooping) {
        playCurrentSong();
      } else {
        skipNext();
      }
    });
  }

  @override
  void dispose() {
    player?.dispose();
    super.dispose();
  }

  Future<void> playCurrentSong() async {
    // laterr
    // final song = songList.tracks[currentSongIndex];

    try {
      await player!.stop();
      await player!.setSource(AssetSource('audio/daft.wav')); // replace with actual source
      await player!.play(AssetSource('audio/daft.wav'));
      setState(() => isPlaying = true);
    } catch (e) {
      print('Playback error: $e');
    }
  }

  void togglePlayPause() {
    if (isPlaying) {
      player!.pause();
    } else {
      playCurrentSong();
    }
    setState(() => isPlaying = !isPlaying);
  }

  Future<void> skipNext() async {
    if (songList.tracks.isEmpty) return;

    setState(() {
      if (isShuffling) {
        currentSongIndex = (currentSongIndex + 1 + DateTime.now().millisecond) % songList.tracks.length;
      } else {
        currentSongIndex = (currentSongIndex + 1) % songList.tracks.length;
      }
    });

    await playCurrentSong();
  }

  Future<void> skipPrevious() async {
    if (songList.tracks.isEmpty) return;

    setState(() {
      if (currentSongIndex == 0) {
        currentSongIndex = songList.tracks.length - 1;
      } else {
        currentSongIndex -= 1;
      }
    });

    await playCurrentSong();
  }

  void toggleShuffle() {
    setState(() => isShuffling = !isShuffling);
  }

  void toggleLoop() {
    setState(() => isLooping = !isLooping);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Final Playlist',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
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
                child: ListView.builder(
                  itemCount: songList.tracks.length,
                  itemBuilder: (context, index) {
                    final song = songList.tracks[index];
                    return ListTile(
                      title: Text('${song.name} - ${song.artist}'),
                    );
                  },
                ),
              ),
            ),
            Text(
              'Now Playing: ${songList.tracks[currentSongIndex].name} - ${songList.tracks[currentSongIndex].artist}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    isShuffling ? Icons.shuffle_on : Icons.shuffle,
                    color: isShuffling ? Colors.blue : Colors.grey,
                  ),
                  onPressed: toggleShuffle,
                ),
                IconButton(
                  icon: const Icon(Icons.skip_previous),
                  onPressed: skipPrevious,
                ),
                IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 32,
                  ),
                  onPressed: togglePlayPause,
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  onPressed: skipNext,
                ),
                IconButton(
                  icon: Icon(
                    isLooping ? Icons.repeat_one : Icons.repeat,
                    color: isLooping ? Colors.blue : Colors.grey,
                  ),
                  onPressed: toggleLoop,
                ),
              ],
            ),
          ]
        )
      )
    );
  }
}

void main() {
  runApp(const MyApp());
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
      home: const FinalPlaylistPage(),
    );
  }
}