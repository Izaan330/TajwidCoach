import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Three rendering modes for the Quran reader.
enum QuranScript {
  /// QCF v2 glyph fonts — pixel-perfect Madani Mushaf (via qcf_quran package).
  mushaf,

  /// PDMS-Saleem IndoPak font — word-by-word rendering for subcontinent style.
  indoPak,

  /// Uthmani font with Tajweed rule color coding.
  tajweed,
}

enum TranslationLanguage {
  english,
  urdu,
  hindi,
}

class SettingsProvider extends ChangeNotifier {
  static const _scriptKey = 'quran_script_v2';
  static const _translationKey = 'translation_language';
  static const _fontSizeKey = 'quran_font_size';
  static const _showTranslationKey = 'show_translation';
  static const _darkModeKey = 'dark_mode';

  QuranScript _quranScript = QuranScript.mushaf;
  TranslationLanguage _translationLanguage = TranslationLanguage.english;
  double _quranFontSize = 28.0;
  bool _showTranslation = true;
  bool _isDarkMode = false;

  QuranScript get quranScript => _quranScript;
  TranslationLanguage get translationLanguage => _translationLanguage;
  double get quranFontSize => _quranFontSize;
  bool get showTranslation => _showTranslation;
  bool get isDarkMode => _isDarkMode;

  /// Whether to show Tajweed colors (only relevant in tajweed script mode).
  bool get showTajweedColors => _quranScript == QuranScript.tajweed;

  /// The font family for the current script mode (used in ayah cards for IndoPak/Tajweed modes).
  String get defaultFontFamily {
    switch (_quranScript) {
      case QuranScript.indoPak:
        return 'IndoPak';
      case QuranScript.tajweed:
      case QuranScript.mushaf:
        return 'UthmanicHafs';
    }
  }

  /// The script type for database queries (IndoPak vs Uthmani text column).
  bool get isIndoPak => _quranScript == QuranScript.indoPak;

  /// The Al-Quran Cloud API edition string for the current script type
  String get scriptEdition {
    switch (_quranScript) {
      case QuranScript.indoPak:
        return 'quran-uthmani-qdc';
      case QuranScript.mushaf:
      case QuranScript.tajweed:
        return 'quran-uthmani';
    }
  }

  /// The Al-Quran Cloud API edition string for the current translation
  String get translationEdition {
    switch (_translationLanguage) {
      case TranslationLanguage.english:
        return 'en.sahih';
      case TranslationLanguage.urdu:
        return 'ur.jalandhry';
      case TranslationLanguage.hindi:
        return 'hi.hindi';
    }
  }

  /// Human-readable script name
  String get scriptName {
    switch (_quranScript) {
      case QuranScript.mushaf:
        return 'Mushaf';
      case QuranScript.indoPak:
        return 'Indo-Pak';
      case QuranScript.tajweed:
        return 'Tajweed';
    }
  }

  /// Human-readable translation name
  String get translationName {
    switch (_translationLanguage) {
      case TranslationLanguage.english:
        return 'English (Sahih International)';
      case TranslationLanguage.urdu:
        return 'اردو (جالندھری)';
      case TranslationLanguage.hindi:
        return 'हिन्दी';
    }
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final scriptIndex = prefs.getInt(_scriptKey) ?? 0;
    final translationIndex = prefs.getInt(_translationKey) ?? 0;
    _quranFontSize = prefs.getDouble(_fontSizeKey) ?? 28.0;
    _showTranslation = prefs.getBool(_showTranslationKey) ?? true;
    _isDarkMode = prefs.getBool(_darkModeKey) ?? false;

    _quranScript = QuranScript.values[scriptIndex.clamp(0, QuranScript.values.length - 1)];
    _translationLanguage = TranslationLanguage.values[translationIndex.clamp(0, TranslationLanguage.values.length - 1)];

    notifyListeners();
  }

  Future<void> setQuranScript(QuranScript script) async {
    _quranScript = script;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_scriptKey, script.index);
  }

  Future<void> setTranslationLanguage(TranslationLanguage lang) async {
    _translationLanguage = lang;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_translationKey, lang.index);
  }

  Future<void> setQuranFontSize(double size) async {
    _quranFontSize = size.clamp(18.0, 48.0);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, _quranFontSize);
  }

  Future<void> setShowTranslation(bool show) async {
    _showTranslation = show;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showTranslationKey, show);
  }

  Future<void> setDarkMode(bool dark) async {
    _isDarkMode = dark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, dark);
  }
}
