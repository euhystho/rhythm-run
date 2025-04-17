import 'package:lastfm/lastfm.dart';
import '../types/song.dart';
import 'package:xml/xml.dart';

String API_KEY = String.fromEnvironment('LASTFM_API_KEY');
String SHARED_SECRET = String.fromEnvironment('LASTFM_SHARED_SECRET');

void getSimilarSongs(song) async {
  // Instantiate the lastfm Call with the fun secrets and stuff :)
  LastFM lastfm = LastFMUnauthorized(API_KEY, SHARED_SECRET);
  // Corrected method call with only two arguments
  // var similarSongs = await lastfm.read(
  //   'track.getSimilar',
  //   {"artist": song.artists[0], "track": song.name, "limit": "10"},
  //   false // For unauthenticated calls
  // );
  final allAboutTool = await lastfm.read('artist.getInfo', {"artist": "Tool"}, false);
  print(allAboutTool);
}

// void getSongs(playlist){
//   for (var i = 0; i < playlist.length; i++){
//     track = playlist.tracks[i];

//   }

// }


void main(){
  Song uhoh = Song("uhoh", ["Kim Petras"], "2:50", 123);
  Song follow = Song("Follow", ["Martin Garrix", "Zedd"], "3:41", 127);
  // Playlist test = Playlist([uhoh, follow]);
  getSimilarSongs(uhoh);

}