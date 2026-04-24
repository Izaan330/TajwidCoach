import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class TajwidRuleProgress {
  final String ruleId;
  int xp;
  int level;
  int successfulRecitations;
  DateTime? lastPracticed;

  TajwidRuleProgress({
    required this.ruleId,
    this.xp = 0,
    this.level = 1,
    this.successfulRecitations = 0,
    this.lastPracticed,
  });

  Map<String, dynamic> toJson() => {
    'ruleId': ruleId,
    'xp': xp,
    'level': level,
    'successfulRecitations': successfulRecitations,
    'lastPracticed': lastPracticed?.toIso8601String(),
  };

  factory TajwidRuleProgress.fromJson(Map<String, dynamic> json) => TajwidRuleProgress(
    ruleId: json['ruleId'],
    xp: json['xp'] ?? 0,
    level: json['level'] ?? 1,
    successfulRecitations: json['successfulRecitations'] ?? 0,
    lastPracticed: json['lastPracticed'] != null ? DateTime.parse(json['lastPracticed']) : null,
  );

  double get progressToNextLevel {
    return (xp % 100) / 100;
  }
}

class TajwidProgressProvider extends ChangeNotifier {
  static const _storageKey = 'tajwid_progress_data';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, TajwidRuleProgress> _progressMap = {};
  String? _userId;

  Map<String, TajwidRuleProgress> get progressMap => _progressMap;

  TajwidProgressProvider() {
    _loadProgress();
  }

  /// Update the current user ID and trigger sync if needed
  void updateUserId(String? uid) {
    if (_userId != uid) {
      _userId = uid;
      if (_userId != null) {
        _syncFromFirestore();
      } else {
        _progressMap = {};
        _loadProgress(); // Reload local data for guest if any
      }
    }
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_storageKey);
    if (data != null) {
      final Map<String, dynamic> jsonMap = json.decode(data);
      _progressMap = jsonMap.map((key, value) => MapEntry(key, TajwidRuleProgress.fromJson(value)));
      notifyListeners();
    }
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final data = json.encode(_progressMap.map((key, value) => MapEntry(key, value.toJson())));
    await prefs.setString(_storageKey, data);
    
    // Sync to cloud
    if (_userId != null) {
      await _syncToFirestore();
    }
  }

  Future<void> _syncToFirestore() async {
    if (_userId == null) return;
    try {
      final data = _progressMap.map((key, value) => MapEntry(key, value.toJson()));
      await _firestore.collection('users').doc(_userId).collection('progress').doc('tajwid').set({
        'data': data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Cloud sync failed: $e');
    }
  }

  Future<void> _syncFromFirestore() async {
    if (_userId == null) return;
    try {
      final doc = await _firestore.collection('users').doc(_userId).collection('progress').doc('tajwid').get();
      if (doc.exists) {
        final Map<String, dynamic> data = doc.data()!['data'] ?? {};
        _progressMap = data.map((key, value) => MapEntry(key, TajwidRuleProgress.fromJson(value)));
        notifyListeners();
        // Update local cache too
        await _saveProgress();
      }
    } catch (e) {
      debugPrint('Cloud fetch failed: $e');
    }
  }

  TajwidRuleProgress getRuleProgress(String ruleId) {
    return _progressMap[ruleId] ?? TajwidRuleProgress(ruleId: ruleId);
  }

  Future<void> addXp(String ruleId, int amount) async {
    final progress = getRuleProgress(ruleId);
    progress.xp += amount;
    progress.successfulRecitations += 1;
    progress.lastPracticed = DateTime.now();

    // Level up logic (every 100 XP)
    int newLevel = (progress.xp / 100).floor() + 1;
    if (newLevel > progress.level) {
      progress.level = newLevel;
    }

    _progressMap[ruleId] = progress;
    notifyListeners();
    await _saveProgress();
  }

  int get totalMasteryScore {
    int score = 0;
    _progressMap.forEach((_, p) => score += p.level);
    return score;
  }

  List<String> get weakRules {
    return _progressMap.entries
        .where((e) => e.value.level < 3)
        .map((e) => e.key)
        .toList();
  }

  List<String> get masteredRules {
    return _progressMap.entries
        .where((e) => e.value.level >= 5)
        .map((e) => e.key)
        .toList();
  }
}
