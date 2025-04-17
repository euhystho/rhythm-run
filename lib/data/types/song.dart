class Playlist {
  List<Song> tracks;
  Playlist(this.tracks);
}


class Song {
  String name;
  List<String> artists;
  String length;
  int tempo;

  Song(this.name, this.artists,this.length, this.tempo);
}
