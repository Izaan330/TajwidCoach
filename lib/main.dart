import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'providers/auth_provider.dart';
import 'providers/streak_provider.dart';
import 'providers/premium_provider.dart';
import 'providers/quran_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/tajwid_progress_provider.dart';
import 'providers/sheikh_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool isFirebaseInitialized = false;
  // Initialize Firebase (requires google-services.json or firebase_options.dart)
  try {
    await Firebase.initializeApp();
    isFirebaseInitialized = true;
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    debugPrint('App will run in Offline/Demo mode.');
  }

  final prefs = await SharedPreferences.getInstance();

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
      ],
      child: const TajwidCoachApp(),
    ),
  );
}


