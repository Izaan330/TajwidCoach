import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/tajwid_rule_model.dart';

class TajwidApiService {
  // CONFIGURATION: Using dynamic local backend for development
  // - Android Emulator uses 10.0.2.2 to access the host machine's localhost.
  // - iOS Simulator and Web use localhost / 127.0.0.1.
  // - For physical device testing, replace with your development machine's local IP (e.g. 'http://192.168.1.100:8000/v1').
  static String get _localUrl {
    if (kIsWeb) return 'http://localhost:8000/v1';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000/v1';
    return 'http://localhost:8000/v1';
  }

  static const String _prodUrl = 'https://tajwid-backend-hsuejed2mq-el.a.run.app/v1';
  
  static String get _baseUrl => kDebugMode ? _localUrl : _prodUrl;
  
  final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 3), // Snappy 3-second connection timeout for offline/local debugging fallback
    receiveTimeout: const Duration(seconds: 15),
  ));

  /// Uploads audio file for Tajwid analysis
  Future<TajwidAnalysisResult> analyzeAudio({
    required File audioFile,
    required String ayahReference,
    required String referenceText,
    String? targetRuleId,
  }) async {
    try {
      final fileName = audioFile.path.split('/').last;
      
      final formData = FormData.fromMap({
        'audio': await MultipartFile.fromFile(audioFile.path, filename: fileName),
        'ayah_ref': ayahReference,
        'reference_text': referenceText,
        if (targetRuleId != null) 'target_rule': targetRuleId,
      });

      final response = await _dio.post(
        '/analyze',
        data: formData,
        onSendProgress: (count, total) {
          // You could expose this progress to the UI if needed
          debugPrint('Uploading: ${(count / total * 100).toStringAsFixed(0)}%');
        },
      );

      if (response.statusCode == 200) {
        return TajwidAnalysisResult.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Server returned error: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
