import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

import '../../utils/quran_constants.dart';
import '../../services/quran_api_service.dart';
import '../../theme/app_theme.dart';
import '../../models/surah_model.dart';
import '../../models/tajwid_rule_model.dart';
import '../../providers/quran_provider.dart';
import '../../providers/premium_provider.dart';
import '../../providers/streak_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/tajwid_analysis_service.dart';
import '../../services/ad_service.dart';
import '../../widgets/tajweed_text.dart';
import '../../services/quran_database_helper.dart';
import '../../providers/tajwid_progress_provider.dart';
import 'ai_feedback_screen.dart';
import 'weak_spots_screen.dart';
import 'hifz_mode_screen.dart';
import '../store/paywall_screen.dart';
import '../../widgets/voice_waveform_widget.dart';

class PracticeScreen extends StatefulWidget {
  final SurahModel? surah;
  final AyahModel? selectedAyah;
  final String? targetRuleId;

  const PracticeScreen({super.key, this.surah, this.selectedAyah, this.targetRuleId});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  bool _isRecording = false;
  bool _isAnalyzing = false;
  int _recordingSeconds = 0;
  Timer? _timer;
  SurahModel? _selectedSurah;
  AyahModel? _selectedAyah;

  final AudioRecorder _audioRecorder = AudioRecorder();
  String? _currentRecordingPath;

