import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:collection/collection.dart'; // For shuffle()
import '../types/song.dart';
import '../services/analyze_api_bpm.dart';
class SongDatabase {
  
  static Database? _database;

  // Initialize database
  static Future<Database> _openDb() async {
    final dbPath = join(await getDatabasesPath(), 'songs.db');
    _database = await openDatabase(dbPath, version: 1, onCreate: _createDb);
  }

  // Create database tables
  static Future<void> _createDb(Database db, int version) async {
    await db.execute('DROP TABLE IF EXISTS songs');
    await db.execute('''
      CREATE TABLE songs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        bpm INTEGER,
        length REAL
      )
    ''');
   
  static Future<void> addSong(AnalyzedSong song) async{
    final db=_database ??=await _openDb();
    await db.insert(
        'songs',
        {'name': song.name, 'bpm': song.tempo, 'length': song.duration},
      );
    }
  }

  

  // Close database
  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
/** Insert sample data
    const sampleSongs = [
      ['Fast 1', 178, 3.5],
      ['Fast 2', 175, 4.0],
      ['Fast 3', 190, 3.4],
      ['Fast 4', 183, 2.0],
      ['Medium 1', 165, 3.2],
      ['Medium 2', 160, 4.0],
      ['Medium 3', 150, 3.0],
      ['Medium 4', 170, 4.0],
      ['Slow 1', 145, 3.8],
      ['Slow 2', 135, 4.1],
      ['Slow 3', 125, 5.0],
      ['Slow 4', 130, 4.5],
    ];
*/