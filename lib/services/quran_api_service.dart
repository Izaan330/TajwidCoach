import 'package:flutter/foundation.dart';
import '../models/surah_model.dart';
import '../utils/quran_constants.dart';
import 'quran_database_helper.dart';

class QuranApiService {
  /// Fetch all Surahs (names, numbers, etc.) from local constants.
  static List<SurahModel> getAllSurahs() {
    return QuranConstants.surahs.map((s) => SurahModel.fromMap(s)).toList();
  }

  /// Fetch ayahs for a given surah exclusively from the local SQLite database.
  static Future<List<AyahModel>> getSurahAyahs(
    int surahNumber, {
    String scriptEdition = 'quran-uthmani',
    String translationEdition = 'en.sahih',
  }) async {
    try {
      return await QuranDatabaseHelper.instance.getSurahAyahs(surahNumber);
    } catch (e) {
      debugPrint("Error fetching from local DB: $e");
      return [];
    }
  }

  /// Fetch a single Ayah from the local database.
  static Future<AyahModel?> getAyah(
    int surahNumber,
    int ayahNumber, {
    String scriptEdition = 'quran-uthmani',
    String translationEdition = 'en.sahih',
  }) async {
    final ayahs = await getSurahAyahs(surahNumber);
    try {
      return ayahs.firstWhere((a) => a.ayahNumber == ayahNumber);
    } catch (_) {
      return null;
    }
  }

  /// Get audio URL for a specific Qari.
  /// This mapping is defined in QuranConstants.
  static String getAudioUrl(String qariId, int globalNumber) {
    return QuranConstants.getAudioUrl(qariId, globalNumber);
  }

  /// Search Surahs by name or number locally.
  static List<SurahModel> searchSurahs(String query) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return getAllSurahs();
    
    return getAllSurahs().where((s) {
      return s.name.toLowerCase().contains(q) ||
          s.arabicName.contains(q) ||
          s.number.toString() == q;
    }).toList();
  }

  /// Clears the cache (No-op in offline mode as we query DB directly).
  static void clearCache() {}
}
