import 'dart:io';
import 'dart:convert';
import '../types/song.dart';

///TODO: PULL THE PYTHON CALL
 ////make the python execution
 ///
Future <Map<String,dynamic>> pythonExec(Map<String,dynamic> idata) async{
  final pythonProc= await Process.start('python3'
                                        , ["/python/get_bpm_copy.py"],
                                        runInShell: true);
  pythonProc.stdin.writeln(jsonDecode(idata));
  await pythonProc.stdin.close();

  final stdout=await pythonProc.stdout.transform(utf8.decoder).join();
  final stderr=await pythonProc.stderr.transform(utf8.decoder).join();
  
  try{
    if (stderr.isNotEmpty){
      throw "Error: $stderr";
    }
    return jsonDecode(stdout);
  }
  catch(e){
    print("Connect fail due to e: $e");
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
    
    data["tracks"]?.add(trackName);
    data["artists"]?.add(artist);
  }
  
  return data;
}
Future<Playlist>MapToAnalyzePlaylist(Map<String,dynamic> m) async{
  final n=m["tracks"].length;
  List<AnalyzedSong> list;
  for(int i=0;i<n;i++){
    //put the place holder 30s song 
    AnalyzedSong a=AnalyzedSong(m["track"][i],m["artists"][i] , 30,m["bpms"][i]);
    list.add(a);
  }
  return Playlist(list);
}