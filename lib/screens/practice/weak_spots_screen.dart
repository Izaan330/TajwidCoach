import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

import '../../theme/app_theme.dart';
import '../../models/surah_model.dart';
import '../../models/tajwid_rule_model.dart';
import '../../utils/tajwid_rules_data.dart';
import '../../utils/quran_constants.dart';
import '../../services/quran_api_service.dart';
import '../../services/quran_database_helper.dart';
import '../../services/tajwid_analysis_service.dart';
import '../../providers/tajwid_progress_provider.dart';
import '../../providers/quran_provider.dart';
import '../../providers/streak_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/premium_provider.dart';
import '../../widgets/tajweed_text.dart';
import 'ai_feedback_screen.dart';

/// Weak Spots Practice Mode
///
/// Surfaces the user's weakest Tajwid rules and creates focused
/// drill sessions with ayahs containing those rules.
class WeakSpotsScreen extends StatefulWidget {
  const WeakSpotsScreen({super.key});

  @override
  State<WeakSpotsScreen> createState() => _WeakSpotsScreenState();
}

class _WeakSpotsScreenState extends State<WeakSpotsScreen>
    with SingleTickerProviderStateMixin {
  // Phases
  bool _isDrillPhase = false;
  TajwidRule? _selectedRule;

  // Drill state
  List<AyahModel> _drillAyahs = [];
  int _currentDrillIndex = 0;
  bool _isLoadingAyahs = false;

  // Recording state
  final AudioPlayer _player = AudioPlayer();
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isPlaying = false;
  bool _isRecording = false;
  bool _isAnalyzing = false;
  int _recordingSeconds = 0;
  Timer? _timer;
  String? _currentRecordingPath;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        if (mounted) setState(() => _isPlaying = false);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _player.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _selectRule(TajwidRule rule) async {
    setState(() {
      _selectedRule = rule;
      _isLoadingAyahs = true;
    });

    final ayahs = await QuranDatabaseHelper.instance
        .getAyahsByRule(rule.id, limit: 20);

    if (mounted) {
      setState(() {
        _drillAyahs = ayahs;
        _currentDrillIndex = 0;
        _isLoadingAyahs = false;
        _isDrillPhase = ayahs.isNotEmpty;
      });

      if (ayahs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No practice ayahs found for ${rule.name}'),
            backgroundColor: AppTheme.warning,
          ),
        );
      }
    }
  }

  AyahModel? get _currentAyah =>
      _drillAyahs.isNotEmpty ? _drillAyahs[_currentDrillIndex] : null;

  void _nextDrillAyah() {
    if (_currentDrillIndex < _drillAyahs.length - 1) {
      setState(() => _currentDrillIndex++);
    } else {
      // Drill complete!
      _showDrillCompleteDialog();
    }
  }

  void _showDrillCompleteDialog() {
    final progress = context.read<TajwidProgressProvider>();
    final ruleProgress = progress.getRuleProgress(_selectedRule!.id);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.celebration_rounded, color: AppTheme.accentAmber, size: 32),
            SizedBox(width: 10),
            Text('Drill Complete!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Great job practicing ${_selectedRule!.name}!',
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    label: 'Level',
                    value: '${ruleProgress.level}',
                    icon: Icons.star_rounded,
                    color: AppTheme.accentAmber,
                  ),
                  _StatItem(
                    label: 'XP',
                    value: '${ruleProgress.xp}',
                    icon: Icons.bolt_rounded,
                    color: AppTheme.primaryGreen,
                  ),
                  _StatItem(
                    label: 'Drills',
                    value: '${ruleProgress.successfulRecitations}',
                    icon: Icons.check_circle_rounded,
                    color: AppTheme.idghamBlue,
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
                _isDrillPhase = false;
                _selectedRule = null;
                _drillAyahs = [];
              });
            },
            child: const Text('Pick Another Rule'),
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

  Future<void> _playAyah() async {
    final ayah = _currentAyah;
    if (ayah == null) return;

    final qariId = context.read<QuranProvider>().selectedQariId;
    final audioId = QuranConstants.qariAudioIds[qariId] ?? 'ar.alafasy';
    final url = QuranApiService.getAudioUrl(audioId, ayah.globalNumber);

    if (_isPlaying) {
      await _player.pause();
      setState(() => _isPlaying = false);
      return;
    }

    setState(() => _isPlaying = true);
    try {
      await _player.setUrl(url);
      await _player.setSpeed(1.0);
      await _player.play();
    } catch (_) {
      setState(() => _isPlaying = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not play audio')),
        );
      }
    }
  }

  Future<void> _startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      final Directory tempDir = await getTemporaryDirectory();
      final String path =
          '${tempDir.path}/weak_spot_${DateTime.now().millisecondsSinceEpoch}.wav';

      const config = RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
      );

      await _audioRecorder.start(config, path: path);

      setState(() {
        _isRecording = true;
        _recordingSeconds = 0;
        _currentRecordingPath = path;
      });

      _pulseController.repeat(reverse: true);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _recordingSeconds++);
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission required')),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    final streakProvider = context.read<StreakProvider>();

    _timer?.cancel();
    _pulseController.stop();
    _pulseController.reset();

    final isPremium = context.read<PremiumProvider>().isPremium;
    final path = await _audioRecorder.stop();

    setState(() {
      _isRecording = false;
      _isAnalyzing = true;
      _currentRecordingPath = path;
    });

    final ayah = _currentAyah!;

    final result = await TajwidAnalysisService.analyze(
      ayahReference: '${ayah.surahNumber}:${ayah.ayahNumber}',
      referenceText: ayah.arabicText,
      durationSeconds: _recordingSeconds,
      audioFile:
          _currentRecordingPath != null ? File(_currentRecordingPath!) : null,
      targetRuleId: _selectedRule?.id,
      isPremium: isPremium,
    );

    // Record streak + XP
    final practiceMinutes = (_recordingSeconds / 60).ceil();
    await streakProvider
        .recordPractice(practiceMinutes > 0 ? practiceMinutes : 1);

    if (mounted) {
      final progressProvider = context.read<TajwidProgressProvider>();
      await progressProvider.addXp(_selectedRule!.id, 20);
    }

    setState(() => _isAnalyzing = false);

    if (mounted) {
      // Resolve surah name
      final surahs = context.read<QuranProvider>().surahs;
      SurahModel? surah;
      try {
        surah = surahs.firstWhere((s) => s.number == ayah.surahNumber);
      } catch (_) {}

      final next = await Navigator.of(context).push(
        MaterialPageRoute<bool>(
          builder: (_) => AIFeedbackScreen(
            result: result,
            surahName: surah?.name ?? 'Surah ${ayah.surahNumber}',
            ayahRef:
                '${surah?.name ?? ayah.surahNumber}:${ayah.ayahNumber}',
            audioPath: _currentRecordingPath,
            durationSeconds: _recordingSeconds,
          ),
        ),
      );

      if (next == true && mounted) {
        _nextDrillAyah();
      }
    }
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundCream,
      appBar: AppBar(
        title: Text(_isDrillPhase
            ? '${_selectedRule?.name} Drill'
            : 'Weak Spots'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (_isDrillPhase) {
              setState(() {
                _isDrillPhase = false;
                _selectedRule = null;
              });
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: _isDrillPhase ? _buildDrillPhase() : _buildRuleSelectionPhase(),
    );
  }

  // ──────────── Rule Selection Phase ────────────

  Widget _buildRuleSelectionPhase() {
    final progressProvider = context.watch<TajwidProgressProvider>();
    final weakRuleIds = progressProvider.weakRules;
    const allRules = TajwidRulesData.rules;

    // Partition: weak rules first, then the rest
    final List<TajwidRule> weakRules = [];
    final List<TajwidRule> otherRules = [];

    for (final rule in allRules) {
      if (weakRuleIds.contains(rule.id)) {
        weakRules.add(rule);
      } else {
        otherRules.add(rule);
      }
    }

    // Sort weak rules by XP ascending (weakest first)
    weakRules.sort((a, b) {
      final pa = progressProvider.getRuleProgress(a.id);
      final pb = progressProvider.getRuleProgress(b.id);
      return pa.xp.compareTo(pb.xp);
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFC62828), Color(0xFFE53935)],
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
                    child: const Icon(Icons.track_changes_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Target Your Weak Spots',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        weakRules.isEmpty
                            ? 'Pick any rule to start practicing!'
                            : '${weakRules.length} rules need attention',
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
          const SizedBox(height: 24),

          // Weak rules section
          if (weakRules.isNotEmpty) ...[
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.qalqalahRed,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Needs Practice',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.qalqalahRed,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...weakRules.map((rule) => _WeakRuleCard(
                  rule: rule,
                  progress: progressProvider.getRuleProgress(rule.id),
                  onTap: () => _selectRule(rule),
                  isWeak: true,
                )),
            const SizedBox(height: 24),
          ],

          // All other rules
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'All Rules',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...(weakRules.isEmpty ? allRules : otherRules).map(
            (rule) => _WeakRuleCard(
              rule: rule,
              progress: progressProvider.getRuleProgress(rule.id),
              onTap: () => _selectRule(rule),
              isWeak: false,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ──────────── Drill Phase ────────────

  Widget _buildDrillPhase() {
    if (_isLoadingAyahs) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppTheme.qalqalahRed),
            SizedBox(height: 16),
            Text('Loading practice ayahs...'),
          ],
        ),
      );
    }

    final ayah = _currentAyah;
    if (ayah == null) return const SizedBox.shrink();

    final settings = context.read<SettingsProvider>();
    final ruleColor = Color(
      int.parse(_selectedRule!.colorHex.replaceFirst('#', '0xFF')),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Drill progress bar
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: ruleColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _selectedRule!.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: ruleColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _selectedRule!.arabicName,
                          style: TextStyle(
                            fontSize: 14,
                            color: ruleColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${_currentDrillIndex + 1}/${_drillAyahs.length}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: (_currentDrillIndex + 1) / _drillAyahs.length,
                    backgroundColor: AppTheme.divider,
                    valueColor: AlwaysStoppedAnimation(ruleColor),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Ayah display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ruleColor.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: ruleColor.withValues(alpha: 0.15),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Surah/Ayah reference
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.cardWhite,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${ayah.surahNumber}:${ayah.ayahNumber}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TajweedText(
                  text: settings.isIndoPak
                      ? ayah.indopakText
                      : ayah.arabicText,
                  ayahNumber: ayah.ayahNumber,
                  fontSize: 22,
                  fontFamily: settings.defaultFontFamily,
                  lineHeight: 2.0,
                  showTajweed: false,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 14),
                TextButton.icon(
                  onPressed: _playAyah,
                  icon: Icon(
                    _isPlaying
                        ? Icons.pause_circle_rounded
                        : Icons.play_circle_rounded,
                    color: ruleColor,
                  ),
                  label: Text(
                    _isPlaying ? 'Pause' : 'Listen',
                    style: TextStyle(
                      color: ruleColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: ruleColor.withValues(alpha: 0.08),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Tip
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.maddAmberBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_rounded, color: AppTheme.accentAmber, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Focus on ${_selectedRule!.name}: ${_selectedRule!.description}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Recording button
          if (_isAnalyzing) ...[
            const CircularProgressIndicator(color: AppTheme.qalqalahRed),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome_rounded,
                    color: AppTheme.qalqalahRed, size: 20),
                SizedBox(width: 10),
                Text(
                  'Analyzing your recitation...',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.qalqalahRed,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ] else ...[
            ScaleTransition(
              scale: _isRecording
                  ? _pulseAnimation
                  : const AlwaysStoppedAnimation(1.0),
              child: GestureDetector(
                onTap: _isRecording ? _stopRecording : _startRecording,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: _isRecording
                        ? const LinearGradient(
                            colors: [Color(0xFFF44336), Color(0xFFB71C1C)],
                          )
                        : LinearGradient(
                            colors: [ruleColor, ruleColor.withValues(alpha: 0.8)],
                          ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (_isRecording ? Colors.red : ruleColor)
                            .withValues(alpha: 0.35),
                        blurRadius: 24,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                    color: Colors.white,
                    size: 42,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _isRecording
                  ? '${_formatTime(_recordingSeconds)} — Tap to stop'
                  : 'Tap to Record',
              style: TextStyle(
                fontSize: 15,
                color: _isRecording
                    ? AppTheme.qalqalahRed
                    : AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Skip button
          if (!_isRecording && !_isAnalyzing)
            TextButton(
              onPressed: _nextDrillAyah,
              child: const Text(
                'Skip to next →',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
        ],
      ),
    );
  }
}

// ──────────── Supporting Widgets ────────────

class _WeakRuleCard extends StatelessWidget {
  final TajwidRule rule;
  final TajwidRuleProgress progress;
  final VoidCallback onTap;
  final bool isWeak;

  const _WeakRuleCard({
    required this.rule,
    required this.progress,
    required this.onTap,
    required this.isWeak,
  });

  @override
  Widget build(BuildContext context) {
    Color ruleColor =
        Color(int.parse(rule.colorHex.replaceFirst('#', '0xFF')));
    final bgColor =
        Color(int.parse(rule.backgroundHex.replaceFirst('#', '0xFF')));

    // Ensure ruleColor is bright enough for dark mode
    if (ruleColor.computeLuminance() < 0.4) {
      ruleColor = HSLColor.fromColor(ruleColor).withLightness(0.75).toColor();
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isWeak ? AppTheme.qalqalahRedBg : AppTheme.cardWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isWeak
                ? AppTheme.qalqalahRed.withValues(alpha: 0.15)
                : AppTheme.divider,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            // Rule icon
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  rule.arabicName.isNotEmpty
                      ? rule.arabicName.substring(0, 1)
                      : '?',
                  style: TextStyle(
                    fontFamily: 'AmiriQuran',
                    fontSize: 20,
                    color: ruleColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Rule info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          rule.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: isWeak
                                ? AppTheme.qalqalahRed
                                : AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      if (isWeak)
                        const Text('⚠️', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    rule.arabicName,
                    style: TextStyle(
                      fontSize: 12,
                      color: ruleColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // XP bar
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress.progressToNextLevel,
                            backgroundColor: AppTheme.divider,
                            valueColor: AlwaysStoppedAnimation(ruleColor),
                            minHeight: 5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Lv ${progress.level}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppTheme.textSecondary.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
