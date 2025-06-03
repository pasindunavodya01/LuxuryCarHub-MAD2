import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/car.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'car_favorites.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE favorites(
            id TEXT PRIMARY KEY,
            make TEXT,
            model TEXT,
            year TEXT,
            price REAL,
            fuel TEXT,
            images TEXT,
            description TEXT
          )
        ''');
      },
    );
  }

  Future<void> toggleFavorite(Car car) async {
    final db = await database;
    final exists = await isFavorite(car.id!);

    if (exists) {
      await db.delete(
        'favorites',
        where: 'id = ?',
        whereArgs: [car.id],
      );
    } else {
      await db.insert(
        'favorites',
        {
          'id': car.id,
          'make': car.make,
          'model': car.model,
          'year': car.year,
          'price': car.price,
          'fuel': car.fuel,
          'images': car.images,
          'description': car.description,
        },
      );
    }
  }

  Future<bool> isFavorite(String carId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'favorites',
      where: 'id = ?',
      whereArgs: [carId],
    );
    return maps.isNotEmpty;
  }

  Future<List<String>> getFavoriteIds() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('favorites');
    return List.generate(maps.length, (i) => maps[i]['id'] as String);
  }
}
