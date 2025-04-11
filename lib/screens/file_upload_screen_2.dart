import 'package:flutter/material.dart';
import 'package:rhythmrun/utils/theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '/data/services/localfilepicker.dart';

class LocalSongsUploadPage extends StatefulWidget {
  const LocalSongsUploadPage({super.key});

  @override
  State<LocalSongsUploadPage> createState() => _LocalSongsUploadPageState();
}

class _LocalSongsUploadPageState extends State<LocalSongsUploadPage> {
  List<String> selectedFiles = [];
  Set<String> selectedForAnalysis = {};

  bool isLoading = false;

  Future<void> pickFiles() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<String> paths = await pickAudioFile();
      setState(() {
        selectedFiles.addAll(paths);
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Import Songs',
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 4,
                            color: Color(0x20000000),
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // FaIcon(
                                //   FontAwesomeIcons.music,
                                //   size: 60,
                                //   color: Theme.of(context).colorScheme.onSurface,
                                // ),
                                Text(
                                  'Select Music Files',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Text(
                                  'Choose local audio files to import',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 17,
                                    color:
                                        RhythmRunTheme.secondaryText,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: isLoading ? null : pickFiles,
                                  icon: FaIcon(FontAwesomeIcons.folderOpen),
                                  label: Text(
                                    isLoading ? 'Loading...' : 'Choose Files',
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(
                                      double.infinity,
                                      50,
                                    ),
                                    backgroundColor:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isLoading)
                            Container(
                              color: Colors.black12,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: selectedFiles.length,
                      itemBuilder: (context, index) {
                        final filePath = selectedFiles[index];
                        final fileName = filePath.split('/').last;
                        return ListTile(
                          title: Text(
                            fileName,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          subtitle: Text(
                            'Pending analysis',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: RhythmRunTheme.secondaryText,
                            ),
                          ),
                          leading: Checkbox(
                            value: selectedForAnalysis.contains(filePath),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  selectedForAnalysis.add(filePath);
                                } else {
                                  selectedForAnalysis.remove(filePath);
                                }
                              });
                            },
                          ),
                          dense: false,
                          contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                        );
                      },
                    ),
                    // child: ReorderableListView.builder(
                    //   padding: EdgeInsets.zero,
                    //   shrinkWrap: true,
                    //   itemCount: selectedFiles.length,
                    //   onReorder: (oldIndex, newIndex) {
                    //     setState(() {
                    //       if (oldIndex < newIndex) {
                    //         newIndex -= 1;
                    //       }
                    //       final item = selectedFiles.removeAt(oldIndex);
                    //       selectedFiles.insert(newIndex, item);
                    //     });
                    //   },
                    //   itemBuilder: (context, index) {
                    //     final filePath = selectedFiles[index];
                    //     final fileName = filePath.split('/').last;
                    //     return Material(
                    //       key: Key('$index'),
                    //       color: Colors.transparent,
                    //       child: ListTile(
                    //         title: Text(
                    //           fileName,
                    //           style: Theme.of(context).textTheme.bodyLarge,
                    //         ),
                    //         subtitle: Text(
                    //           'Pending analysis',
                    //           style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    //             color: RhythmRunTheme.secondaryText,
                    //           ),
                    //         ),
                    //         leading: Checkbox(
                    //           value: selectedForAnalysis.contains(filePath),
                    //           onChanged: (bool? value) {
                    //             setState(() {
                    //               if (value == true) {
                    //                 selectedForAnalysis.add(filePath);
                    //               } else {
                    //                 selectedForAnalysis.remove(filePath);
                    //               }
                    //             });
                    //           },
                    //         ),
                    //         dense: false,
                    //         contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                    //         trailing: ReorderableDragStartListener(
                    //           index: index,
                    //           child: Icon(
                    //             Icons.drag_handle,
                    //             color: Theme.of(context).colorScheme.onSurfaceVariant,
                    //           ),
                    //         ),
                    //       ),
                    //     );
                    //   },
                    // ),
                  ),
                ],
              ),
            ),
            if (selectedFiles.isNotEmpty)
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
                              '${selectedForAnalysis.length} Songs',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Ready to analyze',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: RhythmRunTheme.secondaryText,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {
                            //TODO: Handle BPM analysis
                            // Do something with selectedForAnalysis
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.tertiary,
                            minimumSize: const Size(150, 40),
                            padding: const EdgeInsets.all(8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Analyze BPM',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
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