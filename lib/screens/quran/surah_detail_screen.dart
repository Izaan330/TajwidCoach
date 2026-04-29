import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qcf_quran/qcf_quran.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../providers/premium_provider.dart';
import '../store/paywall_screen.dart';

import '../../theme/app_theme.dart';
import '../../models/surah_model.dart';
import '../../providers/quran_provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/quran_constants.dart';
import '../../services/quran_api_service.dart';
import '../../widgets/tajweed_text.dart';
import '../../widgets/mushaf_page_view.dart';
import '../practice/practice_screen.dart';

class SurahDetailScreen extends StatefulWidget {
  final SurahModel surah;
  final int? initialPage;
  final int? initialAyah;

  const SurahDetailScreen({
    super.key,
    required this.surah,
    this.initialPage,
    this.initialAyah,
  });

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  final AudioPlayer _player = AudioPlayer();
  int? _playingAyah;
  double _playbackSpeed = 1.0;
  late PageController _pageController;
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  bool _hasScrolled = false;

  @override
  void initState() {
    super.initState();
    _loadSurah();
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        setState(() => _playingAyah = null);
      }
    });

    final initialPage = context.read<QuranProvider>().currentPage;
    _pageController = PageController(initialPage: initialPage - 1);
  }

  void _scrollToAyah(int ayahNumber) {
    if (!_itemScrollController.isAttached) return;

    // We add 1 for headers (Speed bar + Bismillah)
    final hasBismillah = widget.surah.number != 9 && widget.surah.number != 1;
    final indexOffset = hasBismillah ? 2 : 1;

    _itemScrollController.scrollTo(
      index: (ayahNumber - 1) + indexOffset,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      alignment: 0.1, // Scroll so item is near the top
    );
  }

  void _loadSurah() {
    final settings = context.read<SettingsProvider>();
    final quranProvider = context.read<QuranProvider>();
    // Navigate to this surah's starting page or resumed page
    if (widget.initialPage != null) {
      quranProvider.goToPage(widget.initialPage!);
    } else {
      quranProvider.goToSurah(widget.surah.number);
    }

    // Track Last Read immediately on entry
    quranProvider.updateLastRead(
      widget.surah,
      pageNumber: widget.initialPage ?? quranProvider.currentPage,
      scriptMode: settings.quranScript.name,
    );

    // Also load ayahs for non-mushaf modes
    quranProvider.loadSurah(
      widget.surah.number,
      scriptEdition: settings.scriptEdition,
      translationEdition: settings.translationEdition,
    );
  }

  @override
  void dispose() {
    _player.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _playAyah(AyahModel ayah) async {
    final qariId = context.read<QuranProvider>().selectedQariId;
    final audioId = QuranConstants.qariAudioIds[qariId] ?? 'ar.alafasy';
    final url = QuranApiService.getAudioUrl(audioId, ayah.globalNumber);

    if (_playingAyah == ayah.ayahNumber) {
      await _player.pause();
      setState(() => _playingAyah = null);
      return;
    }

    setState(() => _playingAyah = ayah.ayahNumber);
    try {
      await _player.setUrl(url);
      await _player.setSpeed(_playbackSpeed);
      await _player.play();
    } catch (e) {
      setState(() => _playingAyah = null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not play audio. Check your connection.'),
            backgroundColor: AppTheme.qalqalahRed,
          ),
        );
      }
    }
  }

  void _manualSaveLastRead() {
    final quranProvider = context.read<QuranProvider>();
    final settings = context.read<SettingsProvider>();
    final script = settings.quranScript;

    if (script == QuranScript.mushaf || script == QuranScript.tajweed) {
      // Full Page Modes
      quranProvider.updateLastRead(
        widget.surah,
        pageNumber: quranProvider.currentPage,
        scriptMode: script.name,
      );
    } else {
      // Text Modes (Indo-Pak / Tajweed Text)
      final positions = _itemPositionsListener.itemPositions.value;
      if (positions.isNotEmpty) {
        final hasBismillah =
            widget.surah.number != 9 && widget.surah.number != 1;
        final indexOffset = hasBismillah ? 2 : 1;

        final sortedPositions = positions.toList()
          ..sort((a, b) => a.index.compareTo(b.index));

        final topPosition = sortedPositions.firstWhere(
          (p) => p.index >= indexOffset && p.itemLeadingEdge <= 0.1,
          orElse: () => sortedPositions.firstWhere(
              (p) => p.index >= indexOffset,
              orElse: () => sortedPositions.first),
        );

        if (topPosition.index >= indexOffset) {
          final ayahNumber = (topPosition.index - indexOffset) + 1;
          quranProvider.updateLastRead(
            widget.surah,
            ayahNumber: ayahNumber,
            pageNumber: quranProvider.currentPage,
            scriptMode: script.name,
          );
        } else {
          quranProvider.updateLastRead(
            widget.surah,
            ayahNumber: 1,
            pageNumber: quranProvider.currentPage,
            scriptMode: script.name,
          );
        }
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Last read position saved!'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final quranProvider = context.watch<QuranProvider>();
    final settings = context.watch<SettingsProvider>();
    final ayahs = quranProvider.currentAyahs;
    final isLoading = quranProvider.isLoading;

    // Handle initial scroll after loading
    if (!isLoading && widget.initialAyah != null && !_hasScrolled) {
      _hasScrolled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToAyah(widget.initialAyah!);
      });
    }
    final script = settings.quranScript;
    final premium = context.watch<PremiumProvider>();

    // Premium Check
    final isFreeSurah = widget.surah.number == 1 || widget.surah.number >= 78;
    final isLocked = !premium.isPremium && !isFreeSurah;

    final isFullScreenMode =
        script == QuranScript.mushaf || script == QuranScript.tajweed;
    final showAppBar = !isFullScreenMode || (quranProvider.isUIVisible);

    return Scaffold(
      backgroundColor: AppTheme.backgroundMid,
      extendBodyBehindAppBar: isFullScreenMode,
      appBar: showAppBar
          ? AppBar(
              toolbarHeight: 82, // More space for 2-line title with Arabic font
              backgroundColor: isFullScreenMode
                  ? AppTheme.backgroundMid.withValues(alpha: 0.8)
                  : null,
              foregroundColor: isFullScreenMode ? AppTheme.textPrimary : null,
              elevation: 0,
              title: Column(
                children: [
                  Text(
                    widget.surah.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  Text(
                    widget.surah.arabicName,
                    style: const TextStyle(
                      fontSize: 16, // Slightly larger for better readability
                      fontFamily: 'AmiriQuran',
                      height:
                          1.4, // Essential to prevent clipping of tall Alifs/diacritics
                      color: AppTheme.primaryGreen,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.bookmark_add_outlined),
                  tooltip: 'Save Position',
                  onPressed: isLocked ? null : _manualSaveLastRead,
                ),
                if (!isFullScreenMode)
                  IconButton(
                    icon: const Icon(Icons.mic_rounded),
                    color: AppTheme.accentAmber,
                    onPressed: isLocked ? null : () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PracticeScreen(surah: widget.surah),
                      ),
                    ),
                  ),
              ],
            )
          : null,
      body: isLocked 
          ? _buildLockedOverlay(context)
          : _buildBody(script, ayahs, isLoading, quranProvider, settings),
    );
  }

  Widget _buildLockedOverlay(BuildContext context) {
    return Stack(
      children: [
        // Blurred background of the first page/ayahs
        Positioned.fill(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: Text('🕌', style: TextStyle(fontSize: 100)),
              ),
            ),
          ),
        ),
        
        // Lock message
        Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.backgroundSurface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_person_rounded, color: AppTheme.premiumGold, size: 64),
                const SizedBox(height: 20),
                const Text(
                  'Premium Surah',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Access to all 114 Surahs is a Premium feature. Start your journey with the full Quran today.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textSecondary, height: 1.5),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PaywallScreen()),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.premiumGold,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Unlock Full Quran', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Back to Free Surahs', style: TextStyle(color: AppTheme.textHint)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(
    QuranScript script,
    List<AyahModel> ayahs,
    bool isLoading,
    QuranProvider quranProvider,
    SettingsProvider settings,
  ) {
    if (script == QuranScript.mushaf || script == QuranScript.tajweed) {
      // ──────────────────────────────────────────────────
      // FULL PAGE MODES (Mushaf QCF or Tajweed Images)
      // ──────────────────────────────────────────────────
      return _FullPageViewer(
        initialPage: quranProvider.currentPage,
        onPageChanged: (page) => quranProvider.goToPage(page),
      );
    }

    // ──────────────────────────────────────────────────
    // TEXT MODES (IndoPak / Tajweed): ayah card list
    // ──────────────────────────────────────────────────
    final hasBismillah = widget.surah.number != 9 && widget.surah.number != 1;
    final headerCount = (hasBismillah ? 1 : 0) + 1; // +1 for SpeedBar

    return Column(
      children: [
        _ScriptToggleBar(
          currentScript: script,
          onSelect: settings.setQuranScript,
        ),

        // Ayah list with scrollable headers
        Expanded(
          child: isLoading
              ? const Center(
                  child:
                      CircularProgressIndicator(color: AppTheme.primaryGreen),
                )
              : ScrollablePositionedList.builder(
                  itemScrollController: _itemScrollController,
                  itemPositionsListener: _itemPositionsListener,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: ayahs.length + headerCount,
                  itemBuilder: (context, index) {
                    int sectionIndex = index;

                    // Header 1: Bismillah
                    if (hasBismillah) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildBismillah(settings),
                        );
                      }
                      sectionIndex--;
                    }

                    // Header 2: Speed Bar
                    if (sectionIndex == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _SpeedBar(
                          currentSpeed: _playbackSpeed,
                          onSpeedChanged: (s) {
                            setState(() => _playbackSpeed = s);
                            _player.setSpeed(s);
                          },
                        ),
                      );
                    }

                    // Ayahs
                    final ayah = ayahs[sectionIndex - 1];
                    return _AyahCard(
                      ayah: ayah,
                      isPlaying: _playingAyah == ayah.ayahNumber,
                      showTranslation: settings.showTranslation,
                      showTajweed: settings.showTajweedColors,
                      fontFamily: settings.defaultFontFamily,
                      fontSize: settings.quranFontSize,
                      onPlay: () {
                        _playAyah(ayah);
                        // Track last read when playing
                        quranProvider.updateLastRead(
                          widget.surah,
                          ayahNumber: ayah.ayahNumber,
                          pageNumber: quranProvider.currentPage,
                          scriptMode: settings.quranScript.name,
                        );
                      },
                      onRecord: () {
                        // Track last read when practicing
                        quranProvider.updateLastRead(
                          widget.surah,
                          ayahNumber: ayah.ayahNumber,
                          pageNumber: quranProvider.currentPage,
                          scriptMode: settings.quranScript.name,
                        );
                        context.read<QuranProvider>().selectAyah(ayah);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PracticeScreen(
                              surah: widget.surah,
                              selectedAyah: ayah,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildBismillah(SettingsProvider settings) {
    final isIndoPak = settings.quranScript == QuranScript.indoPak;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isIndoPak ? 16 : 24,
        horizontal: 16,
      ),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '\u0628\u0650\u0633\u0652\u0645\u0650 \u0627\u0644\u0644\u0651\u0670\u0647\u0650 \u0627\u0644\u0631\u0651\u064e\u062d\u0652\u0645\u064e\u0670\u0646\u0650 \u0627\u0644\u0631\u0651\u064e\u062d\u0650\u064a\u0645\u0650',
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          fontFamily: settings.defaultFontFamily,
          fontSize: isIndoPak ? 22 : 28,
          color: AppTheme.primaryGreen,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// 3-Way Script Toggle Bar
// ─────────────────────────────────────────────────────────

class _ScriptToggleBar extends StatelessWidget {
  final QuranScript currentScript;
  final Function(QuranScript) onSelect;

  const _ScriptToggleBar({
    required this.currentScript,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.cardWhite,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: QuranScript.values.map((script) {
          final labels = {
            QuranScript.mushaf: '🕌 Mushaf',
            QuranScript.indoPak: '🔠 Indo-Pak',
            QuranScript.tajweed: '🎨 Tajweed',
          };
          final isSelected = script == currentScript;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(script),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryGreen
                      : AppTheme.backgroundCream,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  labels[script]!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Full-Page View (Handles both QCF Mushaf and Tajweed Images)
// ─────────────────────────────────────────────────────────

class _FullPageViewer extends StatefulWidget {
  final int initialPage;
  final Function(int) onPageChanged;

  const _FullPageViewer({
    required this.initialPage,
    required this.onPageChanged,
  });

  @override
  State<_FullPageViewer> createState() => _FullPageViewerState();
}

class _FullPageViewerState extends State<_FullPageViewer> {
  int _currentPage = 1;
  int? _tajweedViewIndex;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _tajweedViewIndex = (_currentPage - 1) + 9;
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final quranProvider = context.read<QuranProvider>();
    final isUIVisible = context.select((QuranProvider p) => p.isUIVisible);

    return GestureDetector(
      onTap: () => quranProvider.toggleUI(),
      child: Stack(
        children: [
          // Render based on selected script
          if (settings.quranScript == QuranScript.tajweed)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: PageView.builder(
                controller: PageController(
                    initialPage: _tajweedViewIndex ?? ((_currentPage - 1) + 9)),
                reverse: true, // Read right-to-left
                itemCount: 624,
                onPageChanged: (index) {
                  int mushafEquivalentPage = index - 8;
                  if (mushafEquivalentPage < 1) mushafEquivalentPage = 1;
                  if (mushafEquivalentPage > 604) mushafEquivalentPage = 604;

                  setState(() {
                    _tajweedViewIndex = index;
                    _currentPage = mushafEquivalentPage;
                  });
                  widget.onPageChanged(mushafEquivalentPage);

                  // Update Last Read on page change
                  final currentSurah =
                      context.read<QuranProvider>().currentSurah;
                  if (currentSurah != null) {
                    context.read<QuranProvider>().updateLastRead(
                          currentSurah,
                          pageNumber: mushafEquivalentPage,
                          scriptMode: settings.quranScript.name,
                        );
                  }
                },
                itemBuilder: (context, index) {
                  return MushafPageView(pageNumber: index + 1);
                },
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Align(
                alignment: Alignment.topCenter,
                child: PageviewQuran(
                  initialPageNumber: _currentPage,
                  sp: 1.0,
                  h: 1.0,
                  theme: QcfThemeData(
                    customHeaderBuilder: (suraNumber) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        margin: const EdgeInsets.only(top: 10, bottom: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color:
                                  AppTheme.primaryGreen.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          "surah${suraNumber.toString().padLeft(3, '0')}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'surahname',
                            package: 'qcf_quran',
                            fontSize: 32,
                            color: Colors.black87,
                          ),
                        ),
                      );
                    },
                  ),
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                      _tajweedViewIndex =
                          (page - 1) + 9; // Match original indexing
                    });
                    widget.onPageChanged(page);

                    // Update Last Read
                    final currentSurah =
                        context.read<QuranProvider>().currentSurah;
                    if (currentSurah != null) {
                      context.read<QuranProvider>().updateLastRead(
                            currentSurah,
                            pageNumber: page,
                            scriptMode: settings.quranScript.name,
                          );
                    }
                  },
                ),
              ),
            ),

          // Animated Bottom Controls Area
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: isUIVisible ? 0 : -150, // Hide off-screen
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.backgroundMid.withValues(alpha: 0.0),
                    AppTheme.backgroundMid.withValues(alpha: 0.95),
                  ],
                ),
              ),
              padding: const EdgeInsets.only(top: 30, bottom: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ScriptToggleBar(
                    currentScript: settings.quranScript,
                    onSelect: settings.setQuranScript,
                  ),
                  const SizedBox(height: 12),
                  // Page number indicator
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Page ${settings.quranScript == QuranScript.tajweed ? (_tajweedViewIndex ?? 0) + 1 : _currentPage} of ${settings.quranScript == QuranScript.tajweed ? 624 : 604}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Speed Bar
// ─────────────────────────────────────────────────────────

class _SpeedBar extends StatelessWidget {
  final double currentSpeed;
  final Function(double) onSpeedChanged;

  const _SpeedBar({required this.currentSpeed, required this.onSpeedChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.cardWhite,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const Text('Speed:',
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            const SizedBox(width: 8),
            ...[0.5, 0.75, 1.0, 1.25, 1.5].map((speed) {
              final isSelected = currentSpeed == speed;
              return GestureDetector(
                onTap: () => onSpeedChanged(speed),
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryGreen
                        : AppTheme.backgroundCream,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${speed}x',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Ayah Card (IndoPak / Tajweed modes)
// ─────────────────────────────────────────────────────────

class _AyahCard extends StatelessWidget {
  final AyahModel ayah;
  final bool isPlaying;
  final bool showTranslation;
  final bool showTajweed;
  final String fontFamily;
  final double fontSize;
  final VoidCallback onPlay;
  final VoidCallback onRecord;

  const _AyahCard({
    required this.ayah,
    required this.isPlaying,
    required this.showTranslation,
    required this.showTajweed,
    required this.fontFamily,
    required this.fontSize,
    required this.onPlay,
    required this.onRecord,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.read<SettingsProvider>();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: isPlaying
            ? AppTheme.primaryGreen.withValues(alpha: 0.1)
            : AppTheme.backgroundSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPlaying
              ? AppTheme.primaryGreen.withValues(alpha: 0.3)
              : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isPlaying
                ? AppTheme.primaryGreen.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.15),
            blurRadius: isPlaying ? 16 : 10,
            offset: isPlaying ? const Offset(0, 6) : const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isPlaying
                            ? Icons.pause_circle_rounded
                            : Icons.play_circle_rounded,
                        color: AppTheme.primaryGreen,
                        size: 32,
                      ),
                      onPressed: onPlay,
                    ),
                    IconButton(
                      icon: const Icon(Icons.mic_rounded,
                          color: AppTheme.accentAmber, size: 26),
                      onPressed: onRecord,
                      tooltip: 'Practice',
                    ),
                  ],
                ),
                Text(
                  '${ayah.surahNumber}:${ayah.ayahNumber}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TajweedText(
                  text: settings.isIndoPak ? ayah.indopakText : ayah.arabicText,
                  ayahNumber: ayah.ayahNumber,
                  fontSize: fontSize,
                  fontFamily: fontFamily,
                  lineHeight: 2.2,
                  showTajweed: showTajweed,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
                if (showTranslation && ayah.translationText.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundMid,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.05)),
                    ),
                    child: Text(
                      ayah.translationText,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: AppTheme.textSecondary,
                        height: 1.6,
                      ),
                      textDirection: TextDirection.ltr,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
