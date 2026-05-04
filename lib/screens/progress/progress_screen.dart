import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/streak_provider.dart';
import '../../services/streak_service.dart';
import '../../utils/tajwid_rules_data.dart';
import '../../providers/tajwid_progress_provider.dart';
import '../practice/practice_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/tajwid_rule_model.dart';
import 'video_player_screen.dart';
import '../../services/islamic_calendar_service.dart';
import '../../providers/premium_provider.dart';
import '../store/paywall_screen.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final streak = context.watch<StreakProvider>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundCream,
      appBar: AppBar(
        title: const Text('Deen Hub'),
        bottom: _DeenHubTabBar(tabController: _tabController),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _StreakTab(streak: streak),
          const _TajwidTab(),
          _BadgesTab(earnedBadges: streak.earnedBadges),
          const _TasbihTab(),
          const _DuasTab(),
          const _EventsTab(),
        ],
      ),
    );
  }
}

// --- CUSTOM TABBAR WITH SCROLL HINTS ---
class _DeenHubTabBar extends StatefulWidget implements PreferredSizeWidget {
  final TabController tabController;
  const _DeenHubTabBar({required this.tabController});

  @override
  State<_DeenHubTabBar> createState() => _DeenHubTabBarState();

  @override
  Size get preferredSize => const Size.fromHeight(48);
}

class _DeenHubTabBarState extends State<_DeenHubTabBar> {
  bool _showLeftFade = false;
  bool _showRightFade = true;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          setState(() {
            _showLeftFade = notification.metrics.pixels > 5;
            _showRightFade = notification.metrics.pixels <
                notification.metrics.maxScrollExtent - 5;
          });
        }
        return false;
      },
      child: Stack(
        children: [
          TabBar(
            controller: widget.tabController,
            isScrollable: true,
            labelColor: AppTheme.primaryGreen,
            unselectedLabelColor: AppTheme.textHint,
            indicatorColor: AppTheme.primaryGreen,
            tabAlignment: TabAlignment.start,
            dividerColor: Colors.transparent,
            labelStyle: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            unselectedLabelStyle: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            tabs: const [
              Tab(text: 'Streak'),
              Tab(text: 'Tajwid'),
              Tab(text: 'Badges'),
              Tab(text: 'Tasbih'),
              Tab(text: 'Duas'),
              Tab(text: 'Events'),
            ],
          ),
          // Left edge fade
          if (_showLeftFade)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 30,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        AppTheme.backgroundCream.withValues(alpha: 0.0),
                        AppTheme.backgroundCream,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          // Right edge fade
          if (_showRightFade)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 50,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        AppTheme.backgroundCream.withValues(alpha: 0.0),
                        AppTheme.backgroundCream,
                      ],
                    ),
                  ),
                  child: const Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: Icon(Icons.chevron_right_rounded,
                          color: AppTheme.primaryGreen, size: 20),
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

