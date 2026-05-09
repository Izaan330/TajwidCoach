import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/surah_model.dart';
import '../models/sheikh_model.dart';
import '../models/last_read_model.dart';
import '../services/quran_api_service.dart';
import '../services/quran_database_helper.dart';

/// Standard Madani Mushaf starting pages for all 114 surahs.
const Map<int, int> surahStartPages = {
  1: 1, 2: 2, 3: 50, 4: 77, 5: 106, 6: 128, 7: 151, 8: 177, 9: 187, 10: 208,
  11: 221, 12: 235, 13: 249, 14: 255, 15: 262, 16: 267, 17: 282, 18: 293,
  19: 305, 20: 312, 21: 322, 22: 332, 23: 342, 24: 350, 25: 359, 26: 367,
  27: 377, 28: 385, 29: 396, 30: 404, 31: 411, 32: 415, 33: 418, 34: 428,
  35: 434, 36: 440, 37: 446, 38: 453, 39: 458, 40: 467, 41: 477, 42: 483,
  43: 489, 44: 496, 45: 499, 46: 502, 47: 507, 48: 511, 49: 515, 50: 518,
  51: 520, 52: 523, 53: 526, 54: 528, 55: 531, 56: 534, 57: 537, 58: 542,
  59: 545, 60: 549, 61: 551, 62: 553, 63: 554, 64: 556, 65: 558, 66: 560,
  67: 562, 68: 564, 69: 566, 70: 568, 71: 570, 72: 572, 73: 574, 74: 575,
  75: 577, 76: 578, 77: 580, 78: 582, 79: 583, 80: 585, 81: 586, 82: 587,
  83: 587, 84: 589, 85: 590, 86: 591, 87: 591, 88: 592, 89: 593, 90: 594,
  91: 595, 92: 595, 93: 596, 94: 596, 95: 597, 96: 597, 97: 598, 98: 598,
  99: 599, 100: 599, 101: 600, 102: 601, 103: 601, 104: 601, 105: 602,
  106: 602, 107: 602, 108: 603, 109: 603, 110: 603, 111: 603, 112: 604,
  113: 604, 114: 604,
};

class QuranProvider extends ChangeNotifier {
  List<SurahModel> _surahs = [];
  List<AyahModel> _currentAyahs = [];
  SurahModel? _currentSurah;
  AyahModel? _selectedAyah;
  String _selectedQariId = 'mishary';
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  int _currentPage = 1;
  bool _isUIVisible = true;
  LastReadModel? _lastRead;
  AyahModel? _verseOfTheDay;

  List<SurahModel> get surahs => _searchQuery.isEmpty
      ? _surahs
      : QuranApiService.searchSurahs(_searchQuery);
  List<AyahModel> get currentAyahs => _currentAyahs;
  SurahModel? get currentSurah => _currentSurah;
  AyahModel? get selectedAyah => _selectedAyah;
  String get selectedQariId => _selectedQariId;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  bool get isUIVisible => _isUIVisible;
  LastReadModel? get lastRead => _lastRead;
  AyahModel? get verseOfTheDay => _verseOfTheDay;

  void toggleUI() {
    _isUIVisible = !_isUIVisible;
    notifyListeners();
  }

  void setUIVisible(bool visible) {
    _isUIVisible = visible;
    notifyListeners();
  }

  // Mock Sheikh list for demo
  List<SheikhModel> get mockSheikhs => [
        const SheikhModel(
          id: 'sheikh_001',
          name: 'Sheikh Ahmed Al-Hussaini',
          englishName: 'Sheikh Ahmed Al-Hussaini',
          phone: '+1 234 567 8900',
          masjid: 'Jama Masjid',
          city: 'Delhi',
          rating: 4.9,
          totalStudents: 234,
          currentStudents: 5,
          isVerified: true,
          isAvailable: true,
          specializations: ['Hafs an Asim', 'Tajwid', 'Hifz'],
          bio:
              'Certified Qari with 15 years of experience. Studied at Madinah University.',
          pricePerSession: 500,
          offersGroupClasses: true,
        ),
        const SheikhModel(
          id: 'sheikh_002',
          name: 'Sheikh Yusuf Malik',
          englishName: 'Sheikh Yusuf Malik',
          phone: '+44 7700 900123',
          masjid: 'Al-Noor Masjid',
          city: 'Mumbai',
          rating: 4.7,
          totalStudents: 189,
          currentStudents: 4,
          isVerified: true,
          isAvailable: true,
          specializations: ['Warsh', 'Qalun', 'Children Teaching'],
          bio:
              'Specialist in teaching children and beginners. Gentle and patient approach.',
          pricePerSession: 400,
          offersGroupClasses: true,
        ),
        const SheikhModel(
          id: 'sheikh_003',
          name: 'Sheikh Ibrahim Al-Madani',
          englishName: 'Sheikh Ibrahim Al-Madani',
          phone: '+971 50 123 4567',
          masjid: 'Al-Rahman Masjid',
          city: 'Hyderabad',
          rating: 5.0,
          totalStudents: 312,
          currentStudents: 3,
          isVerified: true,
          isAvailable: false,
          specializations: ['Hafs an Asim', 'Ijazah', 'Advanced Tajwid'],
          bio:
              'Holder of Ijazah in multiple Qiraat. Over 20 years of teaching experience.',
          pricePerSession: 800,
          offersGroupClasses: false,
        ),
        const SheikhModel(
          id: 'sheikh_004',
          name: 'Sheikh Bilal Hassan',
          englishName: 'Sheikh Bilal Hassan',
          phone: '+60 12-345 6789',
          masjid: 'Bilal Masjid',
          city: 'Bengaluru',
          rating: 4.8,
          totalStudents: 156,
          currentStudents: 2,
          isVerified: true,
          isAvailable: true,
          specializations: ['Tajwid', 'Memorization', 'Mujawwad'],
          bio:
              'Expert in melodious recitation (Mujawwad). Trained multiple Hafiz students.',
          pricePerSession: 600,
          offersGroupClasses: true,
        ),
      ];

