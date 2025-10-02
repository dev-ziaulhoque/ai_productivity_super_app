import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static Database? _db;

  DatabaseService._();

  static DatabaseService get instance => _instance ??= DatabaseService._();

  Future<Database> get database async {
    _db ??= await init();
    return _db!;
  }

  Future<Database> init() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'app.db');
    return await openDatabase(path, version: 3, onCreate: _createDb, onUpgrade: _upgradeDb);
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        summary TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        category TEXT DEFAULT 'Personal',
        deadline TIMESTAMP,
        is_completed INTEGER DEFAULT 0,
        reminder_timestamp TIMESTAMP,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  Future<void> _upgradeDb(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS tasks (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          description TEXT,
          category TEXT DEFAULT 'Personal',
          deadline TIMESTAMP,
          is_completed INTEGER DEFAULT 0,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE tasks ADD COLUMN reminder_timestamp TIMESTAMP');
    }
  }


  // Notes methods (existing)
  Future<int> insertNote(String content, {String? summary}) async {
    final db = await database;
    return await db.insert('notes', {'content': content, 'summary': summary});
  }

  Future<List<Map<String, dynamic>>> getAllNotes() async {
    final db = await database;
    return await db.query('notes');
  }

  Future<Map<String, dynamic>> getNoteById(int id) async {
    final db = await database;
    final list = await db.query('notes', where: 'id = ?', whereArgs: [id]);
    if (list.isEmpty) throw Exception('Note not found');
    return list.first;
  }

  Future<int> updateNoteSummary(int id, String summary) async {
    final db = await database;
    return await db.update('notes', {'summary': summary}, where: 'id = ?', whereArgs: [id]);
  }

  // Tasks methods
  Future<int> insertTask(String title, {String? description, String? category, DateTime? deadline, DateTime? reminderTimestamp}) async {
    final db = await database;
    return await db.insert('tasks', {
      'title': title,
      'description': description,
      'category': category ?? 'Personal',
      'deadline': deadline?.toIso8601String(),
      'reminder_timestamp': reminderTimestamp?.toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getAllTasks() async {
    final db = await database;
    return await db.query('tasks');
  }

  Future<Map<String, dynamic>> getTaskById(int id) async {
    final db = await database;
    final list = await db.query('tasks', where: 'id = ?', whereArgs: [id]);
    if (list.isEmpty) throw Exception('Task not found');
    return list.first;
  }

  Future<int> updateTaskCategory(int id, String category) async {
    final db = await database;
    return await db.update('tasks', {'category': category}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateTaskCompleted(int id, bool isCompleted) async {
    final db = await database;
    return await db.update('tasks', {'is_completed': isCompleted ? 1 : 0}, where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> deleteTask(int id) async {
    final db = await database;
    final result = await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
    return result > 0;
  }

  // New upsertTask method
  Future<void> upsertTask(Map<String, dynamic> taskData) async {
    final db = await database;
    final id = taskData['id'] as int?;
    if (id != null) {
      final existing = await db.query('tasks', where: 'id = ?', whereArgs: [id]);
      if (existing.isNotEmpty) {
        await db.update('tasks', taskData, where: 'id = ?', whereArgs: [id]);
      } else {
        await db.insert('tasks', taskData);
      }
    } else {
      await db.insert('tasks', taskData);
    }
  }


  Future<int> setTaskReminder(int id, DateTime? reminderTimestamp) async {
    final db = await database;
    return await db.update('tasks', {'reminder_timestamp': reminderTimestamp?.toIso8601String()},
        where: 'id = ?', whereArgs: [id]);
  }

}