// --- STREAK TAB ---
class _StreakTab extends StatelessWidget {
  final StreakProvider streak;
  const _StreakTab({required this.streak});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Premium Streak Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF00BFA5),
                  Color(0xFF00796B),
                  Color(0xFF004D40)
                ],
                stops: [0.0, 0.5, 1.0],
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF004D40).withValues(alpha: 0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.1),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.local_fire_department_rounded, color: AppTheme.accentAmber, size: 54),
                ),
                const SizedBox(height: 20),
                Text(
                  '${streak.currentStreak}',
                  style: GoogleFonts.outfit(
                    fontSize: 84,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1,
                    letterSpacing: -4,
                  ),
                ),
                Text(
                  'DAY STREAK',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatItem(
                          'BEST',
                          '${streak.longestStreak}D',
                          Icons.emoji_events_rounded,
                        ),
                      ),
                      Container(
                          width: 1.5,
                          height: 40,
                          color: Colors.white.withValues(alpha: 0.1)),
                      Expanded(
                        child: _StatItem(
                          'FREEZES',
                          '${streak.streakFreezes}',
                          Icons.ac_unit_rounded,
                        ),
                      ),
                      Container(
                          width: 1.5,
                          height: 40,
                          color: Colors.white.withValues(alpha: 0.1)),
                      Expanded(
                        child: _StatItem(
                          'BADGES',
                          '${streak.earnedBadges.length}/${StreakService.allBadges.length}',
                          Icons.workspace_premium_rounded,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Status message
          if (streak.isStreakInDanger)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: AppTheme.warning.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.warning.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: AppTheme.warning,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      "Don't break your ${streak.currentStreak}-day streak! Practice today to keep it going!",
                      style: GoogleFonts.plusJakartaSans(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (streak.hasStreakToday)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.ikhfaGreenBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: AppTheme.ikhfaGreen, size: 24),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "You've practiced today! Great job!",
                      style: TextStyle(
                        color: AppTheme.ikhfaGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),

          // Heatmap Calendar
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Practice Calendar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 12),
          _StreakHeatmap(
            heatmapData: streak.heatmapData,
            isPremium: context.watch<PremiumProvider>().isPremium,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatItem(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFFFD700), size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.white.withAlpha(150),
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class _StreakHeatmap extends StatefulWidget {
  final Map<String, int> heatmapData;
  final bool isPremium;
  const _StreakHeatmap({required this.heatmapData, this.isPremium = false});

  @override
  State<_StreakHeatmap> createState() => _StreakHeatmapState();
}

class _StreakHeatmapState extends State<_StreakHeatmap> {
  final ScrollController _scrollController = ScrollController();
  final List<double> _monthWidths = [];
  final double _gapWidth = 16.0;
  final double _columnWidth = 18.0; // 14px + 2*2px margin

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _scrollToCurrentMonth());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentMonth() {
    if (!_scrollController.hasClients || _monthWidths.isEmpty) return;

    final screenWidth = MediaQuery.of(context).size.width -
        48; // Scaffold padding + Card padding
    double targetOffset = 0;

    // We want to center the LAST month (current month)
    // targetOffset = (Total Width - MonthWidths.last) - (screenWidth / 2) + (MonthWidths.last / 2)

    double totalWidth = 0;
    for (int i = 0; i < _monthWidths.length - 1; i++) {
      totalWidth += _monthWidths[i] + _gapWidth;
    }

    final lastMonthWidth = _monthWidths.last;
    targetOffset = totalWidth + (lastMonthWidth / 2) - (screenWidth / 2);

    if (targetOffset < 0) targetOffset = 0;
    if (targetOffset > _scrollController.position.maxScrollExtent) {
      targetOffset = _scrollController.position.maxScrollExtent;
    }

    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutQuart,
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final List<DateTime> monthsToShow = [];
    final int monthsCount = widget.isPremium ? 6 : 1;
    for (int i = monthsCount - 1; i >= 0; i--) {
      monthsToShow.add(DateTime(now.year, now.month - i, 1));
    }

    _monthWidths.clear();
    final monthBlocks = <Widget>[];

    for (int i = 0; i < monthsToShow.length; i++) {
      final monthStart = monthsToShow[i];
      final (columns, width) = _buildMonthColumns(monthStart, today);

      _monthWidths.add(width);

      monthBlocks.add(_buildMonthBlock(monthStart, columns));
      if (i < monthsToShow.length - 1) {
        monthBlocks.add(SizedBox(width: _gapWidth));
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PRACTICE HISTORY',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryGreen,
                  letterSpacing: 1.2,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'ACTIVE',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: monthBlocks,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Text('Less',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textHint)),
              const SizedBox(width: 10),
              _legendBox(const Color(0xFFF1F3F4)),
              _legendBox(const Color(0xFFA7FFEB)),
              _legendBox(const Color(0xFF1DE9B6)),
              _legendBox(const Color(0xFF00BFA5)),
              const SizedBox(width: 10),
              Text('More',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textHint)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundCream,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 12, color: AppTheme.primaryGreen),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.heatmapData.length} days active',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!widget.isPremium)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PaywallScreen()),
                ),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.premiumGold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.premiumGold.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.workspace_premium_rounded, color: AppTheme.premiumGold, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Unlock full 6-month practice history with Premium',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.premiumGold,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppTheme.premiumGold, size: 18),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  (List<Widget>, double) _buildMonthColumns(
      DateTime monthStart, DateTime today) {
    final firstDayOfMonth = DateTime(monthStart.year, monthStart.month, 1);
    final lastDayOfMonth = DateTime(monthStart.year, monthStart.month + 1, 0);

    // Start of week padding (Sunday = 0 for our calc)
    // DateTime.weekday: Mon=1, ..., Sun=7
    final startPadding = firstDayOfMonth.weekday % 7;

    final daysInMonth = lastDayOfMonth.day;
    final totalSlots = ((startPadding + daysInMonth + 6) ~/ 7) * 7;

    final List<Widget> columns = [];
    List<Widget> currentColumnCells = [];

    for (int i = 0; i < totalSlots; i++) {
      final dayIndex = i - startPadding;
      if (dayIndex < 0 || dayIndex >= daysInMonth) {
        currentColumnCells.add(_cell(Colors.transparent));
      } else {
        final date = DateTime(monthStart.year, monthStart.month, dayIndex + 1);
        if (date.isAfter(today)) {
          currentColumnCells.add(_cell(Colors.transparent));
        } else {
          final key =
              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          final minutes = widget.heatmapData[key] ?? 0;

          Color cellColor;
          if (minutes == 0) {
            cellColor = const Color(0xFFF1F3F4);
          } else if (minutes < 5) {
            cellColor = const Color(0xFFA7FFEB);
          } else if (minutes < 15) {
            cellColor = const Color(0xFF1DE9B6);
          } else {
            cellColor = const Color(0xFF00BFA5);
          }
          currentColumnCells.add(_cell(cellColor));
        }
      }

      if (currentColumnCells.length == 7) {
        columns.add(Column(children: currentColumnCells));
        currentColumnCells = [];
      }
    }

    final width = columns.length * _columnWidth;
    return (columns, width);
  }

  Widget _buildMonthBlock(DateTime monthStart, List<Widget> columns) {
    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          monthNames[monthStart.month - 1].toUpperCase(),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: AppTheme.textHint,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: columns,
        ),
      ],
    );
  }

  Widget _cell(Color c) => Container(
        width: 14,
        height: 14,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: c,
          borderRadius: BorderRadius.circular(5),
          boxShadow: c == Colors.transparent || c == const Color(0xFFF1F3F4)
              ? null
              : [
                  BoxShadow(
                    color: c.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
      );

  Widget _legendBox(Color c) => Container(
        width: 14,
        height: 14,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: c,
          borderRadius: BorderRadius.circular(4),
        ),
      );
}

