import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';
import 'quran_database_helper.dart';
import '../providers/quran_provider.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    
    await _notifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('Notification clicked: ${details.payload}');
      },
    );
  }

  Future<void> scheduleDailyVerseNotification() async {
    final now = DateTime.now();
    // Schedule for 8:00 AM
    var scheduledTime = DateTime(now.year, now.month, now.day, 8, 0);
    
    // If it's already past 8:00 AM, schedule for tomorrow
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    final globalNumber = QuranProvider.getVerseIndexForDate(scheduledTime);
    
    try {
      final ayah = await QuranDatabaseHelper.instance.getAyahByGlobalNumber(globalNumber);
      if (ayah == null) return;

      await _notifications.zonedSchedule(
        id: 0,
        title: 'Verse of the Day',
        body: ayah.translationText,
        scheduledDate: tz.TZDateTime.from(scheduledTime, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_verse',
            'Daily Verse Notifications',
            channelDescription: 'Daily spiritual boost with Quran verses',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'verse_of_the_day',
      );
      
      debugPrint('Scheduled daily notification for: $scheduledTime');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }
}
