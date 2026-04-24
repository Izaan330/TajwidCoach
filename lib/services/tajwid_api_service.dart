import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/tajwid_rule_model.dart';

class TajwidApiService {
  // CONFIGURATION: Using local backend for development
  // 10.0.2.2 is the special address to reach the host machine from Android Emulator.
  // We use your real local IP (192.168.29.237) for real Android device testing.
  static const String _localUrl = 'http://192.168.29.237:8000/v1'; 
  static const String _prodUrl = 'https://tajwid-backend-73260634451.asia-south1.run.app/v1';
  
  static const String _baseUrl = kDebugMode ? _localUrl : _prodUrl;
  
  final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 300),
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
