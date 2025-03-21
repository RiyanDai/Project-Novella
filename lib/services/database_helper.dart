import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/novel.dart';
import '../models/chapter.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('novels.db');
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
      CREATE TABLE novels(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE chapters(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        novel_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        chapter_number INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (novel_id) REFERENCES novels (id)
          ON DELETE CASCADE
      )
    ''');
  }

  // Novel CRUD operations
  Future<Novel> insertNovel(Novel novel) async {
    final db = await database;
    final id = await db.insert('novels', novel.toMap());
    return novel.copyWith(id: id);
  }

  Future<List<Novel>> getAllNovels() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('novels');
    return List.generate(maps.length, (i) => Novel.fromMap(maps[i]));
  }

  Future<Novel?> getNovel(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'novels',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Novel.fromMap(maps.first);
  }

  // Chapter CRUD operations
  Future<Chapter> insertChapter(Chapter chapter) async {
    final db = await database;
    final id = await db.insert('chapters', chapter.toMap());
    return chapter.copyWith(id: id);
  }

  Future<List<Chapter>> getNovelChapters(int novelId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'chapters',
      where: 'novel_id = ?',
      whereArgs: [novelId],
      orderBy: 'chapter_number ASC',
    );
    return List.generate(maps.length, (i) => Chapter.fromMap(maps[i]));
  }

  Future<int> updateChapter(Chapter chapter) async {
    final db = await database;
    return db.update(
      'chapters',
      chapter.toMap(),
      where: 'id = ?',
      whereArgs: [chapter.id],
    );
  }
} 