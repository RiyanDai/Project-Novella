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
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE reading_progress(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        novel_id TEXT NOT NULL,
        title TEXT NOT NULL,
        current_page INTEGER NOT NULL,
        total_pages INTEGER NOT NULL,
        last_read TEXT NOT NULL
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      final List<Map<String, dynamic>> oldData = await db.query('reading_progress');
      
      await db.execute('DROP TABLE reading_progress');
      
      await _createDB(db, newVersion);
      
      for (var item in oldData) {
        await db.insert('reading_progress', {
          ...item,
          'title': 'Novel',
        });
      }
    }
  }

  Future<void> saveProgress(String novelId, String title, int currentPage, int totalPages) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final existing = await db.query(
      'reading_progress',
      where: 'novel_id = ?',
      whereArgs: [novelId],
    );

    if (existing.isEmpty) {
      await db.insert('reading_progress', {
        'novel_id': novelId,
        'title': title,
        'current_page': currentPage,
        'total_pages': totalPages,
        'last_read': now,
      });
    } else {
      await db.update(
        'reading_progress',
        {
          'title': title,
          'current_page': currentPage,
          'total_pages': totalPages,
          'last_read': now,
        },
        where: 'novel_id = ?',
        whereArgs: [novelId],
      );
    }
  }

  Future<Map<String, dynamic>?> getProgress(String novelId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'reading_progress',
      where: 'novel_id = ?',
      whereArgs: [novelId],
    );

    if (result.isEmpty) return null;
    return result.first;
  }

  Future<List<Map<String, dynamic>>> getRecentlyRead({int limit = 5}) async {
    final db = await database;
    
    try {
      final List<Map<String, dynamic>> result = await db.query(
        'reading_progress',
        orderBy: 'last_read DESC',
        limit: limit,
      );

      return result;
    } catch (e) {
      print('Error getting recently read: $e');
      return [];
    }
  }

  Future<void> deleteProgress(String novelId) async {
    final db = await database;
    await db.delete(
      'reading_progress',
      where: 'novel_id = ?',
      whereArgs: [novelId],
    );
  }

  Future<int> getReadingCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM reading_progress');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<Map<String, dynamic>?> getLastReadProgress() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'reading_progress',
      orderBy: 'last_read DESC',
      limit: 1,
    );
    
    if (result.isEmpty) return null;
    return result.first;
  }

  Future<List<Map<String, dynamic>>> getAllProgress() async {
    final db = await database;
    return await db.query('reading_progress', orderBy: 'last_read DESC');
  }

  Future<void> updateLastRead(String novelId) async {
    final db = await database;
    await db.update(
      'reading_progress',
      {'last_read': DateTime.now().toIso8601String()},
      where: 'novel_id = ?',
      whereArgs: [novelId],
    );
  }
} 