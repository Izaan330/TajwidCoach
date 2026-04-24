import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../providers/streak_provider.dart';
import 'main_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _scaleIn;
  late Animation<double> _slideUp;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );
    _scaleIn = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );
    _slideUp = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // Navigation is now handled by AuthWrapper in app.dart
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final streak = context.watch<StreakProvider>().currentStreak;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Premium Background
          const _SplashBackground(),
          
          // 2. Main Content
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Glassmorphic Logo Container
                    Transform.scale(
                      scale: _scaleIn.value,
                      child: Opacity(
                        opacity: _fadeIn.value,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(25),
                            borderRadius: BorderRadius.circular(35),
                            border: Border.all(
                              color: Colors.white.withAlpha(50),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryGreen.withAlpha(75),
                                blurRadius: 40,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Center(
                            child: ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [Color(0xFFFFD700), Color(0xFFE6BE8A)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds),
                              child: const Icon(
                                Icons.auto_stories_rounded,
                                size: 80,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    
                    // App Name & Tagline
                    Transform.translate(
                      offset: Offset(0, _slideUp.value),
                      child: Opacity(
                        opacity: _fadeIn.value,
                        child: Column(
                          children: [
                            const Text(
                              'TajwidCoach',
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -1.0,
                                shadows: [
                                  Shadow(
                                    color: Colors.black26,
                                    offset: Offset(0, 4),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'PERFECT YOUR RECITATION',
                              style: TextStyle(
                                fontSize: 13,
                                letterSpacing: 3.5,
                                color: Colors.white.withAlpha(180),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 32),
                            const Text(
                              'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                              style: TextStyle(
                                fontSize: 24,
                                color: Color(0xFFFFD700),
                                fontFamily: 'AmiriQuran',
                                fontWeight: FontWeight.w500,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 64),
                    
                    // Streak Banner (Premium Style)
                    if (streak > 0)
                      Transform.translate(
                        offset: Offset(0, _slideUp.value + 20),
                        child: Opacity(
                          opacity: _fadeIn.value,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 15,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🔥', style: TextStyle(fontSize: 22)),
                                const SizedBox(width: 12),
                                Text(
                                  '$streak-DAY STREAK!',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          
          // 3. Bottom Credits
          const Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 0.4,
              child: Center(
                child: Text(
                  'MADE WITH SPIRITUAL CARE',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 2,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashBackground extends StatelessWidget {
  const _SplashBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF004D40), // Dark Teal
            Color(0xFF00251A), // Near Black Teal
          ],
        ),
      ),
      child: CustomPaint(
        painter: _IslamicPatternPainter(),
      ),
    );
  }
}

class _IslamicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const spacing = 100.0;
    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        _drawEightPointStar(canvas, Offset(x, y), 25, paint);
      }
    }
  }

  void _drawEightPointStar(Canvas canvas, Offset center, double radius, Paint paint) {
    // Draw two overlapping squares rotated 45 degrees
    final path1 = Path();
    path1.addRect(Rect.fromCircle(center: center, radius: radius * 0.7));
    
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(0.785398); // 45 degrees
    canvas.translate(-center.dx, -center.dy);
    canvas.drawPath(path1, paint);
    canvas.restore();
    
    canvas.drawPath(path1, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<_OnboardingPage> _pages = [
    _OnboardingPage(
      emoji: '🎤',
      title: 'Assalamu Alaikum!',
      subtitle: 'Welcome to TajwidCoach',
      description:
          'Your AI-powered companion for perfecting Quran recitation. Our system detects 25+ Tajwid rules in real-time.',
      color: AppTheme.primaryGreen,
    ),
    _OnboardingPage(
      emoji: '🔥',
      title: 'Build Your Streak',
      subtitle: 'Practice Every Day',
      description:
          'Earn badges for consistent practice. 7-day 🔥, 30-day 🌟, 100-day 🕌, 365-day 👑. Don\'t break your streak!',
      color: AppTheme.accentAmber,
    ),
    _OnboardingPage(
      emoji: '👨‍🏫',
      title: 'Learn from Sheikhs',
      subtitle: 'Verified Islamic Scholars',
      description:
          'Connect with certified Sheikhs for live corrections and earn your digital Ijazah certificate.',
      color: Color(0xFF6A1B9A),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundCream,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (context, index) => _buildPage(_pages[index]),
              ),
            ),
            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _currentPage ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _currentPage
                        ? AppTheme.primaryGreen
                        : AppTheme.textHint,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // CTA Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('hasSeenOnboarding', true);
                      if (context.mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const MainNavigation(),
                          ),
                        );
                      }
                    }
                  },
                  child: Text(
                    _currentPage < _pages.length - 1
                        ? 'Next'
                        : 'Get Started — بسم الله',
                  ),
                ),
              ),
            ),
            if (_currentPage < _pages.length - 1)
              TextButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('hasSeenOnboarding', true);
                  if (context.mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const MainNavigation()),
                    );
                  }
                },
                child: const Text('Skip'),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: page.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(page.emoji, style: const TextStyle(fontSize: 56)),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            page.subtitle,
            style: TextStyle(
              color: page.color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage {
  final String emoji;
  final String title;
  final String subtitle;
  final String description;
  final Color color;

  const _OnboardingPage({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.color,
  });
}

