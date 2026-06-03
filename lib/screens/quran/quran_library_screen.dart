import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/surah_model.dart';
import '../../providers/quran_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/premium_provider.dart';
import '../../services/offline_service.dart';
import '../../utils/quran_constants.dart';
import '../../models/last_read_model.dart';
import 'surah_detail_screen.dart';
import '../store/paywall_screen.dart';

class QuranLibraryScreen extends StatefulWidget {
  final int initialTabIndex;
  final int? initialJuzFilter;

  const QuranLibraryScreen({
    super.key,
    this.initialTabIndex = 0,
    this.initialJuzFilter,
  });

  @override
  State<QuranLibraryScreen> createState() => _QuranLibraryScreenState();
}

class _QuranLibraryScreenState extends State<QuranLibraryScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  int? _selectedJuz;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _selectedJuz = widget.initialJuzFilter;
    _tabController = TabController(
      length: 2, 
      vsync: this, 
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quranProvider = context.watch<QuranProvider>();
    final isPremium = context.watch<PremiumProvider>().isPremium;

    List<SurahModel> displaySurahs = quranProvider.surahs;
    if (_selectedJuz != null) {
      displaySurahs =
          displaySurahs.where((s) => s.juzNumber == _selectedJuz).toList();
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundCream,
      appBar: AppBar(
        title: const Text('Quran Library'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryGreen,
            unselectedLabelColor: AppTheme.textHint,
            indicatorColor: AppTheme.primaryGreen,
            tabs: const [
              Tab(text: 'Surahs'),
              Tab(text: 'Juz'),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchController,
              onChanged: (q) => quranProvider.setSearchQuery(q),
              decoration: InputDecoration(
                hintText: 'Search Surah name or number...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.textHint),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          quranProvider.setSearchQuery('');
                        },
                      )
                    : null,
              ),
            ),
          ),
          // Qari Selector
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: _QariSelector(
              selectedQariId: quranProvider.selectedQariId,
              onSelect: (id) => quranProvider.selectQari(id),
              isPremium: isPremium,
            ),
          ),
          // Surah / Juz list
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _SurahList(surahs: displaySurahs, isPremium: isPremium),
                _JuzList(surahs: quranProvider.surahs, isPremium: isPremium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QariSelector extends StatelessWidget {
  final String selectedQariId;
  final Function(String) onSelect;
  final bool isPremium;

  const _QariSelector({
    required this.selectedQariId,
    required this.onSelect,
    required this.isPremium,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: QuranConstants.qaris.length,
        itemBuilder: (context, index) {
          final qari = QuranConstants.qaris[index];
          final id = qari['id']!;
          final isSelected = id == selectedQariId;
          final isLocked = !isPremium && !PremiumProvider.freeQariIds.contains(id);

          return GestureDetector(
            onTap: isLocked
                ? () => _showPremiumDialog(context)
                : () => onSelect(id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryGreen : AppTheme.cardWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppTheme.primaryGreen : AppTheme.divider,
                ),
              ),
              child: Row(
                children: [
                  if (isLocked)
                    const Text('🔒 ', style: TextStyle(fontSize: 12)),
                  Text(
                    qari['name']!.split(' ').take(2).join(' '),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w400,
                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showPremiumDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.workspace_premium_rounded, color: AppTheme.premiumGold, size: 24),
            SizedBox(width: 8),
            Text('Premium Feature'),
          ],
        ),
        content: const Text(
          'Unlock all 15 world-class Qaris with Premium. Upgrade for just ₹199/year!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PaywallScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }
}

class _SurahList extends StatelessWidget {
  final List<SurahModel> surahs;
  final bool isPremium;

  const _SurahList({required this.surahs, required this.isPremium});

  @override
  Widget build(BuildContext context) {
    final lastRead = context.watch<QuranProvider>().lastRead;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: surahs.length + (lastRead != null ? 1 : 0),
      itemBuilder: (context, index) {
        if (lastRead != null && index == 0) {
          return _LastReadCard(lastRead: lastRead);
        }

        final surahIndex = lastRead != null ? index - 1 : index;
        final surah = surahs[surahIndex];
        return _SurahTile(surah: surah);
      },
    );
  }
}

class _LastReadCard extends StatelessWidget {
  final LastReadModel lastRead;

  const _LastReadCard({required this.lastRead});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16, top: 8),
      elevation: 4,
      shadowColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryGreen,
              AppTheme.primaryGreen.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: InkWell(
          onTap: () async {
            final quranProvider = context.read<QuranProvider>();
            final settings = context.read<SettingsProvider>();

            // Restore script mode if available
            if (lastRead.scriptMode != null) {
              final mode = QuranScript.values.firstWhere(
                (m) => m.name == lastRead.scriptMode,
                orElse: () => QuranScript.indoPak,
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
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Last Read',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        lastRead.surahName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SurahTile extends StatelessWidget {
  final SurahModel surah;

  const _SurahTile({required this.surah});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              '${surah.number}',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryGreen,
                fontSize: 15,
              ),
            ),
          ),
        ),
        title: Row(
          children: [
            Text(
              surah.name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ],
        ),
        subtitle: Text(
          '${surah.type} • ${surah.ayahCount} Ayahs • Juz ${surah.juzNumber}',
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
        trailing: _SurahAction(surah: surah),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => SurahDetailScreen(surah: surah)),
          );
        },
      ),
    );
  }
}

