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
    Song('Souvenir ', 'BUMP OF CHICKEN'),
  ]);


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