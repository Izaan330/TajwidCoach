import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/streak_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/quran_provider.dart';
import '../providers/premium_provider.dart';
import '../models/last_read_model.dart';
import '../models/surah_model.dart';
import 'quran/surah_detail_screen.dart';
import 'store/paywall_screen.dart';
import 'settings/settings_screen.dart';
import 'progress/progress_screen.dart';
import '../services/quran_api_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final streak = context.watch<StreakProvider>();
    final quran = context.watch<QuranProvider>();
    final surahs = quran.surahs;

    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final dailySurah =
        surahs.isNotEmpty ? surahs[dayOfYear % surahs.length] : null;

    final isPremium = context.watch<PremiumProvider>().isPremium;

    return Scaffold(
      backgroundColor: AppTheme.backgroundMid,
      body: CustomScrollView(
        slivers: [
          // ─── Collapsible Hero App Bar ────────────────────────────────────
          SliverAppBar(
            expandedHeight: 170,
            floating: true,
            pinned: true,
            snap: false,
            backgroundColor: AppTheme.backgroundMid,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: AppTheme.glassmorphicDecoration(
                  borderRadius: 10,
                  opacity: 0.15,
                ),
                child: const Icon(Icons.settings_rounded,
                    color: AppTheme.textPrimary, size: 20),
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
            actions: [
              // Streak badge
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProgressScreen()),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3D2000), Color(0xFF1A0D00)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.accentAmber.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_fire_department_rounded, color: AppTheme.accentAmber, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        '${streak.currentStreak}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppTheme.accentAmber,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF0D1628),
                      Color(0xFF0A1E14),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 70, 20, 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              'Assalamualaikum ${user?.isSheikh == true ? 'Sheikh ${user?.name}' : (user?.name ?? 'Izaan')}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.dark_mode_rounded, color: AppTheme.accentAmber, size: 20),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─── Main Content ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Daily Challenge
                  if (dailySurah != null)
                    _DailyChallengeCard(
                      surah: dailySurah,
                      onTap: () async {
                        HapticFeedback.mediumImpact();
                        final settings = context.read<SettingsProvider>();
                        await settings.setQuranScript(QuranScript.indoPak);
                        if (context.mounted) {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) =>
                                SurahDetailScreen(surah: dailySurah),
                          ));
                        }
                      },
                    ),
                  const SizedBox(height: 20),

                  // Verse of the Day
                  if (quran.verseOfTheDay != null)
                    _VerseOfTheDayCard(ayah: quran.verseOfTheDay!),
                  const SizedBox(height: 20),

                  // Resume Reading
                  if (quran.lastRead != null) ...[
                    _ResumeReadingCard(lastRead: quran.lastRead!),
                    const SizedBox(height: 20),
                  ],

                  // Streak Section
                  _SectionHeader(
                    title: 'Your Streak',
                    icon: Icons.local_fire_department_rounded,
                    iconColor: AppTheme.accentAmber,
                    action: 'View All',
                    onActionTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProgressScreen()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _StreakCard(streak: streak),
                  const SizedBox(height: 20),

                  // Weak Rules
                  if (user?.weakRules.isNotEmpty == true) ...[
                    const _SectionHeader(
                      title: 'Focus Areas',
                      icon: Icons.my_location_rounded,
                      iconColor: AppTheme.qalqalahRed,
                      action: 'Practice Now',
                    ),
                    const SizedBox(height: 12),
                    _WeakRulesCard(weakRules: user!.weakRules),
                    const SizedBox(height: 20),
                  ],

                  // Premium Upsell
                  if (!isPremium)
                    _PremiumBanner(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const PaywallScreen()),
                        );
                      },
                    ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Header
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color? iconColor;
  final String action;
  final VoidCallback? onActionTap;

  const _SectionHeader({
    required this.title,
    this.icon,
    this.iconColor,
    this.action = '',
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: iconColor ?? AppTheme.textPrimary, size: 24),
              const SizedBox(width: 8),
            ],
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        if (action.isNotEmpty)
          TextButton(
            onPressed: onActionTap ?? () {},
            child: Text(action),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Daily Challenge Card  (animated glow)
// ─────────────────────────────────────────────────────────────────────────────
class _DailyChallengeCard extends StatefulWidget {
  final VoidCallback onTap;
  final SurahModel surah;
  const _DailyChallengeCard({required this.onTap, required this.surah});

  @override
  State<_DailyChallengeCard> createState() => _DailyChallengeCardState();
}

class _DailyChallengeCardState extends State<_DailyChallengeCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          final glowAlpha = 0.25 + 0.2 * _glowController.value;
          return Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF004D2C), Color(0xFF00251A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppTheme.primaryGreen.withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGreen.withValues(alpha: glowAlpha),
                  blurRadius: 30,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: child,
          );
        },
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bolt_rounded, color: AppTheme.primaryGreen, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Daily Challenge',
                          style: TextStyle(
                            color: AppTheme.primaryGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    widget.surah.name,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    '${widget.surah.arabicName} • ${widget.surah.ayahCount} Ayahs',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: AppTheme.greenGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color:
                              AppTheme.primaryGreen.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.mic_rounded, color: Colors.black, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Practice Now',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            const _PulsingBookIcon(controller: null),
          ],
        ),
      ),
    );
  }
}

