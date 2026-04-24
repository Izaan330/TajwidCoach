import 'dart:convert';

class LastReadModel {
  final int surahNumber;
  final String surahName;
  final int? ayahNumber;
  final int? pageNumber;
  final String? scriptMode;
  final DateTime timestamp;

  LastReadModel({
    required this.surahNumber,
    required this.surahName,
    this.ayahNumber,
    this.pageNumber,
    this.scriptMode,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'surahNumber': surahNumber,
      'surahName': surahName,
      'ayahNumber': ayahNumber,
      'pageNumber': pageNumber,
      'scriptMode': scriptMode,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory LastReadModel.fromMap(Map<String, dynamic> map) {
    return LastReadModel(
      surahNumber: map['surahNumber'] ?? 1,
      surahName: map['surahName'] ?? '',
      ayahNumber: map['ayahNumber'],
      pageNumber: map['pageNumber'],
      scriptMode: map['scriptMode'],
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  String toJson() => json.encode(toMap());

  factory LastReadModel.fromJson(String source) =>
      LastReadModel.fromMap(json.decode(source));
}
