import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:podpal/models/pod_status_model.dart';

class DatabaseService {
  // Singleton pattern to ensure only one instance of the database service exists.
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;
  DateTime _lastWriteTime = DateTime.fromMillisecondsSinceEpoch(0);

  /// Gets the database instance, initializing it if it doesn't exist yet.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  /// Initializes the SQLite database.
  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'podpal.db');

    // This will trigger the onUpgrade callback if the user has an old database.
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        // This code runs only if the database is created for the very first time.
        // It includes all columns, new and old.
        await db.execute('''
          CREATE TABLE sensor_history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp TEXT NOT NULL,
            temperature REAL NOT NULL,
            humidity REAL NOT NULL,
            moisture INTEGER NOT NULL,
            water_level TEXT,
            nutrient_level TEXT
          )
        ''');
      },
      // This is the key to adding the new columns to an already existing database
      // without deleting it. It runs when the version number above is increased.
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // If the database version on the user's phone is 1, we add the new columns.
          await db.execute("ALTER TABLE sensor_history ADD COLUMN water_level TEXT");
          await db.execute("ALTER TABLE sensor_history ADD COLUMN nutrient_level TEXT");
          print("Database upgraded to version 2 with new columns.");
        }
      },
    );
  }

  /// Inserts a new sensor reading, including the new data, but only every 5 minutes.
  Future<void> insertSensorReadingThrottled(PodStatusModel status) async {
    final now = DateTime.now();

    // THROTTLING: Only write to the database if 5 minutes have passed.
    if (now.difference(_lastWriteTime).inMinutes < 5) {
      return;
    }

    final db = await database;
    await db.insert(
      'sensor_history',
      {
        'timestamp': now.toIso8601String(),
        'temperature': status.temperature,
        'humidity': status.humidity,
        'moisture': status.moisture,
        // Saving the new data to the database
        'water_level': status.waterLevel,
        'nutrient_level': status.nutrientLevel,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Update the last write time and prune old data.
    _lastWriteTime = now;
    print("✅ Throttled sensor data (with new fields) saved to local database.");
    await _pruneOldData();
  }

  /// Deletes records from the database that are older than 24 hours.
  Future<void> _pruneOldData() async {
    final db = await database;
    final twentyFourHoursAgo = DateTime.now().subtract(const Duration(hours: 24));

    int count = await db.delete(
      'sensor_history',
      where: 'timestamp <= ?',
      whereArgs: [twentyFourHoursAgo.toIso8601String()],
    );

    if (count > 0) {
      print("🧹 Pruned $count old records from the database.");
    }
  }

  /// Fetches sensor readings from the last 12 hours for AI prompts.
  Future<List<Map<String, dynamic>>> getRecentReadings() async {
    final db = await database;
    final twelveHoursAgo = DateTime.now().subtract(const Duration(hours: 12));

    final List<Map<String, dynamic>> maps = await db.query(
      'sensor_history',
      where: 'timestamp > ?',
      whereArgs: [twelveHoursAgo.toIso8601String()],
      orderBy: 'timestamp DESC',
    );

    print("Fetched ${maps.length} historical readings from the last 12 hours.");
    return maps;
  }
}