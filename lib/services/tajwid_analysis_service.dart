import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/tajwid_rule_model.dart';
import '../utils/tajwid_rules_data.dart';
import 'tajwid_api_service.dart';
import '../providers/premium_provider.dart';

/// AI Tajwid analysis service.
/// Uses TajwidApiService for cloud ML but falls back to Mock for dev.
class TajwidAnalysisService {
  static final TajwidApiService _apiService = TajwidApiService();
  static final Random _random = Random();

  static const Map<String, List<String>> _ruleFeedbacks = {
    'idgham': [
      'Excellent Idgham! The letters merged perfectly.',
      'Good Idgham but extend the Ghunnah slightly (2 counts).',
      'Idgham needs improvement — the letters should fully merge.',
    ],
    'ikhfa': [
      'Perfect Ikhfa! Great nasal sound with proper concealment.',
      'Ikhfa is slightly too clear — conceal the Noon more.',
      'Ikhfa pronunciation needs work — the Nun should be hidden.',
    ],
    'qalqalah': [
      'Excellent Qalqalah bounce! Very clear echo sound.',
      'Qalqalah is good, but make the bounce slightly stronger.',
      'Qalqalah is weak — letters ق ط ب ج د need echoing on Sukoon.',
    ],
    'madd_tabi': [
      'Perfect natural Madd — exactly 2 counts!',
      'Natural Madd is slightly short — extend to 2 full counts.',
      'Madd Tabi\'i is too long — keep it to exactly 2 counts.',
    ],
    'ghunnah': [
      'Beautiful Ghunnah! Perfect 2-count nasal sound.',
      'Ghunnah is there but too short — extend to 2 full counts.',
      'Ghunnah is missing — Meem/Noon with Shaddah needs nasal sound.',
    ],
    'madd_muttasil': [
      'Excellent! Madd Muttasil stretched to full 4-5 counts.',
      'Madd Muttasil is too short — extend to 4-5 counts.',
      'Madd Muttasil missed — Hamzah after Madd letter needs elongation.',
    ],
  };

  /// Performs real analysis using audio file if available, otherwise mock.
  static Future<TajwidAnalysisResult> analyze({
    required String ayahReference,
    required String referenceText,
    required int durationSeconds,
    File? audioFile,
    String? targetRuleId,
    List<String>? existingWeakRules,
    bool isPremium = false,
  }) async {
    // If we have a file, try the real API
    if (audioFile != null) {
      try {
        final result = await _apiService.analyzeAudio(
          audioFile: audioFile,
          ayahReference: ayahReference,
          referenceText: referenceText,
          targetRuleId: targetRuleId,
        );

        if (isPremium) return result;

        // Filter for free users
        final filteredScores = result.ruleScores
            .where((s) => PremiumProvider.freeRuleIds.contains(s.ruleId))
            .toList();
        
        return TajwidAnalysisResult(
          overallScore: result.overallScore,
          feedback: result.feedback,
          grade: result.grade,
          ruleScores: filteredScores,
          weakWords: result.weakWords, // Keep weak words as hint
          weakRuleIds: result.weakRuleIds.where((id) => PremiumProvider.freeRuleIds.contains(id)).toList(),
          excellentRuleIds: result.excellentRuleIds.where((id) => PremiumProvider.freeRuleIds.contains(id)).toList(),
          encouragement: result.encouragement,
          lockedRulesCount: result.ruleScores.length - filteredScores.length,
        );
      } catch (e) {
        debugPrint('Real ML API failed: $e');
        
        String errorMessage = 'We encountered a connection issue. Please ensure the AI server is accessible and your device is connected to the internet.';
        String encouragement = 'Please check your connection and try again.';
        
        if (e is DioException) {
          if (e.type == DioExceptionType.receiveTimeout) {
            errorMessage = 'The analysis took longer than expected. Try a shorter recording or check your network speed.';
            encouragement = 'Try a smaller verse or a faster connection.';
          } else if (e.type == DioExceptionType.connectionTimeout) {
            errorMessage = 'Could not reach the AI server. Please verify your network and server settings.';
          }
        }

        return TajwidAnalysisResult(
          overallScore: 0,
          feedback: errorMessage, // Removed raw details from user-facing feedback
          grade: 'Reviewing...',
          ruleScores: [],
          weakWords: [],
          weakRuleIds: [],
          excellentRuleIds: [],
          encouragement: encouragement,
        );
      }
    }

    // Simulate processing delay for mock
    await Future.delayed(const Duration(seconds: 2));

    // Generate realistic scores - bias toward 70-95 range
    final baseScore = 65 + _random.nextInt(30);
    final ruleScores = <RuleScore>[];
    final weakRuleIds = <String>[];
    final excellentRuleIds = <String>[];

    // Analyze a subset of relevant rules
    final relevantRuleIds = [
      'idgham',
      'ikhfa',
      'qalqalah',
      'madd_tabi',
      'ghunnah',
      'madd_muttasil',
    ];

    for (final ruleId in relevantRuleIds) {
      final rule = TajwidRulesData.findById(ruleId);
      if (rule == null) continue;

      // Weight toward existing weak rules
      int ruleScore;
      if (existingWeakRules != null && existingWeakRules.contains(ruleId)) {
        ruleScore = 50 + _random.nextInt(35); // biased lower
      } else {
        ruleScore = 70 + _random.nextInt(30);
      }

      final feedbackList = _ruleFeedbacks[ruleId] ?? ['Good pronunciation.'];
      final String feedback = ruleScore >= 85
          ? feedbackList[0]
          : ruleScore >= 65
              ? feedbackList[1]
              : feedbackList[2];

      final isWeak = ruleScore < 70;
      if (isWeak) weakRuleIds.add(ruleId);
      if (ruleScore >= 90) excellentRuleIds.add(ruleId);

      ruleScores.add(
        RuleScore(
          ruleId: ruleId,
          ruleName: rule.name,
          score: ruleScore,
          feedback: feedback,
          isWeak: isWeak,
        ),
      );
    }

    // Calculate overall score as weighted average
    final avgRuleScore = ruleScores.isEmpty
        ? baseScore
        : ruleScores.map((r) => r.score).reduce((a, b) => a + b) ~/
            ruleScores.length;
    final overallScore = ((baseScore + avgRuleScore) ~/ 2).clamp(30, 100);

    // Filter results if not premium
    int lockedRulesCount = 0;
    List<RuleScore> finalScores = ruleScores;
    List<String> finalWeakIds = weakRuleIds;
    List<String> finalExcellentIds = excellentRuleIds;

    if (!isPremium) {
      finalScores = ruleScores.where((s) => PremiumProvider.freeRuleIds.contains(s.ruleId)).toList();
      finalWeakIds = weakRuleIds.where((id) => PremiumProvider.freeRuleIds.contains(id)).toList();
      finalExcellentIds = excellentRuleIds.where((id) => PremiumProvider.freeRuleIds.contains(id)).toList();
      lockedRulesCount = ruleScores.length - finalScores.length;
    }

    // Generate weak words (Arabic examples)
    final weakWords =
        finalWeakIds.isNotEmpty ? _generateWeakWords(finalWeakIds) : <String>[];

    return TajwidAnalysisResult(
      overallScore: overallScore,
      feedback: _buildFeedback(overallScore, finalWeakIds),
      grade: _getGrade(overallScore),
      ruleScores: finalScores,
      weakWords: weakWords,
      weakRuleIds: finalWeakIds,
      excellentRuleIds: finalExcellentIds,
      encouragement: _getEncouragement(overallScore),
      lockedRulesCount: lockedRulesCount,
    );
  }

