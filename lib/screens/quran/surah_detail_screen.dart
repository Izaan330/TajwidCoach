import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qcf_quran/qcf_quran.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../theme/app_theme.dart';
import '../../models/surah_model.dart';
import '../../providers/quran_provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/quran_constants.dart';
import '../../utils/tajweed_mapping.dart';
import '../../services/quran_api_service.dart';
import '../../widgets/tajweed_text.dart';
import '../practice/practice_screen.dart';
import '../../services/ad_service.dart';
import '../../providers/premium_provider.dart';
import '../store/paywall_screen.dart';

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
        if (mounted) setState(() => _playingAyah = null);
      }
    });

    _itemPositionsListener.itemPositions.addListener(_onScroll);

    final initialPage = context.read<QuranProvider>().currentPage;
    _pageController = PageController(initialPage: initialPage - 1);
  }

  void _onScroll() {
    final settings = context.read<SettingsProvider>();
    if (settings.quranScript == QuranScript.mushaf) return;

    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) return;

    // Find the first visible ayah to determine current page
    final hasBismillah = widget.surah.number != 9 && widget.surah.number != 1;
    final indexOffset = hasBismillah ? 2 : 1;

    final sortedPositions = positions.toList()
      ..sort((a, b) => a.index.compareTo(b.index));

    final topPosition = sortedPositions.firstWhere(
      (p) => p.index >= indexOffset,
      orElse: () => sortedPositions.first,
    );

    if (topPosition.index >= indexOffset) {
      final quranProvider = context.read<QuranProvider>();
      final ayahs = quranProvider.currentAyahs;
      final ayahIndex = topPosition.index - indexOffset;
      if (ayahIndex >= 0 && ayahIndex < ayahs.length) {
        final pageNumber = ayahs[ayahIndex].pageNumber;
        quranProvider.setCurrentPage(pageNumber);
      }
    }
  }

  void _scrollToCurrentPage() {
    if (!_itemScrollController.isAttached) return;
    
    final quranProvider = context.read<QuranProvider>();
    final targetPage = quranProvider.currentPage;
    final ayahIndex = quranProvider.findFirstAyahIndexOnPage(targetPage);
    
    final hasBismillah = widget.surah.number != 9 && widget.surah.number != 1;
    final indexOffset = hasBismillah ? 2 : 1;

    _itemScrollController.jumpTo(
      index: ayahIndex + indexOffset,
    );
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

    // Contextual guard: if a non-premium user has a premium script active
    // (e.g. from a restored backup or downgrade race condition), silently
    // reset to the free Indo-Pak script before any loading occurs.
    final isPremium = context.read<PremiumProvider>().isPremium;
    if (!isPremium && settings.quranScript != QuranScript.indoPak) {
      settings.setQuranScript(QuranScript.indoPak);
    }

    // Navigate to this surah's starting page or resumed page
    if (widget.initialPage != null) {
      quranProvider.goToPage(widget.initialPage!);
    } else {
      if (settings.quranScript == QuranScript.tajweed) {
        final standardPage = surahStartPages[widget.surah.number] ?? 1;
        final tajweedUIPage = TajweedMapping.getStartPage(widget.surah.number, standardPage);
        quranProvider.goToSurah(widget.surah.number, tajweedPage: tajweedUIPage);
      } else {
        quranProvider.goToSurah(widget.surah.number);
      }
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
      preservePage: settings.quranScript == QuranScript.tajweed,
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
    final isPremium = context.watch<PremiumProvider>().isPremium;
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

    final isFullScreenMode =
        script == QuranScript.mushaf || script == QuranScript.tajweed;
    final showAppBar = !isFullScreenMode || (quranProvider.isUIVisible);

    return Scaffold(
      backgroundColor: AppTheme.backgroundCream,
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
                PopupMenuButton<QuranScript>(
                  icon: const Icon(Icons.auto_stories_outlined),
                  tooltip: 'Reading Mode',
                  onSelected: (script) {
                    if (script == settings.quranScript) return;

                    if (script != QuranScript.indoPak && !isPremium) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const PaywallScreen()),
                      );
                      return;
                    }
                    
                    // If switching TO a text mode from a full-page mode, 
                    // we'll need to scroll the list after the next frame
                    final wasFullScreen = settings.quranScript == QuranScript.mushaf || 
                                         settings.quranScript == QuranScript.tajweed;
                    final wasTajweed = settings.quranScript == QuranScript.tajweed;
                    final isTajweed = script == QuranScript.tajweed;
                    
                    if (wasTajweed && !isTajweed) {
                      // Switch FROM Tajweed TO Standard
                      if (quranProvider.currentPage > 604) {
                        quranProvider.goToPage(604);
                      }
                    } else if (!wasTajweed && isTajweed) {
                      // Switch FROM Standard TO Tajweed
                      final tajUIPage = TajweedMapping.getStartPage(widget.surah.number, quranProvider.currentPage);
                      quranProvider.goToPage(tajUIPage);
                    }
                    
                    settings.setQuranScript(script);

                    final isNewFullScreen = script == QuranScript.mushaf || 
                                           script == QuranScript.tajweed;

                    if (wasFullScreen && !isNewFullScreen) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scrollToCurrentPage();
                      });
                    }
                  },
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        value: QuranScript.mushaf,
                        child: Row(
                          children: [
                            const Icon(Icons.menu_book_rounded,
                                color: AppTheme.primaryGreen, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                                child: Text('Mushaf (Madani)',
                                    style: TextStyle(
                                        color: settings.quranScript ==
                                                QuranScript.mushaf
                                            ? AppTheme.primaryGreen
                                            : null))),
                            if (!isPremium)
                              const Icon(Icons.lock_outline_rounded,
                                  size: 14, color: AppTheme.textHint),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: QuranScript.indoPak,
                        child: Row(
                          children: [
                            const Icon(Icons.text_fields_rounded,
                                color: AppTheme.info, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                                child: Text('Indo-Pak Script',
                                    style: TextStyle(
                                        color: settings.quranScript ==
                                                QuranScript.indoPak
                                            ? AppTheme.info
                                            : null))),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: QuranScript.tajweed,
                        child: Row(
                          children: [
                            const Icon(Icons.palette_rounded,
                                color: AppTheme.accentAmber, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                                child: Text('Tajweed Mode (Images)',
                                    style: TextStyle(
                                        color: settings.quranScript ==
                                                QuranScript.tajweed
                                            ? AppTheme.accentAmber
                                            : null))),
                            if (!isPremium)
                              const Icon(Icons.lock_outline_rounded,
                                  size: 14, color: AppTheme.textHint),
                          ],
                        ),
                      ),
                    ];
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.bookmark_add_outlined),
                  tooltip: 'Save Position',
                  onPressed: _manualSaveLastRead,
                ),

                if (!isFullScreenMode)
                  IconButton(
                    icon: const Icon(Icons.mic_rounded),
                    color: AppTheme.accentAmber,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PracticeScreen(surah: widget.surah),
                      ),
                    ),
                  ),
              ],
            )
          : null,
      body: _buildBody(script, ayahs, isLoading, quranProvider, settings),
      bottomNavigationBar: AdService.getBannerAd(
        isPremium: context.watch<PremiumProvider>().isPremium,
      ),
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
      // FULL PAGE MODES (Mushaf QCF Vector or Tajweed Images)
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
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageController = PageController(initialPage: _currentPage - 1);
  }

  @override
  void didUpdateWidget(_FullPageViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialPage != widget.initialPage) {
      if (mounted) {
        setState(() => _currentPage = widget.initialPage);
        if (_pageController.hasClients) {
          _pageController.jumpToPage(widget.initialPage - 1);
        }
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
          Container(
            color: settings.mushafTheme == MushafTheme.white
                ? Colors.white
                : settings.mushafTheme == MushafTheme.cream
                    ? const Color(0xFFF4ECD8)
                    : settings.mushafTheme == MushafTheme.dark
                        ? const Color(0xFF1A1A1A)
                        : const Color(0xFF0D1628),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Align(
              alignment: Alignment.topCenter,
              child: settings.quranScript == QuranScript.mushaf
                ? PageviewQuran(
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
                            color: AppTheme.primaryGreen
                                .withValues(alpha: 0.3)),
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
                  if (mounted) {
                    setState(() => _currentPage = page);
                  }
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
              )
            : PageView.builder(
                controller: _pageController,
                reverse: true, // Quran is RTL
                itemCount: settings.quranScript == QuranScript.tajweed ? 615 : 604,
                onPageChanged: (index) {
                  final page = index + 1;
                  if (mounted) {
                    setState(() => _currentPage = page);
                  }
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
                itemBuilder: (context, index) {
                  final uiPage = index + 1;
                  final pageStr = TajweedMapping.getAssetPageString(uiPage);
                  return InteractiveViewer(
                    minScale: 1.0,
                    maxScale: 4.0,
                    child: Image.asset(
                      'assets/images/quran/page_$pageStr.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.image_not_supported_outlined,
                                  size: 48, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text(
                                'Page $pageStr not found\nin assets/images/quran/',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
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

                  // Page number indicator
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Page $_currentPage of ${settings.quranScript == QuranScript.tajweed ? 615 : 604}',
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


