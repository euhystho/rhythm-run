import 'package:flutter/material.dart';
import 'loading_page.dart';
import 'theme.dart';
import 'localfilepicker.dart';
class FileUploadPage extends StatefulWidget {
  const FileUploadPage({super.key});

  @override
  _FileUploadPageState createState() => _FileUploadPageState();
}

class _FileUploadPageState extends State<FileUploadPage> {
  List<String> selectedFiles = ["b"]; // placeholder for selected files

  // TODO: implement file picking
  void pickFiles() async {
    //Khoi's pick files:
    List<String> paths=await pickAudioFile();
    selectedFiles.addAll(paths);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Songs", style: Theme.of(context).textTheme.headlineSmall),
        backgroundColor: RhythmRunTheme.scaffoldBackgroundColor,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              RhythmRunTheme.scaffoldBackgroundColor,
              Theme.of(context).colorScheme.primary,
            ],
            stops: const [0, 1],
            begin: AlignmentDirectional(0, 1),
            end: AlignmentDirectional(0, -1),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: pickFiles,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
                child: Text("Choose Files",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        )),
              ),
              Expanded(
                child: ListView(
                  children: selectedFiles
                      .map((file) => ListTile(
                            title: Text(file, style: Theme.of(context).textTheme.bodyMedium),
                          ))
                      .toList(),
                ),
              ),
              if (selectedFiles.isNotEmpty)
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoadingPage()),
                      );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                  ),
                  child: Text("Analyze BPM",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onTertiary,
                          )),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