  static List<String> _generateWeakWords(List<String> weakRuleIds) {
    final wordMap = {
      'idgham': ['مِن يَقُولُ', 'مِن وَل'],
      'ikhfa': ['مَن تَابَ', 'مِن ثَمَرَة'],
      'qalqalah': ['قُلْ', 'يَبْطُل'],
      'ghunnah': ['إِنَّ', 'ثُمَّ'],
      'madd_muttasil': ['جَاءَ', 'شَاءَ'],
    };
    final result = <String>[];
    for (final ruleId in weakRuleIds) {
      if (wordMap.containsKey(ruleId)) {
        result.addAll(wordMap[ruleId]!.take(1));
      }
    }
    return result;
  }

  static String _buildFeedback(int score, List<String> weakRuleIds) {
    if (score >= 90) {
      return 'Excellent recitation! Your Tajwid is near perfect.';
    } else if (score >= 80) {
      if (weakRuleIds.isNotEmpty) {
        final ruleName = TajwidRulesData.findById(weakRuleIds.first)?.name ??
            weakRuleIds.first;
        return 'Very good! Focus on improving your $ruleName.';
      }
      return 'Very good recitation! Keep practicing for perfection.';
    } else if (score >= 65) {
      final names = weakRuleIds
          .take(2)
          .map((id) => TajwidRulesData.findById(id)?.name ?? id)
          .join(' and ');
      return 'Good effort! Work on $names to improve your score.';
    }
    return 'Keep practicing! Focus on the fundamentals of Tajwid.';
  }

  static String _getGrade(int score) {
    if (score >= 95) return 'Excellent (ممتاز)';
    if (score >= 85) return 'Very Good (جيد جداً)';
    if (score >= 75) return 'Good (جيد)';
    if (score >= 60) return 'Acceptable (مقبول)';
    return 'Needs Practice (يحتاج مزيدًا من التدريب)';
  }

  static String _getEncouragement(int score) {
    if (score >= 90) return 'MashaAllah! Your recitation is beautiful!';
    if (score >= 80) return 'Excellent work! You\'re almost there!';
    if (score >= 70) return 'Great effort! Practice makes perfect!';
    if (score >= 60) return 'Keep going! Every practice brings you closer!';
    return '"Indeed, the one who recites Quran and is expert in it will be with the noble obedient angels." - Sahih Muslim';
  }
}

