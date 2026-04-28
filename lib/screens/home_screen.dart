import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/streak_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/quran_provider.dart';
import '../models/last_read_model.dart';
import '../models/surah_model.dart';
import 'quran/surah_detail_screen.dart';
import 'store/store_screen.dart';
import 'settings/settings_screen.dart';
import 'progress/progress_screen.dart';

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

    return Scaffold(
      backgroundColor: AppTheme.backgroundMid,
      body: CustomScrollView(
        slivers: [
          // ─── Collapsible Hero App Bar ────────────────────────────────────
          SliverAppBar(
            expandedHeight: 140,
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
                      const Text('🔥', style: TextStyle(fontSize: 16)),
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
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Assalamu Alaikum 🌙',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.name ?? 'Student',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.5,
                        ),
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

                  // Resume Reading
                  if (quran.lastRead != null) ...[
                    _ResumeReadingCard(lastRead: quran.lastRead!),
                    const SizedBox(height: 20),
                  ],

                  // Streak Section
                  _SectionHeader(
                    title: '🔥 Your Streak',
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
                      title: '🎯 Focus Areas',
                      action: 'Practice Now',
                    ),
                    const SizedBox(height: 12),
                    _WeakRulesCard(weakRules: user!.weakRules),
                    const SizedBox(height: 20),
                  ],

                  // Premium Upsell
                  if (!(user?.isPremium ?? false))
                    _PremiumBanner(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const StoreScreen()),
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
  final String action;
  final VoidCallback? onActionTap;

  const _SectionHeader({
    required this.title,
    this.action = '',
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
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
                    child: const Text(
                      '⚡ Daily Challenge',
                      style: TextStyle(
                        color: AppTheme.primaryGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
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
                    child: const Text(
                      '🎤 Practice Now',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
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
        child: Text('📖', style: TextStyle(fontSize: 40)),
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
              _StreakStat('Current', '${streak.currentStreak}', '🔥',
                  AppTheme.accentAmber),
              _vDivider(),
              _StreakStat('Best', '${streak.longestStreak}', '🏆',
                  AppTheme.premiumGold),
              _vDivider(),
              _StreakStat('Freezes', '${streak.streakFreezes}', '❄️',
                  AppTheme.info),
              _vDivider(),
              _StreakStat('Badges', '${streak.earnedBadges.length}', '🎖️',
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
  final String emoji;
  final Color color;
  const _StreakStat(this.label, this.value, this.emoji, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
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
              child: const Text('👑',
                  style: TextStyle(fontSize: 34, color: Colors.white)),
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
                    'Full Quran + 15 Qaris + AI + Sheikh access',
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


