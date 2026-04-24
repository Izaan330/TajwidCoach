import 'package:flutter/material.dart';
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

    // Calculate daily surah based on day of year
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final dailySurah = surahs.isNotEmpty ? surahs[dayOfYear % surahs.length] : null;

    return Scaffold(
      backgroundColor: AppTheme.backgroundCream,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            backgroundColor: AppTheme.cardWhite,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.settings_rounded, color: AppTheme.textPrimary),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
              tooltip: 'Settings',
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Assalamu Alaikum 🌙',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  user?.name ?? 'Student',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            actions: [
              // Streak badge in app bar
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accentAmber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 4),
                    Text(
                      '${streak.currentStreak}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.accentAmberDark,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Daily Challenge Card
                  if (dailySurah != null)
                    _DailyChallengeCard(
                      surah: dailySurah,
                      onTap: () async {
                        // Always use Indo-Pak for daily challenge as requested
                        final settings = context.read<SettingsProvider>();
                        await settings.setQuranScript(QuranScript.indoPak);
                        
                        if (context.mounted) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => SurahDetailScreen(surah: dailySurah),
                            ),
                          );
                        }
                      },
                    ),
                  const SizedBox(height: 20),
                  
                  // Last Read / Resume Card
                  if (quran.lastRead != null) ...[
                    _ResumeReadingCard(lastRead: quran.lastRead!),
                    const SizedBox(height: 20),
                  ],

                  // Streak Section
                  _buildSectionHeader(
                    context,
                    '🔥 Your Streak',
                    'View All',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ProgressScreen()),
                      );
                    },
                  ),

                  const SizedBox(height: 12),
                  _StreakCard(streak: streak),
                  const SizedBox(height: 20),

                  // Weak Rules
                  if (user?.weakRules.isNotEmpty == true) ...[
                    _buildSectionHeader(
                      context,
                      '🎯 Focus Areas',
                      'Practice Now',
                      null,
                    ),
                    const SizedBox(height: 12),
                    _WeakRulesCard(weakRules: user!.weakRules),
                    const SizedBox(height: 20),
                  ],

                  // Premium Upsell
                  if (!(user?.isPremium ?? false))
                    _PremiumBanner(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const StoreScreen(),
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    String action,
    VoidCallback? onActionTap,
  ) {
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
            child: Text(action)
          ),
      ],
    );
  }
}

class _DailyChallengeCard extends StatelessWidget {
  final VoidCallback onTap;
  final SurahModel surah;
  const _DailyChallengeCard({required this.onTap, required this.surah});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppTheme.greenGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryGreen.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '⚡ Daily Challenge',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    surah.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '${surah.arabicName} • ${surah.ayahCount} Ayahs',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '🎤 Practice Now',
                      style: TextStyle(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            const Text('📖', style: TextStyle(fontSize: 64)),
          ],
        ),
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  final StreakProvider streak;
  const _StreakCard({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          if (streak.isFreezeActiveToday)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.ac_unit_rounded, color: Colors.blue, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'STREAK FREEZE ACTIVE',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StreakStat('Current', '${streak.currentStreak}', '🔥'),
              _divider(),
              _StreakStat('Best', '${streak.longestStreak}', '🏆'),
              _divider(),
              _StreakStat('Freezes', '${streak.streakFreezes}', '❄️'),
              _divider(),
              _StreakStat('Badges', '${streak.earnedBadges.length}', '🎖️'),
            ],
          ),
          if ((streak.isStreakInDanger || streak.isStreakRestorable) && !streak.isFreezeActiveToday && streak.streakFreezes > 0)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => streak.useFreeze(),
                  icon: const Icon(Icons.ac_unit_rounded),
                  label: Text(streak.isStreakRestorable ? 'RESTORE STREAK' : 'ACTIVATE STREAK FREEZE'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: streak.isStreakRestorable ? Colors.orange : Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _divider() => Container(width: 1, height: 40, color: AppTheme.divider);
}

class _StreakStat extends StatelessWidget {
  final String label;
  final String value;
  final String emoji;
  const _StreakStat(this.label, this.value, this.emoji);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}

class _WeakRulesCard extends StatelessWidget {
  final List<String> weakRules;
  const _WeakRulesCard({required this.weakRules});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.qalqalahRedBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.qalqalahRed.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AI detected rules needing practice:',
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: weakRules
                .map(
                  (rule) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.qalqalahRed,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      rule,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _PremiumBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _PremiumBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppTheme.premiumGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Text('👑', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upgrade to Premium',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Full Quran + 15 Qaris + AI + Sheikh access',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                '₹199/yr',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.accentAmberDark,
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

class _ResumeReadingCard extends StatelessWidget {
  final LastReadModel lastRead;

  const _ResumeReadingCard({required this.lastRead});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final quranProvider = context.read<QuranProvider>();
        final settings = context.read<SettingsProvider>();

        // Restore script mode if available
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
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SurahDetailScreen(
                surah: surah,
                initialPage: lastRead.pageNumber,
                initialAyah: lastRead.ayahNumber,
              ),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.menu_book_rounded, color: AppTheme.primaryGreen),
              ),
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
                      letterSpacing: 1.2,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 2),
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
            const Icon(Icons.play_arrow_rounded, color: AppTheme.primaryGreen, size: 28),
          ],
        ),
      ),
    );
  }
}
