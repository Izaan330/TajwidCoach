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
        title: 'Quran Pro: Tajwid AI',
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
  PremiumTier? _lastTier;

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    final startTime = DateTime.now();
    
    final quran = context.read<QuranProvider>();
    final settings = context.read<SettingsProvider>();

    await settings.loadSettings();
    quran.init();

    // Ensure splash screen shows for at least 1500ms for premium experience
    final elapsed = DateTime.now().difference(startTime).inMilliseconds;
    if (elapsed < 1500) {
      await Future.delayed(Duration(milliseconds: 1500 - elapsed));
    }

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
    final premium = context.watch<PremiumProvider>();
    final user = auth.user;
    final uid = user?.uid;

    // Global guard: enforce free script for non-premium users on startup,
    // login, and any premium tier change (e.g. downgrade / expiry).
    final settings = context.read<SettingsProvider>();
    if (!premium.isPremium && settings.quranScript != QuranScript.indoPak) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) settings.setQuranScript(QuranScript.indoPak);
      });
    }
    
    if (uid != _lastUid) {
      _lastUid = uid;
      // Push UID into dependent services so cloud sync activates/deactivates
      context.read<StreakProvider>().updateUserId(uid);
      context.read<TajwidProgressProvider>().updateUserId(uid);
      
      final premium = context.read<PremiumProvider>();
      premium.updateUserId(uid);
      
      // Sync premium status to StreakProvider
      context.read<StreakProvider>().updatePremiumStatus(
        !premium.isLocked(PremiumFeature.unlimitedFreezes),
        premium.maxFreezes,
      );

      if (uid != null && user != null && user.isSheikh) {
        context.read<SheikhProvider>().listenToPendingReviews(uid);
        context.read<SheikhProvider>().listenToMyStudents(uid);
      }
    } else if (premium.tier != _lastTier) {
      // Tier changed for the same user (Upgrade)
      final oldMax = context.read<StreakProvider>().maxFreezes;
      final newMax = premium.maxFreezes;

      context.read<StreakProvider>().updatePremiumStatus(
        !premium.isLocked(PremiumFeature.unlimitedFreezes),
        newMax,
      );

      if (newMax > oldMax && mounted) {
        final diff = newMax - oldMax;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.ac_unit_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Premium Reward: +$diff Streak Freezes added!'),
                  ),
                ],
              ),
              backgroundColor: AppTheme.info,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
        });
      }
    }
    _lastTier = premium.tier;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // Stay on splash screen until BOTH internal services AND auth state are ready
    if (!_isInitialized || !auth.isAuthDetermined) {
      return const SplashScreen();
    }

    if (auth.isAuthenticated) {
      return const MainNavigation();
    } else {
      return const AuthScreen();
    }
  }
}

// Root application widget routing and global state configuration
