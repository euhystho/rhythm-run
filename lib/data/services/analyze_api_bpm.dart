import 'dart:io';
import 'dart:convert';
import '../types/song.dart';
import 'dart:core';
import 'dart:async';
///TODO: PULL THE PYTHON CALL
 ////make the python execution
 ///
Future<Map<String, dynamic>> pythonExec(Map<String, dynamic> idata) async {
  try {
    final pythonProc = await Process.start(
      'python3',
      ['/home/khoi/Khoi/Flutter/rhythm-run/python/get_bpm_copy.py'],
      runInShell: true,
    );

    pythonProc.stdin.writeln(jsonEncode(idata));
    await pythonProc.stdin.close();

    final stdout = await pythonProc.stdout.transform(utf8.decoder).join();
    final stderr = await pythonProc.stderr.transform(utf8.decoder).join();
    
    if (stderr.isNotEmpty) {
      throw Exception("Python script error: $stderr");
    }

    if (stdout.isEmpty) {
      throw Exception("Python script returned empty output");
    }
    Map<String,dynamic> stdTrim=jsonDecode(stdout.trim()) as Map<String,dynamic>;
    return (stdTrim);

  } catch (e) {
    print("Python execution failed due to error: $e");
    // Return an empty map with error information instead of null
    return {
      'error': true,
      'message': e.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
Future<Map<String, dynamic>> playlistToMap(Playlist playlist) async {
  var data = {
    "action": "Request",
    "tracks": [],
    "artists": []
  };
  
  for (final track in playlist.tracks) {
    final trackName = track.name;
    final artist = track.artist;
    
    (data["tracks"] as List).add(trackName);
    (data["artists"] as List).add(artist);
  }
  
  return data;
}
Future<Playlist>mapToAnalyzePlaylist(Map<String,dynamic> m) async{
  print(m);
  final n=(m["tracks"] as List).length;
  List<Song> list=[];
  for(int i=0;i<n;i++){
    //put the place holder 30s song 
    Song a=AnalyzedSong(m["tracks"][i],m["artists"][i] , 30,m["bpms"][i]) as Song;
    list.add(a);
  }
  return Playlist(list);
}
void main() async {
  // Example input map
  Stopwatch stopwatch=Stopwatch()..start();
  Map<String,dynamic> data={
    "action":"Request",
    "tracks":["Disease", "Abracadabra"],
    "artists":["Lady Gaga","Lady Gaga"]
  };
  final mockData=await pythonExec(data);
  // Call the function and print the result
  Playlist playlist = await mapToAnalyzePlaylist(mockData);
  print(playlist);
  stopwatch.stop();
  print('Elapse time: ${stopwatch.elapsedMilliseconds} ms');
}