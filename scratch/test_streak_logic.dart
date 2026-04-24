// ignore_for_file: avoid_print

void main() {
  testLogic();
}

void testLogic() {
  print('--- Testing Streak Logic ---');

  // Helper to format date
  String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  final today = DateTime.now();
  final yesterday = today.subtract(const Duration(days: 1));
  final sixDaysAgo = today.subtract(const Duration(days: 6));
  final twoDaysAgo = today.subtract(const Duration(days: 2));

  print('Today: ${formatDate(today)}');
  print('Yesterday: ${formatDate(yesterday)}');
  print('6 Days Ago: ${formatDate(sixDaysAgo)}');

  // Mock Smart Getter Calculation
  int calculateCurrentStreak(int stored, String? last, int freezes) {
    if (stored == 0) return 0;
    if (last == null) return 0;
    
    final tStr = formatDate(today);
    final yStr = formatDate(yesterday);
    
    if (last == tStr || last == yStr) return stored;

    try {
      final lastDate = DateTime.parse(last);
      final nowDate = DateTime.parse(tStr);
      final daysGap = nowDate.difference(lastDate).inDays;
      final missedDays = daysGap - 1;

      print('  Gap: $daysGap days, Missed: $missedDays days');

      if (missedDays > 0 && missedDays <= freezes) {
        return stored; // Saved by freezes
      }
    } catch (e) {
      print('  Error parsing date: $e');
    }

    return 0;
  }

  // Case 1: Active user
  print('\nCase 1: Practiced yesterday, 2 day streak, 0 freezes');
  int res1 = calculateCurrentStreak(2, formatDate(yesterday), 0);
  print('Result: $res1 (Expected: 2)');

  // Case 2: Inactive user (6 days) no freezes
  print('\nCase 2: Practiced 6 days ago, 2 day streak, 0 freezes');
  int res2 = calculateCurrentStreak(2, formatDate(sixDaysAgo), 0);
  print('Result: $res2 (Expected: 0)');

  // Case 3: Inactive user (2 days ago), 1 freeze
  print('\nCase 3: Practiced 2 days ago (missed yesterday), 5 day streak, 1 freeze');
  int res3 = calculateCurrentStreak(5, formatDate(twoDaysAgo), 1);
  print('Result: $res3 (Expected: 5)');

  // Case 4: Inactive user (2 days ago), 0 freezes
  print('\nCase 4: Practiced 2 days ago (missed yesterday), 5 day streak, 0 freezes');
  int res4 = calculateCurrentStreak(5, formatDate(twoDaysAgo), 0);
  print('Result: $res4 (Expected: 0)');

  // Case 5: 6 days ago with 10 freezes
  print('\nCase 5: Practiced 6 days ago, 3 day streak, 10 freezes');
  int res5 = calculateCurrentStreak(3, formatDate(sixDaysAgo), 10);
  print('Result: $res5 (Expected: 3)');
}
