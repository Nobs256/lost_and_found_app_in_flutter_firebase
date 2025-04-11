import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final _databaseName = 'lost_items.db';
  static final _tableName = 'images';

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path, version: 1, onCreate: (db, version) {
      return db.execute('''
        CREATE TABLE $_tableName (
          id INTEGER PRIMARY KEY,
          image BLOB
        )
      ''');
    });
  }

  Future<void> insertImage(File image) async {
    final db = await database;
    final bytes = await image.readAsBytes();
    await db.insert(_tableName, {'image': bytes});
  }

  Future<List<File>> getImages() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tableName);
    List<File> images = [];
    for (var map in maps) {
      final bytes = map['image'];
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await file.writeAsBytes(bytes);
      images.add(file);
    }
    return images;
  }
}