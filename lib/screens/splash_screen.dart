import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../providers/streak_provider.dart';
import 'main_navigation.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SPLASH SCREEN  (unchanged logic, same dark background as before)
// ─────────────────────────────────────────────────────────────────────────────
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
          const Positioned.fill(child: _SplashBackground()),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                              shaderCallback: (bounds) =>
                                  const LinearGradient(
                                colors: [
                                  Color(0xFFFFD700),
                                  Color(0xFFE6BE8A)
                                ],
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
                              'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
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
                    if (streak > 0)
                      Transform.translate(
                        offset: Offset(0, _slideUp.value + 20),
                        child: Opacity(
                          opacity: _fadeIn.value,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF2E7D32),
                                  Color(0xFF1B5E20)
                                ],
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
                                const Text('🔥',
                                    style: TextStyle(fontSize: 22)),
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
            Color(0xFF004D40),
            Color(0xFF00251A),
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

  void _drawEightPointStar(
      Canvas canvas, Offset center, double radius, Paint paint) {
    final path1 = Path();
    path1.addRect(Rect.fromCircle(center: center, radius: radius * 0.7));

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(0.785398);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawPath(path1, paint);
    canvas.restore();

    canvas.drawPath(path1, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// ONBOARDING SCREEN  (premium dark immersive redesign)
// ─────────────────────────────────────────────────────────────────────────────
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late final AnimationController _ctaPulseController;
  late final AnimationController _bgOrbitController;

  static const List<_OnboardingPage> _pages = [
    _OnboardingPage(
      emoji: '🎤',
      title: 'Assalamu Alaikum!',
      subtitle: 'Welcome to TajwidCoach',
      description:
          'Your AI-powered companion for perfecting Quran recitation. Our system detects 25+ Tajwid rules in real-time.',
      color: AppTheme.primaryGreen,
      bgColor: Color(0xFF002416),
    ),
    _OnboardingPage(
      emoji: '🔥',
      title: 'Build Your Streak',
      subtitle: 'Practice Every Day',
      description:
          'Earn badges for consistent practice. 7-day 🔥, 30-day 🌟, 100-day 🕌, 365-day 👑. Don\'t break your streak!',
      color: AppTheme.accentAmber,
      bgColor: Color(0xFF1C0E00),
    ),
    _OnboardingPage(
      emoji: '👨‍🏫',
      title: 'Learn from Sheikhs',
      subtitle: 'Verified Islamic Scholars',
      description:
          'Connect with certified Sheikhs for live corrections and earn your digital Ijazah certificate.',
      color: Color(0xFFCE93D8),
      bgColor: Color(0xFF150A1F),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _ctaPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _bgOrbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _ctaPulseController.dispose();
    _bgOrbitController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    HapticFeedback.mediumImpact();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, anim, __) => const MainNavigation(),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(
            opacity: anim,
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Stack(
        children: [
          // ─── Animated radial orbit background ──────────────────────────
          AnimatedBuilder(
            animation: _bgOrbitController,
            builder: (context, _) {
              return CustomPaint(
                painter: _OrbitPainter(
                  angle: _bgOrbitController.value * 2 * math.pi,
                  color: page.color,
                ),
                size: Size.infinite,
              );
            },
          ),

          // ─── Skip button top-right ──────────────────────────────────────
          if (_currentPage < _pages.length - 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 20,
              child: TextButton(
                onPressed: _complete,
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.textSecondary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('Skip'),
              ),
            ),

          // ─── Main content ───────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Segmented progress bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: _SegmentedProgressBar(
                    total: _pages.length,
                    current: _currentPage,
                    color: page.color,
                  ),
                ),

                // Pages
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (i) {
                      HapticFeedback.selectionClick();
                      setState(() => _currentPage = i);
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) =>
                        _buildPage(_pages[index]),
                  ),
                ),

                // CTA Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: AnimatedBuilder(
                    animation: _ctaPulseController,
                    builder: (context, child) {
                      final glowOpacity =
                          0.2 + 0.2 * _ctaPulseController.value;
                      final scale =
                          1.0 + 0.02 * _ctaPulseController.value;
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: page.color
                                    .withValues(alpha: glowOpacity),
                                blurRadius: 24,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: child,
                        ),
                      );
                    },
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_currentPage < _pages.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeInOutCubic,
                            );
                          } else {
                            await _complete();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: page.color,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          _currentPage < _pages.length - 1
                              ? 'Continue →'
                              : 'Get Started — بسم الله',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(_OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Glowing emoji orb
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  page.color.withValues(alpha: 0.25),
                  page.color.withValues(alpha: 0.05),
                  Colors.transparent,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: page.color.withValues(alpha: 0.2),
                  blurRadius: 50,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Text(
                page.emoji,
                style: const TextStyle(fontSize: 70),
              ),
            ),
          ),
          const SizedBox(height: 48),

          // Subtitle tag
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: page.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: page.color.withValues(alpha: 0.3)),
            ),
            child: Text(
              page.subtitle.toUpperCase(),
              style: TextStyle(
                color: page.color,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              letterSpacing: -0.5,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Segmented Progress Bar ────────────────────────────────────────────────
class _SegmentedProgressBar extends StatelessWidget {
  final int total;
  final int current;
  final Color color;

  const _SegmentedProgressBar({
    required this.total,
    required this.current,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final isActive = i <= current;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: isActive
                  ? color
                  : AppTheme.textHint.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 8,
                      )
                    ]
                  : [],
            ),
          ),
        );
      }),
    );
  }
}

// ─── Orbiting background particles painter ────────────────────────────────
class _OrbitPainter extends CustomPainter {
  final double angle;
  final Color color;

  const _OrbitPainter({required this.angle, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.3;
    final r = size.width * 0.45;

    final paint = Paint()
      ..color = color.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Three concentric subtle rings
    canvas.drawCircle(Offset(cx, cy), r * 0.5, paint);
    canvas.drawCircle(Offset(cx, cy), r * 0.75, paint);
    canvas.drawCircle(Offset(cx, cy), r, paint);

    // Orbiting dots
    final dotPaint = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 3; i++) {
      final a = angle + (i * 2 * math.pi / 3);
      final dx = cx + r * 0.75 * math.cos(a);
      final dy = cy + r * 0.75 * math.sin(a);
      canvas.drawCircle(Offset(dx, dy), 3.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_OrbitPainter old) =>
      old.angle != angle || old.color != color;
}

// ─── Data model ───────────────────────────────────────────────────────────
class _OnboardingPage {
  final String emoji;
  final String title;
  final String subtitle;
  final String description;
  final Color color;
  final Color bgColor;

  const _OnboardingPage({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.color,
    required this.bgColor,
  });
}
