class Playlist {
  List<Song> tracks;
  Playlist(this.tracks);

  @override
  String toString() {
    String res = '';
    for (int i = 0; i < tracks.length; i++) {
      res += '${tracks[i]}';
      if (i != (tracks.length - 1)) {
        res += ', ';
      }
    }
    return res;
  }
}


class Song {
  String name;
  String artist;

  Song(this.name, this.artist);

  @override
  String toString() {
    return '$name by $artist';
  }
}

class StreamableSong extends Song {
  String mbid;
  String streamID;
  StreamableSong(super.name, super.artist, this.mbid, this.streamID);
}

class SimilarSong extends Song {
  double match;
  Song originalSong;

  SimilarSong(this.originalSong, super.name, super.artist, this.match);

  get origname => originalSong.name;
  get origartist => originalSong.artist;
}

class AnalyzedSong extends Song {
  int duration;
  int tempo;

  AnalyzedSong(super.name,super.artist, this.duration, this.tempo);

}