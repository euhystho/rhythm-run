// import 'dart:io';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import 'package:collection/collection.dart'; // For shuffle()
// import '../services/analyze_api_bpm.dart';

import 'package:supabase/supabase.dart'; // Use this for Dart testing...
// import 'package:supabase_flutter/supabase_flutter.dart'; // Use this for integrating with Flutter...
import 'package:dotenv/dotenv.dart' as dotenv;
import '../types/song.dart';

final env = dotenv.DotEnv()..load(['assets/.env']);

class Database {
  Future<void> openDB() async {}

  Future<void> createDB() async {}

  Future<void> addSong(AnalyzedSong song) async {}

  Future<void> getSong(String artistName, String trackName) async {
    throw UnimplementedError('getSong method is not implemented yet.');
  }
}

class SupaDatabase extends Database {
  // Singleton pattern
  static final SupaDatabase _instance = SupaDatabase._internal();
  factory SupaDatabase() => _instance;
  SupaDatabase._internal();

  late final SupabaseClient _client;
  SupabaseClient get client => _client;
  GoTrueClient get auth => _client.auth;
  SupabaseQueryBuilder get db => _client.from('songs');

  final String supabaseURL =
      String.fromEnvironment('SUPABASE_URL').isNotEmpty
          ? String.fromEnvironment('SUPABASE_URL')
          : env['SUPABASE_URL'] ?? '';
  final String supabaseKey =
      String.fromEnvironment('SUPABASE_ANON_KEY').isNotEmpty
          ? String.fromEnvironment('SUPABASE_ANON_KEY')
          : env['SUPABASE_ANON_KEY'] ?? '';

  
  @override
  
  Future<void> openDB() async {
  // Opens the Client for Supabase
    _client = SupabaseClient(supabaseURL, supabaseKey);

    //Checks if the Authentication has changed and puts in the session:
    _client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (event == AuthChangeEvent.signedIn) {
        print('User signed in: ${session?.user.email}');
      } else if (event == AuthChangeEvent.signedOut) {
        print('User signed out');
      }
    });
  }

  @override
  Future<void> addSong(AnalyzedSong song) async {
    try {
      final response = await _client.from('songs').insert({
        'track_name': song.name,
        'artist_name': song.artist,
        'bpm': song.tempo,
        'duration': song.duration,
      });

      if (response.error != null) {
        throw response.error!;
      }
    } catch (e) {
      if (e is PostgrestException && e.code == "23505") {
        print('Duplicate entry: ${e.message}');
      } else {
        print('An error has occured: $e');
      }
    }
  }

  @override
  Future<AnalyzedSong?> getSong(String artistName, String trackName) async {
  // Tries to connect to the Supabase using the SupabaseClient
  // Searches via artistName and trackName to find the song
    try {
      final response =
          await _client
              .from('songs')
              .select('track_name, artist_name, bpm, duration')
              .eq('artist_name', artistName)
              .eq('track_name', trackName)
              .single();

      //Gets the song details from the database and returns them
      return AnalyzedSong(
        response['track_name'],
        response['artist_name'],
        response['duration'],
        response['bpm'],
      );
    } catch (e) {
      print('An error occurred while fetching the song: $e');
      return null; // Return null just incase of an error
    }
  }
}

// class SongDatabase extends Database {
//   static Database? _database;

//   // Initialize database
//   @override
//   Future<void> openDB() async {
//     final dbPath = join(await getDatabasesPath(), 'songs.db');
//     _database = await openDatabase(dbPath, version: 1, onCreate: createDb);
//   }

//   // Create database tables
//   @override
//   Future<void> createDB(Database db) async {
//     await db.execute('DROP TABLE IF EXISTS songs');
//     await db.execute('''
//       CREATE TABLE songs (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         track_name TEXT,
//         bpm INTEGER,
//         length REAL
//       )
//     ''');
//   }

//   // Close database
//   Future<void> close() async {

//     if (_database != null) {
//       await _database!.close();
//       _database = null;
//     }
//   }
//   @override
//   Future<void> addSong(AnalyzedSong song) async{
//     await _database.insert(
//         'songs',
//         {'name': song.name, 'bpm': song.tempo, 'length': song.duration},
//       );

//   }

// }

Future<void> main() async {
  var database = SupaDatabase();
  await database.openDB();

  // Fetch a song
  AnalyzedSong? song = await database.getSong("Lady Gaga", "Abracadabra");
  if (song != null) {
    print('Song found: ${song.name} by ${song.artist}');
  } else {
    print('Song not found.');
  }
}
