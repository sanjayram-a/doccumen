import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/document_record.dart';
import '../models/app_settings.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('doccumen.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE recent_documents (
        id TEXT PRIMARY KEY,
        file_path TEXT NOT NULL,
        file_name TEXT NOT NULL,
        file_type TEXT NOT NULL,
        file_size INTEGER NOT NULL,
        opened_at INTEGER NOT NULL,
        thumbnail_path TEXT,
        is_favorite INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_opened_at ON recent_documents(opened_at DESC)
    ''');

    await db.execute('''
      CREATE INDEX idx_file_type ON recent_documents(file_type)
    ''');

    await db.execute('''
      CREATE INDEX idx_is_favorite ON recent_documents(is_favorite)
    ''');

    await db.execute('''
      CREATE TABLE app_settings (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        theme_mode TEXT NOT NULL DEFAULT 'system',
        keep_history INTEGER NOT NULL DEFAULT 1,
        history_retention_days INTEGER NOT NULL DEFAULT 90,
        default_to_in_app_viewer INTEGER NOT NULL DEFAULT 1,
        show_thumbnails INTEGER NOT NULL DEFAULT 1,
        pdf_default_zoom REAL NOT NULL DEFAULT 1.0,
        pdf_continuous_scroll INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.insert('app_settings', {
      'id': 1,
      ...const AppSettings().toMap(),
    });
  }

  Future<DocumentRecord> insertDocument(DocumentRecord document) async {
    final db = await database;
    
    final existing = await getDocumentByPath(document.filePath);
    if (existing != null) {
      await updateDocument(existing.copyWith(
        openedAt: DateTime.now(),
      ));
      return existing.copyWith(openedAt: DateTime.now());
    }

    await db.insert(
      'recent_documents',
      document.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return document;
  }

  Future<DocumentRecord?> getDocumentByPath(String filePath) async {
    final db = await database;
    final maps = await db.query(
      'recent_documents',
      where: 'file_path = ?',
      whereArgs: [filePath],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return DocumentRecord.fromMap(maps.first);
  }

  Future<List<DocumentRecord>> getAllDocuments({
    FileType? filterType,
    bool? favoritesOnly,
    int? limit,
    String? searchQuery,
  }) async {
    final db = await database;
    
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (filterType != null) {
      whereClause = 'file_type = ?';
      whereArgs.add(filterType.name);
    }

    if (favoritesOnly == true) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'is_favorite = 1';
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'file_name LIKE ?';
      whereArgs.add('%$searchQuery%');
    }

    final maps = await db.query(
      'recent_documents',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'opened_at DESC',
      limit: limit,
    );

    return maps.map((map) => DocumentRecord.fromMap(map)).toList();
  }

  Future<int> updateDocument(DocumentRecord document) async {
    final db = await database;
    return await db.update(
      'recent_documents',
      document.toMap(),
      where: 'id = ?',
      whereArgs: [document.id],
    );
  }

  Future<int> toggleFavorite(String documentId) async {
    final db = await database;
    final maps = await db.query(
      'recent_documents',
      where: 'id = ?',
      whereArgs: [documentId],
      limit: 1,
    );

    if (maps.isEmpty) return 0;

    final doc = DocumentRecord.fromMap(maps.first);
    return await updateDocument(doc.copyWith(isFavorite: !doc.isFavorite));
  }

  Future<int> deleteDocument(String documentId) async {
    final db = await database;
    return await db.delete(
      'recent_documents',
      where: 'id = ?',
      whereArgs: [documentId],
    );
  }

  Future<int> clearHistory() async {
    final db = await database;
    return await db.delete('recent_documents');
  }

  Future<int> deleteOldDocuments(int retentionDays) async {
    final db = await database;
    final cutoffDate = DateTime.now().subtract(Duration(days: retentionDays));
    return await db.delete(
      'recent_documents',
      where: 'opened_at < ? AND is_favorite = 0',
      whereArgs: [cutoffDate.millisecondsSinceEpoch],
    );
  }

  Future<AppSettings> getSettings() async {
    final db = await database;
    final maps = await db.query('app_settings', where: 'id = 1', limit: 1);
    
    if (maps.isEmpty) {
      return const AppSettings();
    }
    
    return AppSettings.fromMap(maps.first);
  }

  Future<int> updateSettings(AppSettings settings) async {
    final db = await database;
    return await db.update(
      'app_settings',
      settings.toMap(),
      where: 'id = 1',
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
