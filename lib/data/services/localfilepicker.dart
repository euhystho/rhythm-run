import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

//3.Task importing local
Future<Set<String>> pickAudioFile() async {
  final Set<String> audioAssetPaths = {};
  //filter the mp3 file from local file
  String? initialDirectory;
  if (Platform.isAndroid) {
    try {
      bool hasPermission = await getPermisionAndroid();
      if (!hasPermission) {
        throw ('Storage permission denied');
      }
      Directory? musicDir = await androidMusicDirectory();
      initialDirectory = musicDir?.path ?? "";
    } catch (e) {
      print("Error when accessing to folder: $e");
    }
  } else if (Platform.isIOS) {
    try {
      bool hasPermission = await getPermisionIOS();
      if (!hasPermission) {
        throw ('Storage permission denied');
      }
      Directory? musicDir = await iosMusicDirectory();
      initialDirectory = musicDir?.path ?? "";
    } catch (e) {
      print("Error when accessing to folder: $e");
    }
  }
  //Step 3 append the file to the result
  FilePickerResult? results = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['wav', 'mp3'],
    allowMultiple: true,
    initialDirectory: (initialDirectory != null) ? initialDirectory : null,
  );
  if (results != null) {
    //add the file paths to the list
    List<String> filePaths =
        results.paths
            .where((path) => path != null)
            .map((path) => path!)
            .toList();
    audioAssetPaths.addAll(filePaths);
  }
  // print the asset path for debuging or testing:
  for (var path in audioAssetPaths) {
    print('-$path');
  }
  return audioAssetPaths;
}

Future<bool> getPermisionAndroid() async {
  Permission permission;
  if (int.parse(Platform.operatingSystemVersion.split(' ').first) >= 13) {
    permission = Permission.audio;
  } else {
    permission = Permission.storage;
  }

  PermissionStatus status = await permission.status;
  if (status.isDenied) {
    status = await permission.request();
  }
  return status.isGranted;
}

Future<Directory?> androidMusicDirectory() async {
  try {
    // Common paths for music on Android
    final externalStorageDir = await getExternalStorageDirectory();
    if (externalStorageDir != null) {
      // Try standard Music folder
      final musicPath = path.join(externalStorageDir.path, '../Music');
      final musicDir = Directory(musicPath);
      if (await musicDir.exists()) {
        return musicDir;
      }

      // Try alternative paths
      final altMusicPath = path.join(externalStorageDir.path, '../../Music');
      final altMusicDir = Directory(altMusicPath);
      if (await altMusicDir.exists()) {
        return altMusicDir;
      }
    }
  } catch (e) {
    print('Error finding music directory: $e');
  }
  return null;
}

Future<bool> getPermisionIOS() async {
  return true;
}

Future<Directory?> iosMusicDirectory() async {
  return null;
}
