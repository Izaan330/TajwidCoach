import 'package:flutter/material.dart';
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
    _tabController = TabController(length: 3, vsync: this);
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
        title: const Text('My Progress'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryGreen,
          unselectedLabelColor: AppTheme.textHint,
          indicatorColor: AppTheme.primaryGreen,
          tabs: const [
            Tab(text: 'Streak'),
            Tab(text: 'Tajwid'),
            Tab(text: 'Badges'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _StreakTab(streak: streak),
          const _TajwidTab(),
          _BadgesTab(earnedBadges: streak.earnedBadges),
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
                colors: [Color(0xFF00BFA5), Color(0xFF00796B), Color(0xFF004D40)],
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
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.1),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Text('🔥', style: TextStyle(fontSize: 48)),
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
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
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
                      Container(width: 1.5, height: 40, color: Colors.white.withValues(alpha: 0.1)),
                      Expanded(
                        child: _StatItem(
                          'FREEZES',
                          '${streak.streakFreezes}',
                          Icons.ac_unit_rounded,
                        ),
                      ),
                      Container(width: 1.5, height: 40, color: Colors.white.withValues(alpha: 0.1)),
                      Expanded(
                        child: _StatItem(
                          'BADGES',
                          '${streak.earnedBadges.length}/5',
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
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  const Text('⚠️', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Don't break your ${streak.currentStreak}-day streak! Practice today to keep it going!",
                      style: const TextStyle(
                        color: Color(0xFFC62828),
                        fontWeight: FontWeight.w600,
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
                  Text('✅', style: TextStyle(fontSize: 20)),
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
          _StreakHeatmap(heatmapData: streak.heatmapData),
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
  const _StreakHeatmap({required this.heatmapData});

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentMonth());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentMonth() {
    if (!_scrollController.hasClients || _monthWidths.isEmpty) return;

    final screenWidth = MediaQuery.of(context).size.width - 48; // Scaffold padding + Card padding
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
    for (int i = 5; i >= 0; i--) {
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
              Text('Less', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textHint)),
              const SizedBox(width: 10),
              _legendBox(const Color(0xFFF1F3F4)),
              _legendBox(const Color(0xFFA7FFEB)),
              _legendBox(const Color(0xFF1DE9B6)),
              _legendBox(const Color(0xFF00BFA5)),
              const SizedBox(width: 10),
              Text('More', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textHint)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundCream,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 12, color: AppTheme.primaryGreen),
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
        ],
      ),
    );
  }

  (List<Widget>, double) _buildMonthColumns(DateTime monthStart, DateTime today) {
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
                final key = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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
    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
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
      boxShadow: c == Colors.transparent || c == const Color(0xFFF1F3F4) ? null : [
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
    final bgColor = Color(int.parse(rule.backgroundHex.replaceFirst('#', '0xFF')));
    final fgColor = Color(int.parse(rule.colorHex.replaceFirst('#', '0xFF')));
    
    // Level names
    final levelNames = ['Unstarted', 'Novice', 'Apprentice', 'Practitioner', 'Adept', 'Master'];
    final levelName = progress.level <= 5 ? levelNames[progress.level] : 'Expert';

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
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                                color: progress.level >= 5 ? AppTheme.primaryGreen : AppTheme.textHint,
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
                            widthFactor: progress.progressToNextLevel.clamp(0.05, 1.0),
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [fgColor.withValues(alpha: 0.7), fgColor],
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
                              color: AppTheme.textHint
                            ),
                          ),
                          Text(
                            'Lvl ${progress.level}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10, 
                              fontWeight: FontWeight.w900, 
                              color: fgColor
                            ),
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
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: () => _showLearnMode(context, rule),
                  icon: const Icon(Icons.menu_book_rounded, size: 18),
                  label: const Text('LEARN'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                    textStyle: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800),
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'PRACTICE',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w900),
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
                        style: TextStyle(color: AppTheme.textSecondary.withValues(alpha: 0.7)),
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
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      rule.description,
                      style: const TextStyle(fontSize: 15, height: 1.5, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Example Word',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  'GOT IT',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
        final earned = earnedBadges.contains(badge.id);
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
            boxShadow: earned ? [
              BoxShadow(
                color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              )
            ] : null,
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
                    color: earned ? Colors.white : AppTheme.divider.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        badge.emoji,
                        style: TextStyle(
                          fontSize: 40,
                          color: earned ? null : Colors.grey.withValues(alpha: 0.3),
                        ),
                      ),
                      if (!earned)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.8),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.lock_rounded, size: 16, color: AppTheme.textHint),
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: earned ? AppTheme.primaryGreen.withValues(alpha: 0.1) : Colors.transparent,
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

