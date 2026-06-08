import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Fade in very quickly to ensure it's never 'dim' for too long
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );
    _scaleIn = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );
    _slideUp = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
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
                    // --- PREMIUM LOGO CONTAINER ---
                    Transform.scale(
                      scale: _scaleIn.value,
                      child: Opacity(
                        opacity: _fadeIn.value,
                        child: Container(
                          width: 160.w,
                          height: 160.w,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                Colors.white.withAlpha(40),
                                Colors.white.withAlpha(10),
                              ],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFFFD700).withAlpha(100),
                              width: 2.w,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFD700).withAlpha(60),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                              BoxShadow(
                                color: Colors.black.withAlpha(100),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Center(
                            child: ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [Color(0xFFFFD700), Color(0xFFFFF8E1)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ).createShader(bounds),
                              child: Icon(
                                Icons.auto_stories_rounded,
                                size: 90.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 56.h),
                    // --- TEXT ELEMENTS ---
                    Transform.translate(
                      offset: Offset(0, _slideUp.value),
                      child: Opacity(
                        opacity: _fadeIn.value,
                        child: Column(
                          children: [
                            Text(
                              'Quran Pro',
                              style: GoogleFonts.outfit(
                                fontSize: 52.sp,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -1.0,
                                shadows: [
                                  const Shadow(
                                    color: Colors.black45,
                                    offset: Offset(0, 4),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'PERFECT YOUR RECITATION',
                              style: GoogleFonts.outfit(
                                fontSize: 12.sp,
                                letterSpacing: 4.0,
                                color: Colors.white, // Changed to pure white for maximum readability
                                fontWeight: FontWeight.w700, // Increased font weight
                              ),
                            ),
                            SizedBox(height: 40.h),
                            Text(
                              'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                              style: TextStyle(
                                fontSize: 28.sp,
                                color: const Color(0xFFFFD700),
                                fontFamily: 'AmiriQuran',
                                fontWeight: FontWeight.w500,
                                shadows: const [
                                  Shadow(
                                    color: Colors.black45, // Darker shadow for better contrast against green
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 72.h),
                    // --- STREAK BADGE ---
                    if (streak > 0)
                      Transform.translate(
                        offset: Offset(0, _slideUp.value + 20),
                        child: Opacity(
                          opacity: _fadeIn.value,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 28, vertical: 14),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(40),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black38,
                                  blurRadius: 20,
                                  offset: Offset(0, 8),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.white12,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.local_fire_department_rounded,
                                    color: AppTheme.accentAmber, size: 28),
                                const SizedBox(width: 12),
                                Text(
                                  '$streak-DAY STREAK!',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    letterSpacing: 1.2,
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
          // --- FOOTER ---
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 0.6,
              child: Center(
                child: Text(
                  'MADE WITH SPIRITUAL CARE',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    letterSpacing: 2.5,
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
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [
            Color(0xFF004D40), // Emerald
            Color(0xFF00251A), // Dark Forest
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
      ..color = Colors.white.withAlpha(15) // Even more subtle
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    const spacing = 120.0; // Larger spacing for cleaner look
    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        _drawEightPointStar(canvas, Offset(x, y), 30, paint);
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
      icon: Icons.mic_rounded,
      title: 'Assalamu Alaikum!',
      subtitle: 'Welcome to Quran Pro',
      description:
          'Your AI-powered companion for perfecting Quran recitation. Our system detects 25+ Tajwid rules in real-time.',
      color: AppTheme.primaryGreen,
      bgColor: Color(0xFF002416),
    ),
    _OnboardingPage(
      icon: Icons.local_fire_department_rounded,
      title: 'Build Your Streak',
      subtitle: 'Practice Every Day',
      description:
          'Earn badges for consistent practice. 7-day flame, 30-day star, 100-day mosque, 365-day crown. Don\'t break your streak!',
      color: AppTheme.accentAmber,
      bgColor: Color(0xFF1C0E00),
    ),
    _OnboardingPage(
      icon: Icons.school_rounded,
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
              child: Icon(
                page.icon,
                size: 70,
                color: page.color,
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
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final Color color;
  final Color bgColor;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.color,
    required this.bgColor,
  });
}