class _PulsingBookIcon extends StatelessWidget {
  final AnimationController? controller;
  const _PulsingBookIcon({this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withValues(alpha: 0.08),
        shape: BoxShape.circle,
        border: Border.all(
            color: AppTheme.primaryGreen.withValues(alpha: 0.15)),
      ),
      child: const Center(
        child: Icon(Icons.auto_stories_rounded, color: AppTheme.primaryGreen, size: 36),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Streak Card
// ─────────────────────────────────────────────────────────────────────────────
class _StreakCard extends StatelessWidget {
  final StreakProvider streak;
  const _StreakCard({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Freeze badge
          if (streak.isFreezeActiveToday)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF001F3C),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppTheme.info.withValues(alpha: 0.4)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.ac_unit_rounded,
                      color: AppTheme.info, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'STREAK FREEZE ACTIVE',
                    style: TextStyle(
                      color: AppTheme.info,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StreakStat('Current', '${streak.currentStreak}', Icons.local_fire_department_rounded,
                  AppTheme.accentAmber),
              _vDivider(),
              _StreakStat('Best', '${streak.longestStreak}', Icons.emoji_events_rounded,
                  AppTheme.premiumGold),
              _vDivider(),
              _StreakStat('Freezes', '${streak.streakFreezes}', Icons.ac_unit_rounded,
                  AppTheme.info),
              _vDivider(),
              _StreakStat('Badges', '${streak.earnedBadges.length}', Icons.military_tech_rounded,
                  AppTheme.primaryGreen),
            ],
          ),

          // Freeze CTA
          if ((streak.isStreakInDanger || streak.isStreakRestorable) &&
              !streak.isFreezeActiveToday &&
              streak.streakFreezes > 0)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    streak.useFreeze();
                  },
                  icon: const Icon(Icons.ac_unit_rounded, size: 18),
                  label: Text(streak.isStreakRestorable
                      ? 'RESTORE STREAK'
                      : 'ACTIVATE FREEZE'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: streak.isStreakRestorable
                        ? AppTheme.warning
                        : AppTheme.info,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
          
          if (streak.streakFreezes <= 0)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PaywallScreen()),
                    );
                  },
                  icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                  label: const Text('GET MORE FREEZES'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.info,
                    side: const BorderSide(color: AppTheme.info),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _vDivider() => Container(
        width: 1,
        height: 44,
        color: AppTheme.divider,
      );
}

class _StreakStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StreakStat(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
              fontSize: 11, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Weak Rules Card
// ─────────────────────────────────────────────────────────────────────────────
class _WeakRulesCard extends StatelessWidget {
  final List<String> weakRules;
  const _WeakRulesCard({required this.weakRules});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.qalqalahRedBg,
        borderRadius: BorderRadius.circular(18),
        border:
            Border.all(color: AppTheme.qalqalahRed.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AI detected rules needing practice:',
            style: TextStyle(
                fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: weakRules
                .map((rule) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppTheme.qalqalahRed.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color:
                                AppTheme.qalqalahRed.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        rule,
                        style: const TextStyle(
                          color: AppTheme.qalqalahRed,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium Banner
// ─────────────────────────────────────────────────────────────────────────────
class _PremiumBanner extends StatefulWidget {
  final VoidCallback onTap;
  const _PremiumBanner({required this.onTap});

  @override
  State<_PremiumBanner> createState() => _PremiumBannerState();
}

class _PremiumBannerState extends State<_PremiumBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _shimmerController,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: const [
                  Color(0xFF3D2000),
                  Color(0xFF7A4300),
                  Color(0xFF3D2000),
                ],
                stops: [
                  0.0,
                  _shimmerController.value.clamp(0.2, 0.8),
                  1.0,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppTheme.premiumGold.withValues(alpha: 0.4)),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.premiumGold.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: child,
          );
        },
        child: Row(
          children: [
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppTheme.goldAccentGradient.createShader(bounds),
              child: const Icon(Icons.workspace_premium_rounded,
                  size: 42, color: Colors.white),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upgrade to Premium',
                    style: TextStyle(
                      color: AppTheme.premiumGold,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'AI Coach + 15 Qaris + Offline + Ad-Free',
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppTheme.goldAccentGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '₹199/yr',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Resume Reading Card
// ─────────────────────────────────────────────────────────────────────────────
class _ResumeReadingCard extends StatelessWidget {
  final LastReadModel lastRead;
  const _ResumeReadingCard({required this.lastRead});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact();
        final quranProvider = context.read<QuranProvider>();
        final settings = context.read<SettingsProvider>();

        if (lastRead.scriptMode != null) {
          final mode = QuranScript.values.firstWhere(
            (m) => m.name == lastRead.scriptMode,
            orElse: () => QuranScript.mushaf,
          );
          await settings.setQuranScript(mode);
        }

        final surah = quranProvider.surahs.firstWhere(
          (s) => s.number == lastRead.surahNumber,
          orElse: () => quranProvider.surahs.first,
        );

        if (context.mounted) {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => SurahDetailScreen(
              surah: surah,
              initialPage: lastRead.pageNumber,
              initialAyah: lastRead.ayahNumber,
            ),
          ));
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.backgroundSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: AppTheme.primaryGreen.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryGreen.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: AppTheme.emeraldGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.menu_book_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'RESUME READING',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    lastRead.surahName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow_rounded,
                  color: AppTheme.primaryGreen, size: 22),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Verse of the Day Card
// ─────────────────────────────────────────────────────────────────────────────
class _VerseOfTheDayCard extends StatefulWidget {
  final AyahModel ayah;
  const _VerseOfTheDayCard({required this.ayah});

  @override
  State<_VerseOfTheDayCard> createState() => _VerseOfTheDayCardState();
}

class _VerseOfTheDayCardState extends State<_VerseOfTheDayCard> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _toggleAudio() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() => _isPlaying = false);
    } else {
      final url = QuranApiService.getAudioUrl('ar.alafasy', widget.ayah.globalNumber);
      try {
        await _audioPlayer.setUrl(url);
        setState(() => _isPlaying = true);
        _audioPlayer.play();
        _audioPlayer.playerStateStream.listen((state) {
          if (state.processingState == ProcessingState.completed) {
            if (mounted) setState(() => _isPlaying = false);
          }
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not play audio')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final quran = context.read<QuranProvider>();
    final surah = quran.surahs.firstWhere((s) => s.number == widget.ayah.surahNumber);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D1F3C), Color(0xFF080E1A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.info.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Pattern (Geometric)
          const Positioned(
            right: -20,
            top: -20,
            child: Opacity(
              opacity: 0.05,
              child: Icon(Icons.mosque_rounded, size: 150, color: AppTheme.info),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.info.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.auto_awesome, color: AppTheme.info, size: 14),
                          SizedBox(width: 6),
                          Text(
                            'VERSE OF THE DAY',
                            style: TextStyle(
                              color: AppTheme.info,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _toggleAudio,
                      icon: Icon(
                        _isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded,
                        color: AppTheme.info,
                        size: 32,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Arabic Text
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    widget.ayah.arabicText,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontFamily: 'AmiriQuran',
                      fontSize: 22,
                      height: 1.8,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Translation
                Text(
                  widget.ayah.translationText,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${surah.name} • ${widget.ayah.ayahNumber}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.info,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => SurahDetailScreen(
                            surah: surah,
                            initialAyah: widget.ayah.ayahNumber,
                          ),
                        ));
                      },
                      icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                      label: const Text('Read Full Surah'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.info,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


