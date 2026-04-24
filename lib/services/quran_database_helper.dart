import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/surah_model.dart';

class QuranDatabaseHelper {
  static final QuranDatabaseHelper instance = QuranDatabaseHelper._internal();
  static Database? _database;

  static const int _dbVersion = 13; 

  factory QuranDatabaseHelper() => instance;

  QuranDatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "quran.db");
    
    final prefs = await SharedPreferences.getInstance();
    final currentVersion = prefs.getInt('quran_db_version') ?? 0;

    // Check if the database exists
    bool exists = await databaseExists(path);

    if (!exists || currentVersion < _dbVersion) {
      // Should copy from assets
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      // Copy from asset
      ByteData data = await rootBundle.load("assets/databases/quran.db");
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the bytes written
      await File(path).writeAsBytes(bytes, flush: true);
      
      // Update version
      await prefs.setInt('quran_db_version', _dbVersion);
    }

    final db = await openDatabase(path);
    
    // Check if tajweed_text column exists, if not, add it
    final columns = await db.rawQuery('PRAGMA table_info(ayats)');
    final hasTajweedColumn = columns.any((c) => c['name'] == 'tajweed_text');
    if (!hasTajweedColumn) {
      await db.execute('ALTER TABLE ayats ADD COLUMN tajweed_text TEXT DEFAULT ""');
    }

    return db;
  }

  /// Fetch all Ayahs for a given Surah
  Future<List<AyahModel>> getSurahAyahs(int surahNumber) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'ayats',
      where: 'sura = ?',
      whereArgs: [surahNumber],
      orderBy: 'aya ASC',
    );

    return List.generate(maps.length, (i) {
      return AyahModel(
        surahNumber: maps[i]['sura'],
        ayahNumber: maps[i]['aya'],
        arabicText: maps[i]['text'],
        indopakText: maps[i]['indopak_text'] ?? '',
        translationText: maps[i]['translation'] ?? '',
        pageNumber: maps[i]['page'] ?? 1,
        globalNumber: maps[i]['global_number'] ?? 0,
        tajweedText: maps[i]['tajweed_text'] ?? '',
      );
    });
  }

  /// Fetch the first Ayah of a specific page
  Future<AyahModel?> getFirstAyahByPage(int pageNumber) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'ayats',
      where: 'page = ?',
      whereArgs: [pageNumber],
      orderBy: 'global_number ASC',
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return AyahModel(
      surahNumber: maps[0]['sura'],
      ayahNumber: maps[0]['aya'],
      arabicText: maps[0]['text'],
      indopakText: maps[0]['indopak_text'] ?? '',
      translationText: maps[0]['translation'] ?? '',
      juzNumber: maps[0]['juez'] ?? 1,
      pageNumber: maps[0]['page'] ?? 1,
      globalNumber: maps[0]['global_number'] ?? 0,
      tajweedText: maps[0]['tajweed_text'] ?? '',
    );
  }

  /// Fetch the next Ayah in sequence
  Future<AyahModel?> getNextAyah(int currentSurah, int currentAyah) async {
    final db = await database;
    
    // First try to get the next ayah in the same surah
    List<Map<String, dynamic>> maps = await db.query(
      'ayats',
      where: 'sura = ? AND aya = ?',
      whereArgs: [currentSurah, currentAyah + 1],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return AyahModel.fromMap(maps[0]);
    }

    // If not found, try the first ayah of the next surah
    maps = await db.query(
      'ayats',
      where: 'sura = ? AND aya = 1',
      whereArgs: [currentSurah + 1],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return AyahModel.fromMap(maps[0]);
    }

    return null;
  }

  /// Close the database connection
  Future close() async {
    final db = await database;
    db.close();
  }

  /// Fetches random Ayahs that contain a specific Tajweed rule pattern
  Future<List<AyahModel>> getAyahsByRule(String ruleId, {int limit = 20}) async {
    final db = await database;
    String pattern = '';

    switch (ruleId) {
      case 'ghunnah':
        pattern = '%نّ%'; // Mushaddad Noon
        break;
      case 'qalqalah':
        pattern = '%ْ%'; // Sukoon is the trigger in Indo-Pak
        break;
      case 'iqlab':
        pattern = '%ۢ%'; // Small Meem marker
        break;
      case 'madd_long':
        pattern = '%\u0653%'; // Maddah wave
        break;
      case 'sajdah':
        pattern = '%\u06e9%'; // Sajdah marker
        break;
      default:
        pattern = '% %'; // Fallback to random with space
    }

    final List<Map<String, dynamic>> results = await db.query(
      'ayats',
      where: 'indopak_text LIKE ?',
      whereArgs: [pattern],
      limit: limit,
    );

    // Shuffle in memory to get random ayahs from the matched set
    final list = results.map((m) => AyahModel.fromMap(m)).toList();
    list.shuffle();
    return list.take(5).toList();
  }
}
