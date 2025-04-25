import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rhythmrun/utils/theme.dart';
// import '../data/services/generate_playlist.dart';
import '../data/types/song.dart';

class TempPlaylistPage extends StatefulWidget {
  const TempPlaylistPage({super.key});

  @override
  State<TempPlaylistPage> createState() => TempPlaylistPageState();
}

class TempPlaylistPageState extends State<TempPlaylistPage> {
  // PLEASE DELETE THE SAMPLES LATER THEY ARE FOR TESTING
  Playlist songList = Playlist([
    Song('Rick Roll', 'Rick Astley'),
    Song('Other Song', 'bbbb'),
    Song('Wow!!', 'aaaa')
  ]);

  double threshold = 20;
  double limit = 0;

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
                        trailing: ReorderableDragStartListener(
                          index: index,
                          child: Icon(
                            Icons.drag_handle,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    );
                  },
                ),
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
                    min: 20,
                    max: 100,
                    inactiveColor: Theme.of(context).colorScheme.onSurface,
                    onChanged: (double value) {
                      setState(() {
                        threshold = value;
                      });
                    },
                  ),
                  Text(
                    'Number of suggestions per song (0-20)',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Slider(
                    value: limit,
                    max: 20,
                    inactiveColor: Theme.of(context).colorScheme.onSurface,
                    onChanged: (double value) {
                      setState(() {
                        limit = value;
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
                            // navigate to final page
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
      home: const TempPlaylistPage(),
    );
  }
}