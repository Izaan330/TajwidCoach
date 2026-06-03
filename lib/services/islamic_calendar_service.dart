import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IslamicCalendarService {
  final Dio _dio = Dio();

  static const String _baseUrl = 'https://api.aladhan.com/v1';
  static const String _cacheKey = 'cached_islamic_events';
  static const String _cacheTimeKey = 'cached_islamic_events_time';

  /// Fetches Gregorian dates for key Islamic events for the current and next Hijri year.
  Future<List<Map<String, String>>> getUpcomingEvents() async {
    final now = DateTime.now();

    // 1. Try to load from local cache first
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_cacheKey);
      final cachedTimeStr = prefs.getString(_cacheTimeKey);

      if (cachedData != null && cachedTimeStr != null) {
        final cachedTime = DateTime.parse(cachedTimeStr);
        // Cache is valid for 24 hours
        if (now.difference(cachedTime).inHours < 24) {
          final List<dynamic> decoded = json.decode(cachedData);
          final List<Map<String, String>> cachedEvents = decoded
              .map((item) => Map<String, String>.from(item as Map))
              .toList();

          // Filter out events that are older than 30 days relative to today
          final filteredEvents = cachedEvents.where((event) {
            final timestamp = int.tryParse(event['timestamp'] ?? '');
            if (timestamp == null) return false;
            final eventDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
            return eventDate.isAfter(now.subtract(const Duration(days: 30)));
          }).toList();

          // If we still have enough events, return them
          if (filteredEvents.length >= 4) {
            debugPrint('Returning ${filteredEvents.length} events from cache');
            return filteredEvents.take(6).toList();
          }
        }
      }
    } catch (e) {
      debugPrint('Error reading events cache: $e');
    }

    // 2. Fetch live data
    try {
      // Get current Hijri date to determine the year
      final currentGregorianDate = DateFormat('dd-MM-yyyy').format(now);
      
      final response = await _dio.get('$_baseUrl/gToH/$currentGregorianDate');
      final hijriData = response.data['data']['hijri'];
      int currentHijriYear = int.parse(hijriData['year']);

      final List<Map<String, String>> events = [];
      final targetYears = [currentHijriYear, currentHijriYear + 1];

      final List<Map<String, String>> eventDefinitions = [
        {'name': 'Islamic New Year', 'day': '01', 'month': '01'},
        {'name': 'Ashura', 'day': '10', 'month': '01'},
        {'name': 'Ramadan Begins', 'day': '01', 'month': '09'},
        {'name': 'Eid al-Fitr', 'day': '01', 'month': '10'},
        {'name': 'Arafah', 'day': '09', 'month': '12'},
        {'name': 'Eid al-Adha', 'day': '10', 'month': '12'},
      ];

      // To avoid rate limiting and connection dropped issues on the public Aladhan API,
      // we execute requests sequentially with a slight delay
      for (var year in targetYears) {
        for (var def in eventDefinitions) {
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
            // Sequential delay to be polite to the Aladhan API
            await Future.delayed(const Duration(milliseconds: 150));
          } catch (e) {
            debugPrint('Failed to fetch event ${def['name']} for year $year: $e');
          }
        }
      }

      if (events.isEmpty) {
        throw Exception('No events fetched from API');
      }

      // Sort by date
      events.sort((a, b) => int.parse(a['timestamp']!).compareTo(int.parse(b['timestamp']!)));

      // 3. Cache the successfully fetched events
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_cacheKey, json.encode(events));
        await prefs.setString(_cacheTimeKey, now.toIso8601String());
        debugPrint('Successfully cached ${events.length} events');
      } catch (e) {
        debugPrint('Error caching events: $e');
      }

      // Limit to next 6 events
      return events.take(6).toList();
    } catch (e) {
      debugPrint('Error fetching Islamic events: $e');

      // Try to return ANY cached data as fallback, even if expired
      try {
        final prefs = await SharedPreferences.getInstance();
        final cachedData = prefs.getString(_cacheKey);
        if (cachedData != null) {
          final List<dynamic> decoded = json.decode(cachedData);
          final List<Map<String, String>> cachedEvents = decoded
              .map((item) => Map<String, String>.from(item as Map))
              .toList();

          final filteredEvents = cachedEvents.where((event) {
            final timestamp = int.tryParse(event['timestamp'] ?? '');
            if (timestamp == null) return false;
            final eventDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
            return eventDate.isAfter(now.subtract(const Duration(days: 30)));
          }).toList();

          if (filteredEvents.isNotEmpty) {
            debugPrint('Returning ${filteredEvents.length} expired/stale events from cache as fallback');
            return filteredEvents.take(6).toList();
          }
        }
      } catch (cacheErr) {
        debugPrint('Fallback cache read failed: $cacheErr');
      }

      // Fallback data in case of internet and cache error
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