class _SurahAction extends StatelessWidget {
  final SurahModel surah;
  const _SurahAction({required this.surah});

  @override
  Widget build(BuildContext context) {
    final offline = context.watch<OfflineService>();
    final premium = context.watch<PremiumProvider>();
    final isDownloaded = offline.isDownloaded(surah.number);
    final progress = offline.downloadProgress[surah.number.toString()];

    if (progress != null) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          value: progress,
          strokeWidth: 2,
          color: AppTheme.primaryGreen,
        ),
      );
    }

    if (isDownloaded) {
      return const Icon(Icons.offline_pin_rounded, color: AppTheme.primaryGreen, size: 24);
    }

    return IconButton(
      icon: const Icon(Icons.download_for_offline_rounded, color: AppTheme.textHint, size: 24),
      onPressed: () {
        if (!premium.isPremium) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PaywallScreen()),
          );
          return;
        }
        
        // Mock download - in real app would fetch all ayah audio URLs
        offline.downloadSurah(surah.number, [
          'https://cdn.islamic.network/quran/audio/128/ar.alafasy/${surah.number}001.mp3'
        ]);
      },
    );
  }
}

class _JuzList extends StatelessWidget {
  final List<SurahModel> surahs;
  final bool isPremium;

  const _JuzList({required this.surahs, required this.isPremium});

  @override
  Widget build(BuildContext context) {
    final lastRead = context.watch<QuranProvider>().lastRead;

    // Group by Juz (Corrected to handle multi-juz surahs)
    final juzMap = <int, List<SurahModel>>{};
    for (final surah in surahs) {
      final startJuz = surah.juzNumber;
      final endJuz = _getEndJuz(surah.number);
      for (int i = startJuz; i <= endJuz; i++) {
        juzMap.putIfAbsent(i, () => []).add(surah);
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: 30 + (lastRead != null ? 1 : 0),
      itemBuilder: (context, index) {
        if (lastRead != null && index == 0) {
          return _LastReadCard(lastRead: lastRead);
        }

        final juzIndex = lastRead != null ? index - 1 : index;
        final juzNum = juzIndex + 1;
        final juzSurahs = juzMap[juzNum] ?? [];

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '$juzNum',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ),
            ),
            title: Row(
              children: [
                Text(
                  'Juz $juzNum',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            subtitle: Text(
              '${juzSurahs.length} Surahs',
              style: const TextStyle(fontSize: 12),
            ),
            children: juzSurahs
                .map(
                  (s) => ListTile(
                    dense: true,
                    title: Text(s.name),
                    trailing: Text(
                      s.arabicName,
                      style: const TextStyle(
                        fontFamily: 'AmiriQuran',
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SurahDetailScreen(surah: s),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }

  // Helper to determine the last Juz a Surah belongs to
  int _getEndJuz(int surahNum) {
    if (surahNum == 2) return 3; // Al-Baqarah spans 1, 2, 3
    if (surahNum == 3) return 4; // Ali 'Imran spans 3, 4
    if (surahNum == 4) return 6; // An-Nisa spans 4, 5, 6
    if (surahNum == 5) return 7; // Al-Ma'idah spans 6, 7
    if (surahNum == 6) return 8; // Al-An'am spans 7, 8
    if (surahNum == 7) return 9; // Al-A'raf spans 8, 9
    
    // Default fallback for most other small surahs
    if (surahNum >= 78) return 30; // Juz Amma
    
    // Scan constants for start of NEXT surah
    for (final s in QuranConstants.surahs) {
        if (s['number'] == surahNum + 1) {
            return s['juz'] as int;
        }
    }
    return 30;
  }
}

