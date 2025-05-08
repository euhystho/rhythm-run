class Playlist {
  List<Song> tracks;
  late final int trackCount;

  Playlist(this.tracks) {
    trackCount = tracks.length;
  }

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

  void addSong(Song song) {
    tracks.add(song);
  }

  void removeSong(Song song) {
    tracks.remove(song);
  }
}

class SpotifyPlaylist {
  final String id;
  final String name;
  final String imageURL;
  final int trackCount;
  List<StreamableSong>? tracks; // Add tracks field

  SpotifyPlaylist({
    required this.id,
    required this.name,
    required this.imageURL,
    required this.trackCount,
    this.tracks,
  });

  factory SpotifyPlaylist.fromJson(Map<String, dynamic> json) {
    return SpotifyPlaylist(
      id: json['id'],
      name: json['name'],
      imageURL: json['images'][0]['url'],
      trackCount: json['tracks']['total'],
    );
  }

  void setTracks(List<StreamableSong> tracks) {
    this.tracks = tracks;
  }

  void addSong(StreamableSong song) {
    tracks?.add(song);
  }

  void removeSong(StreamableSong song) {
    tracks?.remove(song);
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
  final String streamID;
  final int duration;

  StreamableSong(super.name, super.artist, this.streamID, this.duration);

  factory StreamableSong.fromSpotifyJson(Map<String, dynamic> json) {
    // Cast the Duration of Miliseconds into the Duration :)
    final duration = Duration(milliseconds: json['track']['duration_ms']);
    return StreamableSong(
      json['track']['name'],
      json['track']['artists'][0]['name'],
      json['track']['uri'],
      duration.inSeconds,
    );
  }

  factory StreamableSong.fromSpotifySearch(Map<String, dynamic> json, Song song){
    final duration = Duration(milliseconds: json['duration_ms']);
    return StreamableSong(
      json['name'],
      json['artists'][0]['name'],
      json['uri'],
      duration.inSeconds
    );
  }

}

class SimilarSong extends Song {
  double match;

  SimilarSong(super.name, super.artist, this.match);

}

class AnalyzedSong extends Song {
  final int tempo;

  AnalyzedSong(super.name, super.artist, this.tempo);


}

class SpotifyAnalyzedSong extends StreamableSong{
  final int tempo;
  SpotifyAnalyzedSong(super.name, super.artist, super.streamID, super.duration, this.tempo);
}