  void init() {
    _surahs = QuranApiService.getAllSurahs();
    loadLastRead();
    fetchVerseOfTheDay();
    notifyListeners();
  }

  Future<void> fetchVerseOfTheDay() async {
    try {
      final now = DateTime.now();
      final globalNumber = getVerseIndexForDate(now);

      _verseOfTheDay = await QuranDatabaseHelper.instance.getAyahByGlobalNumber(globalNumber);
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching Verse of the Day: $e");
    }
  }

  /// Calculates a seeded random verse index (1-6236) for a given date.
  static int getVerseIndexForDate(DateTime date) {
    final seed = date.year * 10000 + date.month * 100 + date.day;
    // Simple LCG (Linear Congruential Generator) for consistent cross-platform random
    final random = (seed * 1103515245 + 12345) & 0x7fffffff;
    return (random % 6236) + 1;
  }

  Future<void> loadLastRead() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastReadJson = prefs.getString('last_read_quran');
      if (lastReadJson != null) {
        _lastRead = LastReadModel.fromJson(lastReadJson);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error loading last read: $e");
    }
  }

  Future<void> updateLastRead(
    SurahModel surah, {
    int? ayahNumber,
    int? pageNumber,
    String? scriptMode,
  }) async {
    _lastRead = LastReadModel(
      surahNumber: surah.number,
      surahName: surah.name,
      ayahNumber: ayahNumber ?? _lastRead?.ayahNumber,
      pageNumber: pageNumber ?? _lastRead?.pageNumber,
      scriptMode: scriptMode ?? _lastRead?.scriptMode,
      timestamp: DateTime.now(),
    );
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_read_quran', _lastRead!.toJson());
    } catch (e) {
      debugPrint("Error saving last read: $e");
    }
  }

  Future<void> loadSurah(
    int surahNumber, {
    String scriptEdition = 'quran-uthmani',
    String translationEdition = 'en.sahih',
    bool preservePage = false,
  }) async {
    _isLoading = true;
    _error = null;
    final surah = _surahs.firstWhere(
      (s) => s.number == surahNumber,
      orElse: () => SurahModel.fromMap({
        'number': surahNumber,
        'name': 'Surah $surahNumber',
        'arabic': '',
        'ayahs': 0,
        'juz': 1,
      }),
    );
    _currentSurah = surah;
    notifyListeners();

    try {
      _currentAyahs = await QuranApiService.getSurahAyahs(
        surahNumber,
        scriptEdition: scriptEdition,
        translationEdition: translationEdition,
      );
      if (_currentAyahs.isNotEmpty && !preservePage) {
        _currentPage = _currentAyahs[0].pageNumber;
      }
    } catch (e) {
      _error = 'Failed to load Surah from local database.';
    }

    _isLoading = false;
    notifyListeners();
  }

  void selectAyah(AyahModel ayah) {
    _selectedAyah = ayah;
    notifyListeners();
  }

  void selectQari(String qariId) {
    _selectedQariId = qariId;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void goToPage(int page) {
    if (page < 1 || page > 624) return;
    if (_currentPage == page) return;
    _currentPage = page;
    notifyListeners();
  }

  /// Silently update the current page (without notification, used during scrolling)
  void setCurrentPage(int page) {
    if (page < 1 || page > 624) return;
    if (_currentPage == page) return;
    _currentPage = page;
    // We don't notify here to avoid rebuild loops during scroll, 
    // unless you want the UI indicators to update immediately.
    notifyListeners();
  }

  /// Returns the index in _currentAyahs of the first ayah on the given page.
  int findFirstAyahIndexOnPage(int pageNumber) {
    if (_currentAyahs.isEmpty) return 0;
    for (int i = 0; i < _currentAyahs.length; i++) {
      if (_currentAyahs[i].pageNumber >= pageNumber) {
        return i;
      }
    }
    return 0;
  }

  /// Navigate directly to a Surah's starting page in the Mushaf.
  void goToSurah(int surahNumber, {int? tajweedPage}) {
    final page = tajweedPage ?? surahStartPages[surahNumber] ?? 1;
    goToPage(page);
    // Also set current surah from the loaded surahs list
    try {
      _currentSurah = _surahs.firstWhere((s) => s.number == surahNumber);
    } catch (_) {}
    notifyListeners();
  }

  void nextPage() => goToPage(_currentPage + 1);
  void previousPage() => goToPage(_currentPage - 1);
}
