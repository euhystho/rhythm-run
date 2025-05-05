import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

Future<Database> initDatabase() async {
  // Get the path to the database
  final databasePath = await getDatabasesPath();
  final path = join(databasePath, '../songs.db');
  
  // Open the database
  return await openDatabase(
    path,
    version: 1,
    onCreate: (db, version) async {
      // Create tables here
      await db.execute('''
        CREATE TABLE users(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          email TEXT
        )
      ''');
    },
  );
}

// Usage
void main() async {
  final db = await initDatabase();
  // Now you can use db to perform queries
}