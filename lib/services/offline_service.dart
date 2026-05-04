import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

class OfflineService extends ChangeNotifier {
  final Dio _dio = Dio();
  final Map<String, double> _downloadProgress = {}; // surahNumber -> progress (0-1.0)
  Set<String> _downloadedSurahs = {};

  Map<String, double> get downloadProgress => _downloadProgress;
  Set<String> get downloadedSurahs => _downloadedSurahs;

  OfflineService() {
    _init();
  }

  Future<void> _init() async {
    final dir = await getApplicationDocumentsDirectory();
    final offlineDir = Directory('${dir.path}/offline_quran');
    if (await offlineDir.exists()) {
      final surahs = offlineDir.listSync().map((e) => e.path.split('/').last).toSet();
      _downloadedSurahs = surahs;
      notifyListeners();
    }
  }

  bool isDownloaded(int surahNumber) => _downloadedSurahs.contains(surahNumber.toString());

  Future<void> downloadSurah(int surahNumber, List<String> audioUrls) async {
    if (isDownloaded(surahNumber)) return;

    final dir = await getApplicationDocumentsDirectory();
    final surahDir = Directory('${dir.path}/offline_quran/$surahNumber');
    if (!await surahDir.exists()) {
      await surahDir.create(recursive: true);
    }

    _downloadProgress[surahNumber.toString()] = 0.0;
    notifyListeners();

    try {
      int completed = 0;
      for (final url in audioUrls) {
        final fileName = url.split('/').last;
        final savePath = '${surahDir.path}/$fileName';
        
        await _dio.download(url, savePath);
        
        completed++;
        _downloadProgress[surahNumber.toString()] = completed / audioUrls.length;
        notifyListeners();
      }

      _downloadedSurahs.add(surahNumber.toString());
      _downloadProgress.remove(surahNumber.toString());
      notifyListeners();
    } catch (e) {
      debugPrint('Download error surah $surahNumber: $e');
      _downloadProgress.remove(surahNumber.toString());
      notifyListeners();
    }
  }

  Future<void> deleteSurah(int surahNumber) async {
    final dir = await getApplicationDocumentsDirectory();
    final surahDir = Directory('${dir.path}/offline_quran/$surahNumber');
    if (await surahDir.exists()) {
      await surahDir.delete(recursive: true);
    }
    _downloadedSurahs.remove(surahNumber.toString());
    notifyListeners();
  }

  String? getOfflinePath(int surahNumber, int ayahNumber) {
    // This is a placeholder. Real implementation would need a mapping of ayah to filename.
    return null;
  }
}