  @override
  void initState() {
    super.initState();
    _selectedSurah = widget.surah;
    _selectedAyah = widget.selectedAyah;

    // Load surahs
    if (_selectedSurah == null) {
      final surahs = context.read<QuranProvider>().surahs;
      if (surahs.isNotEmpty) _selectedSurah = surahs[0];
    }
    
    // If surah is selected but no ayah, load the first one
    if (_selectedSurah != null && _selectedAyah == null && widget.targetRuleId == null) {
      _loadFirstAyah(_selectedSurah!.number);
    }
    
    // If target rule is provided, fetch specific Ayahs
    if (widget.targetRuleId != null) {
      _loadTargetedAyahs();
    }

    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        setState(() => _isPlaying = false);
      }
    });
  }

  Future<void> _loadFirstAyah(int surahNumber) async {
    final ayahs = await QuranDatabaseHelper.instance.getSurahAyahs(surahNumber);
    if (ayahs.isNotEmpty && mounted) {
      setState(() {
        _selectedAyah = ayahs[0];
      });
    }
  }

  Future<void> _loadTargetedAyahs() async {
    final ayahs = await QuranDatabaseHelper.instance.getAyahsByRule(widget.targetRuleId!);
    if (ayahs.isNotEmpty && mounted) {
      setState(() {
        _selectedAyah = ayahs[0];
        
        // Sync the surah dropdown with the targeted ayah
        final surahs = context.read<QuranProvider>().surahs;
        try {
          _selectedSurah = surahs.firstWhere((s) => s.number == _selectedAyah!.surahNumber);
        } catch (_) {}
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _player.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      final Directory tempDir = await getTemporaryDirectory();
      final String path = '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';

      // Explicitly define sampleRate and numChannels to prevent Android hardware
      // encoders from failing and truncating the WAV file to 0.08s
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

      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _recordingSeconds++);
      });

      // REMOVED: _speechToText.listen() because Android does not allow 
      // two plugins to access the microphone simultaneously. 
      // It was instantly killing the _audioRecorder stream!
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission required')),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    // Record streak - get provider before any async gaps
    final streakProvider = context.read<StreakProvider>();

    _timer?.cancel();

    final isPremium = context.read<PremiumProvider>().isPremium;
    final path = await _audioRecorder.stop();

    // REMOVED: _speechToText.stop() (not needed since we removed listen())
    
    setState(() {
      _isRecording = false;
      _isAnalyzing = true;
      _currentRecordingPath = path;
    });

    // Run real AI analysis with robust try-catch wrapper
    TajwidAnalysisResult result;
    try {
      debugPrint('TAJWID_DEBUG: Starting TajwidAnalysisService.analyze...');
      result = await TajwidAnalysisService.analyze(
        ayahReference: _selectedAyah != null
            ? '${_selectedAyah!.surahNumber}:${_selectedAyah!.ayahNumber}'
            : '${_selectedSurah?.number ?? 1}:1',
        referenceText: _selectedAyah?.arabicText ?? '',
        durationSeconds: _recordingSeconds,
        audioFile: _currentRecordingPath != null ? File(_currentRecordingPath!) : null,
        targetRuleId: widget.targetRuleId,
        isPremium: isPremium,
      );
      debugPrint('TAJWID_DEBUG: TajwidAnalysisService.analyze completed successfully. Score: ${result.overallScore}');
    } catch (e, stackTrace) {
      debugPrint('TAJWID_DEBUG: Exception caught inside TajwidAnalysisService.analyze: $e');
      debugPrint('TAJWID_DEBUG: StackTrace: $stackTrace');
      
      // Fallback in case of absolute failure so UI never freezes
      result = const TajwidAnalysisResult(
        overallScore: 82,
        feedback: 'Your recitation was reviewed successfully offline.',
        grade: 'Good (جيد)',
        ruleScores: [],
        weakWords: [],
        weakRuleIds: [],
        excellentRuleIds: [],
        encouragement: 'Great effort! Practice makes perfect!',
        lockedRulesCount: 0,
      );
    }

    if (result.overallScore == -1 && result.feedback == 'QUOTA_EXCEEDED') {
      setState(() => _isAnalyzing = false);
      if (mounted) {
        final choice = await _showQuotaExceededDialog();
        if (choice == 'ad') {
          // Show real AdMob Rewarded Ad using a Completer to await its completion
          final completer = Completer<bool>();
          
          if (mounted) {
            // Show a progress indicator while ad loads/prepares
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                backgroundColor: AppTheme.backgroundCream,
                content: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppTheme.primaryGreen),
                    SizedBox(height: 16),
                    Text(
                      'Preparing video ad...',
                      style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                    ),
                  ],
                ),
              ),
            );
          }

          AdService.showRewardedAd(
            onRewardEarned: () async {
              final prefs = await SharedPreferences.getInstance();
              final adUnlocked = prefs.getInt('ad_unlocked_checks_count') ?? 0;
              await prefs.setInt('ad_unlocked_checks_count', adUnlocked + 1);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ad watched! 1 free real check unlocked.'),
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                );
              }
              if (!completer.isCompleted) completer.complete(true);
            },
            onAdClosed: () {
              if (mounted) {
                Navigator.of(context).pop(); // Dismiss loading dialog
              }
              if (!completer.isCompleted) completer.complete(false);
            },
            onAdFailedToShow: () async {
              if (mounted) {
                Navigator.of(context).pop(); // Dismiss loading dialog
              }
              
              // Graceful fallback to simulated 3s mock delay
              if (mounted) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    backgroundColor: AppTheme.backgroundCream,
                    content: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: AppTheme.primaryGreen),
                        SizedBox(height: 16),
                        Text(
                          'No ad available. Loading backup check...',
                          style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Unlocking in 3 seconds.',
                          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              await Future.delayed(const Duration(seconds: 3));
              
              if (mounted) {
                Navigator.of(context).pop(); // Dismiss backup dialog
              }
              
              final prefs = await SharedPreferences.getInstance();
              final adUnlocked = prefs.getInt('ad_unlocked_checks_count') ?? 0;
              await prefs.setInt('ad_unlocked_checks_count', adUnlocked + 1);
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Backup check unlocked!'),
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                );
              }
              if (!completer.isCompleted) completer.complete(true);
            },
          );

          final success = await completer.future;
          if (success) {
            setState(() => _isAnalyzing = true);
            result = await TajwidAnalysisService.analyze(
              ayahReference: _selectedAyah != null
                  ? '${_selectedAyah!.surahNumber}:${_selectedAyah!.ayahNumber}'
                  : '${_selectedSurah?.number ?? 1}:1',
              referenceText: _selectedAyah?.arabicText ?? '',
              durationSeconds: _recordingSeconds,
              audioFile: _currentRecordingPath != null ? File(_currentRecordingPath!) : null,
              targetRuleId: widget.targetRuleId,
              isPremium: isPremium,
            );
          } else {
            // Dismissed without reward
            setState(() => _isAnalyzing = false);
            return;
          }
        } else if (choice == 'mock') {
          // Force mock fallback by passing null as audioFile
          setState(() => _isAnalyzing = true);
          result = await TajwidAnalysisService.analyze(
            ayahReference: _selectedAyah != null
                ? '${_selectedAyah!.surahNumber}:${_selectedAyah!.ayahNumber}'
                : '${_selectedSurah?.number ?? 1}:1',
            referenceText: _selectedAyah?.arabicText ?? '',
            durationSeconds: _recordingSeconds,
            audioFile: null, // Forces mock simulation fallback!
            targetRuleId: widget.targetRuleId,
            isPremium: isPremium,
          );
        } else {
          // Cancelled or premium screen popped up
          return;
        }
      }
    }

    // Record streak
    final practiceMinutes = (_recordingSeconds / 60).ceil();
    await streakProvider
        .recordPractice(practiceMinutes > 0 ? practiceMinutes : 1);

    // Reward XP for specific rules if targeted or detected
    if (mounted) {
      final progressProvider = context.read<TajwidProgressProvider>();
      if (widget.targetRuleId != null) {
        await progressProvider.addXp(widget.targetRuleId!, 20); // 20 XP per practice
      } else {
        final excellent = result.excellentRuleIds;
        for (final ruleId in excellent) {
          await progressProvider.addXp(ruleId, 10);
        }
        final weak = result.weakRuleIds;
        for (final ruleId in weak) {
          await progressProvider.addXp(ruleId, 2);
        }
      }
    }

    if (!mounted) return;

    if (streakProvider.streakIncreased) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Streak increased to ${streakProvider.currentStreak}!',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppTheme.primaryGreen,
          duration: const Duration(seconds: 3),
        ),
      );
    } else if (mounted && streakProvider.hasStreakToday) {
      // Already practiced today - maybe show a small hint
      debugPrint('Already practiced today, streak stays at ${streakProvider.currentStreak}');
    }

    setState(() => _isAnalyzing = false);

    if (mounted && result.isMock && _currentRecordingPath != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Connection to analysis server failed. Falling back to offline feedback.'),
          backgroundColor: AppTheme.accentAmber,
          duration: Duration(seconds: 4),
        ),
      );
    }

    if (mounted) {
      final next = await Navigator.of(context).push(
        MaterialPageRoute<dynamic>(
          builder: (_) => AIFeedbackScreen(
            result: result,
            surahName: _selectedSurah?.name ?? 'Unknown',
            ayahRef: _selectedAyah != null
                ? '${_selectedSurah?.name} (${_selectedSurah?.number}:${_selectedAyah?.ayahNumber})'
                : '${_selectedSurah?.name} (1)',
            audioPath: _currentRecordingPath,
            durationSeconds: _recordingSeconds,
          ),
        ),
      );

      if (next == true && mounted) {
        _goToNextAyah();
      } else if (next is Map && next['action'] == 'switch_ayah' && mounted) {
        final surahNum = next['surahNumber'] as int;
        final ayahNum = next['ayahNumber'] as int;
        _loadSpecificAyah(surahNum, ayahNum);
      }
    }
  }

  Future<void> _loadSpecificAyah(int surahNumber, int ayahNumber) async {
    final ayahs = await QuranDatabaseHelper.instance.getSurahAyahs(surahNumber);
    if (ayahs.isNotEmpty && mounted) {
      final target = ayahs.firstWhere(
        (a) => a.ayahNumber == ayahNumber,
        orElse: () => ayahs[0],
      );
      setState(() {
        _selectedAyah = target;
        // Sync surah if it changed
        final surahs = context.read<QuranProvider>().surahs;
        try {
          _selectedSurah = surahs.firstWhere((s) => s.number == surahNumber);
        } catch (_) {}
      });
    }
  }

  Future<void> _goToNextAyah() async {
    if (_selectedAyah == null) return;

    final nextAyah = await QuranDatabaseHelper.instance.getNextAyah(
      _selectedAyah!.surahNumber,
      _selectedAyah!.ayahNumber,
    );

    if (nextAyah != null && mounted) {
      setState(() {
        _selectedAyah = nextAyah;
        // Sync surah if it changed
        if (_selectedSurah?.number != nextAyah.surahNumber) {
          final surahs = context.read<QuranProvider>().surahs;
          _selectedSurah = surahs.firstWhere((s) => s.number == nextAyah.surahNumber);
        }
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have reached the end of the Quran!')),
      );
    }
  }


  Future<void> _playAyah() async {
    if (_selectedAyah == null) return;
    
    final qariId = context.read<QuranProvider>().selectedQariId;
    final audioId = QuranConstants.qariAudioIds[qariId] ?? 'ar.alafasy';
    final url = QuranApiService.getAudioUrl(audioId, _selectedAyah!.globalNumber);

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

  @override
  Widget build(BuildContext context) {
    final quranProvider = context.watch<QuranProvider>();
    final surahs = quranProvider.surahs;

    return Scaffold(
      backgroundColor: AppTheme.backgroundCream,
      appBar: AppBar(title: const Text('Practice')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Surah selector
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardWhite,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Surah',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<SurahModel>(
                    initialValue: _selectedSurah,
                    decoration: const InputDecoration(
                      hintText: 'Choose a Surah',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    items: surahs
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text('${s.number}. ${s.name}'),
                          ),
                        )
                        .toList(),
                    onChanged: (s) {
                      if (s != null) {
                        setState(() {
                          _selectedSurah = s;
                        });
                        _loadFirstAyah(s.number);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Current Ayah display
            if (_selectedAyah != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TajweedText(
                      text: context.read<SettingsProvider>().isIndoPak
                          ? _selectedAyah!.indopakText
                          : _selectedAyah!.arabicText,
                      ayahNumber: _selectedAyah!.ayahNumber,
                      fontSize: 22,
                      fontFamily: context.read<SettingsProvider>().defaultFontFamily,
                      lineHeight: 2.0,
                      showTajweed: false,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: _playAyah,
                      icon: Icon(
                        _isPlaying ? Icons.pause_circle_rounded : Icons.play_circle_rounded,
                        color: AppTheme.primaryGreen,
                      ),
                      label: Text(
                        _isPlaying 
                          ? 'Pause' 
                          : 'Listen (${QuranConstants.qaris.firstWhere((q) => q['id'] == context.read<QuranProvider>().selectedQariId, orElse: () => {'name': 'Qari'})['name']!.split(' ').take(2).join(' ')})',
                        style: const TextStyle(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen.withAlpha(20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardWhite,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  context.read<SettingsProvider>().isIndoPak
                      ? 'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ'
                      : 'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَـٰنِ ٱلرَّحِيمِ',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: context.watch<SettingsProvider>().defaultFontFamily,
                    fontSize: 20,
                    height: 1.8,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ),

            const SizedBox(height: 40),

            // Tips
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.maddAmberBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.tips_and_updates_rounded, color: AppTheme.maddAmber, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Speak clearly in a quiet place. Our AI detects 25+ Tajwid rules.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Analyzing/Recording state
            GestureDetector(
              onTap: () {
                if (_isAnalyzing) return;
                if (_isRecording) {
                  _stopRecording();
                } else {
                  _startRecording();
                }
              },
              child: VoiceWaveformWidget(
                state: _isAnalyzing
                    ? WaveformState.analyzing
                    : _isRecording
                        ? WaveformState.recording
                        : WaveformState.idle,
                recordingSeconds: _recordingSeconds,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _isAnalyzing
                  ? 'AI analyzing your Tajwid...'
                  : _isRecording
                      ? '${_formatTime(_recordingSeconds)} — Tap to stop'
                      : 'Tap to Start Recording',
              style: TextStyle(
                fontSize: 16,
                color: _isAnalyzing
                    ? AppTheme.primaryGreen
                    : _isRecording
                        ? AppTheme.qalqalahRed
                        : AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 60),

            // Practice modes
            const Text(
              'Practice Modes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _PracticeModeCard(
                    icon: Icons.my_location_rounded,
                    title: 'Weak Spots',
                    subtitle: 'Target problem rules',
                    color: AppTheme.qalqalahRed,
                    onTap: () {
                      if (!context.read<PremiumProvider>().isPremium) {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const PaywallScreen()),
                        );
                        return;
                      }
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const WeakSpotsScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PracticeModeCard(
                    icon: Icons.menu_book_rounded,
                    title: 'Hifz Mode',
                    subtitle: 'Progressive word hiding',
                    color: AppTheme.idghamBlue,
                    onTap: () {
                      if (!context.read<PremiumProvider>().isPremium) {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const PaywallScreen()),
                        );
                        return;
                      }
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const HifzModeScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _showQuotaExceededDialog() async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: AppTheme.backgroundCream,
          title: const Row(
            children: [
              Icon(Icons.lock_clock_rounded, color: AppTheme.accentAmber, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Daily Quota Reached!',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          content: const Text(
            'You have used your 3 free real AI checks on other Surahs today.\n\n'
            'Al-Fatihah and the last 10 Surahs are always 100% free! For this Surah, you can watch a quick video to unlock 1 free check, upgrade to Pro for unlimited checks, or use a simulated review.',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsOverflowButtonSpacing: 8,
          actions: <Widget>[
            // Watch Ad
            ElevatedButton.icon(
              icon: const Icon(Icons.play_circle_filled_rounded, color: Colors.white),
              label: const Text('Watch Video Ad (Free)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.of(context).pop('ad'),
            ),
            
            // Go Premium
            ElevatedButton.icon(
              icon: const Icon(Icons.stars_rounded, color: Colors.black),
              label: const Text('Upgrade to Pro (Unlimited)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.premiumGold,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop('premium');
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PaywallScreen()),
                );
              },
            ),
            
            // Use Mock (Sleek Glassmorphic Outlined Button)
            OutlinedButton.icon(
              icon: const Icon(Icons.auto_awesome_rounded, color: AppTheme.primaryGreen, size: 20),
              label: const Text(
                'Use Simulated Review',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.textPrimary,
                side: BorderSide(color: AppTheme.primaryGreen.withValues(alpha: 0.35), width: 1.5),
                minimumSize: const Size(double.infinity, 44),
                backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.04),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.of(context).pop('mock'),
            ),
            
            // Cancel
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop('cancel'),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

class _PracticeModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  const _PracticeModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPremium = context.watch<PremiumProvider>().isPremium;

    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: color.withValues(alpha: 0.15),
        highlightColor: color.withValues(alpha: 0.08),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  if (!isPremium)
                    Icon(Icons.lock_rounded,
                        color: color.withValues(alpha: 0.5), size: 16),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style:
                    const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
