import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ReadingProgressHelper {
  static final ReadingProgressHelper instance = ReadingProgressHelper._init();
  static Database? _database;

  ReadingProgressHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('reading_progress.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE reading_progress(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        novel_id INTEGER NOT NULL,
        current_page INTEGER NOT NULL,
        total_pages INTEGER NOT NULL,
        last_read TEXT NOT NULL
      )
    ''');
  }

  Future<void> saveProgress(int novelId, int currentPage, int totalPages) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    // Check if progress exists
    final existing = await db.query(
      'reading_progress',
      where: 'novel_id = ?',
      whereArgs: [novelId],
    );

    if (existing.isEmpty) {
      // Insert new progress
      await db.insert('reading_progress', {
        'novel_id': novelId,
        'current_page': currentPage,
        'total_pages': totalPages,
        'last_read': now,
      });
    } else {
      // Update existing progress
      await db.update(
        'reading_progress',
        {
          'current_page': currentPage,
          'total_pages': totalPages,
          'last_read': now,
        },
        where: 'novel_id = ?',
        whereArgs: [novelId],
      );
    }
  }

  Future<Map<String, dynamic>?> getProgress(int novelId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'reading_progress',
      where: 'novel_id = ?',
      whereArgs: [novelId],
    );

    if (result.isEmpty) return null;
    return result.first;
  }

  Future<List<Map<String, dynamic>>> getRecentlyRead({int limit = 10}) async {
    final db = await database;
    return await db.query(
      'reading_progress',
      orderBy: 'last_read DESC',
      limit: limit,
    );
  }

  Future<void> deleteProgress(int novelId) async {
    final db = await database;
    await db.delete(
      'reading_progress',
      where: 'novel_id = ?',
      whereArgs: [novelId],
    );
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
} 