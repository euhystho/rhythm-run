import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rhythmrun/utils/theme.dart';

class TempPlaylistPage extends StatefulWidget {
  const TempPlaylistPage({super.key});

  @override
  State<TempPlaylistPage> createState() => TempPlaylistPageState();
}

class TempPlaylistPageState extends State<TempPlaylistPage> {
  // PLEASE DELETE THE SAMPLES LATER THEY ARE FOR TESTING
  List<String> songList = [
    'Rick Roll - 114 BPM',
    'Other Song - 125 BPM',
    'Wow!! - 130 BPM'
  ];

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
              child: ReorderableListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: songList.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    final item = songList.removeAt(oldIndex);
                    songList.insert(newIndex, item);
                  });
                },
                itemBuilder: (context, index) {
                  final fileName = songList[index];
                  return Material(
                    key: Key('$index'),
                    color: Colors.transparent,
                    child: ListTile(
                      title: Text(
                        fileName,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      dense: false,
                      contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
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
            if (songList.isNotEmpty)
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
                              '${songList.length} Songs',
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