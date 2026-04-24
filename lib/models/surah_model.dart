class SurahModel {
  final int number;
  final String name;
  final String arabicName;
  final int ayahCount;
  final int juzNumber;
  final String type; // 'Meccan' or 'Medinan'
  final int progressPercent; // 0-100

  const SurahModel({
    required this.number,
    required this.name,
    required this.arabicName,
    required this.ayahCount,
    required this.juzNumber,
    this.type = 'Meccan',
    this.progressPercent = 0,
  });

  bool get isJuz30 => juzNumber == 30;

  factory SurahModel.fromMap(Map<String, dynamic> map) {
    return SurahModel(
      number: map['number'] ?? 0,
      name: map['name'] ?? '',
      arabicName: map['arabic'] ?? map['arabicName'] ?? '',
      ayahCount: map['ayahs'] ?? map['ayahCount'] ?? 0,
      juzNumber: map['juz'] ?? map['juzNumber'] ?? 1,
      type: map['type'] ?? 'Meccan',
      progressPercent: map['progressPercent'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'number': number,
    'name': name,
    'arabicName': arabicName,
    'ayahCount': ayahCount,
    'juzNumber': juzNumber,
    'type': type,
    'progressPercent': progressPercent,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SurahModel &&
          runtimeType == other.runtimeType &&
          number == other.number;

  @override
  int get hashCode => number.hashCode;
}

class AyahModel {
  final int surahNumber;
  final int ayahNumber;
  final String arabicText;
  final String indopakText;
  final String translationText;
  final String transliteration;
  final List<WordModel> words;
  final int juzNumber;
  final int pageNumber;
  final int globalNumber;
  final String tajweedText;

  const AyahModel({
    required this.surahNumber,
    required this.ayahNumber,
    required this.arabicText,
    required this.globalNumber,
    this.indopakText = '',
    this.translationText = '',
    this.transliteration = '',
    this.tajweedText = '',
    this.words = const [],
    this.juzNumber = 1,
    this.pageNumber = 1,
  });

  String get reference => '$surahNumber:$ayahNumber';

  factory AyahModel.fromApiMap(Map<String, dynamic> map) {
    return AyahModel(
      surahNumber: map['surah']?['number'] ?? 0,
      ayahNumber: map['numberInSurah'] ?? map['number'] ?? 0,
      arabicText: map['text'] ?? '',
      translationText: map['translation'] ?? '',
      juzNumber: map['juz'] ?? 1,
      pageNumber: map['page'] ?? 1,
      globalNumber: map['number'] ?? 0,
    );
  }

  factory AyahModel.fromMap(Map<String, dynamic> map) {
    return AyahModel(
      surahNumber: map['sura'] ?? map['surahNumber'] ?? 0,
      ayahNumber: map['aya'] ?? map['ayahNumber'] ?? 0,
      arabicText: map['text'] ?? map['arabicText'] ?? '',
      indopakText: map['indopak_text'] ?? map['indopakText'] ?? '',
      translationText: map['translation'] ?? map['translationText'] ?? '',
      juzNumber: map['juez'] ?? map['juzNumber'] ?? 1,
      pageNumber: map['page'] ?? map['pageNumber'] ?? 1,
      globalNumber: map['global_number'] ?? map['globalNumber'] ?? 0,
      tajweedText: map['tajweed_text'] ?? map['tajweedText'] ?? '',
    );
  }
}

class WordModel {
  final String arabic;
  final String transliteration;
  final String translation;
  final String? tajwidRuleId;
  final String? colorHex;

  const WordModel({
    required this.arabic,
    this.transliteration = '',
    this.translation = '',
    this.tajwidRuleId,
    this.colorHex,
  });
}

