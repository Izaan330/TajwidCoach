import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/streak_service.dart';

class StreakProvider extends ChangeNotifier {
  final StreakService _service;

  StreakProvider(SharedPreferences prefs) : _service = StreakService(prefs);

  void updateUserId(String? uid) {
    _service.userId = uid;
    notifyListeners();
  }

  int get currentStreak => _service.currentStreak;
  int get longestStreak => _service.longestStreak;
  int get streakFreezes => _service.streakFreezes;
  List<String> get earnedBadges => _service.earnedBadges;
  bool get hasStreakToday => _service.hasStreakToday();
  bool get isStreakInDanger => _service.isStreakInDanger();
  bool get isStreakRestorable => _service.isStreakRestorable();
  bool get isFreezeActiveToday => _service.isFreezeActiveToday();
  Map<String, int> get heatmapData => _service.getHeatmapData();

  StreakBadge? _justEarnedBadge;
  StreakBadge? get justEarnedBadge => _justEarnedBadge;

  bool _streakIncreased = false;
  bool get streakIncreased => _streakIncreased;

  Future<void> recordPractice(int minutes) async {
    final oldStreak = currentStreak;
    _justEarnedBadge = await _service.recordPractice();
    _streakIncreased = currentStreak > oldStreak;
    
    final today = DateTime.now();
    final dateStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    await _service.addHeatmapEntry(dateStr, minutes);
    notifyListeners();
  }

  Future<void> useFreeze() async {
    final success = await _service.useManualFreeze();
    if (success) {
      notifyListeners();
    }
  }

  Future<void> purchaseFreezes(int count) async {
    await _service.addFreezes(count);
    notifyListeners();
  }

  void clearJustEarnedBadge() {
    _justEarnedBadge = null;
    notifyListeners();
  }
}
