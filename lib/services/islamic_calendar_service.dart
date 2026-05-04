import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

class IslamicCalendarService {
  final Dio _dio = Dio();

  static const String _baseUrl = 'https://api.aladhan.com/v1';

  /// Fetches Gregorian dates for key Islamic events for the current and next Hijri year.
  Future<List<Map<String, String>>> getUpcomingEvents() async {
    try {
      // 1. Get current Hijri date to determine the year
      final now = DateTime.now();
      final currentGregorianDate = DateFormat('dd-MM-yyyy').format(now);
      
      final response = await _dio.get('$_baseUrl/gToH/$currentGregorianDate');
      final hijriData = response.data['data']['hijri'];
      int currentHijriYear = int.parse(hijriData['year']);

      final List<Map<String, String>> events = [];

      // We'll fetch for the current Hijri year and the next one to ensure we have upcoming ones
      final targetYears = [currentHijriYear, currentHijriYear + 1];

      final List<Map<String, String>> eventDefinitions = [
        {'name': 'Islamic New Year', 'day': '01', 'month': '01'},
        {'name': 'Ashura', 'day': '10', 'month': '01'},
        {'name': 'Ramadan Begins', 'day': '01', 'month': '09'},
        {'name': 'Eid al-Fitr', 'day': '01', 'month': '10'},
        {'name': 'Arafah', 'day': '09', 'month': '12'},
        {'name': 'Eid al-Adha', 'day': '10', 'month': '12'},
      ];

      final List<Future<void>> fetchTasks = [];

      for (var year in targetYears) {
        for (var def in eventDefinitions) {
          fetchTasks.add(() async {
            try {
              final dateStr = '${def['day']}-${def['month']}-$year';
              final gResponse = await _dio.get('$_baseUrl/hToG/$dateStr');
              
              final gData = gResponse.data['data']['gregorian'];
              final gDateTime = DateFormat('dd-MM-yyyy').parse(gData['date']);
              
              // Only add if it's in the future or within the last 30 days
              if (gDateTime.isAfter(now.subtract(const Duration(days: 30)))) {
                events.add({
                  'name': def['name']!,
                  'hijri': '${_getOrdinal(int.parse(def['day']!))} ${gResponse.data['data']['hijri']['month']['en']}',
                  'gregorian': DateFormat('MMM dd, yyyy').format(gDateTime),
                  'timestamp': gDateTime.millisecondsSinceEpoch.toString(),
                });
              }
            } catch (e) {
              // Skip failed date conversions
            }
          }().catchError((_) => null));
        }
      }

      await Future.wait(fetchTasks);

      // Sort by date
      events.sort((a, b) => int.parse(a['timestamp']!).compareTo(int.parse(b['timestamp']!)));
      
      // Limit to next 6 events
      return events.take(6).toList();
    } catch (e) {
      debugPrint('Error fetching Islamic events: $e');
      // Fallback data in case of internet error
      return _getFallbackEvents();
    }
  }

  String _getOrdinal(int day) {
    if (day >= 11 && day <= 13) return '${day}th';
    switch (day % 10) {
      case 1: return '${day}st';
      case 2: return '${day}nd';
      case 3: return '${day}rd';
      default: return '${day}th';
    }
  }

  List<Map<String, String>> _getFallbackEvents() {
    return [
      {'name': 'Ramadan Begins', 'hijri': '1st Ramadan', 'gregorian': 'Live date unavailable'},
      {'name': 'Eid al-Fitr', 'hijri': '1st Shawwal', 'gregorian': 'Live date unavailable'},
      {'name': 'Arafah', 'hijri': '9th Dhu al-Hijjah', 'gregorian': 'Live date unavailable'},
      {'name': 'Eid al-Adha', 'hijri': '10th Dhu al-Hijjah', 'gregorian': 'Live date unavailable'},
      {'name': 'Islamic New Year', 'hijri': '1st Muharram', 'gregorian': 'Live date unavailable'},
      {'name': 'Ashura', 'hijri': '10th Muharram', 'gregorian': 'Live date unavailable'},
    ];
  }
}
