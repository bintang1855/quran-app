import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class DatabaseManager {
  DatabaseManager._private();
  static DatabaseManager instance = DatabaseManager._private();

  Database? _db;

  Future<Database> get db async {
    _db ??= await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    // pakai documents directory agar persistent
    final Directory docDir = await getApplicationDocumentsDirectory();
    final String path = join(docDir.path, "bookmark.db");

    return await openDatabase(
      path,
      version: 1,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE bookmark (
            id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            surah TEXT NOT NULL,
            number_surah INTEGER NOT NULL,
            ayat INTEGER NOT NULL,
            juz INTEGER NOT NULL,
            via TEXT NOT NULL,
            index_ayat INTEGER NOT NULL,
            last_read INTEGER DEFAULT 0
          );
        ''');
      },
    );
  }

  Future<void> closeDB() async {
    final d = await db;
    await d.close();
    _db = null;
  }
}
