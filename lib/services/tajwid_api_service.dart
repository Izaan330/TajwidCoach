import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/tajwid_rule_model.dart';

class TajwidApiService {
  static const String _prodUrl = 'https://tajwid-backend-709262255399.asia-south1.run.app/v1';
  
  static String get _baseUrl => _prodUrl;

  
  final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 30), // Cloud Run cold-start can take up to 30s
    receiveTimeout: const Duration(seconds: 120), // ML inference (Whisper + Wav2Vec2) can take ~60s
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
