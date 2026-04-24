import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/quran_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/streak_provider.dart';
import 'providers/tajwid_progress_provider.dart';
import 'providers/sheikh_provider.dart';
import 'providers/premium_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/main_navigation.dart';

class TajwidCoachApp extends StatelessWidget {
  const TajwidCoachApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(392, 800),
      minTextAdapt: true,
      builder: (context, child) => MaterialApp(
        title: 'TajwidCoach',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isInitialized = false;
  String? _lastUid;

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    final quran = context.read<QuranProvider>();
    final settings = context.read<SettingsProvider>();

    await settings.loadSettings();
    quran.init();

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  /// Called every time any dependency (including AuthProvider) changes.
  /// This is the correct Flutter pattern for coordinating cross-provider state.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final uid = user?.uid;
    
    if (uid != _lastUid) {
      _lastUid = uid;
      // Push UID into dependent services so cloud sync activates/deactivates
      context.read<StreakProvider>().updateUserId(uid);
      context.read<TajwidProgressProvider>().updateUserId(uid);
      context.read<PremiumProvider>().updateUserId(uid);

      if (uid != null && user != null && user.isSheikh) {
        context.read<SheikhProvider>().listenToPendingReviews(uid);
        context.read<SheikhProvider>().listenToMyStudents(uid);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!_isInitialized) {
      return const SplashScreen();
    }

    if (auth.isAuthenticated) {
      return const MainNavigation();
    } else {
      return const AuthScreen();
    }
  }
}
