import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class StreakBadge {
  final String id;
  final String emoji;
  final String name;
  final int requiredDays;
  final String description;

  const StreakBadge({
    required this.id,
    required this.emoji,
    required this.name,
    required this.requiredDays,
    required this.description,
  });
}

class StreakService {
  static const List<StreakBadge> allBadges = [
    StreakBadge(
      id: 'first_day',
      emoji: '🌱',
      name: 'First Step',
      requiredDays: 1,
      description: 'Started your Quran journey',
    ),
    StreakBadge(
      id: 'week',
      emoji: '🔥',
      name: 'Week Warrior',
      requiredDays: 7,
      description: '7 days of consistent practice',
    ),
    StreakBadge(
      id: 'month',
      emoji: '🌟',
      name: 'Month Master',
      requiredDays: 30,
      description: '30 days of dedication',
    ),
    StreakBadge(
      id: 'hundred',
      emoji: '🕌',
      name: 'Century Prophet',
      requiredDays: 100,
      description: '100 days — true devotion',
    ),
    StreakBadge(
      id: 'year',
      emoji: '👑',
      name: 'Hafiz Journey',
      requiredDays: 365,
      description: '365 days — a full year of Quran',
    ),
  ];

  final SharedPreferences _prefs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _userId;

  StreakService(this._prefs);

  set userId(String? uid) {
    if (_userId != uid) {
      _userId = uid;
      if (_userId != null) {
        syncFromFirestore();
      }
    }
  }

  int get currentStreak {
    final stored = _prefs.getInt('streak_days') ?? 0;
    if (stored == 0) return 0;

    final today = _todayString();
    final last = lastPracticeDate;
    if (last == null) return 0;
    
    // If practiced today or yesterday, streak is valid
    if (last == today || last == _yesterdayString()) return stored;

    // Check if a manual freeze protects the gap
    final frozen = lastFrozenDate;
    if (frozen != null) {
      try {
        final lastDate = DateTime.parse(last);
        final frozenDate = DateTime.parse(frozen);
        final nowDate = DateTime.parse(today);
        
        // If the gap between last practice and today is covered by the frozen date
        // e.g. Last=Mon, Frozen=Tue, Today=Wed.
        if (frozenDate.difference(lastDate).inDays == 1 && 
            (nowDate.difference(frozenDate).inDays == 1 || nowDate == frozenDate)) {
          return stored;
        }
      } catch (_) {}
    }

    return 0;
  }

  int get longestStreak => _prefs.getInt('longest_streak') ?? 0;
  String? get lastPracticeDate => _prefs.getString('last_practice_date');
  String? get lastFrozenDate => _prefs.getString('last_frozen_date');
  List<String> get earnedBadges => _prefs.getStringList('earned_badges') ?? [];
  int get streakFreezes => _prefs.getInt('streak_freezes') ?? 2;

  Future<void> addFreezes(int count) async {
    await _setStreakFreezes(streakFreezes + count);
    if (_userId != null) await syncToFirestore();
  }

  Future<bool> useManualFreeze() async {
    if (streakFreezes <= 0) return false;
    
    final today = _todayString();
    final yesterday = _yesterdayString();
    
    String dateToFreeze;
    if (isStreakInDanger()) {
      dateToFreeze = today;
    } else if (isStreakRestorable()) {
      dateToFreeze = yesterday;
    } else {
      return false;
    }

    if (lastFrozenDate == dateToFreeze) return false; // Already frozen

    await _prefs.setString('last_frozen_date', dateToFreeze);
    await _setStreakFreezes(streakFreezes - 1);
    
    if (_userId != null) await syncToFirestore();
    return true;
  }


  bool isFreezeActiveToday() => lastFrozenDate == _todayString();

  Future<void> _setStreakFreezes(int count) async {
    await _prefs.setInt('streak_freezes', count);
  }