// --- TAJWID TAB ---
class _TajwidTab extends StatelessWidget {
  const _TajwidTab();

  @override
  Widget build(BuildContext context) {
    final progressProvider = context.watch<TajwidProgressProvider>();
    const rules = TajwidRulesData.rules;

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: rules.length,
      itemBuilder: (context, index) {
        final rule = rules[index];
        final progress = progressProvider.getRuleProgress(rule.id);
        return _MasteryCard(rule: rule, progress: progress);
      },
    );
  }
}

class _MasteryCard extends StatelessWidget {
  final TajwidRule rule;
  final TajwidRuleProgress progress;

  const _MasteryCard({required this.rule, required this.progress});

  @override
  Widget build(BuildContext context) {
    final bgColor =
        Color(int.parse(rule.backgroundHex.replaceFirst('#', '0xFF')));
    final fgColor = Color(int.parse(rule.colorHex.replaceFirst('#', '0xFF')));

    // Level names
    final levelNames = [
      'Unstarted',
      'Novice',
      'Apprentice',
      'Practitioner',
      'Adept',
      'Master'
    ];
    final levelName =
        progress.level <= 5 ? levelNames[progress.level] : 'Expert';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Rule icon/Arabic
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: bgColor.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(8),
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      rule.arabicName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: fgColor,
                        fontFamily: 'AmiriQuran',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                // Rule details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              rule.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: progress.level >= 5
                                  ? AppTheme.primaryGreen.withValues(alpha: 0.1)
                                  : AppTheme.divider.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              levelName.toUpperCase(),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: progress.level >= 5
                                    ? AppTheme.primaryGreen
                                    : AppTheme.textHint,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        rule.category,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Progress bar
                      Stack(
                        children: [
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppTheme.divider.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor:
                                progress.progressToNextLevel.clamp(0.05, 1.0),
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    fgColor.withValues(alpha: 0.7),
                                    fgColor
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: fgColor.withValues(alpha: 0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${(progress.progressToNextLevel * 100).toInt()}% towards Lev. ${progress.level + 1}',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textHint),
                          ),
                          Text(
                            'Lvl ${progress.level}',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: fgColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Action Buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.backgroundCream.withValues(alpha: 0.5),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: () => _showLearnMode(context, rule),
                  icon: const Icon(Icons.menu_book_rounded, size: 18),
                  label: const Text('LEARN'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                    textStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PracticeScreen(targetRuleId: rule.id),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: fgColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'PRACTICE',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLearnMode(BuildContext context, TajwidRule rule) {
    if (rule.videoUrl != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoPlayerScreen(rule: rule),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text(
                  rule.arabicName,
                  style: const TextStyle(
                    fontFamily: 'AmiriQuran',
                    fontSize: 42,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rule.name,
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        rule.category,
                        style: TextStyle(
                            color:
                                AppTheme.textSecondary.withValues(alpha: 0.7)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'What is this rule?',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      rule.description,
                      style: const TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Example Word',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundCream,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          rule.exampleWord,
                          style: const TextStyle(
                            fontFamily: 'AmiriQuran',
                            fontSize: 36,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  'GOT IT',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- BADGES TAB ---
class _BadgesTab extends StatelessWidget {
  final List<String> earnedBadges;
  const _BadgesTab({required this.earnedBadges});

  @override
  Widget build(BuildContext context) {
    final premium = context.watch<PremiumProvider>();
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: StreakService.allBadges.length,
      itemBuilder: (context, index) {
        final badge = StreakService.allBadges[index];
        bool earned = earnedBadges.contains(badge.id);
        
        // Handle premium-only badges
        if (badge.isPremiumOnly) {
          if (badge.id == 'khadim' && premium.isPremium) earned = true;
          if (badge.id == 'family_shield' && premium.tier == PremiumTier.family) earned = true;
        }
        return Container(
          decoration: BoxDecoration(
            color: earned
                ? AppTheme.primaryGreen.withValues(alpha: 0.08)
                : AppTheme.cardWhite,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: earned
                  ? AppTheme.primaryGreen.withValues(alpha: 0.2)
                  : AppTheme.divider.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: earned
                ? [
                    BoxShadow(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ]
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: earned
                        ? Colors.white
                        : AppTheme.divider.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        badge.icon,
                        size: 40,
                        color: earned
                            ? AppTheme.accentAmber
                            : Colors.grey.withValues(alpha: 0.3),
                      ),
                      if (!earned)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.8),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.lock_rounded,
                              size: 16, color: AppTheme.textHint),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  badge.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: earned ? AppTheme.textPrimary : AppTheme.textHint,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: earned
                        ? AppTheme.primaryGreen.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${badge.requiredDays} DAYS',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      color: earned ? AppTheme.primaryGreen : AppTheme.textHint,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: Text(
                    badge.description,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9.5,
                      color: AppTheme.textSecondary.withValues(alpha: 0.6),
                      height: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// --- TASBIH TAB ---
class _TasbihTab extends StatefulWidget {
  const _TasbihTab();

  @override
  State<_TasbihTab> createState() => _TasbihTabState();
}

class _TasbihTabState extends State<_TasbihTab> {
  int _count = 0;
  int _target = 33;

  void _increment() {
    if (_count >= _target) {
      HapticFeedback.vibrate();
      return;
    }
    HapticFeedback.lightImpact();
    setState(() {
      _count++;
      if (_count == _target) {
        HapticFeedback.heavyImpact();
      }
    });
  }

  void _reset() {
    HapticFeedback.mediumImpact();
    setState(() {
      _count = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.backgroundSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.divider),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _target,
                  dropdownColor: AppTheme.backgroundSurface,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.primaryGreen),
                  style: GoogleFonts.plusJakartaSans(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                  items: [33, 99, 1000].map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text('Target: ${value == 1000 ? 'Infinity' : value}'),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _target = newValue;
                        _count = 0;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 40),
          GestureDetector(
            onTap: _increment,
            child: Column(
              children: [
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.primaryGreen.withValues(alpha: 0.2),
                        AppTheme.primaryGreen.withValues(alpha: 0.05),
                      ],
                    ),
                    border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.5), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.2),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$_count',
                      style: GoogleFonts.outfit(
                        fontSize: 80,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ),
                ),
                if (_count == _target)
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'GOAL REACHED!',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          IconButton(
            onPressed: _reset,
            icon: const Icon(Icons.refresh_rounded),
            iconSize: 40,
            color: AppTheme.textHint,
            tooltip: 'Reset',
          ),
        ],
      ),
    ),
    );
  }
}

// --- DUAS TAB ---
class _DuasTab extends StatelessWidget {
  const _DuasTab();

  @override
  Widget build(BuildContext context) {
    final duas = [
      {
        'title': 'Waking Up',
        'arabic': 'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
        'translation': 'All praise is for Allah who gave us life after having taken it from us and unto Him is the resurrection.',
      },
      {
        'title': 'Before Sleeping',
        'arabic': 'بِاسْمِكَ رَبِّي وَضَعْتُ جَنْبِي، وَبِكَ أَرْفَعُهُ',
        'translation': 'In Your name my Lord, I lie down and in Your name I rise.',
      },
      {
        'title': 'Before Eating',
        'arabic': 'بِسْمِ اللَّهِ',
        'translation': 'In the name of Allah.',
      },
      {
        'title': 'After Eating',
        'arabic': 'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا وَجَعَلَنَا مُسْلِمِينَ',
        'translation': 'Praise be to Allah Who has fed us and given us drink, and made us Muslims.',
      },
      {
        'title': 'Entering Home',
        'arabic': 'بِسْمِ اللَّهِ وَلَجْنَا، وَبِسْمِ اللَّهِ خَرَجْنَا، وَعَلَى رَبِّنَا تَوَكَّلْنَا',
        'translation': 'In the name of Allah we enter, in the name of Allah we leave, and upon our Lord we rely.',
      },
      {
        'title': 'Leaving Home',
        'arabic': 'بِسْمِ اللَّهِ تَوَكَّلْتُ عَلَى اللَّهِ، وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
        'translation': 'In the name of Allah, I place my trust in Allah, and there is no might nor power except with Allah.',
      },
      {
        'title': 'Entering Mosque',
        'arabic': 'اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ',
        'translation': 'O Allah, open the doors of Your mercy for me.',
      },
      {
        'title': 'Leaving Mosque',
        'arabic': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ',
        'translation': 'O Allah, I ask You from Your favor.',
      },
      {
        'title': 'For Parents',
        'arabic': 'رَّبِّ ارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا',
        'translation': 'My Lord, have mercy upon them as they brought me up [when I was] small.',
      },
      {
        'title': 'For Knowledge',
        'arabic': 'رَّبِّ زِدْنِي عِلْمًا',
        'translation': 'My Lord, increase me in knowledge.',
      },
      {
        'title': 'When Traveling',
        'arabic': 'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ وَإِنَّا إِلَى رَبِّنَا لَمُنْقَلِبُونَ',
        'translation': 'Glory to Him who has brought this under our control, though we were unable to do it ourselves, and to our Lord we shall return.',
      },
      {
        'title': 'Entering Bathroom',
        'arabic': 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْخُبُثِ وَالْخَبَائِثِ',
        'translation': 'O Allah, I seek protection in You from the male and female shaitan.',
      },
      {
        'title': 'Leaving Bathroom',
        'arabic': 'غُفْرَانَكَ',
        'translation': 'I ask You for forgiveness.',
      },
      {
        'title': 'After Wudu',
        'arabic': 'أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ',
        'translation': 'I bear witness that there is no god but Allah alone, without partner, and I bear witness that Muhammad is His servant and Messenger.',
      },
      {
        'title': 'Hearing Athan',
        'arabic': 'اللَّهُمَّ رَبَّ هَذِهِ الدَّعْوَةِ التَّامَّةِ وَالصَّلَاةِ الْقَائِمَةِ آتِ مُحَمَّدًا الْوَسِيلَةَ وَالْفَضِيلَةَ',
        'translation': 'O Allah, Lord of this perfect call and the prayer to be offered, grant Muhammad the privilege and the excellence.',
      },
      {
        'title': 'Wearing Clothes',
        'arabic': 'الْحَمْدُ لِلَّهِ الَّذِي كَسَانِي هَذَا الثَّوْبَ وَرَزَقَنِيهِ مِنْ غَيْرِ حَوْلٍ مِنِّي وَلَا قُوَّةٍ',
        'translation': 'Praise be to Allah Who has clothed me with this garment and provided it for me without any might or power on my part.',
      },
      {
        'title': 'Looking in the Mirror',
        'arabic': 'اللَّهُمَّ أَنْتَ حَسَّنْتَ خَلْقِي فَحَسِّنْ خُلُقِي',
        'translation': 'O Allah, You have made my physical appearance beautiful, so make my character beautiful.',
      },
      {
        'title': 'For Anxiety and Sorrow',
        'arabic': 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ، وَالْعَجْزِ وَالْكَسَلِ',
        'translation': 'O Allah, I seek refuge in You from anxiety and sorrow, weakness and laziness.',
      },
      {
        'title': 'Seeking Ease',
        'arabic': 'رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي',
        'translation': 'My Lord, expand for me my chest [with assurance] and ease for me my task.',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: duas.length,
      itemBuilder: (context, index) {
        final dua = duas[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.cardWhite,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dua['title']!,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  dua['arabic']!,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontFamily: 'AmiriQuran',
                    fontSize: 24,
                    color: AppTheme.primaryGreen,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                dua['translation']!,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// --- EVENTS TAB ---
class _EventsTab extends StatefulWidget {
  const _EventsTab();

  @override
  State<_EventsTab> createState() => _EventsTabState();
}

class _EventsTabState extends State<_EventsTab> {
  late Future<List<Map<String, String>>> _eventsFuture;
  final IslamicCalendarService _calendarService = IslamicCalendarService();

  @override
  void initState() {
    super.initState();
    _eventsFuture = _calendarService.getUpcomingEvents();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, String>>>(
      future: _eventsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: AppTheme.primaryGreen),
                const SizedBox(height: 16),
                Text(
                  'Fetching live dates...',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppTheme.textHint,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Center(
            child: Text(
              'Could not load events.\nPlease check your connection.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(color: AppTheme.textHint),
            ),
          );
        }

        final events = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.backgroundSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.event_rounded,
                        color: AppTheme.primaryGreen),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event['name']!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          event['hijri']!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: AppTheme.textPrimary.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_month_rounded,
                              size: 14,
                              color: AppTheme.primaryGreen.withValues(alpha: 0.6),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              event['gregorian']!,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: AppTheme.primaryGreen,
                                fontWeight: FontWeight.bold,
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
          },
        );
      },
    );
  }
}
