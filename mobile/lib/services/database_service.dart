import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/report.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('reports.db');
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
      CREATE TABLE reports(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        workerName TEXT NOT NULL,
        area TEXT NOT NULL,
        incidentType TEXT NOT NULL,
        description TEXT NOT NULL,
        photoPath TEXT,
        isSynced INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  // Create new report
  Future<Report> createReport(Report report) async {
    final db = await database;
    final id = await db.insert('reports', report.toMap());
    return report..id = id;
  }

  // Read all reports
  Future<List<Report>> getAllReports() async {
    final db = await database;
    final result = await db.query('reports', orderBy: 'date DESC');
    return result.map((json) => Report.fromMap(json)).toList();
  }

  // Get unsynchronized reports
  Future<List<Report>> getUnsyncedReports() async {
    final db = await database;
    final result = await db.query(
      'reports',
      where: 'isSynced = ?',
      whereArgs: [0],
    );
    return result.map((json) => Report.fromMap(json)).toList();
  }

  // Update report
  Future<int> updateReport(Report report) async {
    final db = await database;
    return db.update(
      'reports',
      report.toMap(),
      where: 'id = ?',
      whereArgs: [report.id],
    );
  }

  // Mark report as synced
  Future<int> markAsSynced(int id) async {
    final db = await database;
    return db.update(
      'reports',
      {'isSynced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete report
  Future<int> deleteReport(int id) async {
    final db = await database;
    return db.delete(
      'reports',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Close database
  Future close() async {
    final db = await database;
    db.close();
  }
}