  /// Records a practice session and updates streak.
  /// Returns newly earned badge if any.
  Future<StreakBadge?> recordPractice() async {
    final today = _todayString();
    final last = lastPracticeDate;

    if (last == today) {
      return null;
    }

    int streak = currentStreak;

    if (last == _yesterdayString()) {
      streak += 1;
    } else if (last == null) {
      streak = 1;
    } else {
      // Check if manual freeze saved the streak
      final frozen = lastFrozenDate;
      bool savedByFreeze = false;
      if (frozen != null) {
        try {
          final lastDate = DateTime.parse(last);
          final frozenDate = DateTime.parse(frozen);
          
          // Only check the day immediately before today
          if (frozen == _yesterdayString() && frozenDate.difference(lastDate).inDays == 1) {
            savedByFreeze = true;
          }
        } catch (_) {}
      }

      if (savedByFreeze) {
        streak += 1;
      } else {
        streak = 1;
      }
    }

    await _prefs.setInt('streak_days', streak);
    await _prefs.setString('last_practice_date', today);

    final longest = longestStreak;
    if (streak > longest) {
      await _prefs.setInt('longest_streak', streak);
    }

    final badge = await _checkAndAwardBadge(streak);
    
    // Reward Streak Freeze for milestones
    if (badge != null) {
      if (badge.requiredDays == 7 || badge.requiredDays == 30 || 
          badge.requiredDays == 100 || badge.requiredDays == 365) {
        await addFreezes(1);
      }
    }
    
    // Sync to cloud
    if (_userId != null) {
      await syncToFirestore();
    }
    
    return badge;
  }

  Future<StreakBadge?> _checkAndAwardBadge(int streak) async {
    final earned = earnedBadges;
    for (final badge in allBadges.reversed) {
      if (streak >= badge.requiredDays && !earned.contains(badge.id)) {
        earned.add(badge.id);
        await _prefs.setStringList('earned_badges', earned);
        return badge;
      }
    }
    return null;
  }

  Map<String, int> getHeatmapData() {
    final data = <String, int>{};
    final raw = _prefs.getString('heatmap_data') ?? '';
    if (raw.isEmpty) return data;

    for (final entry in raw.split(',')) {
      final parts = entry.split(':');
      if (parts.length == 2) {
        data[parts[0]] = int.tryParse(parts[1]) ?? 0;
      }
    }
    return data;
  }

  Future<void> addHeatmapEntry(String date, int minutes) async {
    final data = getHeatmapData();
    data[date] = (data[date] ?? 0) + minutes;
    final encoded = data.entries.map((e) => '${e.key}:${e.value}').join(',');
    await _prefs.setString('heatmap_data', encoded);
    
    if (_userId != null) {
      await syncToFirestore();
    }
  }

  Future<void> syncToFirestore() async {
    if (_userId == null) return;
    try {
      await _firestore.collection('users').doc(_userId).collection('progress').doc('streak').set({
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'lastPracticeDate': lastPracticeDate,
        'lastFrozenDate': lastFrozenDate,
        'earnedBadges': earnedBadges,
        'streakFreezes': streakFreezes,
        'heatmapData': _prefs.getString('heatmap_data') ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Streak cloud sync failed: $e');
    }
  }

  Future<void> syncFromFirestore() async {
    if (_userId == null) return;
    try {
      final doc = await _firestore.collection('users').doc(_userId).collection('progress').doc('streak').get();
      if (doc.exists) {
        final data = doc.data()!;
        await _prefs.setInt('streak_days', data['currentStreak'] ?? 0);
        await _prefs.setInt('longest_streak', data['longestStreak'] ?? 0);
        await _prefs.setString('last_practice_date', data['lastPracticeDate']);
        await _prefs.setString('last_frozen_date', data['lastFrozenDate']);
        await _prefs.setStringList('earned_badges', List<String>.from(data['earnedBadges'] ?? []));
        await _prefs.setInt('streak_freezes', data['streakFreezes'] ?? 2);
        await _prefs.setString('heatmap_data', data['heatmapData'] ?? '');
      }
    } catch (e) {
      debugPrint('Streak cloud fetch failed: $e');
    }
  }

  bool hasStreakToday() => lastPracticeDate == _todayString();

  bool isStreakInDanger() =>
      lastPracticeDate == _yesterdayString() && !hasStreakToday();

  bool isStreakRestorable() {
    final last = lastPracticeDate;
    if (last == null) return false;
    
    final stored = _prefs.getInt('streak_days') ?? 0;
    if (stored == 0) return false;

    // If current streak is 0 (meaning we missed yesterday)
    // and yesterday wasn't already frozen
    if (currentStreak == 0 && last == _twoDaysAgoString() && lastFrozenDate != _yesterdayString()) {
      return true;
    }
    return false;
  }


  String _todayString() {
    final now = DateTime.now();
    return _formatDate(now);
  }

  String _yesterdayString() {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    return _formatDate(yesterday);
  }

  String _twoDaysAgoString() {
    final now = DateTime.now();
    final twoDaysAgo = DateTime(now.year, now.month, now.day - 2);
    return _formatDate(twoDaysAgo);
  }


  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

