import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../theme/app_theme.dart';
import '../../models/surah_model.dart';
import '../../providers/quran_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/quran_database_helper.dart';

/// Hifz (Memorization) Mode
///
/// A progressive word-hiding drill. The user selects a surah,
/// then reads through ayahs while the app hides words to test recall.
class HifzModeScreen extends StatefulWidget {
  const HifzModeScreen({super.key});

  @override
  State<HifzModeScreen> createState() => _HifzModeScreenState();
}

class _HifzModeScreenState extends State<HifzModeScreen>
    with TickerProviderStateMixin {
  // Phases
  bool _isDrillPhase = false;

  // Setup
  SurahModel? _selectedSurah;
  List<AyahModel> _loadedAyahs = [];
  int _currentAyahIndex = 0;
  double _difficulty = 0.3; // 0.0 – 1.0
  bool _isLoading = false;

  // Word hiding state
  List<_HifzWord> _words = [];
  Set<int> _revealedIndices = {};
  bool _showAllRevealed = false;

  // Self assessment
  bool _showSelfAssess = false;

  // Animation
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Persistence keys
  static const _lastSurahKey = 'hifz_last_surah';
  static const _lastAyahKey = 'hifz_last_ayah';
  static const _difficultyKey = 'hifz_difficulty';

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
    _loadSavedState();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedState() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDifficulty = prefs.getDouble(_difficultyKey);
    if (savedDifficulty != null && mounted) {
      setState(() => _difficulty = savedDifficulty);
    }
  }

  Future<void> _saveDrillState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_difficultyKey, _difficulty);
    if (_selectedSurah != null) {
      await prefs.setInt(_lastSurahKey, _selectedSurah!.number);
    }
    if (_loadedAyahs.isNotEmpty) {
      await prefs.setInt(
        _lastAyahKey,
        _loadedAyahs[_currentAyahIndex].ayahNumber,
      );
    }
  }

  String get _difficultyLabel {
    if (_difficulty <= 0.2) return 'Easy';
    if (_difficulty <= 0.5) return 'Medium';
    if (_difficulty <= 0.8) return 'Hard';
    return 'Test';
  }

  Color get _difficultyColor {
    if (_difficulty <= 0.2) return AppTheme.primaryGreen;
    if (_difficulty <= 0.5) return AppTheme.accentAmber;
    if (_difficulty <= 0.8) return AppTheme.warning;
    return AppTheme.qalqalahRed;
  }

  IconData get _difficultyIcon {
    if (_difficulty <= 0.2) return Icons.visibility_rounded;
    if (_difficulty <= 0.5) return Icons.visibility_off_rounded;
    if (_difficulty <= 0.8) return Icons.lock_rounded;
    return Icons.quiz_rounded;
  }

  Future<void> _startDrill() async {
    if (_selectedSurah == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a Surah first')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final ayahs = await QuranDatabaseHelper.instance
        .getSurahAyahs(_selectedSurah!.number);

    if (ayahs.isEmpty && mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No ayahs found for this Surah')),
      );
      return;
    }

    if (mounted) {
      setState(() {
        _loadedAyahs = ayahs;
        _currentAyahIndex = 0;
        _isLoading = false;
        _isDrillPhase = true;
        _showSelfAssess = false;
        _showAllRevealed = false;
        _revealedIndices = {};
      });
      _generateWords();
      _saveDrillState();
    }
  }

  void _generateWords() {
    final settings = context.read<SettingsProvider>();
    final ayah = _loadedAyahs[_currentAyahIndex];
    final text = settings.isIndoPak ? ayah.indopakText : ayah.arabicText;

    // Split into words
    final rawWords = text.split(RegExp(r'\s+'));

    // Deterministic seed based on surah + ayah + difficulty, so the same
    // positions are hidden on repeat
    final seed = ayah.surahNumber * 1000 +
        ayah.ayahNumber * 10 +
        (_difficulty * 100).toInt();
    final rng = Random(seed);

    // Decide which words to hide
    final words = <_HifzWord>[];
    for (int i = 0; i < rawWords.length; i++) {
      final hide = rng.nextDouble() < _difficulty;
      words.add(_HifzWord(
        text: rawWords[i],
        isHidden: hide,
        index: i,
      ));
    }

    // Ensure at least one word is visible (for context)
    if (words.every((w) => w.isHidden) && words.isNotEmpty) {
      words[0] = _HifzWord(
        text: words[0].text,
        isHidden: false,
        index: 0,
      );
    }

    setState(() {
      _words = words;
      _revealedIndices = {};
      _showAllRevealed = false;
      _showSelfAssess = false;
    });

    // Reset animation
    _fadeController.reset();
    _fadeController.forward();
  }

  void _revealWord(int index) {
    setState(() {
      _revealedIndices.add(index);
    });
  }

  void _revealAll() {
    setState(() {
      _showAllRevealed = true;
      _showSelfAssess = true;
    });
  }

  void _handleSelfAssessment(String rating) {
    // Adjust difficulty based on performance
    switch (rating) {
      case 'perfect':
        // Increase difficulty slightly
        _difficulty = (_difficulty + 0.15).clamp(0.0, 1.0);
        break;
      case 'good':
        // Stay the same
        break;
      case 'needs_work':
        // Decrease difficulty
        _difficulty = (_difficulty - 0.15).clamp(0.1, 1.0);
        break;
    }

    _saveDrillState();
    _nextAyah();
  }

  void _nextAyah() {
    if (_currentAyahIndex < _loadedAyahs.length - 1) {
      setState(() {
        _currentAyahIndex++;
        _showSelfAssess = false;
        _showAllRevealed = false;
      });
      _generateWords();
    } else {
      _showSurahCompleteDialog();
    }
  }

  void _showSurahCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('🏆', style: TextStyle(fontSize: 28)),
            SizedBox(width: 10),
            Expanded(child: Text('Surah Complete!')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You\'ve completed all ${_loadedAyahs.length} ayahs of ${_selectedSurah?.name}!',
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.idghamBlueBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.trending_up_rounded,
                      color: AppTheme.idghamBlue, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Difficulty: $_difficultyLabel (${(_difficulty * 100).toInt()}%)',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.idghamBlue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _currentAyahIndex = 0;
              });
              _generateWords();
            },
            child: const Text('Restart'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundCream,
      appBar: AppBar(
        title: Text(_isDrillPhase
            ? '${_selectedSurah?.name ?? 'Hifz'} - Memorize'
            : 'Hifz Mode'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (_isDrillPhase) {
              setState(() => _isDrillPhase = false);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: _isDrillPhase ? _buildDrillPhase() : _buildSetupPhase(),
    );
  }

  // ──────────── Setup Phase ────────────

  Widget _buildSetupPhase() {
    final surahs = context.watch<QuranProvider>().surahs;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text('📚', style: TextStyle(fontSize: 26)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Memorization Drill',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Progressive word hiding to test your Hifz',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Surah Selector
          const Text(
            'Select Surah',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.cardWhite,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                ),
              ],
            ),
            child: DropdownButtonFormField<SurahModel>(
              initialValue: _selectedSurah,
              decoration: const InputDecoration(
                hintText: 'Choose a Surah to memorize',
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: InputBorder.none,
              ),
              items: surahs
                  .map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text(
                        '${s.number}. ${s.name} (${s.ayahCount} ayahs)',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (s) {
                if (s != null) setState(() => _selectedSurah = s);
              },
            ),
          ),
          const SizedBox(height: 28),

          // Difficulty Slider
          const Text(
            'Difficulty Level',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.cardWhite,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(_difficultyIcon, color: _difficultyColor, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          _difficultyLabel,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: _difficultyColor,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _difficultyColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${(_difficulty * 100).toInt()}% hidden',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: _difficultyColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: _difficultyColor,
                    thumbColor: _difficultyColor,
                    inactiveTrackColor:
                        _difficultyColor.withValues(alpha: 0.15),
                    overlayColor: _difficultyColor.withValues(alpha: 0.12),
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 8),
                    trackHeight: 5,
                  ),
                  child: Slider(
                    value: _difficulty,
                    min: 0.1,
                    max: 1.0,
                    divisions: 9,
                    onChanged: (v) => setState(() => _difficulty = v),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _DifficultyLabel(
                      label: 'Easy',
                      color: AppTheme.primaryGreen,
                      isActive: _difficulty <= 0.2,
                    ),
                    _DifficultyLabel(
                      label: 'Medium',
                      color: AppTheme.accentAmber,
                      isActive: _difficulty > 0.2 && _difficulty <= 0.5,
                    ),
                    _DifficultyLabel(
                      label: 'Hard',
                      color: AppTheme.warning,
                      isActive: _difficulty > 0.5 && _difficulty <= 0.8,
                    ),
                    _DifficultyLabel(
                      label: 'Test',
                      color: AppTheme.qalqalahRed,
                      isActive: _difficulty > 0.8,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // How it works
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.idghamBlueBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📖 How it Works',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppTheme.idghamBlue,
                  ),
                ),
                SizedBox(height: 8),
                _HowItWorksStep(
                  number: '1',
                  text: 'Words are hidden based on difficulty',
                ),
                _HowItWorksStep(
                  number: '2',
                  text: 'Try to recall hidden words from memory',
                ),
                _HowItWorksStep(
                  number: '3',
                  text: 'Tap hidden words to reveal, or show all',
                ),
                _HowItWorksStep(
                  number: '4',
                  text: 'Rate yourself — difficulty auto-adjusts!',
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Start button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _startDrill,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.play_arrow_rounded),
              label: Text(
                _isLoading ? 'Loading...' : 'Start Memorization',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.idghamBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ──────────── Drill Phase ────────────

  Widget _buildDrillPhase() {
    final ayah = _loadedAyahs[_currentAyahIndex];
    final hiddenCount = _words.where((w) => w.isHidden).length;
    final revealedCount = _revealedIndices.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Progress header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.cardWhite,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_selectedSurah?.name} — Ayah ${ayah.ayahNumber}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _difficultyColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _difficultyLabel,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: _difficultyColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (_currentAyahIndex + 1) / _loadedAyahs.length,
                      backgroundColor: AppTheme.divider,
                      valueColor:
                          const AlwaysStoppedAnimation(AppTheme.idghamBlue),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ayah ${_currentAyahIndex + 1} of ${_loadedAyahs.length}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Text(
                        '$hiddenCount words hidden',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Ayah with hidden words
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.idghamBlue.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.idghamBlue.withValues(alpha: 0.15),
                ),
              ),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 14,
                  alignment: WrapAlignment.start,
                  children: _words.map((word) {
                    final isRevealed =
                        _showAllRevealed || _revealedIndices.contains(word.index);
                    final shouldHide = word.isHidden && !isRevealed;

                    return GestureDetector(
                      onTap: shouldHide ? () => _revealWord(word.index) : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: shouldHide
                              ? AppTheme.idghamBlue.withValues(alpha: 0.12)
                              : (word.isHidden && isRevealed)
                                  ? AppTheme.primaryGreen.withValues(alpha: 0.08)
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: shouldHide
                              ? Border.all(
                                  color: AppTheme.idghamBlue
                                      .withValues(alpha: 0.25),
                                  width: 1.5,
                                )
                              : (word.isHidden && isRevealed)
                                  ? Border.all(
                                      color: AppTheme.primaryGreen
                                          .withValues(alpha: 0.3),
                                      width: 1.5,
                                    )
                                  : null,
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: shouldHide
                              ? Text(
                                  _generateDots(word.text.length),
                                  key: ValueKey('hidden_${word.index}'),
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: AppTheme.idghamBlue
                                        .withValues(alpha: 0.4),
                                    letterSpacing: 2,
                                  ),
                                )
                              : Text(
                                  word.text,
                                  key: ValueKey('visible_${word.index}'),
                                  style: TextStyle(
                                    fontFamily: context
                                        .read<SettingsProvider>()
                                        .defaultFontFamily,
                                    fontSize: 22,
                                    height: 1.8,
                                    color: (word.isHidden && isRevealed)
                                        ? AppTheme.primaryGreen
                                        : Colors.black87,
                                    fontWeight: (word.isHidden && isRevealed)
                                        ? FontWeight.w700
                                        : FontWeight.normal,
                                  ),
                                ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Reveal hint
            if (!_showAllRevealed && hiddenCount > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  revealedCount > 0
                      ? '${hiddenCount - revealedCount} words still hidden — tap to reveal'
                      : 'Tap hidden words to peek, or reveal all below',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

            // Action buttons
            if (!_showSelfAssess) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _revealAll,
                  icon: const Icon(Icons.visibility_rounded, size: 20),
                  label: const Text(
                    'Check Answer',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.idghamBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],

            // Self-assessment
            if (_showSelfAssess) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.cardWhite,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'How did you do?',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Your rating adjusts the next difficulty',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _AssessButton(
                            icon: Icons.star_rounded,
                            label: 'Perfect',
                            subtitle: 'Harder next',
                            color: AppTheme.primaryGreen,
                            onTap: () => _handleSelfAssessment('perfect'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _AssessButton(
                            icon: Icons.thumb_up_rounded,
                            label: 'Good',
                            subtitle: 'Stay same',
                            color: AppTheme.idghamBlue,
                            onTap: () => _handleSelfAssessment('good'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _AssessButton(
                            icon: Icons.auto_stories_rounded,
                            label: 'Review',
                            subtitle: 'Easier next',
                            color: AppTheme.accentAmber,
                            onTap: () => _handleSelfAssessment('needs_work'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  String _generateDots(int wordLength) {
    // Scale dots proportional to word length so the gap looks natural
    final count = (wordLength * 0.6).clamp(2, 6).toInt();
    return '●' * count;
  }
}

// ──────────── Data Classes ────────────

class _HifzWord {
  final String text;
  final bool isHidden;
  final int index;

  const _HifzWord({
    required this.text,
    required this.isHidden,
    required this.index,
  });
}

// ──────────── Supporting Widgets ────────────

class _DifficultyLabel extends StatelessWidget {
  final String label;
  final Color color;
  final bool isActive;

  const _DifficultyLabel({
    required this.label,
    required this.color,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
        color: isActive ? color : AppTheme.textHint,
      ),
    );
  }
}

class _HowItWorksStep extends StatelessWidget {
  final String number;
  final String text;

  const _HowItWorksStep({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppTheme.idghamBlue.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.idghamBlue,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssessButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _AssessButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: color,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
