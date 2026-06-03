import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'services/firebase_messaging_service.dart';
import 'services/notification_service.dart';
import 'providers/auth_provider.dart';
import 'providers/streak_provider.dart';
import 'providers/premium_provider.dart';
import 'providers/quran_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/tajwid_progress_provider.dart';
import 'providers/sheikh_provider.dart';
import 'services/offline_service.dart';
import 'services/ad_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool isFirebaseInitialized = false;
  // Initialize Firebase (requires google-services.json or firebase_options.dart)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    isFirebaseInitialized = true;
    
    // Initialize Notifications
    final messagingService = FirebaseMessagingService();
    await messagingService.init();

    final notificationService = NotificationService();
    await notificationService.init();
    await notificationService.scheduleDailyVerseNotification();
  } catch (e) {
    debugPrint('Firebase or Notification initialization failed: $e');
    debugPrint('App will run in Offline/Demo mode.');
  }

  final prefs = await SharedPreferences.getInstance();
  
  // Initialize Mobile Ads SDK and prefetch rewarded ad
  await AdService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(isFirebaseAvailable: isFirebaseInitialized)),
        ChangeNotifierProvider(create: (_) => QuranProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => PremiumProvider()),
        ChangeNotifierProvider(create: (_) => StreakProvider(prefs)),
        ChangeNotifierProvider(create: (_) => TajwidProgressProvider()),
        ChangeNotifierProvider(create: (_) => SheikhProvider()),
        ChangeNotifierProvider(create: (_) => OfflineService()),
      ],
      child: const TajwidCoachApp(),
    ),
  );
}


